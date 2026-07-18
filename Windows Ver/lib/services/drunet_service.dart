import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:video_converter_pro/utils/app_log.dart';
import 'package:video_converter_pro/utils/processing_fps_sanitize.dart';
import 'package:video_converter_pro/utils/platform_paths.dart';

class DRUNetService {
  static String _getAppDirectory() {
    try {
      final executable = Platform.resolvedExecutable;
      final executableDir = path.dirname(executable);
      if (Platform.isLinux) {
        if (executableDir.contains('/usr/share/video-converter-pro')) {
          return '/usr/share/video-converter-pro';
        }
      } else if (Platform.isWindows) {
        if (executableDir.contains('video-converter-pro')) {
          return executableDir;
        }
      }
      var dir = executableDir;
      for (int i = 0; i < 12; i++) {
        final scriptsPath = path.join(dir, 'scripts', 'python');
        if (Directory(scriptsPath).existsSync()) return dir;
        final parent = path.dirname(dir);
        if (parent == dir) break;
        dir = parent;
      }
      return Directory.current.path;
    } catch (e) {
      return Directory.current.path;
    }
  }

  static String _getScriptsDirectory() {
    final appDir = _getAppDirectory();
    final scriptsPath = path.join(appDir, 'scripts', 'python');
    if (Directory(scriptsPath).existsSync()) return scriptsPath;
    return path.join(Directory.current.path, 'scripts', 'python');
  }

  static String get _scriptPath => path.join(_getScriptsDirectory(), 'drunet_denoiser.py');
  static String get _venvPath => path.join(_getScriptsDirectory(), 'venv');
  static String get _setupScriptPath =>
      path.join(_getScriptsDirectory(), PlatformPaths.setupScriptName);

  static int _recommendedWorkers({bool gpuLikely = false}) {
    final n = Platform.numberOfProcessors.clamp(1, 64);
    if (gpuLikely) return 1;
    return (n ~/ 2).clamp(2, 16);
  }

  static Future<String> _getPythonExecutable() async {
    final venvPython = File(PlatformPaths.getVenvPythonPath(_getScriptsDirectory()));
    if (await venvPython.exists()) {
      return venvPython.absolute.path;
    }
    return PlatformPaths.pythonFallback;
  }

  static Future<bool> checkDependencies() async {
    try {
      final pythonExe = await _getPythonExecutable();

      final pythonCheck = await Process.run(pythonExe, ['--version']);
      if (pythonCheck.exitCode != 0) {
        return false;
      }

      final scriptFile = File(_scriptPath);
      if (!await scriptFile.exists()) {
        return false;
      }

      final importCheck = await Process.run(pythonExe, [
        '-c',
        'import numpy, cv2; print("OK")',
      ]);

      return importCheck.exitCode == 0;
    } catch (e) {
      appLog('� [DRUNet] Dependency check failed: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> installDependencies({
    void Function(String message)? onProgress,
  }) async {
    try {
      final setup = File(_setupScriptPath);
      if (!await setup.exists()) {
        return {'success': false, 'error': '${PlatformPaths.setupScriptName} not found'};
      }
      onProgress?.call('start');

      final int exitCode;
      if (Platform.isWindows) {
        final r = await Process.run('cmd.exe', ['/c', _setupScriptPath]);
        exitCode = r.exitCode;
      } else {
        await Process.run('chmod', ['+x', _setupScriptPath]);
        final r = await Process.run('bash', [_setupScriptPath]);
        exitCode = r.exitCode;
      }

      if (exitCode != 0) {
        return {'success': false, 'error': 'Setup script failed with exit code $exitCode'};
      }
      onProgress?.call('done');
      final ready = await checkDependencies();
      return {
        'success': ready,
        'error': ready ? null : 'Dependencies still missing after setup',
      };
    } catch (e) {
      return {'success': false, 'error': 'Dependency setup error: $e'};
    }
  }

  static Future<Map<String, dynamic>> denoiseFrame({
    required String framePath,
    required String outputPath,
    int noiseLevel = 7,
    String? modelPath,
    String device = 'auto',
  }) async {
    try {
      final scriptFile = File(_scriptPath);
      if (!await scriptFile.exists()) {
        return {
          'success': false,
          'error': 'DRUNet script not found. Please ensure Python dependencies are installed.'
        };
      }

      if (!Platform.isWindows) {
        await Process.run('chmod', ['+x', _scriptPath]);
      }

      final pythonExe = await _getPythonExecutable();

      final args = [
        _scriptPath,
        '--input', framePath,
        '--output', outputPath,
        '--noise-level', noiseLevel.toString(),
        '--device', device,
        '--workers', _recommendedWorkers(gpuLikely: device != 'cpu').toString(),
      ];

      if (modelPath != null && modelPath.isNotEmpty) {
        args.addAll(['--model-path', modelPath]);
      }

      appLog('� [DRUNet] Denoising frame: $framePath');
      appLog('   \u2192 Python: $pythonExe');
      appLog('   \u2192 Noise level: $noiseLevel');

      final n = Platform.numberOfProcessors.clamp(1, 32).toString();
      final env = Map<String, String>.from(Platform.environment);
      env['OMP_NUM_THREADS'] = n;
      env['MKL_NUM_THREADS'] = n;
      env['OPENBLAS_NUM_THREADS'] = n;
      final process = await Process.run(
        pythonExe,
        args,
        environment: env,
      );

      if (process.exitCode != 0) {
        final errorOutput = process.stderr.toString();
        appLog('� [DRUNet] Error: $errorOutput');
        return {
          'success': false,
          'error': errorOutput.isNotEmpty ? errorOutput : 'Unknown error during denoising'
        };
      }

      final output = process.stdout.toString().trim();
      if (output.isEmpty) {
        return {
          'success': false,
          'error': 'No output from DRUNet script'
        };
      }

      try {
        final result = json.decode(output) as Map<String, dynamic>;
        if (result['success'] == true) {
          appLog('� [DRUNet] Frame denoised successfully: $outputPath');
        }
        return result;
      } catch (e) {
        return {
          'success': false,
          'error': 'Failed to parse DRUNet output: $e'
        };
      }
    } catch (e) {
      appLog('� [DRUNet] Exception: $e');
      return {
        'success': false,
        'error': 'Exception during denoising: $e'
      };
    }
  }

  static Future<Map<String, dynamic>> denoiseFrames({
    required List<String> framePaths,
    required String outputDir,
    int noiseLevel = 7,
    String? modelPath,
    String device = 'auto',
    void Function(int current, int total)? onProgress,
  }) async {
    try {
      if (framePaths.isEmpty) {
        return {'success': false, 'error': 'no frames'};
      }
      final scriptFile = File(_scriptPath);
      if (!await scriptFile.exists()) {
        return {
          'success': false,
          'error': 'DRUNet script not found',
        };
      }
      final work = await Directory.systemTemp.createTemp('drunet_batch_in_');
      final inDir = work.path;
      var i = 0;
      for (final fp in framePaths) {
        i++;
        onProgress?.call(i, framePaths.length);
        final dest = path.join(inDir, path.basename(fp));
        await File(fp).copy(dest);
      }
      final pythonExe = await _getPythonExecutable();
      final args = <String>[
        _scriptPath,
        '--batch-dir',
        inDir,
        outputDir,
        '--noise-level',
        noiseLevel.toString(),
        '--device',
        device,
        '--workers',
        _recommendedWorkers(gpuLikely: device != 'cpu').toString(),
      ];
      if (modelPath != null && modelPath.isNotEmpty) {
        args.addAll(['--model-path', modelPath]);
      }
      final proc = await Process.run(pythonExe, args);
      try {
        await work.delete(recursive: true);
      } catch (_) {}
      if (proc.exitCode != 0) {
        return {
          'success': false,
          'error': proc.stderr.toString().trim().isEmpty
              ? proc.stdout.toString()
              : proc.stderr.toString(),
        };
      }
      final out = proc.stdout.toString().trim();
      if (out.isEmpty) {
        return {'success': false, 'error': 'empty Python stdout'};
      }
      final j = json.decode(out) as Map<String, dynamic>;
      final ok = j['success'] == true;
      return {
        'success': ok,
        'total_frames': framePaths.length,
        'success_count': j['frames_ok'] ?? (ok ? framePaths.length : 0),
        'fail_count': ok ? 0 : framePaths.length,
        'output_dir': outputDir,
        'raw': j,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Exception during batch denoising: $e'
      };
    }
  }

  static Future<double?> _probeVideoFps(String inputVideo) async {
    try {
      final r = await Process.run('ffprobe', [
        '-v', '0',
        '-of', 'csv=p=0',
        '-select_streams', 'v:0',
        '-show_entries', 'stream=avg_frame_rate',
        inputVideo,
      ]);
      if (r.exitCode != 0) return null;
      final s = r.stdout.toString().trim();
      final parts = s.split('/');
      if (parts.length == 2) {
        final a = double.tryParse(parts[0]);
        final b = double.tryParse(parts[1]);
        if (a != null && b != null && b != 0) return a / b;
      }
      return double.tryParse(s);
    } catch (_) {
      return null;
    }
  }

  static Future<double?> _probeVideoDurationSec(String inputVideo) async {
    try {
      final r = await Process.run('ffprobe', [
        '-v', 'error',
        '-show_entries', 'format=duration',
        '-of', 'default=noprint_wrappers=1:nokey=1',
        inputVideo,
      ]);
      if (r.exitCode != 0) return null;
      return double.tryParse(r.stdout.toString().trim());
    } catch (_) {
      return null;
    }
  }

  static double? _stderrFfmpegFps(String line) {
    final m = RegExp(r'\bfps=\s*([0-9]+(?:\.[0-9]+)?)').firstMatch(line);
    if (m == null) return null;
    final v = double.tryParse(m.group(1)!);
    if (v == null || v <= 0) return null;
    return v;
  }

  static double? _stderrFfmpegTimeSec(String line) {
    final m = RegExp(r'\btime=(\d{2}):(\d{2}):(\d{2})\.(\d{2})\b').firstMatch(line);
    if (m == null) return null;
    final h = int.tryParse(m.group(1)!) ?? 0;
    final min = int.tryParse(m.group(2)!) ?? 0;
    final s = int.tryParse(m.group(3)!) ?? 0;
    final cs = int.tryParse(m.group(4)!) ?? 0;
    return h * 3600 + min * 60 + s + cs / 100;
  }

  static int _countImageFramesInDir(Directory d) {
    var n = 0;
    for (final e in d.listSync()) {
      if (e is! File) continue;
      final p = e.path.toLowerCase();
      if (p.endsWith('.png') || p.endsWith('.jpg') || p.endsWith('.jpeg')) n++;
    }
    return n;
  }

  static Future<int> _runFfmpegStreaming(
    List<String> command,
    void Function(String line) onStderrLine,
  ) async {
    final proc = await Process.start(command[0], command.sublist(1));
    unawaited(proc.stdout.drain());
    await for (final line in proc.stderr.transform(utf8.decoder).transform(const LineSplitter())) {
      onStderrLine(line);
    }
    return proc.exitCode;
  }

  static Future<Map<String, dynamic>> denoiseVideoFull({
    required String inputVideo,
    required String outputVideo,
    int noiseLevel = 7,
    String? modelPath,
    String device = 'auto',
    void Function(double progress, {double? processingFps})? onProgress,
  }) async {
    Directory? workDir;
    try {
      final scriptFile = File(_scriptPath);
      if (!await scriptFile.exists()) {
        return {
          'success': false,
          'error': 'drunet_denoiser.py not found under scripts/python',
        };
      }
      onProgress?.call(0.02);
      workDir = await Directory.systemTemp.createTemp('fe_drunet_vid_');
      final root = workDir.path;
      final framesIn = Directory(path.join(root, 'in'));
      final framesOut = Directory(path.join(root, 'out'));
      await framesIn.create(recursive: true);
      await framesOut.create(recursive: true);

      final durationSec = await _probeVideoDurationSec(inputVideo);
      var exLastTimeSec = 0.0;
      var exLastWall = DateTime.now();
      var exTimeStarted = false;
      double? exWallFps;

      void onExtractLine(String line) {
        final fpsInline =
            ProcessingFpsSanitize.fromReported(_stderrFfmpegFps(line));
        final t = _stderrFfmpegTimeSec(line);
        if (t != null) {
          final now = DateTime.now();
          if (!exTimeStarted) {
            exTimeStarted = true;
            exLastTimeSec = t;
            exLastWall = now;
          } else {
            final wallDt = now.difference(exLastWall).inMicroseconds / 1e6;
            final inst = ProcessingFpsSanitize.fromMediaTimeDelta(
              prevTimeSec: exLastTimeSec,
              timeSec: t,
              wallDtSec: wallDt,
            );
            if (inst != null) {
              exWallFps = exWallFps == null
                  ? inst
                  : (exWallFps! * 0.75 + inst * 0.25);
            }
            exLastTimeSec = t;
            exLastWall = now;
          }
        }
        final fps = fpsInline ?? exWallFps;
        var p = 0.02;
        if (durationSec != null && durationSec > 0 && t != null) {
          p = (0.02 + (t / durationSec).clamp(0.0, 1.0) * 0.12).clamp(0.02, 0.14);
        }
        if (fps != null || (durationSec != null && t != null)) {
          onProgress?.call(p, processingFps: fps);
        }
      }

      final extractCmd = [
        'ffmpeg',
        '-y',
        '-hwaccel',
        'auto',
        '-i',
        inputVideo,
        '-vsync',
        '0',
        '-threads',
        Platform.numberOfProcessors.clamp(1, 32).toString(),
        path.join(framesIn.path, '%06d.png'),
      ];
      final extractCode = await _runFfmpegStreaming(extractCmd, onExtractLine);
      if (extractCode != 0) {
        return {
          'success': false,
          'error': 'ffmpeg frame extract failed (exit $extractCode)',
        };
      }
      onProgress?.call(0.15);

      final pythonExe = await _getPythonExecutable();
      final args = <String>[
        _scriptPath,
        '--batch-dir',
        framesIn.path,
        framesOut.path,
        '--noise-level',
        noiseLevel.toString(),
        '--device',
        device,
        '--workers',
        _recommendedWorkers(gpuLikely: device != 'cpu').toString(),
      ];
      if (modelPath != null && modelPath.isNotEmpty) {
        args.addAll(['--model-path', modelPath]);
      }

      final proc = await Process.start(pythonExe, args);
      final outBuf = StringBuffer();
      final errBuf = StringBuffer();
      await Future.wait([
        proc.stderr
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .forEach((line) {
          errBuf.writeln(line);
          if (line.startsWith('FE_PROGRESS ')) {
            final rest = line.substring(12).trim().split(RegExp(r'\s+'));
            if (rest.length >= 3) {
              final cur = int.tryParse(rest[0]);
              final tot = int.tryParse(rest[1]);
              final fp = double.tryParse(rest[2]);
              if (cur != null && tot != null && tot > 0 && fp != null) {
                final sub = cur / tot;
                final p = 0.15 + sub * 0.60;
                final safeFps = ProcessingFpsSanitize.fromReported(fp);
                onProgress?.call(
                  p.clamp(0.15, 0.74),
                  processingFps: safeFps,
                );
              }
            }
          }
        }),
        proc.stdout
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .forEach((line) => outBuf.writeln(line)),
      ]);
      final denCode = await proc.exitCode;
      if (denCode != 0) {
        return {
          'success': false,
          'error': errBuf.toString().trim().isEmpty
              ? outBuf.toString().trim()
              : errBuf.toString().trim(),
        };
      }

      Map<String, dynamic>? pyJson;
      final lines = outBuf.toString().trim().split('\n');
      for (var i = lines.length - 1; i >= 0; i--) {
        final t = lines[i].trim();
        if (t.isEmpty) continue;
        try {
          pyJson = json.decode(t) as Map<String, dynamic>;
          break;
        } catch (_) {}
      }
      if (pyJson == null || pyJson['success'] != true) {
        return {
          'success': false,
          'error': pyJson?['error']?.toString() ?? 'invalid Python batch output',
        };
      }
      onProgress?.call(0.75);

      final fps = (await _probeVideoFps(inputVideo)) ?? 25.0;
      final encoders = await Process.run('ffmpeg', ['-hide_banner', '-encoders']);
      final eout = encoders.stdout.toString();
      final videoCodec = eout.contains('h264_nvenc')
          ? 'h264_nvenc'
          : eout.contains('h264_qsv')
              ? 'h264_qsv'
              : eout.contains('h264_amf')
                  ? 'h264_amf'
                  : eout.contains('h264_mf')
                      ? 'h264_mf'
                      : eout.contains('h264_vaapi')
                          ? 'h264_vaapi'
                          : 'libx264';
      final codecArgs = <String>[];
      if (videoCodec == 'h264_nvenc') {
        codecArgs.addAll(['-preset', 'p4', '-rc', 'vbr', '-cq', '19']);
      } else if (videoCodec == 'libx264') {
        codecArgs.addAll(['-crf', '16', '-preset', 'veryfast']);
      }

      final muxTotal = _countImageFramesInDir(framesOut);
      if (muxTotal == 0) {
        return {'success': false, 'error': 'no denoised frames for remux'};
      }
      var muxLastFrame = 0;
      var muxLastWall = DateTime.now();
      double? muxFrameFps;

      void onMuxLine(String line) {
        final fpsInline =
            ProcessingFpsSanitize.fromReported(_stderrFfmpegFps(line));
        final fm = RegExp(r'\bframe=\s*([0-9]+)').firstMatch(line);
        int? fn;
        if (fm != null) fn = int.tryParse(fm.group(1)!);
        final now = DateTime.now();
        if (fn != null && fn > muxLastFrame) {
          final dt = now.difference(muxLastWall).inMicroseconds / 1e6;
          if (muxLastFrame > 0 && dt >= 0.4) {
            final inst = ProcessingFpsSanitize.fromReported(
              (fn - muxLastFrame) / dt,
            );
            if (inst != null) {
              muxFrameFps = muxFrameFps == null
                  ? inst
                  : (muxFrameFps! * 0.75 + inst * 0.25);
            }
          }
          muxLastFrame = fn;
          muxLastWall = now;
        }
        final fpsOut = fpsInline ?? muxFrameFps;
        final frac = fn != null ? (fn / muxTotal).clamp(0.0, 1.0) : 0.0;
        final p = (0.75 + frac * 0.24).clamp(0.75, 0.995);
        if (fpsOut != null || fn != null) {
          onProgress?.call(p, processingFps: fpsOut);
        }
      }

      final muxCmd = [
        'ffmpeg',
        '-y',
        '-framerate',
        fps.toString(),
        '-start_number',
        '1',
        '-i',
        path.join(framesOut.path, '%06d.png'),
        '-i',
        inputVideo,
        '-map',
        '0:v',
        '-map',
        '1:a?',
        '-c:v',
        videoCodec,
        ...codecArgs,
        '-pix_fmt',
        'yuv420p',
        '-c:a',
        'copy',
        '-shortest',
        outputVideo,
      ];
      final muxCode = await _runFfmpegStreaming(muxCmd, onMuxLine);
      if (muxCode != 0) {
        return {
          'success': false,
          'error': 'ffmpeg remux failed (exit $muxCode)',
        };
      }
      onProgress?.call(1.0);
      return {'success': true, 'output_path': outputVideo};
    } catch (e) {
      return {
        'success': false,
        'error': 'Exception during video denoising: $e',
      };
    } finally {
      if (workDir != null) {
        try {
          if (workDir.existsSync()) await workDir.delete(recursive: true);
        } catch (_) {}
      }
    }
  }

  static Future<Map<String, dynamic>> denoiseVideo({
    required String inputVideo,
    required String outputVideo,
    int noiseLevel = 7,
    String? modelPath,
    String device = 'auto',
    void Function(double progress, {double? processingFps})? onProgress,
  }) {
    return denoiseVideoFull(
      inputVideo: inputVideo,
      outputVideo: outputVideo,
      noiseLevel: noiseLevel,
      modelPath: modelPath,
      device: device,
      onProgress: onProgress,
    );
  }

  static Future<Map<String, dynamic>> processFrame({
    required String framePath,
    required String outputPath,
    String mode = 'denoise',
    int noiseLevel = 7,
    double upscaleFactor = 2.0,
    double deblurStrength = 0.5,
    String? modelPath,
    String device = 'auto',
  }) async {
    try {
      final scriptFile = File(_scriptPath);
      if (!await scriptFile.exists()) {
        return {
          'success': false,
          'error': 'DRUNet script not found. Please ensure Python dependencies are installed.'
        };
      }

      if (!Platform.isWindows) {
        await Process.run('chmod', ['+x', _scriptPath]);
      }

      final pythonExe = await _getPythonExecutable();

      final args = [
        _scriptPath,
        '--mode', mode,
        '--input', framePath,
        '--output', outputPath,
        '--noise-level', noiseLevel.toString(),
        '--device', device,
        '--workers', _recommendedWorkers(gpuLikely: device != 'cpu').toString(),
      ];
      if (mode == 'upscale') {
        args.addAll(['--upscale-factor', upscaleFactor.toStringAsFixed(1)]);
      }
      if (mode == 'deblur') {
        args.addAll(['--deblur-strength', deblurStrength.toStringAsFixed(2)]);
      }
      if (modelPath != null && modelPath.isNotEmpty) {
        args.addAll(['--model-path', modelPath]);
      }

      final n = Platform.numberOfProcessors.clamp(1, 32).toString();
      final env = Map<String, String>.from(Platform.environment);
      env['OMP_NUM_THREADS'] = n;
      env['MKL_NUM_THREADS'] = n;
      env['OPENBLAS_NUM_THREADS'] = n;
      final process = await Process.run(pythonExe, args, environment: env);

      if (process.exitCode != 0) {
        final errorOutput = process.stderr.toString();
        return {
          'success': false,
          'error': errorOutput.isNotEmpty ? errorOutput : 'Unknown error during $mode processing'
        };
      }

      final output = process.stdout.toString().trim();
      if (output.isEmpty) {
        return {'success': false, 'error': 'No output from DRUNet script'};
      }

      try {
        final result = json.decode(output) as Map<String, dynamic>;
        if (result['success'] == true) {
          appLog('✅ [DRUNet] Frame processed (mode: $mode): $outputPath');
        }
        return result;
      } catch (e) {
        return {'success': false, 'error': 'Failed to parse DRUNet output: $e'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Exception during $mode processing: $e'};
    }
  }

  static Future<Map<String, dynamic>> processFrames({
    required List<String> framePaths,
    required String outputDir,
    String mode = 'denoise',
    int noiseLevel = 7,
    double upscaleFactor = 2.0,
    double deblurStrength = 0.5,
    String? modelPath,
    String device = 'auto',
    void Function(int current, int total)? onProgress,
  }) async {
    try {
      if (framePaths.isEmpty) {
        return {'success': false, 'error': 'no frames'};
      }
      final scriptFile = File(_scriptPath);
      if (!await scriptFile.exists()) {
        return {'success': false, 'error': 'DRUNet script not found'};
      }
      final work = await Directory.systemTemp.createTemp('drunet_batch_in_');
      final inDir = work.path;
      var i = 0;
      for (final fp in framePaths) {
        i++;
        onProgress?.call(i, framePaths.length);
        final dest = path.join(inDir, path.basename(fp));
        await File(fp).copy(dest);
      }
      final pythonExe = await _getPythonExecutable();
      final args = <String>[
        _scriptPath,
        '--mode', mode,
        '--batch-dir', inDir, outputDir,
        '--noise-level', noiseLevel.toString(),
        '--device', device,
        '--workers', _recommendedWorkers(gpuLikely: device != 'cpu').toString(),
      ];
      if (mode == 'upscale') {
        args.addAll(['--upscale-factor', upscaleFactor.toStringAsFixed(1)]);
      }
      if (mode == 'deblur') {
        args.addAll(['--deblur-strength', deblurStrength.toStringAsFixed(2)]);
      }
      if (modelPath != null && modelPath.isNotEmpty) {
        args.addAll(['--model-path', modelPath]);
      }
      final proc = await Process.run(pythonExe, args);
      try {
        await work.delete(recursive: true);
      } catch (_) {}
      if (proc.exitCode != 0) {
        return {
          'success': false,
          'error': proc.stderr.toString().trim().isEmpty
              ? proc.stdout.toString()
              : proc.stderr.toString(),
        };
      }
      final out = proc.stdout.toString().trim();
      if (out.isEmpty) {
        return {'success': false, 'error': 'empty Python stdout'};
      }
      final j = json.decode(out) as Map<String, dynamic>;
      final ok = j['success'] == true;
      return {
        'success': ok,
        'total_frames': framePaths.length,
        'success_count': j['frames_ok'] ?? (ok ? framePaths.length : 0),
        'fail_count': ok ? 0 : framePaths.length,
        'output_dir': outputDir,
        'mode': mode,
        'raw': j,
      };
    } catch (e) {
      return {'success': false, 'error': 'Exception during batch processing: $e'};
    }
  }

  static Future<Map<String, dynamic>> processVideoFull({
    required String inputVideo,
    required String outputVideo,
    String mode = 'denoise',
    int noiseLevel = 7,
    double upscaleFactor = 2.0,
    double deblurStrength = 0.5,
    String? modelPath,
    String device = 'auto',
    void Function(double progress, {double? processingFps})? onProgress,
  }) async {
    Directory? workDir;
    try {
      final scriptFile = File(_scriptPath);
      if (!await scriptFile.exists()) {
        return {
          'success': false,
          'error': 'drunet_denoiser.py not found under scripts/python',
        };
      }
      onProgress?.call(0.02);
      workDir = await Directory.systemTemp.createTemp('fe_drunet_vid_');
      final root = workDir.path;
      final framesIn = Directory(path.join(root, 'in'));
      final framesOut = Directory(path.join(root, 'out'));
      await framesIn.create(recursive: true);
      await framesOut.create(recursive: true);

      final durationSec = await _probeVideoDurationSec(inputVideo);
      var exLastTimeSec = 0.0;
      var exLastWall = DateTime.now();
      var exTimeStarted = false;
      double? exWallFps;

      void onExtractLine(String line) {
        final fpsInline = ProcessingFpsSanitize.fromReported(_stderrFfmpegFps(line));
        final t = _stderrFfmpegTimeSec(line);
        if (t != null) {
          final now = DateTime.now();
          if (!exTimeStarted) {
            exTimeStarted = true;
            exLastTimeSec = t;
            exLastWall = now;
          } else {
            final wallDt = now.difference(exLastWall).inMicroseconds / 1e6;
            final inst = ProcessingFpsSanitize.fromMediaTimeDelta(
              prevTimeSec: exLastTimeSec,
              timeSec: t,
              wallDtSec: wallDt,
            );
            if (inst != null) {
              exWallFps = exWallFps == null ? inst : (exWallFps! * 0.75 + inst * 0.25);
            }
            exLastTimeSec = t;
            exLastWall = now;
          }
        }
        final fps = fpsInline ?? exWallFps;
        var p = 0.02;
        if (durationSec != null && durationSec > 0 && t != null) {
          p = (0.02 + (t / durationSec).clamp(0.0, 1.0) * 0.12).clamp(0.02, 0.14);
        }
        if (fps != null || (durationSec != null && t != null)) {
          onProgress?.call(p, processingFps: fps);
        }
      }

      final extractCmd = [
        'ffmpeg', '-y', '-hwaccel', 'auto', '-i', inputVideo,
        '-vsync', '0',
        '-threads', Platform.numberOfProcessors.clamp(1, 32).toString(),
        path.join(framesIn.path, '%06d.png'),
      ];
      final extractCode = await _runFfmpegStreaming(extractCmd, onExtractLine);
      if (extractCode != 0) {
        return {'success': false, 'error': 'ffmpeg frame extract failed (exit $extractCode)'};
      }
      onProgress?.call(0.15);

      final pythonExe = await _getPythonExecutable();
      final args = <String>[
        _scriptPath,
        '--mode', mode,
        '--batch-dir', framesIn.path, framesOut.path,
        '--noise-level', noiseLevel.toString(),
        '--device', device,
        '--workers', _recommendedWorkers(gpuLikely: device != 'cpu').toString(),
      ];
      if (mode == 'upscale') {
        args.addAll(['--upscale-factor', upscaleFactor.toStringAsFixed(1)]);
      }
      if (mode == 'deblur') {
        args.addAll(['--deblur-strength', deblurStrength.toStringAsFixed(2)]);
      }
      if (modelPath != null && modelPath.isNotEmpty) {
        args.addAll(['--model-path', modelPath]);
      }

      final proc = await Process.start(pythonExe, args);
      final outBuf = StringBuffer();
      final errBuf = StringBuffer();
      await Future.wait([
        proc.stderr
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .forEach((line) {
          errBuf.writeln(line);
          if (line.startsWith('FE_PROGRESS ')) {
            final rest = line.substring(12).trim().split(RegExp(r'\s+'));
            if (rest.length >= 3) {
              final cur = int.tryParse(rest[0]);
              final tot = int.tryParse(rest[1]);
              final fp = double.tryParse(rest[2]);
              if (cur != null && tot != null && tot > 0 && fp != null) {
                final sub = cur / tot;
                final p = 0.15 + sub * 0.60;
                final safeFps = ProcessingFpsSanitize.fromReported(fp);
                onProgress?.call(p.clamp(0.15, 0.74), processingFps: safeFps);
              }
            }
          }
        }),
        proc.stdout
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .forEach((line) => outBuf.writeln(line)),
      ]);
      final denCode = await proc.exitCode;
      if (denCode != 0) {
        return {
          'success': false,
          'error': errBuf.toString().trim().isEmpty
              ? outBuf.toString().trim()
              : errBuf.toString().trim(),
        };
      }

      Map<String, dynamic>? pyJson;
      final lines = outBuf.toString().trim().split('\n');
      for (var i = lines.length - 1; i >= 0; i--) {
        final t = lines[i].trim();
        if (t.isEmpty) continue;
        try {
          pyJson = json.decode(t) as Map<String, dynamic>;
          break;
        } catch (_) {}
      }
      if (pyJson == null || pyJson['success'] != true) {
        return {
          'success': false,
          'error': pyJson?['error']?.toString() ?? 'invalid Python batch output',
        };
      }
      onProgress?.call(0.75);

      final fps = (await _probeVideoFps(inputVideo)) ?? 25.0;
      final encoders = await Process.run('ffmpeg', ['-hide_banner', '-encoders']);
      final eout = encoders.stdout.toString();
      final videoCodec = eout.contains('h264_nvenc')
          ? 'h264_nvenc'
          : eout.contains('h264_qsv')
              ? 'h264_qsv'
              : eout.contains('h264_amf')
                  ? 'h264_amf'
                  : eout.contains('h264_mf')
                      ? 'h264_mf'
                      : eout.contains('h264_vaapi')
                          ? 'h264_vaapi'
                          : 'libx264';
      final codecArgs = <String>[];
      if (videoCodec == 'h264_nvenc') {
        codecArgs.addAll(['-preset', 'p4', '-rc', 'vbr', '-cq', '19']);
      } else if (videoCodec == 'libx264') {
        codecArgs.addAll(['-crf', '16', '-preset', 'veryfast']);
      }

      final muxTotal = _countImageFramesInDir(framesOut);
      if (muxTotal == 0) {
        return {'success': false, 'error': 'no processed frames for remux'};
      }
      var muxLastFrame = 0;
      var muxLastWall = DateTime.now();
      double? muxFrameFps;

      void onMuxLine(String line) {
        final fpsInline = ProcessingFpsSanitize.fromReported(_stderrFfmpegFps(line));
        final fm = RegExp(r'\bframe=\s*([0-9]+)').firstMatch(line);
        int? fn;
        if (fm != null) fn = int.tryParse(fm.group(1)!);
        final now = DateTime.now();
        if (fn != null && fn > muxLastFrame) {
          final dt = now.difference(muxLastWall).inMicroseconds / 1e6;
          if (muxLastFrame > 0 && dt >= 0.4) {
            final inst = ProcessingFpsSanitize.fromReported((fn - muxLastFrame) / dt);
            if (inst != null) {
              muxFrameFps = muxFrameFps == null ? inst : (muxFrameFps! * 0.75 + inst * 0.25);
            }
          }
          muxLastFrame = fn;
          muxLastWall = now;
        }
        final fpsOut = fpsInline ?? muxFrameFps;
        final frac = fn != null ? (fn / muxTotal).clamp(0.0, 1.0) : 0.0;
        final p = (0.75 + frac * 0.24).clamp(0.75, 0.995);
        if (fpsOut != null || fn != null) {
          onProgress?.call(p, processingFps: fpsOut);
        }
      }

      final muxCmd = [
        'ffmpeg', '-y',
        '-framerate', fps.toString(),
        '-start_number', '1',
        '-i', path.join(framesOut.path, '%06d.png'),
        '-i', inputVideo,
        '-map', '0:v',
        '-map', '1:a?',
        '-c:v', videoCodec,
        ...codecArgs,
        '-pix_fmt', 'yuv420p',
        '-c:a', 'copy',
        '-shortest',
        outputVideo,
      ];
      final muxCode = await _runFfmpegStreaming(muxCmd, onMuxLine);
      if (muxCode != 0) {
        return {'success': false, 'error': 'ffmpeg remux failed (exit $muxCode)'};
      }
      onProgress?.call(1.0);
      return {'success': true, 'output_path': outputVideo};
    } catch (e) {
      return {'success': false, 'error': 'Exception during video processing: $e'};
    } finally {
      if (workDir != null) {
        try {
          if (workDir.existsSync()) await workDir.delete(recursive: true);
        } catch (_) {}
      }
    }
  }

  static Future<Map<String, dynamic>> upscaleVideo({
    required String inputVideo,
    required String outputVideo,
    double upscaleFactor = 2.0,
    String? modelPath,
    String device = 'auto',
    void Function(double progress, {double? processingFps})? onProgress,
  }) {
    return processVideoFull(
      inputVideo: inputVideo,
      outputVideo: outputVideo,
      mode: 'upscale',
      upscaleFactor: upscaleFactor,
      modelPath: modelPath,
      device: device,
      onProgress: onProgress,
    );
  }

  static Future<Map<String, dynamic>> deblurVideo({
    required String inputVideo,
    required String outputVideo,
    double deblurStrength = 0.5,
    String? modelPath,
    String device = 'auto',
    void Function(double progress, {double? processingFps})? onProgress,
  }) {
    return processVideoFull(
      inputVideo: inputVideo,
      outputVideo: outputVideo,
      mode: 'deblur',
      deblurStrength: deblurStrength,
      modelPath: modelPath,
      device: device,
      onProgress: onProgress,
    );
  }

  static Future<Map<String, dynamic>> restoreJPEGVideo({
    required String inputVideo,
    required String outputVideo,
    int noiseLevel = 7,
    String? modelPath,
    String device = 'auto',
    void Function(double progress, {double? processingFps})? onProgress,
  }) {
    return processVideoFull(
      inputVideo: inputVideo,
      outputVideo: outputVideo,
      mode: 'jpeg_restore',
      noiseLevel: noiseLevel,
      modelPath: modelPath,
      device: device,
      onProgress: onProgress,
    );
  }

  static Future<Map<String, dynamic>> processImage({
    required String inputPath,
    required String outputPath,
    String mode = 'denoise',
    int noiseLevel = 7,
    double upscaleFactor = 2.0,
    double deblurStrength = 0.5,
    String? modelPath,
    String device = 'auto',
  }) {
    return processFrame(
      framePath: inputPath,
      outputPath: outputPath,
      mode: mode,
      noiseLevel: noiseLevel,
      upscaleFactor: upscaleFactor,
      deblurStrength: deblurStrength,
      modelPath: modelPath,
      device: device,
    );
  }

  static int getRecommendedNoiseLevel({
    double? noisePercentage,
    bool hasHighNoise = false,
  }) {
    if (noisePercentage != null) {
      if (noisePercentage > 20.0) return 15;
      if (noisePercentage > 15.0) return 12;
      if (noisePercentage > 10.0) return 8;
      if (noisePercentage > 5.0) return 5;
      return 3;
    }

    if (hasHighNoise) return 10;
    return 7;
  }
}
