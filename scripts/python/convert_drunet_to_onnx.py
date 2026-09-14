#!/usr/bin/env python3
"""Convert DRUNet PyTorch model (.pth) to ONNX format."""
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import torch
import numpy as np
from drunet_kair_unet import UNetRes

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_PTH = os.path.join(SCRIPT_DIR, '..', '..', 'linux', 'bundled', 'models', 'drunet', 'drunet_model.pth')
MODEL_ONNX = os.path.join(SCRIPT_DIR, '..', '..', 'linux', 'bundled', 'models', 'drunet', 'drunet_model.onnx')

def normalize_checkpoint(raw):
    if isinstance(raw, dict):
        for key in ('params', 'state_dict', 'model_state_dict'):
            if key in raw and isinstance(raw[key], dict):
                raw = raw[key]
                break
    if not isinstance(raw, dict):
        return {}
    out = {}
    for k, v in raw.items():
        nk = k
        for prefix in ('module.', 'netG.', 'model.'):
            if nk.startswith(prefix):
                nk = nk[len(prefix):]
        out[nk] = v
    return out

def main():
    print(f"Loading PyTorch model from: {MODEL_PTH}")
    raw = torch.load(MODEL_PTH, map_location='cpu', weights_only=True)
    sd = normalize_checkpoint(raw)
    print(f"Loaded {len(sd)} parameters")

    # DRUNet: 4 input channels (RGB + noise level), 3 output channels (RGB), no bias
    net = UNetRes(in_nc=4, out_nc=3, nc=[64, 128, 256, 512], nb=4,
                  act_mode='R', downsample_mode='strideconv', upsample_mode='convtranspose', bias=False)
    missing, unexpected = net.load_state_dict(sd, strict=False)
    print(f"Missing: {len(missing)}, Unexpected: {len(unexpected)}")
    if missing:
        print(f"  Missing keys: {missing[:5]}...")
    if unexpected:
        print(f"  Unexpected keys: {unexpected[:5]}...")
    net.eval()

    # Input: 4 channels (3 RGB + 1 noise level broadcast to spatial)
    dummy = torch.randn(1, 4, 256, 256)
    
    print(f"\nExporting to ONNX: {MODEL_ONNX}")
    os.makedirs(os.path.dirname(MODEL_ONNX), exist_ok=True)
    torch.onnx.export(
        net, dummy, MODEL_ONNX,
        opset_version=14,
        input_names=['input'],
        output_names=['output'],
        dynamic_axes={'input': {2: 'height', 3: 'width'},
                      'output': {2: 'height', 3: 'width'}},
        dynamo=False,
    )
    print(f"ONNX model saved: {MODEL_ONNX}")
    print(f"Size: {os.path.getsize(MODEL_ONNX) / (1024*1024):.1f} MB")

    # --- Verify ---
    print("\nVerifying ONNX model...")
    import onnxruntime as ort
    import onnx
    onnx_model = onnx.load(MODEL_ONNX)
    onnx.checker.check_model(onnx_model)
    print("ONNX model validation: OK")

    session = ort.InferenceSession(MODEL_ONNX)
    ort_out = session.run(None, {'input': dummy.numpy()})[0]

    with torch.no_grad():
        pt_out = net(dummy).numpy()

    diff = np.abs(ort_out - pt_out).max()
    mean_diff = np.abs(ort_out - pt_out).mean()
    print(f"Max absolute difference: {diff:.8f}")
    print(f"Mean absolute difference: {mean_diff:.8f}")
    
    if diff < 1e-4:
        print("PASS: ONNX output matches PyTorch output")
    elif diff < 1e-3:
        print("WARN: Small numerical difference (acceptable for float32)")
    else:
        print("FAIL: Large difference between ONNX and PyTorch outputs")
        sys.exit(1)

    # Test with different sizes
    print("\nTesting different resolutions:")
    for h, w in [(128, 128), (480, 640), (720, 1280)]:
        test = torch.randn(1, 4, h, w)
        ort_out = session.run(None, {'input': test.numpy()})[0]
        with torch.no_grad():
            pt_out = net(test).numpy()
        d = np.abs(ort_out - pt_out).max()
        print(f"  {h}x{w}: max_diff={d:.8f} {'OK' if d < 1e-4 else 'WARN'}")

    print("\nDone!")

if __name__ == '__main__':
    main()
