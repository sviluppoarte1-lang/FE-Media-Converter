# Python Scripts for Video Converter Pro

Questo modulo contiene script Python per funzionalità avanzate di elaborazione video.

## Dipendenze

### Installazione

⚠️ **IMPORTANTE**: Su sistemi Linux moderni (Debian/Ubuntu), Python protegge l'ambiente di sistema. 
**Usa sempre un virtual environment** per installare le dipendenze.

#### Metodo Consigliato: Virtual Environment

```bash
# Installa Python 3 e venv se non già installato
sudo apt-get install python3 python3-venv python3-pip

# Vai nella directory degli script
cd scripts/python

# Esegui lo script di setup (crea automaticamente il venv e installa le dipendenze)
./setup_python_env.sh
```

Lo script `setup_python_env.sh`:
- Crea automaticamente un virtual environment in `scripts/python/venv`
- Installa tutte le dipendenze necessarie
- Verifica l'installazione

#### Installazione Manuale

Se preferisci installare manualmente:

```bash
# Crea virtual environment
python3 -m venv scripts/python/venv

# Attiva virtual environment
source scripts/python/venv/bin/activate

# Installa dipendenze
pip install -r scripts/python/requirements.txt
```

#### Verifica Installazione

Dopo l'installazione, verifica che tutto funzioni:

```bash
# Attiva il venv
source scripts/python/venv/bin/activate

# Verifica import (usa virgolette singole per evitare problemi con bash)
python3 -c 'import torch, scenedetect, cv2; print("OK: Tutte le dipendenze installate")'

# Oppure senza attivare il venv (usa il Python del venv direttamente)
scripts/python/venv/bin/python3 -c 'import torch, scenedetect, cv2; print("OK")'
```

### Dipendenze Principali

- **PyTorch** - Per DRUNet deep learning denoising
- **PySceneDetect** - Per il rilevamento automatico delle scene
- **OpenCV** - Per elaborazione immagini/video
- **NumPy** - Per calcoli numerici
- **Pillow** - Per elaborazione immagini

## Funzionalità

### 1. DRUNet Denoising

DRUNet è un denoiser basato su deep learning che può migliorare significativamente la qualità video rimuovendo il rumore.

**Uso:**
```bash
python3 drunet_denoiser.py --input frame.png --output frame_denoised.png --noise-level 7
```

**Parametri:**
- `--input`: Percorso frame di input
- `--output`: Percorso frame di output
- `--noise-level`: Livello di rumore (0-255), default 7
- `--model-path`: Percorso opzionale al modello DRUNet pre-addestrato
- `--device`: Dispositivo da usare ('auto', 'cpu', 'cuda')

**Note:**
- DRUNet richiede un modello pre-addestrato per risultati ottimali
- Senza modello, viene usato un fallback con filtri OpenCV
- Il processo può essere lento su CPU, si consiglia GPU se disponibile

### 2. PySceneDetect

PySceneDetect rileva automaticamente i cambi di scena nei video per ottimizzare la qualità.

**Uso:**
```bash
python3 scene_detector.py --input video.mp4 --method adaptive --analyze-quality
```

**Parametri:**
- `--input`: Percorso video di input
- `--method`: Metodo di rilevamento ('adaptive', 'content', 'threshold')
- `--threshold`: Soglia per metodi content/threshold, default 30.0
- `--output-json`: Percorso opzionale per salvare la lista scene come JSON
- `--split`: Divide il video in file separati per ogni scena
- `--output-dir`: Directory per i file divisi (se --split)
- `--analyze-quality`: Analizza le scene e fornisce raccomandazioni qualità

**Metodi di Rilevamento:**
- **adaptive**: Metodo adattivo (consigliato) - si adatta automaticamente al contenuto
- **content**: Rileva cambi basati sul contenuto visivo
- **threshold**: Rileva cambi basati su una soglia fissa

## Integrazione nell'App

Le funzionalità sono integrate automaticamente nell'app Flutter:

1. **Analisi Automatica**: Durante la conversione video, l'app analizza automaticamente:
   - Scene changes (se abilitato)
   - Noise levels per raccomandare DRUNet
   - Quality issues per ottimizzazioni

2. **Raccomandazioni**: L'app fornisce raccomandazioni basate sull'analisi:
   - Livello DRUNet ottimale
   - Impostazioni qualità basate sulle scene
   - Bitrate/CRF ottimali

3. **UI**: Le opzioni sono disponibili nel pannello filtri video:
   - Enable/disable DRUNet denoising
   - Enable/disable scene detection
   - Scene-based quality optimization

## Troubleshooting

### L'app segnala "No module named 'scenedetect'" o "No module named 'torch'"

L’app usa il Python del **virtual environment** in `scripts/python/venv`. Se quel venv non esiste o non ha le dipendenze, crealo e installale una sola volta:

```bash
# Dalla root del progetto (dove si trova scripts/python)
cd /path/to/ultimate_video_converter_pro
./scripts/python/setup_python_env.sh
```

Oppure dalla cartella degli script:

```bash
cd scripts/python
./setup_python_env.sh
```

Dopo il setup, rilancia l’app: userà automaticamente `scripts/python/venv/bin/python3`.

### Errori di Importazione (dopo il setup)

Se ricevi errori di importazione **dopo** aver eseguito lo script di setup:
```bash
# Verifica che il venv abbia le dipendenze (usa il Python del venv)
scripts/python/venv/bin/python3 -c 'import torch, scenedetect, cv2; print("OK")'

# Se mancano, riesegui lo setup
./scripts/python/setup_python_env.sh
```

### DRUNet Model Not Found

DRUNet funziona anche senza modello pre-addestrato, ma con efficacia limitata. Per risultati ottimali:
1. Scarica un modello DRUNet pre-addestrato
2. Specifica il percorso con `--model-path`

### Performance Lente

- **DRUNet**: Usa GPU se disponibile (`--device cuda`)
- **Scene Detection**: Il metodo 'adaptive' è più veloce di 'content'
- Considera di ridurre la risoluzione per test rapidi

## Riferimenti

- [PySceneDetect Documentation](https://www.scenedetect.com/)
- [DRUNet Paper](https://ieeexplore.ieee.org/document/9503477)
- [Spyrit DRUNet Tutorial](https://spyrit.readthedocs.io/en/2.3.0/gallery/tuto_07_drunet_split_measurements.html)

