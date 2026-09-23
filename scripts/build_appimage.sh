#!/bin/bash
# Crea l'AppImage di FE Media Converter.
# Uso: ./scripts/build_appimage.sh
# L'output finisce in package_appimage/FE-Media-Converter-<versione>-x86_64.AppImage

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PACKAGE_DIR="$PROJECT_ROOT/package_appimage"
APPIMAGE_DIR="$PACKAGE_DIR/AppDir"

APP_NAME="FE-Media-Converter"
APP_ID="com.videoconverterpro"
APP_VERSION="$(grep -E '^version:' "$PROJECT_ROOT/pubspec.yaml")"
APP_VERSION="${APP_VERSION#version: }"
APP_VERSION="${APP_VERSION%%+*}"
APP_DESCRIPTION="Professional video, audio and image conversion application"

if [ -z "$APP_VERSION" ]; then
    echo -e "${RED}Versione non trovata in pubspec.yaml${NC}"
    exit 1
fi

echo -e "${GREEN}=== AppImage $APP_NAME v$APP_VERSION ===${NC}"

command -v flutter >/dev/null || { echo -e "${RED}Flutter non trovato${NC}"; exit 1; }
command -v patchelf >/dev/null || echo -e "${YELLOW}patchelf assente: installalo per runpath puliti (sudo apt install patchelf)${NC}"

# appimagetool: riusa quello locale o scaricalo dalle release ufficiali
APPIMAGETOOL="$PACKAGE_DIR/appimagetool-x86_64.AppImage"
if [ ! -f "$APPIMAGETOOL" ]; then
    echo -e "${YELLOW}Download appimagetool...${NC}"
    mkdir -p "$PACKAGE_DIR"
    wget -q -O "$APPIMAGETOOL" \
        "https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage" || {
        echo -e "${RED}Download appimagetool fallito${NC}"
        exit 1
    }
fi
chmod +x "$APPIMAGETOOL"

# appimagetool e un AppImage a sua volta: senza FUSE funzionante non si avvia,
# ma si puo estrarre una volta sola e usare l'AppRun scompattato
APPIMAGETOOL_RUN="$APPIMAGETOOL"
if ! "$APPIMAGETOOL" --version >/dev/null 2>&1; then
    echo -e "${YELLOW}FUSE non disponibile: estraggo appimagetool...${NC}"
    (cd "$PACKAGE_DIR" && "$APPIMAGETOOL" --appimage-extract >/dev/null 2>&1)
    APPIMAGETOOL_RUN="$PACKAGE_DIR/squashfs-root/AppRun"
fi

# Ricostruisci AppDir da zero
echo -e "${YELLOW}Build Flutter...${NC}"
cd "$PROJECT_ROOT"
flutter pub get
flutter build linux --release

BUNDLE_DIR="$PROJECT_ROOT/build/linux/x64/release/bundle"
[ -d "$BUNDLE_DIR" ] || { echo -e "${RED}Bundle non trovato: $BUNDLE_DIR${NC}"; exit 1; }

echo -e "${YELLOW}Assemblaggio AppDir...${NC}"
rm -rf "$APPIMAGE_DIR"
mkdir -p "$APPIMAGE_DIR/usr/bin"
mkdir -p "$APPIMAGE_DIR/usr/share/$APP_ID"
mkdir -p "$APPIMAGE_DIR/usr/share/applications"
mkdir -p "$APPIMAGE_DIR/usr/share/icons/hicolor/256x256/apps"
mkdir -p "$APPIMAGE_DIR/usr/share/pixmaps"

# Bundle Flutter (binario, lib, assets, ffmpeg/ffprobe e modelli integrati)
cp -r "$BUNDLE_DIR"/* "$APPIMAGE_DIR/usr/share/$APP_ID/"
chmod +x "$APPIMAGE_DIR/usr/share/$APP_ID/video_converter_pro"
[ -f "$APPIMAGE_DIR/usr/share/$APP_ID/ffmpeg" ] && chmod +x "$APPIMAGE_DIR/usr/share/$APP_ID/ffmpeg"
[ -f "$APPIMAGE_DIR/usr/share/$APP_ID/ffprobe" ] && chmod +x "$APPIMAGE_DIR/usr/share/$APP_ID/ffprobe"

# Runpath relativi invece dei percorsi assoluti di build
if command -v patchelf >/dev/null; then
    find "$APPIMAGE_DIR/usr/share/$APP_ID/lib" -name "*.so" -type f \
        -exec patchelf --set-rpath '$ORIGIN' {} \; 2>/dev/null || true
    patchelf --set-rpath '$ORIGIN/lib' \
        "$APPIMAGE_DIR/usr/share/$APP_ID/video_converter_pro" 2>/dev/null || true
fi

ln -sf "../share/$APP_ID/video_converter_pro" "$APPIMAGE_DIR/usr/bin/video_converter_pro"

# Desktop file
if [ -f "$PROJECT_ROOT/linux/com.videoconverterpro.desktop" ]; then
    cp "$PROJECT_ROOT/linux/com.videoconverterpro.desktop" \
        "$APPIMAGE_DIR/usr/share/applications/$APP_ID.desktop"
else
    cat > "$APPIMAGE_DIR/usr/share/applications/$APP_ID.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=FE Media Converter
Comment=$APP_DESCRIPTION
Exec=video_converter_pro %F
Icon=$APP_ID
Terminal=false
Categories=AudioVideo;Video;Audio;Graphics;
MimeType=video/*;audio/*;image/*;
StartupNotify=true
EOF
fi
cp "$APPIMAGE_DIR/usr/share/applications/$APP_ID.desktop" "$APPIMAGE_DIR/$APP_ID.desktop"
# La chiave URL non e valida per Type=Application e fa fallire appimagetool
grep -v '^URL=' "$APPIMAGE_DIR/$APP_ID.desktop" > "$APPIMAGE_DIR/$APP_ID.desktop.tmp"
mv "$APPIMAGE_DIR/$APP_ID.desktop.tmp" "$APPIMAGE_DIR/$APP_ID.desktop"

# Icona
ICON_SRC=""
[ -f "$PROJECT_ROOT/assets/icon.png" ] && ICON_SRC="$PROJECT_ROOT/assets/icon.png"
[ -f "$PROJECT_ROOT/assets/icons/icon.png" ] && ICON_SRC="$PROJECT_ROOT/assets/icons/icon.png"
if [ -n "$ICON_SRC" ]; then
    cp "$ICON_SRC" "$APPIMAGE_DIR/usr/share/icons/hicolor/256x256/apps/$APP_ID.png"
    cp "$ICON_SRC" "$APPIMAGE_DIR/usr/share/pixmaps/$APP_ID.png"
    cp "$ICON_SRC" "$APPIMAGE_DIR/.DirIcon"
    # appimagetool richiede l'icona con lo stesso nome della chiave Icon nella root
    cp "$ICON_SRC" "$APPIMAGE_DIR/$APP_ID.png"
else
    echo -e "${YELLOW}Icona non trovata in assets/, proseguo senza${NC}"
fi

# Script Python (senza venv: viene creato al primo avvio in una cartella scrivibile)
if [ -d "$PROJECT_ROOT/scripts/python" ]; then
    mkdir -p "$APPIMAGE_DIR/usr/share/$APP_ID/scripts"
    cp -r "$PROJECT_ROOT/scripts/python" "$APPIMAGE_DIR/usr/share/$APP_ID/scripts/"
    rm -rf "$APPIMAGE_DIR/usr/share/$APP_ID/scripts/python/venv"
    rm -rf "$APPIMAGE_DIR/usr/share/$APP_ID/scripts/python/__pycache__"
fi

# AppRun
cat > "$APPIMAGE_DIR/AppRun" << APPRUN_EOF
#!/bin/bash
APPDIR="\$(dirname "\$(readlink -f "\${0}")")"
export PATH="\$APPDIR/usr/bin:\$PATH"
export LD_LIBRARY_PATH="\$APPDIR/usr/share/$APP_ID/lib:\$APPDIR/usr/lib:\$LD_LIBRARY_PATH"

# Su Wayland usa XWayland: l'embedder Flutter e piu stabile su X11
if [ -n "\$WAYLAND_DISPLAY" ] && [ "\$GDK_BACKEND" != "x11" ]; then
    export GDK_BACKEND=x11
fi

# Workaround driver NVIDIA che causano freeze con Flutter
if command -v nvidia-smi &> /dev/null; then
    export __GL_SYNC_TO_VBLANK=0
    export __GL_THREADED_OPTIMIZATIONS=0
fi

exec "\$APPDIR/usr/share/$APP_ID/video_converter_pro" "\$@"
APPRUN_EOF
chmod +x "$APPIMAGE_DIR/AppRun"

# Controlli pre-tool
[ -x "$APPIMAGE_DIR/AppRun" ] || { echo -e "${RED}AppRun mancante${NC}"; exit 1; }
[ -f "$APPIMAGE_DIR/$APP_ID.desktop" ] || { echo -e "${RED}.desktop mancante${NC}"; exit 1; }
[ -x "$APPIMAGE_DIR/usr/share/$APP_ID/video_converter_pro" ] || { echo -e "${RED}binario mancante${NC}"; exit 1; }

# Genera l'AppImage
echo -e "${YELLOW}Generazione AppImage...${NC}"
cd "$PACKAGE_DIR"
OUT_FILE="${APP_NAME}-${APP_VERSION}-x86_64.AppImage"
rm -f "$OUT_FILE"
ARCH=x86_64 "$APPIMAGETOOL_RUN" "$APPIMAGE_DIR" "$OUT_FILE" 2>&1 | tail -5

[ -f "$OUT_FILE" ] || { echo -e "${RED}AppImage non creato${NC}"; exit 1; }
chmod +x "$OUT_FILE"
echo -e "${GREEN}Fatto: $OUT_FILE ($(du -h "$OUT_FILE" | cut -f1))${NC}"
