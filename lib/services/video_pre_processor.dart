import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../models/video_filters.dart';
import 'frame_by_frame_analyzer.dart';
import 'scene_detection_service.dart';
import 'drunet_service.dart';
import 'package:video_converter_pro/utils/app_log.dart';

class VideoPreProcessor {
  static Future<Map<String, dynamic>> analyzeVideoQuality(String inputPath) async {
    try {
      final file = File(inputPath);
      if (!await file.exists()) {
        return {
          'success': false, 
          'error': 'File non trovato: $inputPath',
          'quality_issues': [],
          'recommendations': []
        };
      }

      // Esegui analisi approfondita con ffprobe
      // Timeout di 10 secondi per evitare blocchi
      ProcessResult process;
      try {
        process = await Process.run('ffprobe', [
          '-v', 'error',
          '-select_streams', 'v:0',
          '-show_entries', 'stream=width,height,codec_name,duration,r_frame_rate,pix_fmt,bit_rate,color_primaries,color_transfer,color_space,field_order',
          '-show_entries', 'format=bit_rate,size',
          '-of', 'json',
          inputPath
        ]).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('ffprobe timeout dopo 10 secondi');
          },
        );
      } catch (e) {
        appLog('⚠️ [VideoPreProcessor] ffprobe timeout o errore: $e');
        // Continua con solo analisi pixel se ffprobe fallisce
        final pixelAnalysis = await _analyzePixelQualityForBrightness(inputPath)
            .timeout(
              const Duration(seconds: 15),
              onTimeout: () {
                return {
                  'success': false,
                  'error': 'Timeout analisi pixel dopo 15 secondi'
                };
              },
            );
        return {
          'success': pixelAnalysis['success'] == true,
          'error': 'ffprobe timeout o errore: $e',
          'quality_issues': pixelAnalysis['success'] == true ? 
            (pixelAnalysis['is_too_dark'] == true ? ['too_dark'] : []) + 
            (pixelAnalysis['low_contrast'] == true ? ['low_contrast'] : []) : [],
          'recommendations': pixelAnalysis['success'] == true ? 
            (pixelAnalysis['is_too_dark'] == true ? ['Automatic brightness correction'] : []) +
            (pixelAnalysis['low_contrast'] == true ? ['Contrast enhancement'] : []) : [],
          'pixel_analysis': pixelAnalysis,
        };
      }

      // Rileva orientamento video PRIMA dell'analisi pixel
      bool isVertical = false;
      if (process.exitCode == 0) {
        try {
          final analysis = json.decode(process.stdout);
          final streams = analysis['streams'] as List<dynamic>?;
          if (streams != null && streams.isNotEmpty) {
            final videoStream = streams.firstWhere(
              (s) => s is Map && s['codec_type'] == 'video',
              orElse: () => streams[0],
            );
            final width = _safeParseInt(videoStream['width']);
            final height = _safeParseInt(videoStream['height']);
            if (width != null && height != null) {
              isVertical = height > width;
              appLog('   📐 Video ${isVertical ? "VERTICALE" : "ORIZZONTALE"} rilevato (${width}x$height)');
            }
          }
        } catch (e) {
          appLog('   ⚠️ Impossibile rilevare orientamento: $e');
        }
      }
      
      // CRITICO: Analisi pixel-per-pixel per luminosità e contrasto
      // Questa analisi viene SEMPRE eseguita, anche se ffprobe fallisce
      // Con timeout per evitare blocchi
      // IMPORTANTE: Passa isVertical per applicare soglie più restrittive per video verticali
      appLog('🔍 [VideoPreProcessor] Eseguendo analisi pixel-per-pixel per luminosità e contrasto...');
      Map<String, dynamic> pixelAnalysis;
      try {
        pixelAnalysis = await _analyzePixelQualityForBrightness(inputPath, isVertical: isVertical)
            .timeout(
              const Duration(seconds: 15),
              onTimeout: () {
                appLog('⚠️ [VideoPreProcessor] Timeout analisi pixel (15s)');
                return {
                  'success': false,
                  'error': 'Timeout analisi pixel dopo 15 secondi'
                };
              },
            );
      } catch (e) {
        appLog('⚠️ [VideoPreProcessor] Errore analisi pixel: $e');
        pixelAnalysis = {
          'success': false,
          'error': 'Errore analisi pixel: $e'
        };
      }
      
      if (process.exitCode == 0) {
        final Map<String, dynamic> analysis = json.decode(process.stdout);
        final qualityAnalysis = await _analyzeVideoCharacteristics(analysis, inputPath);
        
        // Aggiungi sempre l'analisi pixel (anche se fallisce, per logging)
        qualityAnalysis['pixel_analysis'] = pixelAnalysis;
        
        if (pixelAnalysis['success'] == true) {
          appLog('✅ [VideoPreProcessor] Analisi pixel-per-pixel completata con successo');
          final avgBrightness = pixelAnalysis['average_brightness'] as double?;
          final avgContrast = pixelAnalysis['average_contrast'] as double?;
          final isTooDark = pixelAnalysis['is_too_dark'] as bool? ?? false;
          final lowContrast = pixelAnalysis['low_contrast'] as bool? ?? false;
          
          appLog('   📊 Risultati analisi:');
          appLog('      Luminosità media: ${avgBrightness?.toStringAsFixed(2) ?? "N/A"}');
          appLog('      Contrasto medio: ${avgContrast?.toStringAsFixed(2) ?? "N/A"}');
          appLog('      Troppo scuro: $isTooDark');
          appLog('      Contrasto basso: $lowContrast');
          
          // Aggiungi problemi di luminosità se rilevati (solo se veramente necessari)
          if (isTooDark == true) {
            qualityAnalysis['quality_issues'].add('too_dark');
            qualityAnalysis['recommendations'].add('Automatic brightness correction');
            appLog('   ⚠️ Video troppo scuro - correzione automatica verrà applicata');
          }
          if (pixelAnalysis['is_too_bright'] == true) {
            qualityAnalysis['quality_issues'].add('too_bright');
            qualityAnalysis['recommendations'].add('Automatic brightness reduction');
            appLog('   ⚠️ Video troppo chiaro - nessuna correzione (non scuriremo)');
          }
          if (lowContrast == true) {
            qualityAnalysis['quality_issues'].add('low_contrast');
            qualityAnalysis['recommendations'].add('Contrast enhancement');
            appLog('   ⚠️ Contrasto basso - correzione automatica verrà applicata');
          }
        } else {
          appLog('⚠️ [VideoPreProcessor] Analisi pixel-per-pixel fallita: ${pixelAnalysis['error']}');
          appLog('   → Continuo senza correzioni automatiche di luminosità/contrasto');
        }
        
        // AGGIUNTA: Analisi frame-per-frame per rumore pixel-per-pixel
        // Con timeout per evitare blocchi
        try {
          final frameAnalysis = await FrameByFrameAnalyzer.analyzeFrameByFrame(inputPath)
              .timeout(
                const Duration(seconds: 15),
                onTimeout: () {
                  appLog('⚠️ [VideoPreProcessor] Timeout analisi frame-per-frame (15s) - salto');
                  return {
                    'success': false,
                    'error': 'Timeout analisi frame-per-frame'
                  };
                },
              );
          if (frameAnalysis['success'] == true) {
            qualityAnalysis['frame_analysis'] = frameAnalysis;
            
            final noiseAnalysis = frameAnalysis['noise_analysis'] as Map<String, dynamic>?;
            if (noiseAnalysis != null) {
              final noisePercentage = noiseAnalysis['noise_percentage'] as double? ?? 0.0;
              if (noisePercentage > 15.0) {
                qualityAnalysis['quality_issues'].add('high_noise');
                qualityAnalysis['recommendations'].add('Advanced pixel-level denoising (DRUNet)');
              }
              
              // Aggiungi forza denoising raccomandata
              qualityAnalysis['recommended_denoise_strength'] = frameAnalysis['recommended_denoise_strength'];
              
              // Aggiungi raccomandazione DRUNet se disponibile
              final hasDRUNet = await DRUNetService.checkDependencies();
              if (hasDRUNet && noisePercentage > 10.0) {
                final recommendedNoiseLevel = DRUNetService.getRecommendedNoiseLevel(
                  noisePercentage: noisePercentage,
                  hasHighNoise: noisePercentage > 15.0,
                );
                qualityAnalysis['recommended_drunet_noise_level'] = recommendedNoiseLevel;
                qualityAnalysis['recommendations'].add('DRUNet deep learning denoising available');
              }
            }
          }
        } catch (e) {
          appLog('⚠️ [VideoPreProcessor] Errore analisi frame-per-frame: $e - continuo senza');
          // Non fallire se l'analisi frame-per-frame fallisce
        }
        
        // AGGIUNTA: Analisi scene con PySceneDetect per ottimizzazione qualità
        // Con timeout per evitare blocchi
        try {
          appLog('🎬 [VideoPreProcessor] Eseguendo analisi scene con PySceneDetect...');
          final sceneAnalysis = await SceneDetectionService.analyzeVideoForOptimization(
            videoPath: inputPath,
            method: 'adaptive',
          ).timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              appLog('⚠️ [VideoPreProcessor] Timeout analisi scene (30s) - salto');
              return {
                'success': false,
                'error': 'Timeout analisi scene'
              };
            },
          );
          
          if (sceneAnalysis['success'] == true) {
            qualityAnalysis['scene_analysis'] = sceneAnalysis;
            
            final qualityRecs = sceneAnalysis['quality_recommendations'] as Map<String, dynamic>?;
            if (qualityRecs != null && qualityRecs['success'] == true) {
              final recommendations = qualityRecs['recommendations'] as Map<String, dynamic>?;
              if (recommendations != null) {
                final totalScenes = sceneAnalysis['total_scenes'] as int? ?? 0;
                appLog('   🎬 Scene rilevate: $totalScenes');
                
                // Aggiungi raccomandazioni basate sulle scene
                if (recommendations['has_rapid_cuts'] == true) {
                  qualityAnalysis['quality_issues'].add('rapid_cuts');
                  qualityAnalysis['recommendations'].add('Optimize for rapid scene changes');
                }
                
                // Suggerisci impostazioni qualità ottimali
                qualityAnalysis['scene_based_bitrate_mode'] = recommendations['suggested_bitrate_mode'];
                qualityAnalysis['scene_based_crf'] = recommendations['suggested_crf'];
                qualityAnalysis['scene_based_bitrate'] = recommendations['suggested_bitrate'];
                
                appLog('   💡 Raccomandazioni qualità basate su scene:');
                appLog('      → Bitrate mode: ${recommendations['suggested_bitrate_mode']}');
                appLog('      → CRF suggerito: ${recommendations['suggested_crf']}');
                appLog('      → Bitrate suggerito: ${recommendations['suggested_bitrate']} kbps');
              }
            }
          } else {
            appLog('⚠️ [VideoPreProcessor] Analisi scene fallita: ${sceneAnalysis['error']}');
            // Non fallire se l'analisi scene fallisce - è opzionale
          }
        } catch (e) {
          appLog('⚠️ [VideoPreProcessor] Errore analisi scene: $e - continuo senza');
          // Non fallire se l'analisi scene fallisce - è opzionale
        }
        
        final fullIssues = qualityAnalysis['quality_issues'] as List<dynamic>;
        final issuesList = fullIssues.map((e) => e.toString()).toList();
        qualityAnalysis['auto_preset'] = _generateAutoPreset(issuesList).toMap();
        
        return {
          'success': true,
          'analysis': analysis,
          ...qualityAnalysis
        };
      } else {
        // Anche se ffprobe fallisce, restituisci l'analisi pixel se disponibile
        appLog('⚠️ [VideoPreProcessor] ffprobe fallito, ma analisi pixel disponibile');
        return {
          'success': pixelAnalysis['success'] == true,  // Successo se almeno pixel analysis funziona
          'error': 'ffprobe failed: ${process.stderr}',
          'quality_issues': pixelAnalysis['success'] == true ? 
            (pixelAnalysis['is_too_dark'] == true ? ['too_dark'] : []) + 
            (pixelAnalysis['low_contrast'] == true ? ['low_contrast'] : []) : [],
          'recommendations': pixelAnalysis['success'] == true ? 
            (pixelAnalysis['is_too_dark'] == true ? ['Automatic brightness correction'] : []) +
            (pixelAnalysis['low_contrast'] == true ? ['Contrast enhancement'] : []) : [],
          'pixel_analysis': pixelAnalysis,  // Includi sempre l'analisi pixel
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Errore durante l\'analisi: $e',
        'quality_issues': [],
        'recommendations': []
      };
    }
  }
  
  /// Analisi rapida pixel quality per luminosità (più veloce della versione completa)
  /// [isVertical] indica se il video è verticale (portrait) - per video verticali le soglie sono più restrittive
  static Future<Map<String, dynamic>> _analyzePixelQualityForBrightness(String inputPath, {bool isVertical = false}) async {
    try {
      // Usa signalstats per analisi rapida della luminosità
      // RIDOTTO: Analizza solo 10 frame per velocità (era 30)
      final process = await Process.run('ffmpeg', [
        '-i', inputPath,
        '-vf', 'signalstats=stat=tout',
        '-frames:v', '10',  // RIDOTTO: 10 frame invece di 30 per velocità
        '-f', 'null',
        '-',
      ], runInShell: false);
      
      final stderr = process.stderr.toString();
      return _parseBrightnessFromSignalStats(stderr, isVertical: isVertical);
    } catch (e) {
      return {'success': false, 'error': 'Errore analisi luminosità: $e'};
    }
  }
  
  /// Parsa le statistiche di luminosità da signalstats
  /// [isVertical] indica se il video è verticale - per applicare soglie più restrittive
  static Map<String, dynamic> _parseBrightnessFromSignalStats(String output, {bool isVertical = false}) {
    final stats = <String, dynamic>{};
    final brightnessValues = <double>[];
    
    // Estrai tutti i valori YAVG (luminosità media per frame)
    final yavgMatches = RegExp(r'YAVG:\s*([\d.]+)').allMatches(output);
    for (final match in yavgMatches) {
      final value = double.tryParse(match.group(1) ?? '');
      if (value != null) {
        brightnessValues.add(value);
      }
    }
    
    if (brightnessValues.isEmpty) {
      return {'success': false, 'error': 'Nessun dato di luminosità trovato'};
    }
    
    // Calcola statistiche
    brightnessValues.sort();
    final avgBrightness = brightnessValues.reduce((a, b) => a + b) / brightnessValues.length;
    final minBrightness = brightnessValues.first;
    final maxBrightness = brightnessValues.last;
    final medianBrightness = brightnessValues[brightnessValues.length ~/ 2];
    
    stats['average_brightness'] = avgBrightness;
    stats['min_brightness'] = minBrightness;
    stats['max_brightness'] = maxBrightness;
    stats['median_brightness'] = medianBrightness;
    stats['contrast'] = maxBrightness - minBrightness;
    stats['contrast_normalized'] = (maxBrightness - minBrightness) / 255.0;
    
    // Determina se troppo scuro/chiaro - SOGLIE MOLTO PIÙ RESTRITTIVE
    // IMPORTANTE: Solo video VERAMENTE troppo scuri vengono corretti
    // Video normali (>= 100/255) NON vengono MAI modificati
    // NOTA: Per video verticali, le soglie sono ancora più restrittive per evitare correzioni errate
    // I video verticali spesso hanno caratteristiche di luminosità diverse e non devono essere modificati
    final tooDarkThreshold = isVertical ? 50.0 : 70.0;  // Per verticali: MOLTO più restrittivo (solo < 50/255)
    final tooBrightThreshold = isVertical ? 255.0 : 240.0;  // Per verticali: mai considerare troppo chiaro
    
    stats['is_too_dark'] = avgBrightness < tooDarkThreshold;  // Soglia molto bassa - solo video estremamente scuri
    stats['is_too_bright'] = avgBrightness > tooBrightThreshold;  // Soglia molto alta - solo video estremamente chiari
    stats['low_contrast'] = (maxBrightness - minBrightness) < 50.0;  // < 20% del range (molto più restrittivo)
    
    if (isVertical) {
      appLog('   📐 Video VERTICALE rilevato - soglie più restrittive applicate');
      appLog('      Soglia "troppo scuro" per verticali: < $tooDarkThreshold (vs 70 per orizzontali)');
    }
    
    // Calcola correzioni raccomandate - SOLO se necessario
    // IMPORTANTE: NON SCURIRE MAI I VIDEO - Solo aumentare luminosità se troppo scuri
    // Video normali (80-255) NON vengono modificati
    // Per video verticali: ancora più conservativo - solo se estremamente scuri
    final targetBrightness = 128.0;  // Target: 50% luminosità
    final correctionThreshold = isVertical ? 50.0 : 80.0;  // Per verticali: solo se < 50/255
    
    if (avgBrightness < correctionThreshold) {
      // Solo se veramente troppo scuro, aumenta luminosità
      final brightnessDiff = targetBrightness - avgBrightness;
      // Per video verticali: correzione più conservativa
      final maxCorrection = isVertical ? 0.2 : 0.3;  // Max +0.2 per verticali invece di +0.3
      stats['recommended_brightness'] = (brightnessDiff / 255.0 * 0.8).clamp(0.0, maxCorrection);
      appLog('   → Video troppo scuro (${avgBrightness.toStringAsFixed(1)}), aumentando luminosità');
      if (isVertical) {
        appLog('      ⚠️ Video VERTICALE - correzione conservativa applicata (max +0.2)');
      }
    } else {
      // Video con luminosità normale o chiara - NON modificare (mai scurire!)
      stats['recommended_brightness'] = 0.0;
      appLog('   ✅ Luminosità normale/chiara (${avgBrightness.toStringAsFixed(1)}), nessuna correzione necessaria');
      if (isVertical && avgBrightness >= correctionThreshold) {
        appLog('      📐 Video VERTICALE con luminosità normale - GARANTITO nessuna modifica');
      }
    }
    
    // Contrasto raccomandato
    final targetContrast = 0.5;
    final currentContrastNorm = stats['contrast_normalized'] as double;
    if (currentContrastNorm < 0.3) {
      stats['recommended_contrast'] = 1.0 + ((targetContrast - currentContrastNorm) * 0.5).clamp(0.0, 0.3);
    } else {
      stats['recommended_contrast'] = 1.0;
    }
    
    // Gamma raccomandato
    // IMPORTANTE: Gamma < 1.0 scurisce, quindi mai ridurre gamma per video chiari
    if (avgBrightness < 100) {
      // Solo se troppo scuro, aumenta gamma per schiarire
      stats['recommended_gamma'] = 1.0 + ((100 - avgBrightness) / 255.0 * 0.3).clamp(0.0, 0.3);
    } else {
      // Video normali o chiari - gamma = 1.0 (nessuna modifica, mai scurire)
      stats['recommended_gamma'] = 1.0;
    }
    
    return {
      'success': true,
      ...stats,
    };
  }
  
  static Future<Map<String, dynamic>> _analyzeVideoCharacteristics(
    Map<String, dynamic> analysis, 
    String inputPath
  ) async {
    final issues = <String>[];
    final recommendations = <String>[];
    final details = <String, dynamic>{};

    try {
      final streams = analysis['streams'] as List<dynamic>?;
      final format = analysis['format'] as Map<String, dynamic>?;
      
      if (streams == null || streams.isEmpty) {
        return {
          'quality_issues': ['unknown_format'],
          'recommendations': ['Verifica il formato del file'],
          'details': details
        };
      }

      // Cerca lo stream video - metodo più robusto
      dynamic videoStream;
      for (final stream in streams) {
        if (stream is Map<String, dynamic> && stream['codec_type'] == 'video') {
          videoStream = stream;
          break;
        }
      }

      if (videoStream == null) {
        // Se non trova stream video esplicitamente, prova a prendere il primo stream
        videoStream = streams.isNotEmpty ? streams[0] : null;
        if (videoStream == null) {
          return {
            'quality_issues': ['no_video_stream'],
            'recommendations': ['File non contiene stream video'],
            'details': details
          };
        }
      }

      // Analisi risoluzione e orientamento
      final width = _safeParseInt(videoStream['width']);
      final height = _safeParseInt(videoStream['height']);
      
      if (width != null && height != null) {
        details['resolution'] = '${width}x$height';
        details['resolution_category'] = _getResolutionCategory(width, height);
        
        // Rileva orientamento video (verticale/portrait vs orizzontale/landscape)
        final isVertical = height > width;
        details['is_vertical'] = isVertical;
        details['is_portrait'] = isVertical;
        details['aspect_ratio'] = width / height;
        
        if (width < 1280 || height < 720) {
          issues.add('low_resolution');
          recommendations.add('AI upscaling + Detail enhancement');
        }
      }

      // Analisi bitrate
      final videoBitrate = _safeParseInt(videoStream['bit_rate']);
      final formatBitrate = _safeParseInt(format?['bit_rate']);
      
      final effectiveBitrate = videoBitrate ?? formatBitrate;
      if (effectiveBitrate != null) {
        details['bitrate'] = effectiveBitrate;
        details['bitrate_mbps'] = (effectiveBitrate / 1000000).toStringAsFixed(2);
        
        if (effectiveBitrate < 2000000) { // 2 Mbps
          issues.add('low_bitrate');
          recommendations.add('Compression artifact removal + Debanding');
        }
      }

      // Analisi codec e formato pixel
      final codecName = videoStream['codec_name']?.toString().toLowerCase() ?? 'unknown';
      final pixFmt = videoStream['pix_fmt']?.toString().toLowerCase() ?? 'unknown';
      
      details['codec'] = codecName;
      details['pixel_format'] = pixFmt;
      
      // Rileva problemi specifici per codec
      if (codecName.contains('mpeg') || codecName.contains('h263') || 
          codecName.contains('wmv') || codecName.contains('divx')) {
        issues.add('old_codec');
        recommendations.add('Modern codec conversion + Quality enhancement');
      }

      // Analisi framerate
      final frameRateStr = videoStream['r_frame_rate']?.toString() ?? '';
      final frameRate = _parseFrameRate(frameRateStr);
      if (frameRate > 0) {
        details['frame_rate'] = frameRate;
        if (frameRate < 24) {
          issues.add('low_frame_rate');
          recommendations.add('Frame interpolation (se necessario)');
        }
      }

      // Analisi HDR
      final colorPrimaries = videoStream['color_primaries']?.toString().toLowerCase();
      final colorTransfer = videoStream['color_transfer']?.toString().toLowerCase();
      
      if (colorTransfer?.contains('bt2020') == true || 
          colorPrimaries?.contains('bt2020') == true) {
        issues.add('hdr_content');
        recommendations.add('HDR tone mapping per display SDR');
        details['hdr'] = true;
      }

      // Analisi interlacciamento
      final fieldOrder = videoStream['field_order']?.toString().toLowerCase();
      if (fieldOrder != null && fieldOrder != 'progressive') {
        issues.add('interlaced');
        recommendations.add('Deinterlacing avanzato');
      }

      // Analisi dimensioni file per rapporto qualità
      final file = File(inputPath);
      if (await file.exists()) {
        final fileSize = await file.length();
        final duration = double.tryParse(videoStream['duration']?.toString() ?? '0') ?? 0;
        
        if (duration > 0) {
          final bitrateFromSize = (fileSize * 8) / duration;
          details['file_size_mb'] = (fileSize / (1024 * 1024)).toStringAsFixed(2);
          details['calculated_bitrate'] = bitrateFromSize.toInt();
          
          if (bitrateFromSize < 1000000) { // 1 Mbps
            issues.add('heavy_compression');
            recommendations.add('Advanced compression cleanup + Noise reduction');
          }
        }
      }

    } catch (e) {
      appLog('Errore nell\'analisi video: $e');
      issues.add('analysis_error');
      recommendations.add('Usa preset di default');
    }

    // Genera preset automatico basato sui problemi rilevati
    final autoPreset = _generateAutoPreset(issues);
    
    return {
      'quality_issues': issues,
      'recommendations': recommendations,
      'auto_preset': autoPreset.toMap(),
      'details': details
    };
  }

  // Metodo helper per parsing sicuro di interi
  static int? _safeParseInt(dynamic value) {
    if (value == null) return null;
    try {
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return int.tryParse(value.toString());
    } catch (e) {
      return null;
    }
  }

  static String _getResolutionCategory(int width, int height) {
    if (width >= 7680 || height >= 4320) return '8K';
    if (width >= 3840 || height >= 2160) return '4K';
    if (width >= 2560 || height >= 1440) return '2K';
    if (width >= 1920 || height >= 1080) return 'Full HD';
    if (width >= 1280 || height >= 720) return 'HD';
    return 'SD';
  }

  static double _parseFrameRate(String frameRateStr) {
    try {
      final parts = frameRateStr.split('/');
      if (parts.length == 2) {
        final num = double.parse(parts[0]);
        final den = double.parse(parts[1]);
        return den > 0 ? num / den : num;
      }
      return double.tryParse(frameRateStr) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  static VideoFilters _generateAutoPreset(List<String> issues) {
    // Preset per video di BASSA QUALITÀ con problemi multipli
    final hasMultipleIssues = issues.length >= 3;
    final hasLowQuality = issues.contains('low_resolution') ||
                         issues.contains('low_bitrate') ||
                         issues.contains('heavy_compression');

    VideoFilters base;
    if (hasMultipleIssues && hasLowQuality) {
      base = VideoFilters.getLowQualityOptimization();
    } else if (issues.contains('heavy_compression') && issues.contains('low_resolution')) {
      base = VideoFilters.getLowQualityOptimization().copyWith(
        superResolutionMethod: 'nnedi3',
        enableDetailEnhancement: true,
      );
    } else if (issues.contains('low_bitrate') && issues.contains('old_codec')) {
      base = VideoFilters.getAICleanupPreset().copyWith(
        advancedDenoiseMethod: 'nlmeans',
        temporalDenoise: 0.6,
      );
    } else if (issues.contains('low_resolution')) {
      base = VideoFilters.getSuperResolution().copyWith(
        detailEnhanceStrength: 0.6,
        enableEdgeSharpening: true,
        textureBoost: 0.4,
      );
    } else if (issues.contains('interlaced') && issues.contains('old_codec')) {
      base = VideoFilters.getFilmRestoration().copyWith(
        enableDeinterlace: true,
        advancedDenoiseMethod: 'vaguedenoiser',
        temporalDenoise: 0.3,
      );
    } else if (issues.contains('hdr_content')) {
      base = VideoFilters.getUltraQualityPreset().copyWith(
        enableHdrToneMapping: true,
        colorProfile: 'cinematic',
      );
    } else if (issues.contains('low_frame_rate')) {
      base = VideoFilters.getProfessionalEnhancement().copyWith(
        sharpness: 1.1,
        contrast: 1.1,
        enableDetailEnhancement: true,
      );
    } else if (issues.contains('heavy_compression') || issues.contains('low_bitrate')) {
      base = VideoFilters.getHeavyCompressionCleanup();
    } else {
      base = VideoFilters.getUltraQualityPreset();
    }
    return base;
  }

  static Future<Map<String, dynamic>> advancedQualityAnalysis(String inputPath) async {
    try {
      final process = await Process.run('ffmpeg', [
        '-i', inputPath,
        '-vf', 'signalstats=stat=out',
        '-f', 'null',
        '-'
      ]);

      final stderr = process.stderr.toString();
      
      return {
        'success': true,
        'analysis': _parseSignalStats(stderr),
        'recommendations': _generateAdvancedRecommendations(stderr)
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Advanced analysis failed: $e'
      };
    }
  }

  static Map<String, dynamic> _parseSignalStats(String statsOutput) {
    final analysis = <String, dynamic>{};
    
    if (statsOutput.contains('VRE')) {
      analysis['interlacing_artifacts'] = true;
    }
    
    if (statsOutput.contains('BRNG')) {
      analysis['clipped_highlights'] = true;
    }
    
    if (statsOutput.contains('SAT')) {
      analysis['saturation_issues'] = true;
    }
    
    return analysis;
  }

  static List<String> _generateAdvancedRecommendations(String statsOutput) {
    final recommendations = <String>[];
    
    if (statsOutput.contains('VRE')) {
      recommendations.add('Apply advanced deinterlacing (YADIF)');
    }
    
    if (statsOutput.contains('BRNG')) {
      recommendations.add('Use tone mapping for highlight recovery');
    }
    
    if (statsOutput.contains('SAT')) {
      recommendations.add('Adjust color saturation and vibrance');
    }
    
    return recommendations;
  }
}