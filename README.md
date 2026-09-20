<img width="1283" height="715" alt="1" src="https://github.com/user-attachments/assets/6dadee42-e579-4a82-a50d-205726a8632c" />
<img width="1283" height="715" alt="2" src="https://github.com/user-attachments/assets/3f434969-e3c5-4e05-9ba7-bf65c192d49f" />
<img width="1268" height="711" alt="3" src="https://github.com/user-attachments/assets/a7f4fbda-5eee-4e9d-93e9-842c4c22cc91" />
<img width="1268" height="711" alt="4" src="https://github.com/user-attachments/assets/2c783593-abe7-4164-93f0-ade70a9e6ce8" />
<img width="1268" height="711" alt="5" src="https://github.com/user-attachments/assets/9b883d85-cf68-4096-ad06-13fd0b219447" />
<img width="1268" height="711" alt="6" src="https://github.com/user-attachments/assets/d8044254-01b4-40dd-92b4-eacdafb3cfb2" />

# FE Media Converter

FE Media Converter (Video Converter Pro) is a Linux desktop media toolkit built with Flutter.  
It wraps a powerful FFmpeg-based workflow behind a clean interface so you can convert video, audio, and images, apply advanced filters, and process multiple files in batch without long command-line commands.

Official repository: [https://github.com/sviluppoarte1-lang/Fe-Media-Converter](https://github.com/sviluppoarte1-lang/Fe-Media-Converter)

## Features

- Convert between common video, audio, and image formats
- Batch conversion queue with progress tracking
- Advanced video, audio, and image filter controls
- GPU-accelerated encoding when available (NVIDIA, Intel, AMD, VAAPI, Apple VideoToolbox)
- AI-related enhancement pipeline integration for quality restoration workflows
- In-app dependency checks and guided FFmpeg setup on Linux
- Drag and drop file support
- Multi-language UI support

## Supported Workflows

- **Video conversion** with codec, quality, bitrate, and filter controls
- **Audio extraction** from video and direct audio conversion
- **Image conversion** with resizing, sharpening, denoise, and color adjustments
- **Queue processing** for multiple files and mixed conversion sessions

## Requirements

- Linux (primary target platform)
- FFmpeg installed and available in `PATH`
- Python 3 (required by some advanced processing pipelines)

> The app includes runtime checks for dependencies and can guide users through FFmpeg installation/update steps.



Release bundle output:

`build/linux/x64/release/bundle/`

## Linux Packaging

This project includes scripts for Linux distribution packages:

- Debian package script: `scripts/build_deb.sh`
- RPM package script: `scripts/build_rpm.sh`
- AppImage package script: `scripts/build_appimage.sh`

Metadata files for software centers/AppStream are included under `linux/` and packaging directories.

## Notes

- FFmpeg is the core engine used for transcoding and media processing.
- Some advanced features may require additional Python packages and model files.
- Runtime behavior can vary depending on GPU drivers and installed codec support.

## License

This repository currently does not declare a top-level license file.  
If you plan to distribute or fork the project, add an explicit `LICENSE` file.
