#!/bin/bash

set -e

APP_NAME="fe-media-converter"
APP_VERSION="2.0.2"
PKGREL="1"
ARCH="x86_64"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build_pkg"
PKG_DIR="$BUILD_DIR/pkg"
SRCDIR="$BUILD_DIR/src"

echo "=== Building $APP_NAME v$APP_VERSION .pkg.zst ==="
echo ""

if [ -d "$BUILD_DIR" ]; then
    echo "Cleaning previous build..."
    rm -rf "$BUILD_DIR"
fi

mkdir -p "$PKG_DIR/opt/$APP_NAME"
mkdir -p "$PKG_DIR/usr/bin"
mkdir -p "$PKG_DIR/usr/share/applications"
mkdir -p "$PKG_DIR/usr/share/pixmaps"

if ! command -v flutter &> /dev/null; then
    echo "ERROR: Flutter not found. Please install Flutter SDK."
    echo "https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "Checking Flutter installation..."
flutter --version

echo ""
echo "Building Flutter app for Linux..."
cd "$SCRIPT_DIR"

flutter config --enable-linux-desktop 2>/dev/null || true
flutter pub get
flutter build linux --release --build-name "$APP_NAME" --build-number "$PKGREL"

BUNDLE_DIR="$SCRIPT_DIR/build/linux/x64/release/bundle"

if [ ! -d "$BUNDLE_DIR" ]; then
    echo "ERROR: Build failed - bundle directory not found"
    exit 1
fi

echo "Copying files to package directory..."
cp -r "$BUNDLE_DIR/"* "$PKG_DIR/opt/$APP_NAME/"

ln -sf "/opt/$APP_NAME/$APP_NAME" "$PKG_DIR/usr/bin/$APP_NAME"

cat > "$PKG_DIR/usr/share/applications/$APP_NAME.desktop" << 'EOF'
[Desktop Entry]
Name=FE Media Converter
Comment=Applicazione professionale per conversione video, audio e immagini
Exec=fe-media-converter
Icon=fe-media-converter
Terminal=false
Type=Application
Categories=AudioVideo;Video;Audio;Utility;
Keywords=video;audio;converter;ffmpeg;media;conversion;
StartupWMClass=fe_media_converter
EOF

if [ -f "$SCRIPT_DIR/assets/icon.png" ]; then
    cp "$SCRIPT_DIR/assets/icon.png" "$PKG_DIR/usr/share/pixmaps/$APP_NAME.png"
fi

echo "Creating .PKGINFO..."
cat > "$PKG_DIR/.PKGINFO" << EOF
pkgname = $APP_NAME
pkgver = $APP_VERSION
pkgrel = $PKGREL
arch = $ARCH
size = 
EOF

echo "Creating .MTREE..."
cd "$PKG_DIR"
find . -type f | sort | while read f; do
    echo ".$f"
done > "$PKG_DIR/.MTREE"

echo "Compressing package..."
cd "$BUILD_DIR"
tar -cvf - -C pkg . | zstd -T0 -o "$SCRIPT_DIR/$APP_NAME-$APP_VERSION-$PKGREL-$ARCH.pkg.tar.zst" 2>/dev/null || \
(tar -cvf - -C pkg . | xz > "$SCRIPT_DIR/$APP_NAME-$APP_VERSION-$PKGREL-$ARCH.pkg.tar.xz" 2>/dev/null && \
mv "$SCRIPT_DIR/$APP_NAME-$APP_VERSION-$PKGREL-$ARCH.pkg.tar.xz" "$SCRIPT_DIR/$APP_NAME-$APP_VERSION-$PKGREL-$ARCH.pkg.zst")

echo ""
echo "=== Build completed ==="
echo "Package: $SCRIPT_DIR/$APP_NAME-$APP_VERSION-$PKGREL-$ARCH.pkg.zst"
ls -lh "$SCRIPT_DIR"/*.pkg.zst 2>/dev/null || ls -lh "$SCRIPT_DIR"/*.pkg.tar.* 2>/dev/null

echo ""
echo "To install:"
echo "  sudo pacman -U $APP_NAME-$APP_VERSION-$PKGREL-$ARCH.pkg.zst"