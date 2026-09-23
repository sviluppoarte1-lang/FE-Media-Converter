<img width="1283" height="715" alt="1" src="https://github.com/user-attachments/assets/6dadee42-e579-4a82-a50d-205726a8632c" />
<img width="1283" height="715" alt="2" src="https://github.com/user-attachments/assets/3f434969-e3c5-4e05-9ba7-bf65c192d49f" />
<img width="1268" height="711" alt="3" src="https://github.com/user-attachments/assets/a7f4fbda-5eee-4e9d-93e9-842c4c22cc91" />
<img width="1268" height="711" alt="4" src="https://github.com/user-attachments/assets/2c783593-abe7-4164-93f0-ade70a9e6ce8" />
<img width="1268" height="711" alt="5" src="https://github.com/user-attachments/assets/9b883d85-cf68-4096-ad06-13fd0b219447" />
<img width="1268" height="711" alt="6" src="https://github.com/user-attachments/assets/d8044254-01b4-40dd-92b4-eacdafb3cfb2" />

# FE Media Converter

FE Media Converter (Video Converter Pro) is a Linux desktop media toolkit built with Flutter.
It puts an FFmpeg-based pipeline behind a straightforward interface: batch-convert video, audio
and images, tune quality, and apply professional filters without typing long command lines.

Official repository: [https://github.com/sviluppoarte1-lang/Fe-Media-Converter](https://github.com/sviluppoarte1-lang/Fe-Media-Converter)

## Media modes

- **Video**: mp4, avi, mkv, webm, mov, flv, wmv, mpeg, ts — codecs H.264, HEVC,
  VP8, VP9, MPEG-4, AV1 (plus hardware encoders when available).
- **Audio**: mp3, wav, aac, flac, ogg, m4a, wma, opus — including audio
  extraction from video files.
- **Image**: jpg, jpeg, png, webp, bmp, tiff, heic — with resize, custom
  resolution and AI upscaling options.

## Conversion workflow

- Batch queue with pause, resume, stop and concurrent jobs, progress tracking,
  time remaining and per-task error reporting.
- Constant quality (CRF) or target bitrate modes, with a benchmark service
  that validates preset compatibility against your system.
- Add files via picker, drag and drop, or by opening media with the app
  (file arguments are passed through to the queue).
- Dependency check screen with guided FFmpeg install, in-app user guide,
  and a persistent application log for troubleshooting.

## Video filters

Denoise (strength, temporal, method), sharpening (unsharp mask, adaptive,
edge), brightness, contrast, saturation, gamma, stabilization, deinterlace,
color profiles and cinematic presets, curves, HSV controls, RGB color balance,
film grain, HDR tone mapping, debanding, artifact removal and compression
cleanup, chroma upsampling control, vibrance, texture boost and detail
enhancement.

## GPU acceleration

Optional hardware encoding with automatic capability detection: NVIDIA NVENC,
Intel Quick Sync, AMD AMF, with per-vendor encoding presets. Falls back to
software encoding when the GPU or driver cannot handle the job.

## AI tools (optional)

- **DRUNet denoise / deblur / upscale / JPEG restore** running on ONNX Runtime
  (CPU, CUDA provider when available), with OpenCV fallback when no model
  or runtime is present. Models are bundled with the packages.
- **Scene detection and splitting** via PySceneDetect, plus analysis helpers
  used for conversion presets.
- First-launch dialogs set up the Python environment and models for you;
  everything is managed from the models panel.

## Audio tools

Volume, 10-band graphic equalizer with presets (flat, bass/treble boost,
voice, rock, pop, jazz, classical), loudness normalization, noise removal
with threshold, dynamic compression and reverb.

## Appearance and languages

Light, dark and system themes. UI translations included for English, Italian,
French, German, Spanish and Portuguese, with first-launch language selection.

## Install

### Snap (recommended)

```bash
sudo snap install fe-media-converter
```

FFmpeg, models and helpers are bundled inside the snap — nothing else to install.

### Debian package

Install `video-converter-pro_*_amd64.deb` from the releases page. Everything
is integrated under `/usr/share/video-converter-pro/` (bundled FFmpeg,
DRUNet models, Python scripts); system dependencies are pulled in via apt.
The optional Python environment (~900 MB with NumPy, OpenCV, ONNX Runtime,
PySceneDetect) is created on first launch.

## Build from source

Requirements: Flutter stable with Linux desktop enabled, `cmake`, `ninja`,
`clang`, `libgtk-3-dev`, `liblzma-dev`.

```bash
flutter pub get
flutter build linux --release
```

The bundle lands in `build/linux/x64/release/bundle/`. Snap builds use
`snapcraft` (see `snapcraft.yaml`); Debian and AppImage helpers live in
`package_deb/` and `scripts/`.

## Notes

- FFmpeg is the core transcoding engine.
- Advanced AI features need the Python environment described above.
- Behavior can vary with GPU drivers and installed codec support —
  check the in-app log if a conversion fails.

## License

MIT — see [LICENSE.md](LICENSE.md). Bundled third-party components
(FFmpeg, Python packages, Flutter SDK) keep their own licenses.
