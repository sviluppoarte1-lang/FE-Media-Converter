#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="${SCRIPT_DIR}/venv"
REQ_BASE="${SCRIPT_DIR}/requirements.txt"
REQ_DRUNET="${SCRIPT_DIR}/requirements-drunet.txt"

echo "Setting up Python environment in: ${VENV_DIR}"

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 not found"
  exit 1
fi

if [ ! -d "${VENV_DIR}" ]; then
  python3 -m venv "${VENV_DIR}"
fi

# shellcheck disable=SC1091
source "${VENV_DIR}/bin/activate"
python -m pip install --upgrade pip setuptools wheel

if [ -f "${REQ_BASE}" ]; then
  python -m pip install -r "${REQ_BASE}"
fi

if [ -f "${REQ_DRUNET}" ]; then
  python -m pip install -r "${REQ_DRUNET}"
fi

echo "Done."
echo "Use: source ${VENV_DIR}/bin/activate"

echo ""
echo "DRUNet / PyTorch: on Linux x86_64, pip often installs CUDA-enabled torch from PyPI."
echo "  On macOS or for a pinned NVIDIA CUDA build, use https://pytorch.org (or conda) in this venv."

echo ""
echo "PyTorch runtime check:"
python - <<'PY' || true
import sys

try:
    import torch

    print(f"  torch {torch.__version__}")
    if torch.cuda.is_available():
        name = torch.cuda.get_device_name(0)
        print(f"  CUDA: yes (toolkit {torch.version.cuda}) — {name}")
    elif getattr(torch.backends, "mps", None) and torch.backends.mps.is_available():
        print("  MPS: yes (Apple GPU)")
    else:
        print("  CUDA/MPS: no — DRUNet uses CPU (slower). NVIDIA: check drivers and torch build.")
except Exception as e:
    print(f"  Could not import torch: {e}", file=sys.stderr)
PY
