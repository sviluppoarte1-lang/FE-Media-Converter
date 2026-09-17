#!/bin/bash
# Script per creare un pacchetto .rpm per Ultimate Video Converter Pro
# Uso: ./scripts/build_rpm.sh

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
PACKAGE_DIR="$PROJECT_ROOT/package_rpm"
RPMBUILD_DIR="$PACKAGE_DIR/rpmbuild"

# Informazioni pacchetto
APP_NAME="video-converter-pro"
APP_VERSION="2.0.2"
APP_RELEASE="1"
APP_DESCRIPTION="Un'applicazione professionale per conversione video, audio e immagini"
APP_MAINTAINER="Marco Di Giangiacomo <marco@example.com>"
APP_ARCH="x86_64"

echo -e "${GREEN}=== Building .rpm package for $APP_NAME ===${NC}"

# Verifica che Flutter sia installato
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}Errore: Flutter non trovato. Installa Flutter prima di continuare.${NC}"
    exit 1
fi

# Verifica dipendenze per creare .rpm
if ! command -v rpmbuild &> /dev/null; then
    echo -e "${RED}Errore: rpmbuild non trovato. Installa rpm-build: sudo dnf install rpm-build${NC}"
    exit 1
fi

# Verifica patchelf o chrpath (obbligatorio per correggere runpath)
if ! command -v patchelf &> /dev/null && ! command -v chrpath &> /dev/null; then
    echo -e "${RED}Errore: patchelf o chrpath non trovati.${NC}"
    echo -e "${RED}Installa patchelf: sudo dnf install patchelf${NC}"
    echo -e "${YELLOW}Oppure imposta QA_RPATHS per ignorare gli errori:${NC}"
    echo -e "${YELLOW}  export QA_RPATHS=\$(( 0x0002 ))${NC}"
    exit 1
fi

# Pulisci directory di build precedenti
echo -e "${YELLOW}Pulizia directory di build...${NC}"
rm -rf "$PACKAGE_DIR"
mkdir -p "$RPMBUILD_DIR"/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}

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

# Crea tarball sorgente con una directory contenente i file
echo -e "${YELLOW}Creazione tarball sorgente...${NC}"
TEMP_SOURCE_DIR="$PACKAGE_DIR/temp_source"
rm -rf "$TEMP_SOURCE_DIR"
mkdir -p "$TEMP_SOURCE_DIR/${APP_NAME}-${APP_VERSION}"

# Copia contenuto della directory bundle nella directory temporanea
cp -r "$BUNDLE_DIR"/* "$TEMP_SOURCE_DIR/${APP_NAME}-${APP_VERSION}/"

# Corregge i runpath PRIMA di creare il tarball
echo -e "${YELLOW}Correzione runpath nei file .so...${NC}"
if command -v patchelf &> /dev/null; then
    # Corregge i file .so nella directory lib
    find "$TEMP_SOURCE_DIR/${APP_NAME}-${APP_VERSION}/lib" -name "*.so" -type f -exec patchelf --set-rpath '$ORIGIN' {} \; 2>/dev/null || true
    # Corregge anche l'eseguibile principale
    if [ -f "$TEMP_SOURCE_DIR/${APP_NAME}-${APP_VERSION}/video_converter_pro" ]; then
        patchelf --set-rpath '$ORIGIN/lib' "$TEMP_SOURCE_DIR/${APP_NAME}-${APP_VERSION}/video_converter_pro" 2>/dev/null || true
    fi
    echo -e "${GREEN}✓ Runpath corretti con patchelf${NC}"
elif command -v chrpath &> /dev/null; then
    find "$TEMP_SOURCE_DIR/${APP_NAME}-${APP_VERSION}/lib" -name "*.so" -type f -exec chrpath -r '$ORIGIN' {} \; 2>/dev/null || true
    echo -e "${GREEN}✓ Runpath corretti con chrpath${NC}"
else
    echo -e "${RED}Errore: patchelf o chrpath non trovati.${NC}"
    echo -e "${RED}Installa patchelf: sudo dnf install patchelf${NC}"
    echo -e "${RED}Oppure imposta QA_RPATHS per ignorare gli errori:${NC}"
    echo -e "${YELLOW}  export QA_RPATHS=\$(( 0x0002 ))${NC}"
    rm -rf "$TEMP_SOURCE_DIR"
    exit 1
fi

# Crea tarball dalla directory temporanea
cd "$TEMP_SOURCE_DIR"
tar czf "$RPMBUILD_DIR/SOURCES/${APP_NAME}-${APP_VERSION}.tar.gz" "${APP_NAME}-${APP_VERSION}"
rm -rf "$TEMP_SOURCE_DIR"

# Genera data per changelog
CHANGELOG_DATE=$(LC_TIME=C date '+%a %b %d %Y')

# Crea file .spec
echo -e "${YELLOW}Creazione file .spec...${NC}"
cat > "$RPMBUILD_DIR/SPECS/${APP_NAME}.spec" << EOF
%define app_name $APP_NAME
%define app_version $APP_VERSION
%define app_release $APP_RELEASE
%define app_arch $APP_ARCH

Name:           %{app_name}
Version:        %{app_version}
Release:        %{app_release}%{?dist}
Summary:        Professional video, audio and image conversion application
URL:            https://github.com/sviluppoarte1-lang/Fe-Media-Converter
License:        Proprietary
Group:          Applications/Multimedia
Source0:        %{app_name}-%{app_version}.tar.gz
BuildArch:      %{app_arch}
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

# Disabilita creazione automatica pacchetti debug
%define debug_package %{nil}
%define _enable_debug_packages 0

Requires:       gtk3 glib2 ffmpeg python3 python3-pip desktop-file-utils
Recommends:     python3-venv

%description
$APP_DESCRIPTION
Professional application for video, audio and image conversion.
Uses FFmpeg for media processing and includes AI-powered features
for video restoration and enhancement.

%prep
%setup -q

%build
# Build già completato, niente da fare qui

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}/usr/share/%{app_name}
mkdir -p %{buildroot}/usr/bin
mkdir -p %{buildroot}/usr/share/applications
mkdir -p %{buildroot}/usr/share/metainfo
mkdir -p %{buildroot}/usr/share/icons/hicolor/256x256/apps
mkdir -p %{buildroot}/usr/share/pixmaps

# Copia file applicazione dalla directory di build
# %setup estrae il tarball creando una directory con il nome del Source0 senza estensione
# Quindi i file saranno in %{_builddir}/%{app_name}-%{app_version}/
# I runpath sono già stati corretti prima di creare il tarball
cp -r %{_builddir}/%{app_name}-%{app_version}/* %{buildroot}/usr/share/%{app_name}/

# Crea symlink per eseguibile (relativo invece di assoluto per evitare avvisi)
mkdir -p %{buildroot}/usr/bin
ln -sf ../share/%{app_name}/video_converter_pro %{buildroot}/usr/bin/video_converter_pro

# Copia file .desktop e AppStream
if [ -f "$PROJECT_ROOT/linux/com.videoconverterpro.desktop" ]; then
    cp "$PROJECT_ROOT/linux/com.videoconverterpro.desktop" %{buildroot}/usr/share/applications/
else
    cat > %{buildroot}/usr/share/applications/com.videoconverterpro.desktop << DESKTOP_EOF
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
DESKTOP_EOF
fi
if [ -f "$PROJECT_ROOT/linux/com.videoconverterpro.metainfo.xml" ]; then
    cp "$PROJECT_ROOT/linux/com.videoconverterpro.metainfo.xml" %{buildroot}/usr/share/metainfo/
fi

# Copia icona
if [ -f "$PROJECT_ROOT/linux/runner/assets/icon_256x256.png" ]; then
    cp "$PROJECT_ROOT/linux/runner/assets/icon_256x256.png" %{buildroot}/usr/share/icons/hicolor/256x256/apps/com.videoconverterpro.png
    cp "$PROJECT_ROOT/linux/runner/assets/icon_256x256.png" %{buildroot}/usr/share/pixmaps/com.videoconverterpro.png
elif [ -f "$PROJECT_ROOT/assets/icons/icon.png" ]; then
    cp "$PROJECT_ROOT/assets/icons/icon.png" %{buildroot}/usr/share/icons/hicolor/256x256/apps/com.videoconverterpro.png
    cp "$PROJECT_ROOT/assets/icons/icon.png" %{buildroot}/usr/share/pixmaps/com.videoconverterpro.png
fi

# Copia script Python
if [ -d "$PROJECT_ROOT/scripts/python" ]; then
    mkdir -p %{buildroot}/usr/share/%{app_name}/scripts
    cp -r "$PROJECT_ROOT/scripts/python" %{buildroot}/usr/share/%{app_name}/scripts/
    # Rimuovi venv se presente
    rm -rf %{buildroot}/usr/share/%{app_name}/scripts/python/venv
    # Rendi eseguibile lo script setup
    if [ -f "%{buildroot}/usr/share/%{app_name}/scripts/python/setup_python_env.sh" ]; then
        chmod +x %{buildroot}/usr/share/%{app_name}/scripts/python/setup_python_env.sh
    fi
fi

%post
#!/bin/sh
# Script post-installazione
# Usa /bin/sh invece di bash per maggiore compatibilità

# Aggiorna database desktop (se disponibile)
if [ -x /usr/bin/update-desktop-database ]; then
    /usr/bin/update-desktop-database >/dev/null 2>&1 || :
fi

# Aggiorna database icone (se disponibile, con timeout per evitare blocchi)
if [ -x /usr/bin/gtk-update-icon-cache ]; then
    timeout 30 /usr/bin/gtk-update-icon-cache /usr/share/icons/hicolor >/dev/null 2>&1 || :
fi

exit 0

%postun
#!/bin/sh
# Script post-disinstallazione
# Usa /bin/sh invece di bash per maggiore compatibilità

# Aggiorna database desktop (se disponibile)
if [ -x /usr/bin/update-desktop-database ]; then
    /usr/bin/update-desktop-database >/dev/null 2>&1 || :
fi

# Aggiorna database icone (se disponibile, con timeout per evitare blocchi)
if [ -x /usr/bin/gtk-update-icon-cache ]; then
    timeout 30 /usr/bin/gtk-update-icon-cache /usr/share/icons/hicolor >/dev/null 2>&1 || :
fi

exit 0

%files
%defattr(-,root,root,-)
/usr/share/%{app_name}
/usr/bin/video_converter_pro
/usr/share/applications/com.videoconverterpro.desktop
/usr/share/metainfo/com.videoconverterpro.metainfo.xml
/usr/share/icons/hicolor/256x256/apps/com.videoconverterpro.png
/usr/share/pixmaps/com.videoconverterpro.png

%changelog
* $CHANGELOG_DATE $APP_MAINTAINER - $APP_VERSION-$APP_RELEASE
- Initial RPM package release
EOF

# Verifica già fatta all'inizio dello script

# Build RPM (disabilita creazione pacchetti debug per evitare errori)
echo -e "${YELLOW}Building pacchetto .rpm...${NC}"
cd "$RPMBUILD_DIR"
rpmbuild --define "_topdir $RPMBUILD_DIR" \
        --define "_builddir $RPMBUILD_DIR/BUILD" \
        --define "debug_package %{nil}" \
        --define "_enable_debug_packages 0" \
        -ba SPECS/${APP_NAME}.spec

# Trova file RPM creato (cerca in tutte le sottodirectory di RPMS)
RPM_FILE=$(find "$RPMBUILD_DIR/RPMS" -type f -name "*.rpm" | head -1)

if [ -n "$RPM_FILE" ] && [ -f "$RPM_FILE" ]; then
    RPM_SIZE=$(du -h "$RPM_FILE" | cut -f1)
    RPM_NAME=$(basename "$RPM_FILE")
    
    # Copia RPM nella directory package
    cp "$RPM_FILE" "$PACKAGE_DIR/"
    
    echo -e "${GREEN}✓ Pacchetto .rpm creato con successo!${NC}"
    echo -e "${GREEN}  File: $RPM_NAME${NC}"
    echo -e "${GREEN}  Dimensione: $RPM_SIZE${NC}"
    echo -e "${GREEN}  Posizione: $PACKAGE_DIR/$RPM_NAME${NC}"
    
    # Mostra informazioni pacchetto
    echo -e "\n${YELLOW}Informazioni pacchetto:${NC}"
    rpm -qip "$PACKAGE_DIR/$RPM_NAME"
else
    echo -e "${RED}Errore: Creazione pacchetto .rpm fallita${NC}"
    exit 1
fi

echo -e "\n${GREEN}=== Build completato con successo! ===${NC}"
