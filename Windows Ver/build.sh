#!/usr/bin/env bash
set -euo pipefail

echo "============================================"
echo " FE MEDIA CONVERTER - Windows Build Script"
echo "============================================"
echo ""

# Ensure we're in the project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

echo "Step 1: Checking Flutter installation..."
if ! command -v flutter >/dev/null 2>&1; then
    echo "ERROR: Flutter is not installed or not in PATH."
    echo "Install Flutter from https://docs.flutter.dev/get-started/install/windows"
    echo "Then run: flutter doctor"
    exit 1
fi

echo "Step 2: Cleaning previous build..."
flutter clean

echo ""
echo "Step 3: Getting dependencies..."
flutter pub get

echo ""
echo "Step 4: Running code generation (if applicable)..."
if grep -q "build_runner" pubspec.yaml 2>/dev/null; then
    dart run build_runner build --delete-conflicting-outputs
fi

echo ""
echo "Step 5: Running analysis..."
flutter analyze

echo ""
echo "Step 6: Building Windows release..."
echo "NOTE: Building for Windows from a Linux host requires cross-compilation."
echo "      It is recommended to run this script on a Windows machine."
echo ""
echo "If running on Windows build machine..."
echo "  flutter build windows --release"
echo ""
echo "If cross-compiling from Linux (experimental), ensure you have:"
echo "  - Flutter Windows SDK configured"
echo "  - flutter config --enable-windows-desktop"
echo ""

if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    flutter build windows --release
    echo ""
    echo "Build complete! Windows executable at: build/windows/x64/runner/Release/"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Detected Linux host. Checking if Windows build tools are available..."
    if flutter config --list 2>/dev/null | grep -q "enable-windows-desktop: true"; then
        echo "Windows desktop enabled. Attempting build..."
        flutter build windows --release || echo "Build failed. Cross-compilation not fully supported on Linux."
    else
        echo "Windows cross-build not configured on this Linux host."
        echo ""
        echo "To build for Windows, run this script on a Windows machine with:"
        echo "  1. Flutter SDK installed"
        echo "  2. Visual Studio 2022 with 'Desktop development with C++'"
        echo "  3. Run: flutter config --enable-windows-desktop"
        echo "  4. Run: $0"
    fi
fi

echo ""
echo "Done."
