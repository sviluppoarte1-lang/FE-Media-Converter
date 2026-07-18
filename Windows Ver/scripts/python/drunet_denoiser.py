#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
# Frame processing: PyTorch DRUNet (KAIR UNetRes + drunet_color.pth) when model_path + torch;
# OpenCV fallback. Modes: denoise, deblur, upscale, jpeg_restore.

from __future__ import annotations

import argparse
import concurrent.futures
import json
import os
import sys
import threading
import time
from pathlib import Path
from typing import Any, Dict, Optional, Tuple

import numpy as np


def _init_runtime_threads(workers: int) -> None:
    n = max(1, min(workers, os.cpu_count() or 1))
    os.environ.setdefault('OMP_NUM_THREADS', str(n))
    os.environ.setdefault('MKL_NUM_THREADS', str(n))
    os.environ.setdefault('OPENBLAS_NUM_THREADS', str(n))
    try:
        import cv2
        cv2.setNumThreads(n)
    except Exception:
        pass


def _cuda_available() -> bool:
    try:
        import cv2
        return hasattr(cv2, 'cuda') and cv2.cuda.getCudaEnabledDeviceCount() > 0
    except Exception:
        return False


def _torch_available() -> bool:
    try:
        import torch  # noqa: F401
        return True
    except Exception:
        return False


def _resolve_torch_device(device: str) -> Any:
    import torch
    if device == 'cpu':
        return torch.device('cpu')
    if device == 'cuda':
        if torch.cuda.is_available():
            return torch.device('cuda:0')
        return torch.device('cpu')
    if torch.cuda.is_available():
        return torch.device('cuda:0')
    if getattr(torch.backends, 'mps', None) and torch.backends.mps.is_available():
        return torch.device('mps')
    return torch.device('cpu')


def _normalize_checkpoint_state(raw: Any) -> Dict[str, Any]:
    if isinstance(raw, dict):
        if 'params' in raw and isinstance(raw['params'], dict):
            raw = raw['params']
        if 'state_dict' in raw and isinstance(raw['state_dict'], dict):
            raw = raw['state_dict']
        if 'model_state_dict' in raw and isinstance(raw['model_state_dict'], dict):
            raw = raw['model_state_dict']
    if not isinstance(raw, dict):
        return {}
    out: Dict[str, Any] = {}
    for k, v in raw.items():
        if not isinstance(k, str):
            continue
        nk = k
        for prefix in ('module.', 'netG.', 'model.'):
            if nk.startswith(prefix):
                nk = nk[len(prefix):]
        out[nk] = v
    return out


def _load_kair_drunet(model_path: Path, device: Any) -> Tuple[Any, Any]:
    import torch
    from drunet_kair_unet import UNetRes
    try:
        ckpt = torch.load(str(model_path), map_location=device, weights_only=True)
    except TypeError:
        ckpt = torch.load(str(model_path), map_location=device)
    sd = _normalize_checkpoint_state(ckpt)
    if not sd:
        raise ValueError('empty or unsupported checkpoint')
    net = UNetRes(
        in_nc=4,
        out_nc=3,
        nc=[64, 128, 256, 512],
        nb=4,
        act_mode='R',
        downsample_mode='strideconv',
        upsample_mode='convtranspose',
        bias=False,
    )
    missing, unexpected = net.load_state_dict(sd, strict=False)
    if len(missing) > 80 or len(sd) < 10:
        raise ValueError('checkpoint mismatch (missing=%s unexpected=%s)' % (len(missing), len(unexpected)))
    net = net.to(device)
    net.eval()
    return net, device


def _denoise_neural_bgr(net: Any, device: Any, img_bgr: np.ndarray, noise_level: int) -> np.ndarray:
    import cv2
    import torch
    img_rgb = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2RGB)
    t = torch.from_numpy(img_rgb).float().div_(255.0).permute(2, 0, 1).unsqueeze(0).to(device)
    sigma = max(0.0, min(1.0, float(noise_level) / 255.0))
    nm = torch.full((1, 1, t.shape[2], t.shape[3]), sigma, device=device, dtype=t.dtype)
    x = torch.cat([t, nm], dim=1)
    with torch.no_grad():
        if device.type == 'cuda':
            try:
                with torch.amp.autocast('cuda', dtype=torch.float16):
                    y = net(x)
            except (AttributeError, TypeError):
                with torch.cuda.amp.autocast():
                    y = net(x)
        else:
            y = net(x)
    y = y.float().clamp_(0, 1).squeeze(0).permute(1, 2, 0).cpu().numpy()
    out_rgb = np.clip(np.round(y * 255.0), 0, 255).astype(np.uint8)
    return cv2.cvtColor(out_rgb, cv2.COLOR_RGB2BGR)


def _denoise_cuda_bgr(img_bgr: np.ndarray, noise_level: int) -> np.ndarray:
    import cv2
    g = cv2.cuda_GpuMat()
    g.upload(img_bgr)
    sigma = int(max(15, min(95, 20 + noise_level * 2)))
    try:
        bf = cv2.cuda.createBilateralFilter(cv2.CV_8UC3, -1, sigma, sigma)
        out = bf.apply(g).download()
    except Exception:
        out = g.download()
    return out


def _denoise_opencv_bgr(img_bgr: np.ndarray, noise_level: int) -> np.ndarray:
    import cv2
    h = int(3 + (max(0, min(noise_level, 30))) * 1.1)
    h = max(3, min(h, 21))
    den = cv2.fastNlMeansDenoisingColored(img_bgr, None, h, h, 7, 21)
    sigma = 0.15 + (noise_level / 30.0) * 0.35
    smooth = cv2.edgePreservingFilter(den, flags=1, sigma_s=55, sigma_r=sigma)
    return smooth


def _deblur_wiener_bgr(img_bgr: np.ndarray, strength: float) -> np.ndarray:
    import cv2
    h, w = img_bgr.shape[:2]
    kernel_size = max(3, int(strength * 15 + 3))
    if kernel_size % 2 == 0:
        kernel_size += 1
    kernel = np.zeros((kernel_size, kernel_size), dtype=np.float32)
    kernel[kernel_size // 2, kernel_size // 2] = 1.0
    kernel = cv2.GaussianBlur(kernel, (kernel_size, kernel_size), strength * 2 + 0.5)
    restored = np.zeros_like(img_bgr)
    for c in range(3):
        dft = cv2.dft(np.float32(img_bgr[:, :, c]), flags=cv2.DFT_COMPLEX_OUTPUT)
        dft_kernel = cv2.dft(np.float32(kernel), flags=cv2.DFT_COMPLEX_OUTPUT, nonzeroRows=kernel_size)
        dft_kernel_shift = np.fft.fftshift(dft_kernel[:, :, 0]) + 1j * np.fft.fftshift(dft_kernel[:, :, 1])
        dft_shift = np.fft.fftshift(dft[:, :, 0]) + 1j * np.fft.fftshift(dft[:, :, 1])
        k_mag = np.abs(dft_kernel_shift)
        k_mag = np.where(k_mag < 1e-6, 1e-6, k_mag)
        nsr = 0.01 + (1.0 - strength) * 0.09
        wiener = np.conj(dft_kernel_shift) / (k_mag**2 + nsr)
        result = dft_shift * wiener
        img_back = np.fft.ifftshift(result)
        restored[:, :, c] = cv2.idft(np.stack([np.real(img_back), np.imag(img_back)], axis=-1), flags=cv2.DFT_SCALE)[:, :, 0]
    restored = np.clip(restored, 0, 255).astype(np.uint8)
    return restored


def _upscale_bgr(img_bgr: np.ndarray, factor: float) -> np.ndarray:
    import cv2
    if factor <= 1.0:
        return img_bgr
    new_w = int(img_bgr.shape[1] * factor)
    new_h = int(img_bgr.shape[0] * factor)
    result = cv2.resize(img_bgr, (new_w, new_h), interpolation=cv2.INTER_LANCZOS4)
    try:
        sr = cv2.dnn_superres.DnnSuperResImpl_create()
        sr_model_path = os.path.join(os.path.dirname(__file__), 'models', 'ESPCN_x2.pb')
        if os.path.isfile(sr_model_path):
            sr.readModel(sr_model_path)
            sr.setModel('espcn', factor if factor <= 4 else 4)
            result = sr.upsample(img_bgr)
            if factor > 4:
                new_w = int(result.shape[1] * (factor / 4))
                new_h = int(result.shape[0] * (factor / 4))
                result = cv2.resize(result, (new_w, new_h), interpolation=cv2.INTER_LANCZOS4)
    except Exception:
        pass
    return result


def _jpeg_restore_bgr(img_bgr: np.ndarray, strength: int) -> np.ndarray:
    import cv2
    h = int(5 + strength * 2)
    h = max(5, min(h, 20))
    den = cv2.fastNlMeansDenoisingColored(img_bgr, None, h, h, 7, 21)
    sharp = cv2.usm(den, 0.0, strength * 0.5 + 0.5, 0.1 + strength * 0.05)
    return sharp


_neural_cache: Dict[str, Optional[Tuple[Any, Any]]] = {}


def _get_neural_net(model_path: str, device_pref: str) -> Optional[Tuple[Any, Any]]:
    key = '%s|%s' % (model_path, device_pref)
    if key in _neural_cache:
        return _neural_cache[key]
    path = Path(model_path)
    if not path.is_file():
        return None
    if not _torch_available():
        print('DRUNet: PyTorch not installed; pip install torch (see requirements-drunet.txt)', file=sys.stderr, flush=True)
        _neural_cache[key] = None
        return None
    dev = _resolve_torch_device(device_pref)
    try:
        net, d = _load_kair_drunet(path, dev)
        _neural_cache[key] = (net, d)
        print('DRUNet: loaded KAIR UNetRes from %s on %s' % (path, d), file=sys.stderr, flush=True)
        return _neural_cache[key]
    except Exception as e:
        print('DRUNet: neural load failed (%s); OpenCV fallback' % e, file=sys.stderr, flush=True)
        _neural_cache[key] = None
        return None


def process_file(
    in_path: Path,
    out_path: Path,
    noise_level: int,
    model_path: str | None,
    device: str,
    mode: str = 'denoise',
    upscale_factor: float = 2.0,
    deblur_strength: float = 0.5,
) -> bool:
    import cv2
    out_path.parent.mkdir(parents=True, exist_ok=True)
    img = cv2.imread(str(in_path), cv2.IMREAD_COLOR)
    if img is None:
        return False

    if mode == 'deblur':
        result = _deblur_wiener_bgr(img, deblur_strength)
        result = cv2.fastNlMeansDenoisingColored(result, None, 3, 3, 7, 21)
        return cv2.imwrite(str(out_path), result)

    if mode == 'upscale':
        result = _upscale_bgr(img, upscale_factor)
        return cv2.imwrite(str(out_path), result)

    if mode == 'jpeg_restore':
        result = _jpeg_restore_bgr(img, noise_level)
        neural = None
        if model_path:
            neural = _get_neural_net(model_path, device)
        if neural is not None:
            net, dev = neural
            try:
                result = _denoise_neural_bgr(net, dev, result, noise_level)
            except Exception as e:
                print('DRUNet: inference error (%s)' % e, file=sys.stderr, flush=True)
        return cv2.imwrite(str(out_path), result)

    neural = None
    if model_path:
        neural = _get_neural_net(model_path, device)
    if neural is not None:
        net, dev = neural
        try:
            result = _denoise_neural_bgr(net, dev, img, noise_level)
        except Exception as e:
            print('DRUNet: inference error (%s); OpenCV fallback' % e, file=sys.stderr, flush=True)
            result = _denoise_opencv_bgr(img, noise_level)
    else:
        use_cuda = device in ('auto', 'cuda') and _cuda_available()
        if use_cuda:
            result = _denoise_cuda_bgr(img, noise_level)
        else:
            result = _denoise_opencv_bgr(img, noise_level)
    return cv2.imwrite(str(out_path), result)


def _emit_frame_progress(done: int, total: int, fps: float) -> None:
    fps = max(0.0, min(180.0, fps))
    print('FE_PROGRESS %d %d %.2f' % (done, total, fps), file=sys.stderr, flush=True)


def run_batch(
    indir: Path,
    outdir: Path,
    noise_level: int,
    model_path: str | None,
    device: str,
    workers: int,
    mode: str = 'denoise',
    upscale_factor: float = 2.0,
    deblur_strength: float = 0.5,
) -> dict:
    patterns = ('*.png', '*.PNG', '*.jpg', '*.jpeg', '*.JPG', '*.JPEG')
    files: list[Path] = []
    for pat in patterns:
        files.extend(sorted(indir.glob(pat)))
    files = sorted(set(files))
    if not files:
        return {'success': False, 'error': 'no frames in input dir'}
    outdir.mkdir(parents=True, exist_ok=True)
    use_neural = bool(mode == 'denoise' and model_path and Path(model_path).is_file() and _get_neural_net(model_path, device) is not None)
    if use_neural or (device in ('auto', 'cuda') and _cuda_available() and mode == 'denoise'):
        actual_workers = 1
    else:
        actual_workers = max(1, workers)
    ok = 0
    total = len(files)
    last_done = 0
    last_report_t = time.monotonic()

    def report(done_count: int, frames_ok: int) -> None:
        nonlocal last_done, last_report_t
        now = time.monotonic()
        dt = now - last_report_t
        delta = done_count - last_done
        if done_count >= total or delta >= 8 or dt >= 0.45:
            fps = (delta / dt) if dt > 1e-6 else 0.0
            _emit_frame_progress(done_count, total, fps)
            last_done = done_count
            last_report_t = now

    if actual_workers == 1:
        for i, p in enumerate(files, start=1):
            target = outdir / p.name
            if process_file(p, target, noise_level, model_path, device, mode, upscale_factor, deblur_strength):
                ok += 1
            report(i, ok)
    else:
        def _job(p: Path) -> bool:
            target = outdir / p.name
            return process_file(p, target, noise_level, model_path, device, mode, upscale_factor, deblur_strength)
        done_lock = threading.Lock()
        done_count = 0
        with concurrent.futures.ThreadPoolExecutor(max_workers=actual_workers) as ex:
            futs = [ex.submit(_job, p) for p in files]
            for fut in concurrent.futures.as_completed(futs):
                if fut.result():
                    ok += 1
                with done_lock:
                    done_count += 1
                    dc = done_count
                report(dc, ok)
    pytorch_cuda = False
    if use_neural:
        try:
            import torch
            d = _resolve_torch_device(device)
            pytorch_cuda = bool(torch.cuda.is_available() and d.type == 'cuda')
        except Exception:
            pass
    return {
        'success': ok > 0,
        'frames_ok': ok,
        'frames_total': len(files),
        'workers': actual_workers,
        'cuda': bool(device in ('auto', 'cuda') and _cuda_available()),
        'neural': use_neural,
        'pytorch_cuda': pytorch_cuda,
        'mode': mode,
    }


def main() -> int:
    p = argparse.ArgumentParser(description='FE frame processing (KAIR DRUNet + OpenCV fallback)')
    p.add_argument('--input', help='single input image')
    p.add_argument('--output', help='single output image')
    p.add_argument('--batch-dir', nargs=2, metavar=('IN_DIR', 'OUT_DIR'), help='batch mode')
    p.add_argument('--mode', default='denoise', choices=['denoise', 'deblur', 'upscale', 'jpeg_restore'],
                   help='processing mode')
    p.add_argument('--noise-level', type=int, default=7)
    p.add_argument('--upscale-factor', type=float, default=2.0)
    p.add_argument('--deblur-strength', type=float, default=0.5)
    p.add_argument('--model-path', default=None)
    p.add_argument('--device', default='auto', choices=['auto', 'cpu', 'cuda'])
    p.add_argument('--workers', type=int, default=max(1, min(16, os.cpu_count() or 4)))
    args = p.parse_args()
    _init_runtime_threads(args.workers)
    try:
        if args.input and args.output:
            ok = process_file(
                Path(args.input),
                Path(args.output),
                args.noise_level,
                args.model_path,
                args.device,
                args.mode,
                args.upscale_factor,
                args.deblur_strength,
            )
            print(json.dumps({'success': bool(ok)}), flush=True)
            return 0 if ok else 1
        if args.batch_dir:
            indir, outd = Path(args.batch_dir[0]), Path(args.batch_dir[1])
            r = run_batch(
                indir,
                outd,
                args.noise_level,
                args.model_path,
                args.device,
                int(args.workers),
                args.mode,
                args.upscale_factor,
                args.deblur_strength,
            )
            print(json.dumps(r), flush=True)
            return 0 if r.get('success') else 1
        print(json.dumps({'success': False, 'error': 'specify --input/--output or --batch-dir'}), flush=True)
        return 1
    except Exception as e:
        print(json.dumps({'success': False, 'error': str(e)}), flush=True)
        return 1


if __name__ == '__main__':
    sys.exit(main())
