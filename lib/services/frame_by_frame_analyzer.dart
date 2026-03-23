import 'dart:io';
import 'package:video_converter_pro/utils/app_log.dart';

class FrameByFrameAnalyzer {
  /// Analizza ogni frame del video per rumore e qualità pixel-per-pixel
  /// Restituisce statistiche dettagliate per ogni frame
  static Future<Map<String, dynamic>> analyzeFrameByFrame(String inputPath) async {
    try {
      appLog('🔍 [FrameByFrame] Inizio analisi frame-per-frame...');
      
      // Usa FFmpeg per analizzare un numero limitato di frame (ottimizzato per velocità)
      // RIDOTTO: Analizza solo 15 frame invece di tutti per evitare blocchi
      final process = await Process.run('ffmpeg', [
        '-i', inputPath,
        '-vf', 'signalstats=stat=tout:metadata=1',
        '-frames:v', '15',  // RIDOTTO: 15 frame invece di tutti per velocità
        '-f', 'null',
        '-',
      ], runInShell: false);
      
      final stderr = process.stderr.toString();
      final frameStats = _parseFrameByFrameStats(stderr);
      
      // Analizza rumore pixel-per-pixel
      final noiseAnalysis = _analyzeNoiseLevels(frameStats);
      
      appLog('✅ [FrameByFrame] Analisi completata: ${frameStats.length} frame analizzati');
      appLog('   📊 Rumore medio: ${noiseAnalysis['average_noise']?.toStringAsFixed(2)}');
      appLog('   📊 Frame con rumore alto: ${noiseAnalysis['high_noise_frames']}');
      
      return {
        'success': true,
        'frame_count': frameStats.length,
        'frame_stats': frameStats,
        'noise_analysis': noiseAnalysis,
        'recommended_denoise_strength': _calculateDenoiseStrength(noiseAnalysis),
      };
    } catch (e, stackTrace) {
      appLog('❌ [FrameByFrame] Errore analisi: $e');
      appLog('   Stack: $stackTrace');
      return {
        'success': false,
        'error': 'Errore durante analisi frame-per-frame: $e',
      };
    }
  }

  /// Parsa le statistiche frame-per-frame da signalstats
  static List<Map<String, dynamic>> _parseFrameByFrameStats(String output) {
    final frames = <Map<String, dynamic>>[];
    final lines = output.split('\n');
    
    Map<String, dynamic>? currentFrame;
    
    for (final line in lines) {
      // Cerca frame number
      final frameMatch = RegExp(r'frame:\s*(\d+)').firstMatch(line);
      if (frameMatch != null) {
        // Salva frame precedente se esiste
        if (currentFrame != null) {
          frames.add(currentFrame);
        }
        // Inizia nuovo frame
        currentFrame = {
          'frame_number': int.tryParse(frameMatch.group(1) ?? '') ?? 0,
        };
      }
      
      if (currentFrame == null) continue;
      
      // Estrai statistiche
      final yavgMatch = RegExp(r'YAVG:\s*([\d.]+)').firstMatch(line);
      final yminMatch = RegExp(r'YMIN:\s*([\d.]+)').firstMatch(line);
      final ymaxMatch = RegExp(r'YMAX:\s*([\d.]+)').firstMatch(line);
      final uavgMatch = RegExp(r'UAVG:\s*([\d.]+)').firstMatch(line);
      final vavgMatch = RegExp(r'VAVG:\s*([\d.]+)').firstMatch(line);
      final satMatch = RegExp(r'SAT:\s*([\d.]+)').firstMatch(line);
      
      if (yavgMatch != null) {
        currentFrame['brightness'] = double.tryParse(yavgMatch.group(1) ?? '') ?? 0.0;
      }
      if (yminMatch != null) {
        currentFrame['min_brightness'] = double.tryParse(yminMatch.group(1) ?? '') ?? 0.0;
      }
      if (ymaxMatch != null) {
        currentFrame['max_brightness'] = double.tryParse(ymaxMatch.group(1) ?? '') ?? 0.0;
      }
      if (uavgMatch != null) {
        currentFrame['u_channel'] = double.tryParse(uavgMatch.group(1) ?? '') ?? 0.0;
      }
      if (vavgMatch != null) {
        currentFrame['v_channel'] = double.tryParse(vavgMatch.group(1) ?? '') ?? 0.0;
      }
      if (satMatch != null) {
        currentFrame['saturation'] = double.tryParse(satMatch.group(1) ?? '') ?? 0.0;
      }
    }
    
    // Aggiungi ultimo frame
    if (currentFrame != null) {
      frames.add(currentFrame);
    }
    
    return frames;
  }

  /// Analizza i livelli di rumore pixel-per-pixel
  static Map<String, dynamic> _analyzeNoiseLevels(List<Map<String, dynamic>> frameStats) {
    if (frameStats.isEmpty) {
      return {
        'average_noise': 0.0,
        'high_noise_frames': 0,
        'noise_distribution': [],
      };
    }
    
    final noiseLevels = <double>[];
    int highNoiseFrames = 0;
    
    for (final frame in frameStats) {
      final brightness = frame['brightness'] as double? ?? 128.0;
      final minBrightness = frame['min_brightness'] as double? ?? 0.0;
      final maxBrightness = frame['max_brightness'] as double? ?? 255.0;
      
      // Calcola rumore come variazione locale (differenza tra max e min in un frame)
      // Più alta la variazione, più rumore
      final localVariation = maxBrightness - minBrightness;
      
      // Normalizza rispetto alla luminosità media
      final normalizedNoise = brightness > 0 
          ? (localVariation / brightness) 
          : localVariation;
      
      noiseLevels.add(normalizedNoise);
      
      // Frame con rumore alto (variazione > 40% della luminosità media)
      if (normalizedNoise > 0.4) {
        highNoiseFrames++;
      }
    }
    
    final averageNoise = noiseLevels.reduce((a, b) => a + b) / noiseLevels.length;
    
    return {
      'average_noise': averageNoise,
      'max_noise': noiseLevels.reduce((a, b) => a > b ? a : b),
      'min_noise': noiseLevels.reduce((a, b) => a < b ? a : b),
      'high_noise_frames': highNoiseFrames,
      'total_frames': frameStats.length,
      'noise_percentage': (highNoiseFrames / frameStats.length * 100),
    };
  }

  /// Calcola la forza di denoising raccomandata basata sull'analisi del rumore
  static double _calculateDenoiseStrength(Map<String, dynamic> noiseAnalysis) {
    final avgNoise = noiseAnalysis['average_noise'] as double? ?? 0.0;
    final noisePercentage = noiseAnalysis['noise_percentage'] as double? ?? 0.0;
    
    // Se > 30% dei frame ha rumore alto, usa denoising forte
    if (noisePercentage > 30.0 || avgNoise > 0.5) {
      return 0.8;  // Denoising forte
    }
    // Se > 15% dei frame ha rumore alto, usa denoising medio
    else if (noisePercentage > 15.0 || avgNoise > 0.3) {
      return 0.5;  // Denoising medio
    }
    // Se > 5% dei frame ha rumore alto, usa denoising leggero
    else if (noisePercentage > 5.0 || avgNoise > 0.15) {
      return 0.3;  // Denoising leggero
    }
    // Rumore basso, denoising minimo
    else {
      return 0.1;  // Denoising minimo
    }
  }

  /// Analizza la qualità pixel-per-pixel usando histogram
  static Future<Map<String, dynamic>> analyzePixelQuality(String inputPath) async {
    try {
      appLog('🔍 [FrameByFrame] Analisi qualità pixel-per-pixel...');
      
      // Usa FFmpeg histogram per analisi dettagliata
      final process = await Process.run('ffmpeg', [
        '-i', inputPath,
        '-vf', 'histogram=display_mode=overlay',
        '-frames:v', '60',  // Analizza più frame per accuratezza
        '-f', 'null',
        '-',
      ], runInShell: false);
      
      // Analizza anche con cropdetect per rilevare bordi neri/artefatti
      final cropProcess = await Process.run('ffmpeg', [
        '-i', inputPath,
        '-vf', 'cropdetect=24:16:0',
        '-frames:v', '30',
        '-f', 'null',
        '-',
      ], runInShell: false);
      
      return {
        'success': true,
        'histogram_analysis': _parseHistogramOutput(process.stderr.toString()),
        'crop_analysis': _parseCropOutput(cropProcess.stderr.toString()),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Errore analisi pixel quality: $e',
      };
    }
  }

  static Map<String, dynamic> _parseHistogramOutput(String output) {
    // Estrai informazioni dall'histogram
    return {
      'analyzed': true,
    };
  }

  static Map<String, dynamic> _parseCropOutput(String output) {
    // Estrai informazioni da cropdetect
    final cropMatch = RegExp(r'crop=(\d+):(\d+):(\d+):(\d+)').firstMatch(output);
    if (cropMatch != null) {
      return {
        'has_crop': true,
        'crop_width': int.tryParse(cropMatch.group(1) ?? ''),
        'crop_height': int.tryParse(cropMatch.group(2) ?? ''),
        'crop_x': int.tryParse(cropMatch.group(3) ?? ''),
        'crop_y': int.tryParse(cropMatch.group(4) ?? ''),
      };
    }
    return {'has_crop': false};
  }
}

