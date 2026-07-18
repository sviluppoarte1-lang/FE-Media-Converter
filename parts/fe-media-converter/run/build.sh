#!/bin/bash
set -euo pipefail
source /mnt/a6c06caa-9d13-4102-9582-a292877cb965/Flutter/ultimate_video_converter_pro/parts/fe-media-converter/run/environment.sh
set -x
git clone --depth 1 -b stable https://github.com/flutter/flutter.git /mnt/a6c06caa-9d13-4102-9582-a292877cb965/Flutter/ultimate_video_converter_pro/parts/fe-media-converter/build/flutter-distro
flutter precache --linux
flutter pub get
flutter build linux --release --verbose --target lib/main.dart
cp -r build/linux/*/release/bundle/* $CRAFT_PART_INSTALL/
