#!/bin/bash

set -e

APP_NAME="fe-media-converter"
APP_VERSION="2.0.2"
PKGVER="2.0.2"
PKREL="1"
ARCH="x86_64"
SRCDIR="$PWD"
BUILDDIR="$PWD/build"

AUR_DIR="$HOME/aur/$APP_NAME"

echo "=== AUR Package Builder for $APP_NAME v$APP_VERSION ==="
echo ""

if [ ! -d "$AUR_DIR" ]; then
    mkdir -p "$AUR_DIR"
fi

cd "$AUR_DIR"

echo "Creating PKGBUILD..."
cat > PKGBUILD << 'PKGBUILD_EOF'
# Maintainer: Marco Di Giangiacomo <marcodigiangiacomo@gmail.com>
# Contributor: 

pkgname=fe-media-converter
_pkgname=fe-media-converter
pkgver=2.0.2
pkgrel=1
pkgdesc="FE Media Converter - Applicazione professionale per conversione video, audio e immagini"
arch=('x86_64')
url="https://github.com/sviluppoarte1-lang/Fe-Media-Converter"
license=('GPL3')
depends=(
    'flutter'
    'ffmpeg'
    'python3'
    'python3-pip'
    'libgtk-3.so'
)
optdepends=(
    'python-onnx: Per funzioni di upscaling AI'
    'cuda: Per accelerazione GPU NVIDIA'
)
makedepends=(
    'git'
    'cmake'
    'ninja'
    'clang'
    'gtk3'
    'pkg-config'
)
provides=('video-converter')
conflicts=('video-converter-pro')
source=("$_pkgname-$pkgver.tar.gz::https://github.com/sviluppoarte1-lang/Fe-Media-Converter/archive/refs/tags/v$pkgver.tar.gz")
sha256sums=('SKIP')

build() {
    cd "$_pkgname-$pkgver"
    
    export FLUTTER_ROOT="$HOME/.local/flutter"
    export PATH="$FLUTTER_ROOT/bin:$PATH"
    
    flutter config --enable-linux-desktop
    
    flutter pub get
    
    flutter build linux --release
}

package() {
    cd "$_pkgname-$pkgver"
    
    install -dm755 "$pkgdir/opt/$_pkgname"
    install -dm755 "$pkgdir/usr/bin"
    
    cp -r build/linux/x64/release/bundle/* "$pkgdir/opt/$_pkgname/"
    
    ln -sf "/opt/$_pkgname/$_pkgname" "$pkgdir/usr/bin/$_pkgname"
    
    install -Dm644 "$pkgdir/opt/$_pkgname/data/flutter_assets/kernel_blob.bin" "$pkgdir/usr/share/flutter/bin/kernel_blob.bin" || true
    
    if [ -f "linux/$_pkgname.desktop" ]; then
        install -Dm644 "linux/$_pkgname.desktop" "$pkgdir/usr/share/applications/$_pkgname.desktop"
    fi
    
    if [ -f "assets/icon.png" ]; then
        install -Dm644 "assets/icon.png" "$pkgdir/usr/share/pixmaps/$_pkgname.png"
    fi
}
PKGBUILD_EOF

echo "Creating .desktop file..."
cat > fe-media-converter.desktop << 'DESKTOP_EOF'
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
DESKTOP_EOF

echo "Creating .md5sums file for source..."
echo "SKIP" > .md5sums

echo ""
echo "=== AUR package files created in: $AUR_DIR ==="
echo ""
echo "Files created:"
ls -la "$AUR_DIR"
echo ""
echo "To upload to AUR:"
echo "  1. cd $AUR_DIR"
echo "  2. git init"
echo "  3. git remote add aur ssh://aur@aur.archlinux.org/$_pkgname.git"
echo "  4. git add PKGBUILD .md5sums"
echo "  5. git commit -m 'Initial PKGBUILD for $_pkgname v$pkgver'"
echo "  6. git push aur master"
echo ""
echo "Or to test build locally:"
echo "  cd $AUR_DIR"
echo "  makepkg -s"