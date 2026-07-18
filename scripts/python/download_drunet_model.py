#!/usr/bin/env python3
"""
Scarica drunet_color.pth (KAIR) come drunet_model.pth per uso offline con drunet_denoiser.py.
Uso: python3 download_drunet_model.py [--models-dir PATH]
Output JSON su stdout: {"success": true, "path": "..."} o {"success": false, "error": "..."}
"""
import argparse
import json
import os
import ssl
import urllib.request

DEFAULT_URLS = [
    "https://github.com/cszn/KAIR/releases/download/v1.0/drunet_color.pth",
    "https://huggingface.co/deepinv/drunet/resolve/main/drunet_color.pth",
]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--models-dir",
        default=None,
        help="Directory modelli (default: ~/.video-converter-pro/models)",
    )
    args = parser.parse_args()

    home = os.environ.get("HOME") or os.environ.get("USERPROFILE") or ""
    if args.models_dir:
        base = args.models_dir
    elif home:
        base = os.path.join(home, ".video-converter-pro", "models")
    else:
        base = os.path.join(os.path.dirname(os.path.abspath(__file__)), "models")

    out_dir = os.path.join(base, "drunet")
    os.makedirs(out_dir, exist_ok=True)
    out_path = os.path.join(out_dir, "drunet_model.pth")

    ctx = ssl.create_default_context()
    last_err = "unknown"
    for url in DEFAULT_URLS:
        try:
            req = urllib.request.Request(
                url,
                headers={"User-Agent": "VideoConverterPro/2.0 (Python download_drunet_model)"},
            )
            with urllib.request.urlopen(req, context=ctx, timeout=600) as resp:
                if resp.status != 200:
                    continue
                data = resp.read()
            if len(data) < 1024 * 1024:
                continue
            with open(out_path, "wb") as f:
                f.write(data)
            print(json.dumps({"success": True, "path": out_path, "bytes": len(data)}))
            return 0
        except Exception as e:
            last_err = str(e)
            continue

    print(json.dumps({"success": False, "error": last_err}))
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
