# Changelog

All notable changes to FE Media Converter are documented here.
Version numbers refer to `pubspec.yaml` / `snapcraft.yaml`.

## Unreleased

- Removed ~300 emoji from log strings and comments across `lib/`; UI title
  and media-type icons no longer depend on emoji glyphs (Material Icons now).
- Removed dead code: `PixelQualityAnalyzer`, `VapourSynthIntegration`.
- Removed the stale `Windows Ver/` snapshot (version 2.0.2 duplicate tree).
- Cleaned leftover patch-instruction comments (`AGGIUNGI QUESTI CAMPI`,
  `NUOVO:`, `CORREZIONE n:`, `IMPORTANTE:` banners).
- `requirements.txt` no longer pulls PyTorch/CUDA (~7 GB venv); DRUNet runs
  on ONNX Runtime, fresh Python environments are ~900 MB.

## 2.0.6

- Snap rebuilt on `core24` with the GNOME 46 platform and the `gpu-2404`
  wrapper (Mesa via the `mesa-2404` content snap).
- Fixes the `libEGL: DRI_Mesa` startup crash on recent distros
  (verified on Kubuntu 26.04) and the Adwaita `gtk.css`/`color.css` theme error.
- Dropped snap environment overrides that fought `desktop-launch`
  (`TMPDIR`, forced software GL, forced `GTK_THEME`, manual
  `GSETTINGS_SCHEMA_DIR`); kept `GDK_BACKEND=x11` for Plasma/Wayland stability.
- `platforms/amd64` key required by the `core24` base.

## 2.0.5

- DRUNet converted to ONNX: no more PyTorch runtime dependency for AI denoise.
- FFmpeg 9 static binaries and the DRUNet model bundled inside the app;
  no external download needed at runtime.
- Snap: removed broken linker overrides (`ld.gold`/`ld.lld`), dropped unused
  native plugins and the unused `libonnxruntime.so`, added the
  `browser-support` plug, bundled `zenity` for the file picker.
- Editor panels reworked (video/image filters, quality settings), full UI
  translations (EN, IT, FR, DE, ES, PT), FPS sanitizer, Python env setup flow.

## 2.0.2

- `.deb` package with everything integrated under
  `/usr/share/video-converter-pro/`: bundled FFmpeg/`ffprobe`, DRUNet models
  (`.onnx` + `.pth`), `scripts/python` (DRUNet denoiser, scene detector,
  Python environment setup).
- Snap Store support, desktop integration, AppStream metadata.
- Snap confinement handling: snap environment detection, `$HOME` output
  fallback, guided FFmpeg install skipped when bundled.
