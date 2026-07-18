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
echo "DRUNet neural path: pip installs CPU PyTorch by default. For NVIDIA GPU inference,"
echo "  reinstall CUDA builds from https://pytorch.org inside this venv after setup."
