#!/bin/bash
# Script per creare un file AppImage per Ultimate Video Converter Pro
# Uso: ./scripts/build_appimage.sh

set -e

# Colori per output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Directory di lavoro
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/build"
PACKAGE_DIR="$PROJECT_ROOT/package_appimage"
APPIMAGE_DIR="$PACKAGE_DIR/AppDir"

# Informazioni pacchetto
APP_NAME="Ultimate-Video-Converter-Pro"
APP_ID="com.videoconverterpro"
APP_VERSION="2.0.2"
APP_DESCRIPTION="Professional video, audio and image conversion application"

echo -e "${GREEN}=== Building AppImage for $APP_NAME ===${NC}"

# Verifica che Flutter sia installato
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}Errore: Flutter non trovato. Installa Flutter prima di continuare.${NC}"
    exit 1
fi

# Verifica/Scarica appimagetool
APPIMAGETOOL="$PACKAGE_DIR/appimagetool-x86_64.AppImage"
if [ ! -f "$APPIMAGETOOL" ]; then
    echo -e "${YELLOW}Download appimagetool...${NC}"
    mkdir -p "$PACKAGE_DIR"
    wget -q -O "$APPIMAGETOOL" "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage" || {
        echo -e "${RED}Errore: Download appimagetool fallito${NC}"
        exit 1
    }
    chmod +x "$APPIMAGETOOL"
fi

# Pulisci directory di build precedenti
echo -e "${YELLOW}Pulizia directory di build...${NC}"
rm -rf "$APPIMAGE_DIR"
mkdir -p "$APPIMAGE_DIR"

# Build Flutter app
echo -e "${YELLOW}Building Flutter app...${NC}"
cd "$PROJECT_ROOT"
flutter clean
flutter pub get
flutter build linux --release

# Verifica che il build sia riuscito
BUNDLE_DIR="$BUILD_DIR/linux/x64/release/bundle"
if [ ! -d "$BUNDLE_DIR" ]; then
    echo -e "${RED}Errore: Directory bundle non trovata: $BUNDLE_DIR${NC}"
    exit 1
fi

# Crea struttura AppDir
echo -e "${YELLOW}Creazione struttura AppDir...${NC}"
mkdir -p "$APPIMAGE_DIR/usr/bin"
mkdir -p "$APPIMAGE_DIR/usr/share/$APP_ID"
mkdir -p "$APPIMAGE_DIR/usr/share/applications"
mkdir -p "$APPIMAGE_DIR/usr/share/icons/hicolor/256x256/apps"
mkdir -p "$APPIMAGE_DIR/usr/share/pixmaps"

# Copia file dell'applicazione
echo -e "${YELLOW}Copia file applicazione...${NC}"
cp -r "$BUNDLE_DIR"/* "$APPIMAGE_DIR/usr/share/$APP_ID/"

# Corregge i runpath nei file .so per rimuovere percorsi assoluti di build
echo -e "${YELLOW}Correzione runpath nei file .so...${NC}"
if command -v patchelf &> /dev/null; then
    find "$APPIMAGE_DIR/usr/share/$APP_ID/lib" -name "*.so" -type f -exec patchelf --set-rpath '$ORIGIN' {} \; 2>/dev/null || true
    # Corregge anche l'eseguibile principale
    patchelf --set-rpath '$ORIGIN/lib' "$APPIMAGE_DIR/usr/share/$APP_ID/video_converter_pro" 2>/dev/null || true
    echo -e "${GREEN}✓ Runpath corretti con patchelf${NC}"
elif command -v chrpath &> /dev/null; then
    find "$APPIMAGE_DIR/usr/share/$APP_ID/lib" -name "*.so" -type f -exec chrpath -r '$ORIGIN' {} \; 2>/dev/null || true
    echo -e "${GREEN}✓ Runpath corretti con chrpath${NC}"
else
    echo -e "${YELLOW}⚠ patchelf/chrpath non trovati, i runpath potrebbero contenere percorsi assoluti${NC}"
fi

# Crea symlink per eseguibile
ln -sf "../share/$APP_ID/video_converter_pro" "$APPIMAGE_DIR/usr/bin/video_converter_pro"

# Copia file .desktop
if [ -f "$PROJECT_ROOT/linux/com.videoconverterpro.desktop" ]; then
    cp "$PROJECT_ROOT/linux/com.videoconverterpro.desktop" "$APPIMAGE_DIR/usr/share/applications/$APP_ID.desktop"
else
    cat > "$APPIMAGE_DIR/usr/share/applications/$APP_ID.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=$APP_NAME
Comment=$APP_DESCRIPTION
Exec=video_converter_pro %F
Icon=$APP_ID
Terminal=false
Categories=AudioVideo;Video;Audio;Graphics;
MimeType=video/*;audio/*;image/*;
StartupNotify=true
EOF
fi

# Copia icona
if [ -f "$PROJECT_ROOT/linux/runner/assets/icon_256x256.png" ]; then
    cp "$PROJECT_ROOT/linux/runner/assets/icon_256x256.png" "$APPIMAGE_DIR/usr/share/icons/hicolor/256x256/apps/$APP_ID.png"
    cp "$PROJECT_ROOT/linux/runner/assets/icon_256x256.png" "$APPIMAGE_DIR/usr/share/pixmaps/$APP_ID.png"
elif [ -f "$PROJECT_ROOT/assets/icons/icon.png" ]; then
    cp "$PROJECT_ROOT/assets/icons/icon.png" "$APPIMAGE_DIR/usr/share/icons/hicolor/256x256/apps/$APP_ID.png"
    cp "$PROJECT_ROOT/assets/icons/icon.png" "$APPIMAGE_DIR/usr/share/pixmaps/$APP_ID.png"
else
    echo -e "${YELLOW}Icona non trovata, verrà usata quella di default${NC}"
fi

# Copia script Python
echo -e "${YELLOW}Copia script Python...${NC}"
if [ -d "$PROJECT_ROOT/scripts/python" ]; then
    mkdir -p "$APPIMAGE_DIR/usr/share/$APP_ID/scripts"
    cp -r "$PROJECT_ROOT/scripts/python" "$APPIMAGE_DIR/usr/share/$APP_ID/scripts/"
    # Rimuovi venv se presente (sarà ricreato dall'utente)
    rm -rf "$APPIMAGE_DIR/usr/share/$APP_ID/scripts/python/venv"
fi

# Crea AppRun
echo -e "${YELLOW}Creazione AppRun...${NC}"
cat > "$APPIMAGE_DIR/AppRun" << 'APPRUN_EOF'
#!/bin/bash
# AppRun script for Ultimate Video Converter Pro

APPDIR="$(dirname "$(readlink -f "${0}")")"
export PATH="$APPDIR/usr/bin:$PATH"
export LD_LIBRARY_PATH="$APPDIR/usr/lib:$APPDIR/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH"

export FLUTTER_ROOT="$APPDIR/usr/share/@APP_ID@"
export APPIMAGE="$APPDIR"

if [ -n "$WAYLAND_DISPLAY" ] && [ "$GDK_BACKEND" != "x11" ]; then
    export GDK_BACKEND=x11
fi

if command -v nvidia-smi &> /dev/null; then
    export __GL_SYNC_TO_VBLANK=0
    export __GL_THREADED_OPTIMIZATIONS=0
    export __GL_ALLOW_UNOFFICIAL_PROTOCOL=0
fi

exec "$APPDIR/usr/share/@APP_ID@/video_converter_pro" "$@"
APPRUN_EOF
sed -i "s/@APP_ID@/$APP_ID/g" "$APPIMAGE_DIR/AppRun"
chmod +x "$APPIMAGE_DIR/AppRun"

# Crea file .DirIcon (simbolico per icona directory)
if [ -f "$APPIMAGE_DIR/usr/share/icons/hicolor/256x256/apps/$APP_ID.png" ]; then
    cp "$APPIMAGE_DIR/usr/share/icons/hicolor/256x256/apps/$APP_ID.png" "$APPIMAGE_DIR/.DirIcon"
fi

# Crea file .desktop nella root (richiesto da AppImage)
if [ -f "$APPIMAGE_DIR/usr/share/applications/$APP_ID.desktop" ]; then
    cp "$APPIMAGE_DIR/usr/share/applications/$APP_ID.desktop" "$APPIMAGE_DIR/"
else
    echo -e "${RED}Errore: File .desktop non trovato per la copia nella root${NC}"
    exit 1
fi

# Verifica che tutti i file necessari siano presenti
echo -e "${YELLOW}Verifica struttura AppDir...${NC}"
if [ ! -f "$APPIMAGE_DIR/AppRun" ]; then
    echo -e "${RED}Errore: AppRun mancante${NC}"
    exit 1
fi
if [ ! -f "$APPIMAGE_DIR/$APP_ID.desktop" ]; then
    echo -e "${RED}Errore: File .desktop nella root mancante${NC}"
    exit 1
fi
if [ ! -f "$APPIMAGE_DIR/usr/share/$APP_ID/video_converter_pro" ]; then
    echo -e "${RED}Errore: Eseguibile video_converter_pro mancante${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Struttura AppDir verificata${NC}"

# Genera AppImage
echo -e "${YELLOW}Generazione AppImage...${NC}"
cd "$PACKAGE_DIR"

# Verifica che AppDir esista e contenga i file necessari
if [ ! -f "$APPIMAGE_DIR/AppRun" ]; then
    echo -e "${RED}Errore: AppRun non trovato in AppDir${NC}"
    exit 1
fi

if [ ! -f "$APPIMAGE_DIR/usr/share/applications/$APP_ID.desktop" ]; then
    echo -e "${RED}Errore: File .desktop non trovato${NC}"
    exit 1
fi

# Esegui appimagetool (deve essere eseguito dalla directory contenente AppDir)
ARCH=x86_64 "$APPIMAGETOOL" "$APPIMAGE_DIR" "${APP_NAME}-${APP_VERSION}-x86_64.AppImage" 2>&1 | tee /tmp/appimage_build.log

# Verifica che il file sia stato creato
if [ ! -f "${APP_NAME}-${APP_VERSION}-x86_64.AppImage" ]; then
    echo -e "${RED}Errore: AppImage non creato. Controlla il log:${NC}"
    cat /tmp/appimage_build.log
    exit 1
fi

# Verifica AppImage
APPIMAGE_FILE="${APP_NAME}-${APP_VERSION}-x86_64.AppImage"
APPIMAGE_PATH="$PACKAGE_DIR/$APPIMAGE_FILE"

if [ -f "$APPIMAGE_PATH" ]; then
    APPIMAGE_SIZE=$(du -h "$APPIMAGE_PATH" | cut -f1)
    chmod +x "$APPIMAGE_PATH"
    
    echo -e "${GREEN}✓ AppImage creato con successo!${NC}"
    echo -e "${GREEN}  File: $APPIMAGE_FILE${NC}"
    echo -e "${GREEN}  Dimensione: $APPIMAGE_SIZE${NC}"
    echo -e "${GREEN}  Posizione: $APPIMAGE_PATH${NC}"
    
    # Verifica AppImage
    echo -e "\n${YELLOW}Verifica AppImage...${NC}"
    if "$APPIMAGE_PATH" --appimage-help &> /dev/null; then
        echo -e "${GREEN}✓ AppImage valido${NC}"
    else
        echo -e "${YELLOW}⚠ AppImage potrebbe non essere valido (test fallito)${NC}"
    fi
else
    echo -e "${RED}Errore: Creazione AppImage fallita - file non trovato in $APPIMAGE_PATH${NC}"
    echo -e "${YELLOW}Contenuto directory $PACKAGE_DIR:${NC}"
    ls -la "$PACKAGE_DIR"
    exit 1
fi

echo -e "\n${GREEN}=== Build completato con successo! ===${NC}"
echo -e "${YELLOW}Per eseguire l'AppImage:${NC}"
echo -e "  ./$APPIMAGE_FILE"
