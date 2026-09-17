#!/bin/bash
# Script per creare un pacchetto .deb per Ultimate Video Converter Pro
# Uso: ./scripts/build_deb.sh

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
PACKAGE_DIR="$PROJECT_ROOT/package_deb"
DEB_DIR="$PACKAGE_DIR/deb"

# Informazioni pacchetto
APP_NAME="video-converter-pro"
APP_VERSION="2.0.2"
APP_RELEASE="1"
APP_DESCRIPTION="Un'applicazione professionale per conversione video, audio e immagini"
APP_MAINTAINER="Marco Di Giangiacomo <marco@example.com>"
APP_ARCH="amd64"

echo -e "${GREEN}=== Building .deb package for $APP_NAME ===${NC}"

# Verifica che Flutter sia installato
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}Errore: Flutter non trovato. Installa Flutter prima di continuare.${NC}"
    exit 1
fi

# Verifica dipendenze per creare .deb
if ! command -v dpkg-deb &> /dev/null; then
    echo -e "${RED}Errore: dpkg-deb non trovato. Installa dpkg-dev: sudo apt-get install dpkg-dev${NC}"
    exit 1
fi

# Pulisci directory di build precedenti
echo -e "${YELLOW}Pulizia directory di build...${NC}"
rm -rf "$PACKAGE_DIR"
mkdir -p "$DEB_DIR"

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

# Crea struttura directory per .deb
echo -e "${YELLOW}Creazione struttura directory .deb...${NC}"
mkdir -p "$DEB_DIR/DEBIAN"
mkdir -p "$DEB_DIR/usr/share/$APP_NAME"
mkdir -p "$DEB_DIR/usr/bin"
mkdir -p "$DEB_DIR/usr/share/applications"
mkdir -p "$DEB_DIR/usr/share/metainfo"
mkdir -p "$DEB_DIR/usr/share/icons/hicolor/256x256/apps"
mkdir -p "$DEB_DIR/usr/share/pixmaps"

# Copia file dell'applicazione
echo -e "${YELLOW}Copia file applicazione...${NC}"
cp -r "$BUNDLE_DIR"/* "$DEB_DIR/usr/share/$APP_NAME/"

# Corregge i runpath nei file .so per rimuovere percorsi assoluti di build
echo -e "${YELLOW}Correzione runpath nei file .so...${NC}"
if command -v patchelf &> /dev/null; then
    find "$DEB_DIR/usr/share/$APP_NAME/lib" -name "*.so" -type f -exec patchelf --set-rpath '$ORIGIN' {} \; 2>/dev/null || true
    # Corregge anche l'eseguibile principale
    patchelf --set-rpath '$ORIGIN/lib' "$DEB_DIR/usr/share/$APP_NAME/video_converter_pro" 2>/dev/null || true
    echo -e "${GREEN}✓ Runpath corretti con patchelf${NC}"
elif command -v chrpath &> /dev/null; then
    find "$DEB_DIR/usr/share/$APP_NAME/lib" -name "*.so" -type f -exec chrpath -r '$ORIGIN' {} \; 2>/dev/null || true
    echo -e "${GREEN}✓ Runpath corretti con chrpath${NC}"
else
    echo -e "${YELLOW}⚠ patchelf/chrpath non trovati, i runpath potrebbero contenere percorsi assoluti${NC}"
fi

# Crea symlink per eseguibile
ln -sf "/usr/share/$APP_NAME/video_converter_pro" "$DEB_DIR/usr/bin/video_converter_pro"

# Copia file .desktop e AppStream (GNOME Software)
if [ -f "$PROJECT_ROOT/linux/com.videoconverterpro.desktop" ]; then
    cp "$PROJECT_ROOT/linux/com.videoconverterpro.desktop" "$DEB_DIR/usr/share/applications/"
else
    echo -e "${YELLOW}File .desktop non trovato, creazione di uno nuovo...${NC}"
    cat > "$DEB_DIR/usr/share/applications/com.videoconverterpro.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=FE MEDIA CONVERTER
Comment=Professional video, audio and image conversion application
Exec=video_converter_pro %F
Icon=com.videoconverterpro
Terminal=false
Categories=AudioVideo;Video;Audio;Graphics;
MimeType=video/*;audio/*;image/*;
StartupNotify=true
EOF
fi
if [ -f "$PROJECT_ROOT/linux/com.videoconverterpro.metainfo.xml" ]; then
    cp "$PROJECT_ROOT/linux/com.videoconverterpro.metainfo.xml" "$DEB_DIR/usr/share/metainfo/"
fi

# Copia icona (nome icona = application ID per coerenza con .desktop)
if [ -f "$PROJECT_ROOT/linux/runner/assets/icon_256x256.png" ]; then
    cp "$PROJECT_ROOT/linux/runner/assets/icon_256x256.png" "$DEB_DIR/usr/share/icons/hicolor/256x256/apps/com.videoconverterpro.png"
    cp "$PROJECT_ROOT/linux/runner/assets/icon_256x256.png" "$DEB_DIR/usr/share/pixmaps/com.videoconverterpro.png"
elif [ -f "$PROJECT_ROOT/assets/icons/icon.png" ]; then
    cp "$PROJECT_ROOT/assets/icons/icon.png" "$DEB_DIR/usr/share/icons/hicolor/256x256/apps/com.videoconverterpro.png"
    cp "$PROJECT_ROOT/assets/icons/icon.png" "$DEB_DIR/usr/share/pixmaps/com.videoconverterpro.png"
else
    echo -e "${YELLOW}Icona non trovata, verrà usata quella di default${NC}"
fi

# Copia script Python
echo -e "${YELLOW}Copia script Python...${NC}"
if [ -d "$PROJECT_ROOT/scripts/python" ]; then
    mkdir -p "$DEB_DIR/usr/share/$APP_NAME/scripts"
    cp -r "$PROJECT_ROOT/scripts/python" "$DEB_DIR/usr/share/$APP_NAME/scripts/"
    # Rimuovi venv se presente (sarà ricreato da postinst/setup)
    rm -rf "$DEB_DIR/usr/share/$APP_NAME/scripts/python/venv"
fi

# Crea file control
echo -e "${YELLOW}Creazione file control...${NC}"
cat > "$DEB_DIR/DEBIAN/control" << EOF
Package: $APP_NAME
Version: $APP_VERSION-$APP_RELEASE
Architecture: $APP_ARCH
Maintainer: $APP_MAINTAINER
Description: $APP_DESCRIPTION
 Interfaccia desktop per FFmpeg: conversioni in coda, codec (H.264/HEVC/VP9/AV1,
 AAC/MP3/Opus…), filtri video/audio, accelerazione GPU opzionale, denoising DRUNet
 e analisi scene (PySceneDetect). Le librerie Python pesanti per le funzioni AI
 opzionali si installano al primo avvio dell'app (finestra di avanzamento), non
 durante dpkg install.
 .
 Include metadati AppStream per GNOME Software (descrizione estesa e funzionalità).
Depends: libgtk-3-0, libglib2.0-0, ffmpeg, python3, python3-pip
Recommends: python3-venv
Section: video
Priority: optional
Homepage: https://github.com/sviluppoarte1-lang/Fe-Media-Converter
EOF

# Crea script postinst
cat > "$DEB_DIR/DEBIAN/postinst" << 'EOF'
#!/bin/bash
set -e

APP_DIR="/usr/share/video-converter-pro"
PYTHON_DIR="$APP_DIR/scripts/python"
SETUP_SCRIPT="$PYTHON_DIR/setup_python_env.sh"

# Aggiorna database desktop
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database
fi

# Aggiorna database icone
if command -v update-icon-caches &> /dev/null; then
    update-icon-caches /usr/share/icons/hicolor || true
fi

# Rendi eseguibili gli script Python
if [ -f "$SETUP_SCRIPT" ]; then
    chmod +x "$SETUP_SCRIPT"
fi
for script in "$PYTHON_DIR"/*.py; do
    [ -f "$script" ] && chmod +x "$script"
done

# Ambiente Python (venv + PyTorch, ecc.): non eseguito qui — l'app propone
# download/install al primo avvio con dialog di avanzamento.

echo "FE Media Converter installato. Avvia l'app per eventuale setup Python opzionale."

exit 0
EOF
chmod +x "$DEB_DIR/DEBIAN/postinst"

# Crea script prerm
cat > "$DEB_DIR/DEBIAN/prerm" << 'EOF'
#!/bin/bash
set -e
exit 0
EOF
chmod +x "$DEB_DIR/DEBIAN/prerm"

# Crea script postrm
cat > "$DEB_DIR/DEBIAN/postrm" << 'EOF'
#!/bin/bash
set -e

# Aggiorna database desktop
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database
fi

# Aggiorna database icone
if command -v update-icon-caches &> /dev/null; then
    update-icon-caches /usr/share/icons/hicolor || true
fi

exit 0
EOF
chmod +x "$DEB_DIR/DEBIAN/postrm"

cat > "$DEB_DIR/DEBIAN/triggers" << 'TRIG_EOF'
interest-noawait /usr/share/metainfo
TRIG_EOF

# Calcola dimensione pacchetto
INSTALLED_SIZE=$(du -sk "$DEB_DIR/usr" | cut -f1)
if grep -q '^Installed-Size:' "$DEB_DIR/DEBIAN/control"; then
    sed -i "s/^Installed-Size:.*/Installed-Size: $INSTALLED_SIZE/" "$DEB_DIR/DEBIAN/control"
else
    echo "Installed-Size: $INSTALLED_SIZE" >> "$DEB_DIR/DEBIAN/control"
fi

# Crea pacchetto .deb
echo -e "${YELLOW}Creazione pacchetto .deb...${NC}"
cd "$PACKAGE_DIR"
dpkg-deb --build deb "${APP_NAME}_${APP_VERSION}-${APP_RELEASE}_${APP_ARCH}.deb"

# Verifica pacchetto
if [ -f "${APP_NAME}_${APP_VERSION}-${APP_RELEASE}_${APP_ARCH}.deb" ]; then
    DEB_SIZE=$(du -h "${APP_NAME}_${APP_VERSION}-${APP_RELEASE}_${APP_ARCH}.deb" | cut -f1)
    echo -e "${GREEN}✓ Pacchetto .deb creato con successo!${NC}"
    echo -e "${GREEN}  File: ${APP_NAME}_${APP_VERSION}-${APP_RELEASE}_${APP_ARCH}.deb${NC}"
    echo -e "${GREEN}  Dimensione: $DEB_SIZE${NC}"
    echo -e "${GREEN}  Posizione: $PACKAGE_DIR/${APP_NAME}_${APP_VERSION}-${APP_RELEASE}_${APP_ARCH}.deb${NC}"
    
    # Mostra informazioni pacchetto
    echo -e "\n${YELLOW}Informazioni pacchetto:${NC}"
    dpkg-deb -I "${APP_NAME}_${APP_VERSION}-${APP_RELEASE}_${APP_ARCH}.deb"
else
    echo -e "${RED}Errore: Creazione pacchetto .deb fallita${NC}"
    exit 1
fi

echo -e "\n${GREEN}=== Build completato con successo! ===${NC}"
