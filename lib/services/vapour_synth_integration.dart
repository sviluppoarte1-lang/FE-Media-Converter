import 'dart:io';
import '../models/video_filters.dart';

class VapourSynthIntegration {
  /// Crea script VapourSynth per enhancement avanzato
  static Future<String> createVapourSynthScript(
    String inputPath, 
    VideoFilters filters
  ) async {
    final script = '''
import vapoursynth as vs
core = vs.get_core()

# Carica il video
video = core.ffms2.Source("${_escapePath(inputPath)}")

# Applica filtri avanzati in pipeline
${_buildVapourSynthFilters(filters)}

# Output finale
video.set_output()
''';
    
    final scriptFile = File('/tmp/enhancement_script.vpy');
    await scriptFile.writeAsString(script);
    return scriptFile.path;
  }

  static String _buildVapourSynthFilters(VideoFilters filters) {
    final filtersCode = <String>[];
    
    // 1. Resize iniziale rimosso - Usa VRT super_resolution invece
    // Il vecchio upscaling è stato rimosso in favore di VRT

    // 2. Denoising avanzato
    if (filters.advancedDenoiseMethod != 'none') {
      filtersCode.add(_buildVapourSynthDenoise(filters));
    }

    // 3. Debanding
    if (filters.advancedDebandingMethod != 'none') {
      filtersCode.add('''
# Debanding avanzato
video = core.f3kdb.Deband(video, range=15, y=32, cb=32, cr=32, grainy=0, grainc=0)
''');
    }

    // 4. Detail enhancement
    if (filters.enableDetailEnhancement && filters.detailEnhanceStrength > 0) {
      filtersCode.add('''
# Detail enhancement
mask = core.std.Sobel(video)
enhanced = core.std.Convolution(video, [0,-1,0,-1,5,-1,0,-1,0])
video = core.std.MaskedMerge(video, enhanced, mask)
''');
    }

    // 5. Sharpening adattivo
    if (filters.enableAdaptiveSharpening) {
      filtersCode.add('''
# Sharpening adattivo
video = core.warp.AWarpSharp2(video, depth=${(filters.sharpness - 1.0).clamp(0.0, 2.0).toStringAsFixed(2)})
''');
    }

    // 6. Color correction
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
# NL-Means denoising (alta qualità)
video = core.knlm.KNLMeansCL(video, d=1, a=2, h=${(filters.denoiseStrength * 3.0).toStringAsFixed(2)})
''';
      
      case 'fftdnoiz':
        return '''
# FFT Denoising (dominio frequenza)
video = core.fft3dfilter.FFT3DFilter(video, sigma=${(filters.denoiseStrength * 5.0).toStringAsFixed(2)})
''';
      
      case 'bm3d':
        return '''
# BM3D Denoising (block-matching)
video = core.bm3d.BM3D(video, sigma=${(filters.denoiseStrength * 10.0).toStringAsFixed(2)})
''';
      
      default:
        return '''
# Denoising base
video = core.std.Convolution(video, [1,2,1,2,4,2,1,2,1])
''';
    }
  }

  static String _buildVapourSynthColorCorrection(VideoFilters filters) {
    final corrections = <String>[];
    
    // Balance colore
    if (filters.colorBalanceR != 0.0 || filters.colorBalanceG != 0.0 || filters.colorBalanceB != 0.0) {
      corrections.add('''
# Color balance
video = core.std.Expr(video, expr=[
    "x ${filters.colorBalanceR >= 0 ? '+' : ''}${filters.colorBalanceR.abs()}",
    "x ${filters.colorBalanceG >= 0 ? '+' : ''}${filters.colorBalanceG.abs()}", 
    "x ${filters.colorBalanceB >= 0 ? '+' : ''}${filters.colorBalanceB.abs()}"
])
''');
    }

    // Profili colore
    switch (filters.colorProfile) {
      case 'vivid':
        corrections.add('''
# Vivid color profile
video = core.std.Expr(video, expr=["x 1.2 *", "x 1.1 *", "x 1.15 *"])
''');
        break;
      
      case 'cinematic':
        corrections.add('''
# Cinematic color profile  
video = core.std.Expr(video, expr=["x 0.95 *", "x 0.98 *", "x 1.05 *"])
''');
        break;
      
      case 'bw':
        corrections.add('''
# Black and white
video = core.std.Expr(video, expr=["x 0.299 * y 0.587 * z 0.114 * + +"])
''');
        break;
    }

    return corrections.join('\n');
  }

  static String _escapePath(String path) {
    return path.replaceAll('\\', '\\\\').replaceAll('"', '\\"');
  }

  /// Esegue enhancement con VapourSynth - METODO AGGIUNTO
  static Future<Map<String, dynamic>> enhanceWithVapourSynth({
    required String inputPath,
    required String outputPath,
    required VideoFilters filters,
  }) async {
    try {
      // Verifica se VapourSynth è disponibile
      if (!await isVapourSynthAvailable()) {
        return {
          'success': false,
          'error': 'VapourSynth non disponibile sul sistema'
        };
      }

      final scriptPath = await createVapourSynthScript(inputPath, filters);
      
      // Esegui VapourSynth e pipe a FFmpeg
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

      // Pipe l'output di vspipe a ffmpeg
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

  /// Verifica se VapourSynth è disponibile
  static Future<bool> isVapourSynthAvailable() async {
    try {
      final result = await Process.run('vspipe', ['--version']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  /// Ottieni informazioni sui filtri VapourSynth disponibili
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
          'knlm': true, // KNLMeansCL
          'fft3dfilter': true,
          'bm3d': true,
          'f3kdb': true, // Deband
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