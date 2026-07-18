import 'dart:io';
import '../models/video_filters.dart';
import 'package:video_converter_pro/utils/app_log.dart';

class PixelQualityAnalyzer {
  /// Analizza la qualità pixel-per-pixel del video
  /// Restituisce statistiche dettagliate su luminosità, contrasto, saturazione, ecc.
  static Future<Map<String, dynamic>> analyzePixelQuality(String inputPath) async {
    try {
      appLog('🔍 [PixelQuality] Inizio analisi pixel-per-pixel...');
      
      // Estrai alcuni frame campione per analisi
      final sampleFrames = await _extractSampleFrames(inputPath);
      
      // Analizza luminosità, contrasto, saturazione usando histogram
      final histogramAnalysis = await _analyzeHistogram(inputPath);
      
      // Analizza statistiche segnale video
      final signalStats = await _analyzeSignalStats(inputPath);
      
      // Combina tutte le analisi
      final combinedAnalysis = _combineAnalyses(
        histogramAnalysis,
        signalStats,
        sampleFrames,
      );
      
      appLog('✅ [PixelQuality] Analisi completata');
      appLog('   📊 Luminosità media: ${combinedAnalysis['average_brightness']?.toStringAsFixed(2)}');
      appLog('   📊 Contrasto: ${combinedAnalysis['contrast']?.toStringAsFixed(2)}');
      appLog('   📊 Saturazione media: ${combinedAnalysis['average_saturation']?.toStringAsFixed(2)}');
      
      return {
        'success': true,
        ...combinedAnalysis,
      };
    } catch (e, stackTrace) {
      appLog('❌ [PixelQuality] Errore analisi: $e');
      appLog('   Stack: $stackTrace');
      return {
        'success': false,
        'error': 'Errore durante analisi pixel quality: $e',
      };
    }
  }

  /// Estrae frame campione per analisi dettagliata
  static Future<List<String>> _extractSampleFrames(String inputPath) async {
    final tempDir = Directory.systemTemp;
    final framesDir = Directory('${tempDir.path}/pixel_analysis_${DateTime.now().millisecondsSinceEpoch}');
    await framesDir.create(recursive: true);
    
    try {
      // Estrai 5 frame distribuiti nel video (inizio, 25%, 50%, 75%, fine)
      final process = await Process.run('ffmpeg', [
        '-i', inputPath,
        '-vf', 'select=not(mod(n\\,30))',  // Ogni 30 frame
        '-frames:v', '5',
        '-vsync', '0',
        '-qscale:v', '2',
        '${framesDir.path}/frame_%03d.jpg',
      ]);
      
      if (process.exitCode == 0) {
        final frames = framesDir.listSync()
            .where((f) => f.path.endsWith('.jpg'))
            .map((f) => f.path)
            .toList();
        return frames;
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Analizza histogram per luminosità, contrasto, distribuzione colori
  static Future<Map<String, dynamic>> _analyzeHistogram(String inputPath) async {
    try {
      // Analizza con signalstats per statistiche precise
      final statsProcess = await Process.run('ffmpeg', [
        '-i', inputPath,
        '-vf', 'signalstats=stat=tout',
        '-frames:v', '30',
        '-f', 'null',
        '-',
      ], runInShell: false);
      
      return _parseHistogramStats(statsProcess.stderr.toString());
    } catch (e) {
      appLog('⚠️ [PixelQuality] Errore analisi histogram: $e');
      return {};
    }
  }

  /// Analizza signalstats per statistiche video dettagliate
  static Future<Map<String, dynamic>> _analyzeSignalStats(String inputPath) async {
    try {
      final process = await Process.run('ffmpeg', [
        '-i', inputPath,
        '-vf', 'signalstats=stat=tout:metadata=1',
        '-frames:v', '30',
        '-f', 'null',
        '-',
      ], runInShell: false);
      
      final stderr = process.stderr.toString();
      return _parseSignalStats(stderr);
    } catch (e) {
      appLog('⚠️ [PixelQuality] Errore analisi signalstats: $e');
      return {};
    }
  }

  /// Parsa le statistiche dell'histogram
  static Map<String, dynamic> _parseHistogramStats(String output) {
    final stats = <String, dynamic>{};
    
    // Cerca valori YMIN, YLOW, YAVG, YHIGH, YMAX (luminosità)
    final yavgMatch = RegExp(r'YAVG:\s*([\d.]+)').firstMatch(output);
    final yminMatch = RegExp(r'YMIN:\s*([\d.]+)').firstMatch(output);
    final ymaxMatch = RegExp(r'YMAX:\s*([\d.]+)').firstMatch(output);
    final ylowMatch = RegExp(r'YLOW:\s*([\d.]+)').firstMatch(output);
    final yhighMatch = RegExp(r'YHIGH:\s*([\d.]+)').firstMatch(output);
    
    if (yavgMatch != null) {
      stats['average_brightness'] = double.tryParse(yavgMatch.group(1) ?? '') ?? 0.0;
    }
    if (yminMatch != null) {
      stats['min_brightness'] = double.tryParse(yminMatch.group(1) ?? '') ?? 0.0;
    }
    if (ymaxMatch != null) {
      stats['max_brightness'] = double.tryParse(ymaxMatch.group(1) ?? '') ?? 0.0;
    }
    if (ylowMatch != null) {
      stats['low_brightness'] = double.tryParse(ylowMatch.group(1) ?? '') ?? 0.0;
    }
    if (yhighMatch != null) {
      stats['high_brightness'] = double.tryParse(yhighMatch.group(1) ?? '') ?? 0.0;
    }
    
    // Calcola contrasto (differenza tra max e min)
    if (stats['max_brightness'] != null && stats['min_brightness'] != null) {
      stats['contrast'] = (stats['max_brightness'] as double) - (stats['min_brightness'] as double);
    }
    
    // Cerca saturazione (SAT)
    final satMatch = RegExp(r'SAT:\s*([\d.]+)').firstMatch(output);
    if (satMatch != null) {
      stats['average_saturation'] = double.tryParse(satMatch.group(1) ?? '') ?? 0.0;
    }
    
    return stats;
  }

  /// Parsa le statistiche del segnale video
  static Map<String, dynamic> _parseSignalStats(String output) {
    final stats = <String, dynamic>{};
    
    // Estrai tutte le statistiche disponibili
    final lines = output.split('\n');
    for (final line in lines) {
      // Cerca pattern tipo "YAVG:123.45" o "frame:123 YAVG:123.45"
      final yavgMatch = RegExp(r'YAVG:\s*([\d.]+)').firstMatch(line);
      final yminMatch = RegExp(r'YMIN:\s*([\d.]+)').firstMatch(line);
      final ymaxMatch = RegExp(r'YMAX:\s*([\d.]+)').firstMatch(line);
      final uavgMatch = RegExp(r'UAVG:\s*([\d.]+)').firstMatch(line);
      final vavgMatch = RegExp(r'VAVG:\s*([\d.]+)').firstMatch(line);
      final satMatch = RegExp(r'SAT:\s*([\d.]+)').firstMatch(line);
      
      if (yavgMatch != null && stats['average_brightness'] == null) {
        stats['average_brightness'] = double.tryParse(yavgMatch.group(1) ?? '') ?? 0.0;
      }
      if (yminMatch != null && stats['min_brightness'] == null) {
        stats['min_brightness'] = double.tryParse(yminMatch.group(1) ?? '') ?? 0.0;
      }
      if (ymaxMatch != null && stats['max_brightness'] == null) {
        stats['max_brightness'] = double.tryParse(ymaxMatch.group(1) ?? '') ?? 0.0;
      }
      if (uavgMatch != null) {
        stats['u_channel_avg'] = double.tryParse(uavgMatch.group(1) ?? '') ?? 0.0;
      }
      if (vavgMatch != null) {
        stats['v_channel_avg'] = double.tryParse(vavgMatch.group(1) ?? '') ?? 0.0;
      }
      if (satMatch != null && stats['average_saturation'] == null) {
        stats['average_saturation'] = double.tryParse(satMatch.group(1) ?? '') ?? 0.0;
      }
    }
    
    // Calcola contrasto se abbiamo min e max
    if (stats['max_brightness'] != null && stats['min_brightness'] != null) {
      final max = stats['max_brightness'] as double;
      final min = stats['min_brightness'] as double;
      stats['contrast'] = max - min;
      // Contrasto normalizzato (0-1)
      stats['contrast_normalized'] = (max - min) / 255.0;
    }
    
    return stats;
  }

  /// Combina tutte le analisi in un risultato unificato
  static Map<String, dynamic> _combineAnalyses(
    Map<String, dynamic> histogram,
    Map<String, dynamic> signalStats,
    List<String> sampleFrames,
  ) {
    final combined = <String, dynamic>{};
    
    // Preferisci signalStats se disponibile, altrimenti histogram
    combined['average_brightness'] = signalStats['average_brightness'] ?? 
                                    histogram['average_brightness'] ?? 
                                    128.0;  // Default medio
    
    combined['min_brightness'] = signalStats['min_brightness'] ?? 
                                 histogram['min_brightness'] ?? 
                                 0.0;
    
    combined['max_brightness'] = signalStats['max_brightness'] ?? 
                                histogram['max_brightness'] ?? 
                                255.0;
    
    combined['contrast'] = signalStats['contrast'] ?? 
                          histogram['contrast'] ?? 
                          128.0;
    
    combined['contrast_normalized'] = signalStats['contrast_normalized'] ?? 
                                      ((combined['contrast'] as double) / 255.0);
    
    combined['average_saturation'] = signalStats['average_saturation'] ?? 
                                     histogram['average_saturation'] ?? 
                                     0.0;
    
    // Determina se il video è troppo scuro
    final avgBrightness = combined['average_brightness'] as double;
    combined['is_too_dark'] = avgBrightness < 100.0;  // Soglia: < 100/255
    combined['is_too_bright'] = avgBrightness > 200.0;  // Soglia: > 200/255
    
    // Determina se il contrasto è basso
    final contrastNorm = combined['contrast_normalized'] as double;
    combined['low_contrast'] = contrastNorm < 0.3;  // Contrasto < 30%
    
    // Calcola correzioni automatiche raccomandate
    combined['recommended_brightness'] = _calculateRecommendedBrightness(avgBrightness);
    combined['recommended_contrast'] = _calculateRecommendedContrast(contrastNorm);
    combined['recommended_gamma'] = _calculateRecommendedGamma(avgBrightness);
    
    return combined;
  }

  /// Calcola brightness raccomandato basato sull'analisi
  static double _calculateRecommendedBrightness(double currentBrightness) {
    // Target: 128 (medio, 50% luminosità)
    final target = 128.0;
    final difference = target - currentBrightness;
    
    // Converti differenza in valore brightness per eq (-1.0 a 1.0)
    // Se brightness è 50, serve +0.3 per arrivare a 128
    // Se brightness è 200, serve -0.28 per arrivare a 128
    final brightnessAdjustment = (difference / 255.0).clamp(-0.5, 0.5);
    
    return brightnessAdjustment;
  }

  /// Calcola contrast raccomandato basato sull'analisi
  static double _calculateRecommendedContrast(double currentContrast) {
    // Target: 0.5 (contrasto medio-alto)
    // IMPORTANTE: Solo aumentare contrasto se basso, mai ridurre
    final target = 0.5;
    
    if (currentContrast < 0.3) {
      // Contrasto basso, aumenta
      return 1.0 + ((target - currentContrast) * 0.5).clamp(0.0, 0.3);
    }
    // Contrasto normale o alto - non modificare (mai ridurre)
    return 1.0;  // Nessuna modifica necessaria
  }

  /// Calcola gamma raccomandato basato sull'analisi
  static double _calculateRecommendedGamma(double currentBrightness) {
    // Target: 128 (medio)
    // IMPORTANTE: Gamma > 1.0 schiarisce, < 1.0 scurisce - MAI RIDURRE GAMMA
    if (currentBrightness < 100) {
      // Troppo scuro, aumenta gamma per schiarire
      return 1.0 + ((100 - currentBrightness) / 255.0 * 0.3).clamp(0.0, 0.3);
    }
    // Video normali o chiari - gamma = 1.0 (mai scurire)
    return 1.0;  // Nessuna modifica necessaria
  }

  /// Genera VideoFilters ottimizzati basati sull'analisi pixel-per-pixel
  static VideoFilters generateOptimizedFilters(Map<String, dynamic> pixelAnalysis) {
    if (!pixelAnalysis['success']) {
      // Fallback a preset di default
      return VideoFilters.getProfessionalEnhancement();
    }
    
    final recommendedBrightness = pixelAnalysis['recommended_brightness'] as double? ?? 0.0;
    final recommendedContrast = pixelAnalysis['recommended_contrast'] as double? ?? 1.0;
    final recommendedGamma = pixelAnalysis['recommended_gamma'] as double? ?? 1.0;
    final isTooDark = pixelAnalysis['is_too_dark'] as bool? ?? false;
    final lowContrast = pixelAnalysis['low_contrast'] as bool? ?? false;
    final avgSaturation = pixelAnalysis['average_saturation'] as double? ?? 0.0;
    
    // Crea filtri base con correzioni automatiche
    var filters = VideoFilters.getProfessionalEnhancement().copyWith(
      brightness: recommendedBrightness,
      contrast: recommendedContrast,
      gamma: recommendedGamma,
    );
    
    // Se troppo scuro, aumenta anche il contrasto per compensare
    if (isTooDark) {
      filters = filters.copyWith(
        contrast: (recommendedContrast * 1.1).clamp(0.8, 1.3),
        brightness: (recommendedBrightness + 0.1).clamp(-0.3, 0.3),
      );
    }
    
    // Se contrasto basso, aumenta
    if (lowContrast) {
      filters = filters.copyWith(
        contrast: (recommendedContrast * 1.15).clamp(1.0, 1.4),
      );
    }
    
    // Aggiusta saturazione se necessario
    if (avgSaturation < 50.0) {
      // Saturazione bassa, aumenta leggermente
      filters = filters.copyWith(
        saturation: 1.1,
      );
    }
    
    return filters;
  }
}

