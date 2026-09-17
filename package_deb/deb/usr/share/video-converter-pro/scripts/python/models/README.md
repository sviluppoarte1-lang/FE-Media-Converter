# Modelli opzionali (AI)

La cartella predefinita dei modelli è tipicamente `~/.video-converter-pro/models/` (configurabile nelle impostazioni).

## DRUNet (denoising)

Il file atteso è:

```
models/drunet/drunet_model.pth
```

- **All’avvio** l’app verifica la presenza del modello; se manca, avvia un **download automatico** (~125 MB) dai mirror ufficiali (release KAIR `drunet_color.pth`, salvato come `drunet_model.pth`).
- **Manuale**: `python3 scripts/python/download_drunet_model.py --models-dir /percorso/models`
- **Offline**: dopo il primo download il file resta su disco per gli avvii successivi senza rete.

Scene detection e altri script Python usano `requirements.txt` e il venv da `setup_python_env.sh`.
