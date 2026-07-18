import 'dart:io';

class BenchmarkService {
  static const List<String> _orderedPresets = <String>['fast', 'medium', 'high_quality'];

  static Future<Map<String, String>> getSystemSignature({
    required bool useGpu,
    required String gpuType,
    required String preferredCodec,
  }) async {
    final ffmpegInfo = await Process.run('ffmpeg', ['-hide_banner', '-version']);
    final ffmpegLine = ffmpegInfo.stdout.toString().split('\n').first.trim();
    final driver = await _readDriverSignature();

    final encoderDump = await Process.run('ffmpeg', ['-hide_banner', '-encoders']);
    final encoders = encoderDump.stdout.toString();
    final codec = _pickCodec(encoders, useGpu, gpuType, preferredCodec);

    return {
      'ffmpeg': ffmpegLine.isEmpty ? 'unknown' : ffmpegLine,
      'driver': driver,
      'codec': codec,
      'gpuType': gpuType,
      'useGpu': useGpu ? '1' : '0',
    };
  }

  static String flattenSignature(Map<String, String> signature) {
    return '${signature['ffmpeg']}|${signature['driver']}|${signature['codec']}|${signature['gpuType']}|${signature['useGpu']}';
  }

  static Future<Map<String, dynamic>> runUniversalBenchmark({
    required bool useGpu,
    required String gpuType,
    required String preferredCodec,
    void Function(double progress, String phase)? onProgress,
  }) async {
    onProgress?.call(0.03, 'phase.collecting');
    final encoderDump = await Process.run('ffmpeg', ['-hide_banner', '-encoders']);
    final encoders = encoderDump.stdout.toString();
    final codec = _pickCodec(encoders, useGpu, gpuType, preferredCodec);
    final signature = await getSystemSignature(
      useGpu: useGpu,
      gpuType: gpuType,
      preferredCodec: preferredCodec,
    );

    final presets = <String, List<String>>{
      'fast': _codecArgs(codec, 'fast'),
      'medium': _codecArgs(codec, 'medium'),
      'high_quality': _codecArgs(codec, 'high_quality'),
    };

    final results = <String, double>{};
    var i = 0;
    for (final key in _orderedPresets) {
      i++;
      onProgress?.call(0.08 + ((i - 1) / presets.length) * 0.85, 'phase.benchmark_$key');
      final e = MapEntry(key, presets[key]!);
      final fps = await _runCase(codec, e.value);
      if (fps > 0) results[e.key] = fps;
    }
    onProgress?.call(0.98, 'phase.selecting_best');
    if (results.isEmpty) {
      return {
        'success': false,
        'error': 'No benchmark case succeeded',
        'signature': signature,
      };
    }
    final best = results.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    onProgress?.call(1.0, 'phase.done');
    return {
      'success': true,
      'codec': codec,
      'bestPreset': best,
      'scoresFps': results,
      'signature': signature,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  static Future<Map<String, dynamic>> validatePresetCompatibility({
    required bool useGpu,
    required String gpuType,
    required String preferredCodec,
    required String preset,
  }) async {
    final encoderDump = await Process.run('ffmpeg', ['-hide_banner', '-encoders']);
    final encoders = encoderDump.stdout.toString();
    final codec = _pickCodec(encoders, useGpu, gpuType, preferredCodec);
    final args = _codecArgs(codec, preset);
    final fps = await _runCase(codec, args, seconds: 1);
    return {
      'success': fps > 0,
      'codec': codec,
      'preset': preset,
      'fps': fps,
    };
  }

  static Future<double> _runCase(
    String codec,
    List<String> extraArgs, {
    int seconds = 4,
  }) async {
    final args = <String>[
      '-hide_banner',
      '-loglevel',
      'error',
      '-f',
      'lavfi',
      '-i',
      'testsrc2=size=1280x720:rate=60',
      '-t',
      seconds.toString(),
      '-pix_fmt',
      'yuv420p',
      '-c:v',
      codec,
      ...extraArgs,
      '-an',
      '-f',
      'null',
      '-',
    ];
    final sw = Stopwatch()..start();
    final r = await Process.run('ffmpeg', args);
    sw.stop();
    if (r.exitCode != 0) return 0.0;
    final totalFrames = 60.0 * seconds;
    final sec = sw.elapsedMilliseconds / 1000.0;
    if (sec <= 0) return 0.0;
    return totalFrames / sec;
  }

  static String _pickCodec(
    String encoders,
    bool useGpu,
    String gpuType,
    String preferredCodec,
  ) {
    if (!useGpu) {
      if (preferredCodec == 'libx265' && encoders.contains('libx265')) return 'libx265';
      return 'libx264';
    }
    final lowerGpu = gpuType.toLowerCase();
    if ((lowerGpu == 'nvidia' || lowerGpu == 'auto') && encoders.contains('h264_nvenc')) return 'h264_nvenc';
    if ((lowerGpu == 'intel' || lowerGpu == 'auto') && encoders.contains('h264_qsv')) return 'h264_qsv';
    if ((lowerGpu == 'amd' || lowerGpu == 'auto') && encoders.contains('h264_amf')) return 'h264_amf';
    if ((lowerGpu == 'vaapi' || lowerGpu == 'auto') && encoders.contains('h264_vaapi')) return 'h264_vaapi';
    return 'libx264';
  }

  static List<String> _codecArgs(String codec, String preset) {
    if (codec.contains('nvenc')) {
      if (preset == 'fast') return ['-preset', 'p1', '-rc-lookahead', '0', '-tune', 'll'];
      if (preset == 'high_quality') return ['-preset', 'p7', '-rc-lookahead', '24', '-spatial-aq', '1'];
      return ['-preset', 'p4', '-rc-lookahead', '10'];
    }
    if (codec.contains('qsv')) {
      if (preset == 'fast') return ['-preset', 'veryfast', '-look_ahead', '0'];
      if (preset == 'high_quality') return ['-preset', 'slow', '-look_ahead', '1', '-look_ahead_depth', '30'];
      return ['-preset', 'medium', '-look_ahead', '1', '-look_ahead_depth', '16'];
    }
    if (codec.contains('amf')) {
      if (preset == 'fast') return ['-quality', 'speed'];
      if (preset == 'high_quality') return ['-quality', 'quality', '-preanalysis', '1'];
      return ['-quality', 'balanced'];
    }
    if (codec.contains('vaapi')) {
      if (preset == 'fast') return ['-qp', '26', '-low_power', '1'];
      if (preset == 'high_quality') return ['-qp', '18'];
      return ['-qp', '22'];
    }
    if (codec == 'libx265') {
      if (preset == 'fast') return ['-preset', 'superfast'];
      if (preset == 'high_quality') return ['-preset', 'medium'];
      return ['-preset', 'faster'];
    }
    if (preset == 'fast') return ['-preset', 'veryfast'];
    if (preset == 'high_quality') return ['-preset', 'medium'];
    return ['-preset', 'faster'];
  }

  static Future<String> _readDriverSignature() async {
    try {
      final nvidia = await Process.run(
        'nvidia-smi',
        ['--query-gpu=driver_version,name', '--format=csv,noheader'],
      );
      if (nvidia.exitCode == 0) {
        final s = nvidia.stdout.toString().trim();
        if (s.isNotEmpty) return 'nvidia:$s';
      }
    } catch (_) {}

    if (!Platform.isWindows) {
      try {
        final rocm = await Process.run('rocm-smi', ['--showdriverversion']);
        if (rocm.exitCode == 0) {
          final s = rocm.stdout.toString().trim();
          if (s.isNotEmpty) return 'amd:$s';
        }
      } catch (_) {}

      try {
        final vainfo = await Process.run('vainfo', []);
        if (vainfo.exitCode == 0) {
          final first = vainfo.stdout.toString().split('\n').first.trim();
          if (first.isNotEmpty) return 'vaapi:$first';
        }
      } catch (_) {}
    }

    return 'unknown';
  }
}
