import 'dart:io';
import 'package:video_converter_pro/utils/app_log.dart';

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
      onProgress?.call(0.0, 'Upscaling con FFmpeg...');

      final process = await Process.run('ffmpeg', [
        '-y',
        '-i', inputPath,
        '-vf', 'scale=iw*$scaleFactor:ih*$scaleFactor:flags=lanczos',
        outputPath,
      ]);

      onProgress?.call(1.0, 'Completato');

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
