import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:video_converter_pro/l10n/app_localizations.dart';
import 'package:video_converter_pro/utils/app_log.dart';

String _upscaleMsg(String key) {
  final lang = Platform.localeName.toLowerCase().split('_').first;
  final l10n = lookupAppLocalizations(Locale(lang));
  switch (key) {
    case 'start':
      return l10n.upscalingWithFfmpeg;
    case 'done':
      return l10n.completed;
    default:
      return key;
  }
}

class ImageUpscalerService {
  bool _initialized = false;

  Future<bool> initialize() async {
    if (_initialized) return true;
    _initialized = true;
    return true;
  }

  Future<String?> upscaleImage(
    String inputPath,
    String outputPath,
    double scaleFactor, {
    void Function(double progress, String message)? onProgress,
  }) async {
    return await _upscaleWithFFmpeg(inputPath, outputPath, scaleFactor, onProgress);
  }

  Future<String?> _upscaleWithFFmpeg(
    String inputPath,
    String outputPath,
    double scaleFactor,
    void Function(double progress, String message)? onProgress,
  ) async {
    try {
      onProgress?.call(0.0, _upscaleMsg('start'));

      final process = await Process.run('ffmpeg', [
        '-y',
        '-i', inputPath,
        '-vf', 'scale=iw*$scaleFactor:ih*$scaleFactor:flags=lanczos',
        outputPath,
      ]);

      onProgress?.call(1.0, _upscaleMsg('done'));

      if (process.exitCode == 0 && File(outputPath).existsSync()) {
        return outputPath;
      } else {
        throw Exception('FFmpeg upscaling fallito: ${process.stderr}');
      }
    } catch (e) {
      appLog('❌ Errore upscaling FFmpeg: $e');
      return null;
    }
  }

  void dispose() {
    _initialized = false;
  }
}
