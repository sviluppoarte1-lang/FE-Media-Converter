import 'dart:io';
import 'package:path/path.dart' as path;
import '../models/video_filters.dart';

class VapourSynthIntegration {
  static Future<String> createVapourSynthScript(
    String inputPath, 
    VideoFilters filters
  ) async {
    final script = '''
import vapoursynth as vs
core = vs.get_core()

video = core.ffms2.Source("${_escapePath(inputPath)}")

${_buildVapourSynthFilters(filters)}

video.set_output()
''';

    final scriptFile = File(path.join(Directory.systemTemp.path, 'enhancement_script.vpy'));
    await scriptFile.writeAsString(script);
    return scriptFile.path;
  }

  static String _buildVapourSynthFilters(VideoFilters filters) {
    final filtersCode = <String>[];

    if (filters.advancedDenoiseMethod != 'none') {
      filtersCode.add(_buildVapourSynthDenoise(filters));
    }

    if (filters.advancedDebandingMethod != 'none') {
      filtersCode.add('''
video = core.f3kdb.Deband(video, range=15, y=32, cb=32, cr=32, grainy=0, grainc=0)
''');
    }

    if (filters.enableDetailEnhancement && filters.detailEnhanceStrength > 0) {
      filtersCode.add('''
mask = core.std.Sobel(video)
enhanced = core.std.Convolution(video, [0,-1,0,-1,5,-1,0,-1,0])
video = core.std.MaskedMerge(video, enhanced, mask)
''');
    }

    if (filters.enableAdaptiveSharpening) {
      filtersCode.add('''
video = core.warp.AWarpSharp2(video, depth=${(filters.sharpness - 1.0).clamp(0.0, 2.0).toStringAsFixed(2)})
''');
    }

    if (filters.colorProfile != 'none' || filters.colorBalanceR != 0.0 || 
        filters.colorBalanceG != 0.0 || filters.colorBalanceB != 0.0) {
      filtersCode.add(_buildVapourSynthColorCorrection(filters));
    }

    return filtersCode.join('\n');
  }

  static String _buildVapourSynthDenoise(VideoFilters filters) {
    switch (filters.advancedDenoiseMethod) {
      case 'nlmeans':
        return '''
video = core.knlm.KNLMeansCL(video, d=1, a=2, h=${(filters.denoiseStrength * 3.0).toStringAsFixed(2)})
''';
      case 'fftdnoiz':
        return '''
video = core.fft3dfilter.FFT3DFilter(video, sigma=${(filters.denoiseStrength * 5.0).toStringAsFixed(2)})
''';
      case 'bm3d':
        return '''
video = core.bm3d.BM3D(video, sigma=${(filters.denoiseStrength * 10.0).toStringAsFixed(2)})
''';
      default:
        return '''
video = core.std.Convolution(video, [1,2,1,2,4,2,1,2,1])
''';
    }
  }

  static String _buildVapourSynthColorCorrection(VideoFilters filters) {
    final corrections = <String>[];

    if (filters.colorBalanceR != 0.0 || filters.colorBalanceG != 0.0 || filters.colorBalanceB != 0.0) {
      corrections.add('''
video = core.std.Expr(video, expr=[
    "x ${filters.colorBalanceR >= 0 ? '+' : ''}${filters.colorBalanceR.abs()}",
    "x ${filters.colorBalanceG >= 0 ? '+' : ''}${filters.colorBalanceG.abs()}", 
    "x ${filters.colorBalanceB >= 0 ? '+' : ''}${filters.colorBalanceB.abs()}"
])
''');
    }

    switch (filters.colorProfile) {
      case 'vivid':
        corrections.add('''
video = core.std.Expr(video, expr=["x 1.2 *", "x 1.1 *", "x 1.15 *"])
''');
        break;
      case 'cinematic':
        corrections.add('''
video = core.std.Expr(video, expr=["x 0.95 *", "x 0.98 *", "x 1.05 *"])
''');
        break;
      case 'bw':
        corrections.add('''
video = core.std.Expr(video, expr=["x 0.299 * y 0.587 * z 0.114 * + +"])
''');
        break;
    }

    return corrections.join('\n');
  }

  static String _escapePath(String path) {
    return path.replaceAll('\\', '\\\\').replaceAll('"', '\\"');
  }

  static Future<Map<String, dynamic>> enhanceWithVapourSynth({
    required String inputPath,
    required String outputPath,
    required VideoFilters filters,
  }) async {
    try {
      if (!await isVapourSynthAvailable()) {
        return {
          'success': false,
          'error': 'VapourSynth non disponibile sul sistema'
        };
      }

      final scriptPath = await createVapourSynthScript(inputPath, filters);

      final vspipeProcess = await Process.start('vspipe', [
        scriptPath,
        '--y4m',
        '-'
      ]);

      final ffmpegProcess = await Process.start('ffmpeg', [
        '-y',
        '-i', 'pipe:0',
        '-c:v', 'libx264',
        '-crf', '18',
        '-preset', 'slow',
        '-c:a', 'copy',
        outputPath
      ]);

      await vspipeProcess.stdout.pipe(ffmpegProcess.stdin);

      final exitCode = await ffmpegProcess.exitCode;

      if (exitCode == 0) {
        return {
          'success': true,
          'output_path': outputPath,
          'method': 'vapoursynth'
        };
      } else {
        return {
          'success': false,
          'error': 'VapourSynth processing failed with exit code: $exitCode'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'VapourSynth error: $e'
      };
    }
  }

  static Future<bool> isVapourSynthAvailable() async {
    try {
      final result = await Process.run('vspipe', ['--version']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> getAvailableVapourSynthFilters() async {
    try {
      final result = await Process.run('vspipe', [
        '-c',
        'import vapoursynth as vs; core = vs.get_core(); print("Available")',
      ]);
      return {
        'success': result.exitCode == 0,
        'available': result.exitCode == 0,
        'filters': {
          'knlm': true,
          'fft3dfilter': true,
          'bm3d': true,
          'f3kdb': true,
          'awarpsharp2': true,
        }
      };
    } catch (e) {
      return {
        'success': false,
        'available': false,
        'filters': {}
      };
    }
  }
}
