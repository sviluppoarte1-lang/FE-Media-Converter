#!/bin/bash

echo "🔍 Controllo Sistema Video Converter Pro"
echo "========================================"

# Verifica FFmpeg
echo ""
echo "📀 Controllo FFmpeg..."
if command -v ffmpeg &> /dev/null; then
    echo "✅ FFmpeg trovato: $(ffmpeg -version | head -n 1)"
else
    echo "❌ FFmpeg non trovato"
    echo "Esegui: ./scripts/install_ffmpeg.sh"
fi

# Verifica codec
echo ""
echo "🎵 Controllo codec supportati..."
ffmpeg -codecs 2>/dev/null | grep -E "(h264|h265|vp9|av1|aac)" | head -10

# Verifica architettura
echo ""
echo "💻 Architettura sistema:"
echo "   OS: $(uname -s)"
echo "   Arch: $(uname -m)"
echo "   Distro: $(lsb_release -d 2>/dev/null | cut -f2 || cat /etc/*release 2>/dev/null | head -n1)"

# Verifica spazio disco
echo ""
echo "💾 Spazio disco disponibile:"
df -h . | tail -1 | awk '{print "   " $4 " liberi su " $2}'

echo ""
echo "✅ Controllo completato"