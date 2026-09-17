#!/bin/bash

echo "📀 Installazione Video Converter Pro"
echo "====================================="

# Verifica se siamo su Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "❌ Questo script supporta solo Linux"
    exit 1
fi

# Verifica permessi root
if [[ $EUID -eq 0 ]]; then
   echo "❌ Non eseguire questo script come root"
   exit 1
fi

# Rileva la distribuzione
if [ -f /etc/fedora-release ]; then
    DISTRO="fedora"
elif [ -f /etc/debian_version ]; then
    DISTRO="debian"
else
    echo "❌ Distribuzione non supportata"
    echo "Installa manualmente FFmpeg per la tua distribuzione"
    exit 1
fi

echo "📦 Distribuzione rilevata: $DISTRO"

# Installa FFmpeg
echo ""
echo "🔧 Installazione FFmpeg..."
case $DISTRO in
    "fedora")
        sudo dnf install -y ffmpeg ffmpeg-freeworld
        ;;
    "debian")
        sudo apt update
        sudo apt install -y ffmpeg
        ;;
esac

# Verifica installazione
if command -v ffmpeg &> /dev/null; then
    echo ""
    echo "✅ FFmpeg installato con successo!"
    ffmpeg -version | head -n 1
else
    echo ""
    echo "❌ Installazione FFmpeg fallita"
    echo "Installa manualmente FFmpeg:"
    case $DISTRO in
        "fedora") echo "  sudo dnf install ffmpeg ffmpeg-freeworld" ;;
        "debian") echo "  sudo apt update && sudo apt install ffmpeg" ;;
    esac
    exit 1
fi

echo ""
echo "🎉 Setup completato! Ora puoi avviare Video Converter Pro"