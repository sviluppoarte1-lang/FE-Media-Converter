@echo off
setlocal enabledelayedexpansion

set SCRIPT_DIR=%~dp0
set VENV_DIR=%SCRIPT_DIR%venv
set REQ_BASE=%SCRIPT_DIR%requirements.txt
set REQ_DRUNET=%SCRIPT_DIR%requirements-drunet.txt

echo Setting up Python environment in: %VENV_DIR%

where python3 >nul 2>&1
if %ERRORLEVEL% neq 0 (
    where python >nul 2>&1
    if %ERRORLEVEL% neq 0 (
        echo python3/python not found in PATH
        echo Please install Python 3 from https://www.python.org/downloads/
        pause
        exit /b 1
    )
    set PYTHON_CMD=python
) else (
    set PYTHON_CMD=python3
)

if not exist "%VENV_DIR%" (
    echo Creating virtual environment...
    %PYTHON_CMD% -m venv "%VENV_DIR%"
)

call "%VENV_DIR%\Scripts\activate.bat"

echo Upgrading pip, setuptools, wheel...
python -m pip install --upgrade pip setuptools wheel

if exist "%REQ_BASE%" (
    echo Installing base requirements...
    python -m pip install -r "%REQ_BASE%"
)

if exist "%REQ_DRUNET%" (
    echo Installing DRUNet requirements...
    python -m pip install -r "%REQ_DRUNET%"
)

echo.
echo Done.
echo To activate: "%VENV_DIR%\Scripts\activate.bat"

echo.
echo DRUNet / PyTorch: on Windows, pip installs CUDA-enabled torch from PyPI
echo if a compatible CUDA toolkit is detected. For CPU-only, use:
echo   pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu

echo.
echo PyTorch runtime check:
python -c "
import sys
try:
    import torch
    print(f'  torch {torch.__version__}')
    if torch.cuda.is_available():
        name = torch.cuda.get_device_name(0)
        print(f'  CUDA: yes (toolkit {torch.version.cuda}) - {name}')
    else:
        print('  CUDA: no - DRUNet uses CPU (slower). NVIDIA: check drivers and torch build.')
except Exception as e:
    print(f'  Could not import torch: {e}', file=sys.stderr)
"

echo.
pause
