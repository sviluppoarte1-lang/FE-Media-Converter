import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:video_converter_pro/models/video_filters.dart';
import 'package:video_converter_pro/models/audio_filters.dart';
import 'package:video_converter_pro/models/image_filters.dart';
import 'package:video_converter_pro/models/media_type.dart';
import 'package:video_converter_pro/services/video_pre_processor.dart';
import 'package:video_converter_pro/services/image_upscaler_service.dart';
import 'package:video_converter_pro/services/video_upscaler_service.dart';
import 'package:video_converter_pro/services/models_manager_service.dart';
import 'package:video_converter_pro/services/drunet_service.dart';
import 'package:video_converter_pro/utils/app_log.dart';
import 'package:video_converter_pro/utils/processing_fps_sanitize.dart';
import 'package:path/path.dart' as p;

/// Optional [processingFps]: video frames processed per second when FFmpeg reports it.
typedef MediaConvertOnProgress = void Function(
  double progress,
  String timeRemaining, {
  double? processingFps,
});

/// Estrae 1–2 righe significative dallo stderr FFmpeg (esclude banner build).
String _ffmpegStderrSnippet(String stderr, {int maxLen = 450}) {
  final lines = stderr
      .split('\n')
      .where((line) =>
          line.trim().isNotEmpty &&
          !line.contains('ffmpeg version') &&
          !line.contains('built with') &&
          !line.contains('configuration:'))
      .take(2)
      .toList();
  if (lines.isEmpty) return '';
  var s = lines.map((l) => l.trim()).join('\n');
  if (s.length > maxLen) s = '${s.substring(0, maxLen)}…';
  return s;
}

String _appendFfmpegDetail(String userMessage, String stderr) {
  final sn = _ffmpegStderrSnippet(stderr);
  if (sn.isEmpty) return userMessage;
  return '$userMessage\n$sn';
}

String _progressLabel(String key) {
  final lang = Platform.localeName.toLowerCase();
  final isIt = lang.startsWith('it');
  final isEs = lang.startsWith('es');
  final isFr = lang.startsWith('fr');
  final isDe = lang.startsWith('de');
  final isPt = lang.startsWith('pt');
  switch (key) {
    case 'preparing':
      if (isIt) return 'Preparazione...';
      if (isEs) return 'Preparando...';
      if (isFr) return 'Preparation...';
      if (isDe) return 'Vorbereitung...';
      if (isPt) return 'Preparando...';
      return 'Preparing...';
    case 'remaining':
      if (isIt) return 'Restante';
      if (isEs) return 'Restante';
      if (isFr) return 'Restant';
      if (isDe) return 'Verbleibend';
      if (isPt) return 'Restante';
      return 'Remaining';
    case 'completed':
      if (isIt) return 'Completato';
      if (isEs) return 'Completado';
      if (isFr) return 'Termine';
      if (isDe) return 'Abgeschlossen';
      if (isPt) return 'Concluido';
      return 'Completed';
    case 'analyzing':
      if (isIt) return 'Analisi video in corso...';
      if (isEs) return 'Analizando video...';
      if (isFr) return 'Analyse vidéo en cours...';
      if (isDe) return 'Video wird analysiert...';
      if (isPt) return 'Analisando vídeo...';
      return 'Analyzing video...';
    case 'checking_acceleration':
      if (isIt) return 'Verifica accelerazione GPU/filtri...';
      if (isEs) return 'Comprobando aceleración GPU/filtros...';
      if (isFr) return 'Vérification accélération GPU/filtres...';
      if (isDe) return 'GPU/Filter-Beschleunigung wird geprüft...';
      if (isPt) return 'Verificando aceleração GPU/filtros...';
      return 'Checking GPU/filter acceleration...';
    case 'drunet_checking':
      if (isIt) return 'DRUNet: controllo dipendenze e modello...';
      if (isEs) return 'DRUNet: comprobando dependencias y modelo...';
      if (isFr) return 'DRUNet : vérification dépendances et modèle...';
      if (isDe) return 'DRUNet: Abhängigkeiten und Modell werden geprüft...';
      if (isPt) return 'DRUNet: verificando dependências e modelo...';
      return 'DRUNet: checking dependencies and model...';
    case 'drunet_extract':
      if (isIt) return 'DRUNet: estrazione frame...';
      if (isEs) return 'DRUNet: extrayendo fotogramas...';
      if (isFr) return 'DRUNet : extraction des images...';
      if (isDe) return 'DRUNet: Frames werden extrahiert...';
      if (isPt) return 'DRUNet: extraindo frames...';
      return 'DRUNet: extracting frames...';
    case 'drunet_denoise':
      if (isIt) return 'DRUNet: denoise AI in corso (può richiedere tempo)...';
      if (isEs) return 'DRUNet: denoise IA en curso (puede tardar)...';
      if (isFr) return 'DRUNet : débruitage IA en cours (peut prendre du temps)...';
      if (isDe) return 'DRUNet: KI-Entrauschen läuft (kann dauern)...';
      if (isPt) return 'DRUNet: denoise IA em andamento (pode demorar)...';
      return 'DRUNet: AI denoising in progress (may take time)...';
    case 'drunet_remux':
      if (isIt) return 'DRUNet: ricostruzione video...';
      if (isEs) return 'DRUNet: reconstruyendo vídeo...';
      if (isFr) return 'DRUNet : reconstruction vidéo...';
      if (isDe) return 'DRUNet: Video wird neu aufgebaut...';
      if (isPt) return 'DRUNet: reconstruindo vídeo...';
      return 'DRUNet: rebuilding video...';
    case 'drunet_done':
      if (isIt) return 'DRUNet pre-pass completato, avvio encoding...';
      if (isEs) return 'Pre-pass DRUNet completado, iniciando codificación...';
      if (isFr) return 'Pré-passe DRUNet terminée, démarrage encodage...';
      if (isDe) return 'DRUNet-Vorlauf abgeschlossen, Encoding startet...';
      if (isPt) return 'Pré-pass DRUNet concluído, iniciando codificação...';
      return 'DRUNet pre-pass completed, starting encoding...';
    default:
      return key;
  }
}

/// Avvisi NVDEC/CUDA ripristinabili (FFmpeg può continuare in software).
/// Non vanno confusi con errori reali della catena -vf.
bool _stderrIsBenignCudaNvdecNoise(String stderr) {
  final s = stderr;
  if (!s.contains('invalid') && !s.contains('Invalid')) return false;
  final hasCudaNoise = s.contains('CUDA_ERROR') ||
      s.contains('cuvid') ||
      s.contains('cuvidCreateDecoder') ||
      s.contains('hwaccel initialisation') ||
      s.contains('NVDEC') ||
      s.contains('nvdec');
  if (!hasCudaNoise) return false;
  // Errore reale di filtro: non mascherare
  if (s.contains('No such filter') ||
      s.contains('Error initializing filter') ||
      s.contains('Error reinitializing filters') ||
      s.contains('Error initializing complex filters')) {
    return false;
  }
  return true;
}

/// Indizi di errore sulla catena filtri (non solo la riga versione libavfilter).
bool _stderrSuggestsVideoFilterChainFailure(String stderr) {
  final lower = stderr.toLowerCase();
  if (lower.contains('no such filter')) return true;
  if (lower.contains('error initializing filter')) return true;
  if (lower.contains('error reinitializing filters')) return true;
  if (lower.contains('error initializing complex filters')) return true;
  if (lower.contains('failed to configure') && lower.contains('filter')) return true;
  return false;
}

enum _EncodePolicy { speed, balanced, quality }

bool _stderrSuggestsUnsupportedHwEncoderOption(String stderr) {
  final s = stderr.toLowerCase();
  return s.contains('unrecognized option') ||
      s.contains('option not found') ||
      s.contains('error setting option') ||
      s.contains('cannot parse option') ||
      s.contains('invalid value') ||
      s.contains('unknown option') ||
      s.contains('unsupported option') ||
      s.contains('cannot set option');
}

class FFmpegService {
  final Map<String, Process> _activeProcesses = {};
  final Map<String, StreamSubscription> _outputSubscriptions = {};
  Map<String, bool>? _availableFilters;
  Map<String, dynamic>? _availableGpuAccelerations;
  bool _filtersChecked = false;
  bool _gpuChecked = false;
  final ImageUpscalerService _imageUpscaler = ImageUpscalerService();
  late final VideoUpscalerService _videoUpscaler;
  Future<void>? _capabilityWarmup;

  FFmpegService() {
    _videoUpscaler = VideoUpscalerService(this);
    // Preload FFmpeg filter/GPU capabilities early to reduce first-conversion latency.
    _capabilityWarmup = _warmupCapabilities();
  }

  Future<void> _warmupCapabilities() async {
    try {
      await _checkAvailableFilters();
      await _checkGpuAcceleration();
    } catch (e) {
      appLog('⚠️ [FFmpegService] Warmup capabilities failed: $e');
    }
  }

  String _estimateDrunetSoftEtaLabel(String inputPath) {
    try {
      final file = File(inputPath);
      final sizeMb = (file.lengthSync() / (1024 * 1024)).clamp(1, 50000).toDouble();
      // Heuristic: pre-pass DRUNet can vary a lot by GPU/CPU; provide a soft range.
      final minMinutes = (sizeMb / 120).clamp(1, 90).round();
      final maxMinutes = (sizeMb / 35).clamp(minMinutes + 1, 240).round();
      return '$minMinutes-$maxMinutes min';
    } catch (_) {
      return '2-15 min';
    }
  }
  
  Completer<void>? _filtersCheckCompleter;
  Completer<void>? _gpuCheckCompleter;
  
  Future<Map<String, dynamic>> convertMedia({
    required String taskId,
    required String inputPath,
    required String outputPath,
    required MediaType mediaType,
    required int videoQuality,
    required int audioQuality,
    required String audioCodec,
    required String videoCodec,
    required int videoBitrate,
    required String videoBitrateMode,
    required VideoFilters videoFilters,
    required AudioFilters audioFilters,
    required ImageFilters imageFilters,
    required int cpuThreads,
    required bool useGpu,
    required String gpuType,
    required MediaConvertOnProgress onProgress,
    bool overwriteExisting = false,
    bool extractAudioFromVideo = false,
  }) async {
    String? drunetTempPath;
    try {
      appLog('🔧 [FFmpegService] Starting conversion for task: $taskId');
      appLog('📁 Input: $inputPath');
      appLog('📁 Output: $outputPath');
      appLog('🎬 Media Type: $mediaType');
      onProgress(0.01, 'phase.preparing');

      Map<String, dynamic>? videoAnalysis;
      final runBlockingPreAnalysis =
          mediaType == MediaType.video &&
          Platform.environment['FE_ENABLE_PRE_ANALYSIS'] == '1';
      if (runBlockingPreAnalysis) {
        onProgress(0.02, 'phase.analyzing');
        appLog('🔍 [FFmpegService] Eseguendo analisi video pre-rendering...');
        appLog('   → Analisi luminosità e contrasto in corso (timeout: 4s)...');
        try {
          videoAnalysis = await VideoPreProcessor.analyzeVideoQuality(inputPath)
              .timeout(
                const Duration(seconds: 4),
                onTimeout: () {
                  appLog('⚠️ [FFmpegService] Timeout analisi video (4s) - continuo senza correzioni automatiche');
                  return {
                    'success': false,
                    'error': 'Analisi timeout dopo 4 secondi',
                    'quality_issues': [],
                    'recommendations': []
                  };
                },
              );
        } catch (e) {
          appLog('⚠️ [FFmpegService] Errore durante analisi video: $e - continuo senza correzioni');
          videoAnalysis = {
            'success': false,
            'error': 'Errore analisi: $e',
            'quality_issues': [],
            'recommendations': []
          };
        }
        if (videoAnalysis['success'] == true) {
          appLog('📊 Video analysis completed - Quality issues: ${videoAnalysis['quality_issues']?.length ?? 0}');
          appLog('💡 Recommendations: ${videoAnalysis['recommendations']}');
          
          final pixelAnalysis = videoAnalysis['pixel_analysis'] as Map<String, dynamic>?;
          if (pixelAnalysis != null && pixelAnalysis['success'] == true) {
            final avgBrightness = pixelAnalysis['average_brightness'] as double?;
            final avgContrast = pixelAnalysis['average_contrast'] as double?;
            final isTooDark = pixelAnalysis['is_too_dark'] as bool? ?? false;
            final lowContrast = pixelAnalysis['low_contrast'] as bool? ?? false;
            final recommendedBrightness = pixelAnalysis['recommended_brightness'] as double? ?? 0.0;
            final recommendedContrast = pixelAnalysis['recommended_contrast'] as double? ?? 1.0;
            
            appLog('   📊 Analisi pixel-per-pixel:');
            appLog('      Luminosità media: ${avgBrightness?.toStringAsFixed(2) ?? "N/A"}');
            appLog('      Contrasto medio: ${avgContrast?.toStringAsFixed(2) ?? "N/A"}');
            appLog('      Troppo scuro: $isTooDark');
            appLog('      Contrasto basso: $lowContrast');
            appLog('      Correzione brightness raccomandata: ${recommendedBrightness.toStringAsFixed(3)}');
            appLog('      Correzione contrast raccomandata: ${recommendedContrast.toStringAsFixed(3)}');
            
            if (isTooDark || lowContrast) {
              appLog('   ⚠️ Problemi rilevati - verranno applicate correzioni automatiche');
            } else {
              appLog('   ✅ Luminosità e contrasto ottimali - nessuna correzione necessaria');
            }
          }
        } else {
          appLog('⚠️ [FFmpegService] Analisi video fallita: ${videoAnalysis['error']}');
          appLog('   → Continuo senza correzioni automatiche');
        }
      } else if (mediaType == MediaType.video) {
        appLog('⚡ [FFmpegService] Pre-analisi video bloccante disabilitata (FE_ENABLE_PRE_ANALYSIS != 1)');
      }

      var conversionInputPath = inputPath;

      final inputValidation = await _validateInputFile(conversionInputPath);
      if (!inputValidation['success']) {
        return inputValidation;
      }

      final outputValidation = await _validateAndSanitizeOutputPath(outputPath, mediaType, overwriteExisting: overwriteExisting);
      if (!outputValidation['success']) {
        if (outputValidation['error'] == 'file_exists' && !overwriteExisting) {
          return {
            'success': false,
            'error': 'file_exists',
            'file_path': outputValidation['file_path'],
            'message': outputValidation['message'],
          };
        }
        return outputValidation;
      }

      final sanitizedOutputPath = outputValidation['sanitized_path']!;
      appLog('✅ Output path sanitized: $sanitizedOutputPath');

      final audioExtRegexEarly = RegExp(
        r'\.(mp3|wav|aac|flac|ogg|m4a|wma|opus)$',
        caseSensitive: false,
      );
      final videoExtRegexEarly = RegExp(
        r'\.(mp4|avi|mkv|mov|wmv|flv|webm|m4v|3gp|ts|mts|m2ts)$',
        caseSensitive: false,
      );
      final isAudioExtraction = (mediaType == MediaType.video &&
              (extractAudioFromVideo || audioExtRegexEarly.hasMatch(sanitizedOutputPath))) ||
          (mediaType == MediaType.audio &&
              videoExtRegexEarly.hasMatch(conversionInputPath));

      await (_capabilityWarmup ?? Future<void>.value());
      onProgress(0.04, 'phase.checking_acceleration');
      await _checkAvailableFilters();
      await _checkGpuAcceleration();

      if (mediaType == MediaType.video &&
          videoFilters.enableDRUNetDenoising &&
          !isAudioExtraction) {
        onProgress(0.05, 'phase.drunet.checking');
        var drDeps = await DRUNetService.checkDependencies();
        if (!drDeps) {
          onProgress(0.055, 'phase.drunet.installing');
          final depInstall = await DRUNetService.installDependencies(
            onProgress: (_) {},
          );
          drDeps = depInstall['success'] == true;
          if (drDeps) {
            onProgress(0.058, 'phase.drunet.install_done');
          } else {
            appLog('⚠️ [FFmpegService] DRUNet auto dependency setup failed: ${depInstall['error']}');
          }
        }
        if (drDeps) {
          final etaSoft = _estimateDrunetSoftEtaLabel(conversionInputPath);
          onProgress(0.055, 'phase.drunet_eta:$etaSoft');
          String? mp;
          final modelReady = await ModelsManagerService.isDRUNetModelReady();
          if (modelReady) {
            final st = await ModelsManagerService.getModelsStatus();
            final dr = st['drunet'] as Map<String, dynamic>?;
            mp = dr?['path'] as String?;
          }
          final drOutPath = p.join(
            Directory.systemTemp.path,
            'fe_drunet_$taskId${DateTime.now().millisecondsSinceEpoch}.mkv',
          );
          drunetTempPath = drOutPath;
          final drResult = await DRUNetService.denoiseVideoFull(
            inputVideo: conversionInputPath,
            outputVideo: drOutPath,
            noiseLevel: videoFilters.drunetNoiseLevel,
            modelPath: mp,
            device: videoFilters.drunetDevice,
            onProgress: (p, {processingFps}) {
              final mapped = (0.06 + (p.clamp(0.0, 1.0) * 0.26)).clamp(0.06, 0.32);
              if (p < 0.15) {
                onProgress(mapped, 'phase.drunet.extract', processingFps: processingFps);
              } else if (p < 0.75) {
                onProgress(mapped, 'phase.drunet.denoise', processingFps: processingFps);
              } else if (p < 1.0) {
                onProgress(mapped, 'phase.drunet.remux', processingFps: processingFps);
              } else {
                onProgress(mapped, 'phase.drunet.done', processingFps: processingFps);
              }
            },
          );
          if (drResult['success'] == true && drResult['output_path'] != null) {
            conversionInputPath = drResult['output_path'] as String;
            appLog('🧠 [FFmpegService] DRUNet pre-pass completato → input temporaneo');
          } else {
            appLog(
              '⚠️ [FFmpegService] DRUNet pre-pass saltato: ${drResult['error'] ?? 'unknown'}',
            );
            try {
              final f = File(drOutPath);
              if (f.existsSync()) await f.delete();
            } catch (_) {}
            drunetTempPath = null;
          }
        } else {
          onProgress(0.06, 'phase.drunet.not_available');
          appLog(
            '⚠️ [FFmpegService] DRUNet: assicurati che scripts/python/drunet_denoiser.py esista '
            'e che numpy/opencv siano installati (es. scripts/python/setup_python_env.sh)',
          );
        }
      }

      final drunetPrepassApplied =
          drunetTempPath != null && conversionInputPath != inputPath;
      var encodeFilters = videoFilters;
      if (drunetPrepassApplied) {
        encodeFilters = videoFilters.copyWith(enableDRUNetDenoising: false);
      }

      String effectiveGpuType = gpuType;
      if (gpuType == 'auto' && _availableGpuAccelerations != null) {
        final detectedGpu = _availableGpuAccelerations!['detected_gpu'] as String?;
        if (detectedGpu != null && detectedGpu != 'none') {
          effectiveGpuType = detectedGpu;
          appLog('🔍 Auto-detected GPU: $effectiveGpuType');
        }
      }
      
      VideoFilters effectiveFilters = encodeFilters;
      if (encodeFilters.gpuVendor == 'auto' && effectiveGpuType != 'auto' && effectiveGpuType != 'none') {
        effectiveFilters = encodeFilters.copyWith(gpuVendor: effectiveGpuType);
      }

      List<String> command;
      bool gpuHwAccelDecodeActive = false;
      var useGpuEncodeVideo =
          _shouldUseGpuVideoEncode(effectiveFilters, useGpu, mediaType, isAudioExtraction);
      int safeThreads = 0;

      if (mediaType == MediaType.image) {
        command = ['ffmpeg', '-y', '-loglevel', 'warning'];
        safeThreads = _getSafeThreadCount(cpuThreads, false);
        if (useGpu && effectiveFilters.enableGpuAcceleration) {
          final gpuArgs = _getGpuAccelerationArgs(effectiveFilters, hasVideoFilters: false);
          if (gpuArgs.isNotEmpty) {
            command.addAll(gpuArgs);
            gpuHwAccelDecodeActive = true;
          }
        }
        command.addAll(['-i', conversionInputPath]);
        command.addAll(['-threads', safeThreads.toString()]);
        appLog(
          '🖼️ Immagini: hwaccel decode=${gpuHwAccelDecodeActive ? "yes" : "no"} '
          '(threads: $safeThreads)',
        );
      } else if (mediaType == MediaType.audio) {
        command = ['ffmpeg', '-y', '-loglevel', 'info'];
        command.addAll(['-analyzeduration', '10000000']);
        command.addAll(['-probesize', '10000000']);
        command.addAll(['-i', conversionInputPath]);
        safeThreads = _getSafeThreadCount(cpuThreads, false);
        command.addAll(['-threads', safeThreads.toString()]);
        useGpuEncodeVideo = false;
        appLog('🎵 Audio: CPU only (threads: $safeThreads, no GPU)');
      } else {
        command = ['ffmpeg', '-y', '-loglevel', 'info'];
        command.addAll(['-analyzeduration', '10000000']);
        command.addAll(['-probesize', '10000000']);
        command.addAll(['-fflags', '+genpts+igndts']);
        final hasVideoFilters = effectiveFilters.hasActiveFilters ||
            effectiveFilters.enableDetailEnhancement ||
            effectiveFilters.denoiseStrength > 0 ||
            effectiveFilters.sharpness != 1.0;
        if (useGpu && effectiveFilters.enableGpuAcceleration) {
          final gpuArgs =
              _getGpuAccelerationArgs(effectiveFilters, hasVideoFilters: hasVideoFilters);
          if (gpuArgs.isNotEmpty) {
            command.addAll(gpuArgs);
            gpuHwAccelDecodeActive = true;
            appLog('🎬 Video: hwaccel decode attivo ($effectiveGpuType)');
          }
        }
        command.addAll(['-i', conversionInputPath]);
        safeThreads = _getSafeThreadCount(cpuThreads, useGpuEncodeVideo);
        command.addAll(['-threads', safeThreads.toString()]);
        appLog(
          '🎬 Video: hwaccel decode=${gpuHwAccelDecodeActive ? "yes" : "no"}, '
          'encode GPU=${useGpuEncodeVideo ? "yes" : "no"} (threads: $safeThreads)',
        );
      }

      List<String> finalCommand;

      if (isAudioExtraction) {
        appLog('🎵 [FFmpegService] Estrazione audio da video - comando dedicato');
        useGpuEncodeVideo = false;
        finalCommand = _buildAudioExtractionCommand(
          inputPath: conversionInputPath,
          outputPath: sanitizedOutputPath,
          audioQuality: audioQuality,
          audioCodec: audioCodec,
          audioFilters: audioFilters,
        );
      } else {
        switch (mediaType) {
          case MediaType.video:
            finalCommand = await _buildVideoCommandWithAnalysis(
              command: command,
              inputPath: conversionInputPath,
              outputPath: sanitizedOutputPath,
              videoQuality: videoQuality,
              audioQuality: audioQuality,
              audioCodec: audioCodec,
              videoCodec: videoCodec,
              videoBitrate: videoBitrate,
              videoBitrateMode: videoBitrateMode,
              videoFilters: effectiveFilters,
              audioFilters: audioFilters,
              cpuThreads: safeThreads,
              useGpu: useGpuEncodeVideo,
              gpuType: effectiveGpuType,
              videoAnalysis: videoAnalysis,
            );
            break;
          
          case MediaType.audio:
            finalCommand = _buildAudioCommand(
              command: command,
              outputPath: sanitizedOutputPath,
              audioQuality: audioQuality,
              audioCodec: audioCodec,
              audioFilters: audioFilters,
            );
            break;
          
          case MediaType.image:
            finalCommand = await _buildImageCommand(
              command: command,
              inputPath: inputPath,
              outputPath: sanitizedOutputPath,
              imageFilters: imageFilters,
              onProgress: (p, m) => onProgress(p, m),
            );
            break;
        }
      }

      appLog('⚡ Final FFmpeg command ready');
      onProgress(0.33, 'phase.encoding_start');

      final reportGpuUsed = switch (mediaType) {
        MediaType.video => useGpuEncodeVideo && !isAudioExtraction,
        MediaType.image => gpuHwAccelDecodeActive,
        _ => false,
      };

      MediaConvertOnProgress encodeOnProgress = onProgress;
      if (drunetPrepassApplied) {
        encodeOnProgress = (progress, timeRemaining, {processingFps}) {
          final mapped = 0.33 + progress.clamp(0.0, 1.0) * 0.67;
          onProgress(mapped, timeRemaining, processingFps: processingFps);
        };
      }

      try {
        return await _runFFmpegCommand(
        taskId: taskId,
        command: finalCommand,
        inputPath: conversionInputPath,
        outputPath: sanitizedOutputPath,
        onProgress: encodeOnProgress,
        useGpu: reportGpuUsed,
      );
      } finally {
        if (drunetTempPath != null) {
          try {
            final f = File(drunetTempPath);
            if (f.existsSync()) await f.delete();
          } catch (_) {}
        }
      }
    } catch (e) {
      if (drunetTempPath != null) {
        try {
          final f = File(drunetTempPath);
          if (f.existsSync()) await f.delete();
        } catch (_) {}
      }
      appLog('💥 Critical error in convertMedia: $e');
      return {
        'success': false,
        'error': 'Errore critico durante la conversione: $e'
      };
    }
  }


  Future<List<String>> _buildVideoCommandWithAnalysis({
    required List<String> command,
    required String inputPath,
    required String outputPath,
    required int videoQuality,
    required int audioQuality,
    required String audioCodec,
    required String videoCodec,
    required int videoBitrate,
    required String videoBitrateMode,
    required VideoFilters videoFilters,
    required AudioFilters audioFilters,
    required int cpuThreads,
    required bool useGpu,
    required String gpuType,
    required Map<String, dynamic>? videoAnalysis,
  }) async {
    appLog('🎬 Building optimized video command with analysis...');

    final optimizedFilters = await _applyAnalysisOptimizations(videoFilters, videoAnalysis);
    
    final videoFilterChain = await _buildOptimizedVideoFilterChain(
      inputPath, 
      optimizedFilters, 
      useGpu,
      videoAnalysis
    );
    
    if (videoFilterChain.isNotEmpty) {
      final optimizedFilterChain = _optimizeFilterChainForPerformance(videoFilterChain, useGpu);
      command.addAll(['-vf', optimizedFilterChain]);
      appLog('🎨 Optimized video filters applied: $optimizedFilterChain');
      
      command.addAll(['-thread_queue_size', useGpu ? '512' : '384']);
      final filterThreads = cpuThreads.clamp(1, 32);
      command.addAll(['-filter_threads', filterThreads.toString()]);
    }

    final audioFilterChain = buildAudioFilterChain(audioFilters);
    if (audioFilterChain.isNotEmpty) {
      command.addAll(['-af', audioFilterChain]);
    }

    final optimizedVideoCodec = _getOptimizedVideoCodec(videoCodec, videoAnalysis, useGpu);
    command.addAll(['-c:v', optimizedVideoCodec]);
    
    final hardwareCodecArgs = _getHardwareCodecOptions(
      optimizedVideoCodec,
      useGpu,
      videoFilters,
      videoAnalysis,
    );
    command.addAll(hardwareCodecArgs);

    final optimizedQuality = _getOptimizedVideoQuality(videoQuality, videoBitrateMode, videoAnalysis);
    if (videoBitrateMode == 'crf') {
      if (optimizedVideoCodec.contains('nvenc') || optimizedVideoCodec.contains('qsv') || 
          optimizedVideoCodec.contains('amf') || optimizedVideoCodec.contains('vaapi')) {
        if (optimizedVideoCodec.contains('nvenc')) {
          command.addAll(['-cq', optimizedQuality.toString()]);
        } else if (optimizedVideoCodec.contains('qsv')) {
          command.addAll(['-global_quality', optimizedQuality.toString()]);
        } else if (optimizedVideoCodec.contains('amf')) {
          command.addAll(['-quality', 'balanced', '-rc', 'vbr_peak', '-qmin', '18', '-qmax', '28']);
          command.addAll(['-b:v', '${optimizedQuality * 100}k']);
        } else if (optimizedVideoCodec.contains('vaapi')) {
          command.addAll(['-global_quality', optimizedQuality.toString()]);
        }
      } else {
        command.addAll(['-crf', optimizedQuality.toString()]);
      }
      appLog('📊 Using optimized quality: $optimizedQuality');
    } else {
      command.addAll(['-b:v', '${optimizedQuality}k']);
      appLog('📊 Using optimized bitrate: ${optimizedQuality}k');
    }

    final safeAudioQuality = audioQuality.clamp(128, 320);
    
    String ffmpegAudioCodec = audioCodec;
    if (audioCodec == 'mp3') {
      ffmpegAudioCodec = 'libmp3lame';
    } else if (audioCodec == 'aac') {
      ffmpegAudioCodec = 'aac';
    } else if (audioCodec == 'opus') {
      ffmpegAudioCodec = 'libopus';
    } else if (audioCodec == 'vorbis') {
      ffmpegAudioCodec = 'libvorbis';
    }
    
    command.addAll(['-c:a', ffmpegAudioCodec]);
    
    if (ffmpegAudioCodec == 'libmp3lame' ||
        ffmpegAudioCodec == 'aac' ||
        ffmpegAudioCodec == 'libopus' ||
        ffmpegAudioCodec == 'libvorbis') {
      command.addAll(['-b:a', '${safeAudioQuality}k']);
      if (ffmpegAudioCodec == 'libopus') {
        command.addAll(['-vbr', 'off']);
      }
    } else {
      command.addAll(['-b:a', '${safeAudioQuality}k']);
    }

    command.addAll([
      '-movflags', '+faststart',
      '-max_muxing_queue_size', '1024',
    ]);
    
    final pixelFormat = _getOptimalPixelFormat(optimizedVideoCodec, useGpu, videoAnalysis);
    if (pixelFormat != null) {
      command.addAll(['-pix_fmt', pixelFormat]);
      appLog('   📐 Pixel format: $pixelFormat');
    } else {
      appLog('   📐 Pixel format: preservato originale (nessuna conversione forzata)');
    }

    if (videoAnalysis != null && videoAnalysis['needs_advanced_processing'] == true) {
      if (!optimizedVideoCodec.contains('nvenc') && !optimizedVideoCodec.contains('qsv') && 
          !optimizedVideoCodec.contains('amf') && !optimizedVideoCodec.contains('vaapi')) {
        command.addAll(['-profile:v', 'high', '-level', '4.1']);
      }
    }
    
    
    if (useGpu) {
      if (!optimizedVideoCodec.contains('nvenc') && !optimizedVideoCodec.contains('qsv') && 
          !optimizedVideoCodec.contains('amf') && !optimizedVideoCodec.contains('vaapi')) {
        command.addAll(['-thread_type', 'frame+slice']);
      }
      command.addAll(['-bufsize', '${videoBitrate * 2}k']); // Buffer doppio del bitrate
    } else {
      command.addAll(['-thread_type', 'frame+slice']);
      final cpuPolicy = _resolveEncodePolicy(
        optimizedVideoCodec,
        videoFilters,
        videoAnalysis,
      );
      if (optimizedVideoCodec == 'libx264') {
        final preset = switch (cpuPolicy) {
          _EncodePolicy.speed => 'veryfast',
          _EncodePolicy.balanced => 'faster',
          _EncodePolicy.quality => 'medium',
        };
        command.addAll(['-preset', preset]);
      } else if (optimizedVideoCodec == 'libx265') {
        final preset = switch (cpuPolicy) {
          _EncodePolicy.speed => 'superfast',
          _EncodePolicy.balanced => 'faster',
          _EncodePolicy.quality => 'medium',
        };
        command.addAll(['-preset', preset]);
        final safeThreads = _getSafeThreadCount(cpuThreads, false);
        command.addAll(['-x265-params', 'threads=$safeThreads']);
      }
    }

    command.add(outputPath);
    
    appLog('✅ Optimized video command built successfully');
    return command;
  }


  Future<VideoFilters> _applyAnalysisOptimizations(
    VideoFilters originalFilters, 
    Map<String, dynamic>? analysis
  ) async {
    if (analysis == null || analysis['success'] != true) {
      return originalFilters;
    }

    final issues = analysis['quality_issues'] as List<dynamic>? ?? [];
    final recommendations = analysis['recommendations'] as List<dynamic>? ?? [];
    
    var optimizedFilters = originalFilters;

    appLog('🔍 Applying optimizations based on analysis:');
    appLog('   Issues: $issues');
    appLog('   Recommendations: $recommendations');

    final pixelAnalysis = analysis['pixel_analysis'] as Map<String, dynamic>?;
    if (pixelAnalysis != null && pixelAnalysis['success'] == true) {
      appLog('   ✅ Analisi pixel-per-pixel disponibile - applicando correzioni automatiche');
      
      final recommendedBrightness = pixelAnalysis['recommended_brightness'] as double?;
      final recommendedContrast = pixelAnalysis['recommended_contrast'] as double?;
      final recommendedGamma = pixelAnalysis['recommended_gamma'] as double?;
      final isTooDark = pixelAnalysis['is_too_dark'] as bool? ?? false;
      final isTooBright = pixelAnalysis['is_too_bright'] as bool? ?? false;
      final lowContrast = pixelAnalysis['low_contrast'] as bool? ?? false;
      
      appLog('   📊 Pixel analysis detected:');
      appLog('      Average brightness: ${pixelAnalysis['average_brightness']?.toStringAsFixed(2)}');
      appLog('      Average contrast: ${pixelAnalysis['average_contrast']?.toStringAsFixed(2)}');
      appLog('      Too dark: $isTooDark, Too bright: $isTooBright, Low contrast: $lowContrast');
      
      if (recommendedBrightness != null && recommendedBrightness > 0.05 && isTooDark) {
        appLog('   🔧 CORREZIONE LUMINOSITÀ: Video troppo scuro, applicando brightness ${recommendedBrightness.toStringAsFixed(3)}');
        final currentBrightness = originalFilters.brightness;
        final newBrightness = (currentBrightness + recommendedBrightness).clamp(0.0, 0.3);  // Solo positivo
        optimizedFilters = optimizedFilters.copyWith(
          brightness: newBrightness,
        );
        appLog('      → Brightness finale: ${newBrightness.toStringAsFixed(3)} (correzione applicata)');
      } else {
        appLog('   ✅ Video normale/chiaro - GARANTITO brightness=0.0 (nessuna modifica)');
        optimizedFilters = optimizedFilters.copyWith(
          brightness: 0.0,  // FORZA a 0.0 per video normali
        );
      }
      
      if (recommendedContrast != null && recommendedContrast > 1.0 && lowContrast) {
        appLog('   🔧 CORREZIONE CONTRASTO: Contrasto basso, applicando contrast ${recommendedContrast.toStringAsFixed(3)}');
        final currentContrast = originalFilters.contrast;
        final newContrast = (currentContrast * recommendedContrast).clamp(1.0, 1.5);  // Mai < 1.0
        optimizedFilters = optimizedFilters.copyWith(
          contrast: newContrast,
        );
        appLog('      → Contrast finale: ${newContrast.toStringAsFixed(3)} (correzione applicata)');
      } else {
        appLog('   ✅ Contrasto normale - GARANTITO contrast=1.0 (nessuna modifica)');
        optimizedFilters = optimizedFilters.copyWith(
          contrast: 1.0,  // FORZA a 1.0 per video normali
        );
      }
      
      if (recommendedGamma != null && recommendedGamma > 1.0 && isTooDark) {
        appLog('   🔧 CORREZIONE GAMMA: Video troppo scuro, applicando gamma ${recommendedGamma.toStringAsFixed(3)}');
        final safeGamma = recommendedGamma.clamp(1.0, 1.3);
        optimizedFilters = optimizedFilters.copyWith(
          gamma: safeGamma,
        );
        appLog('      → Gamma finale: ${safeGamma.toStringAsFixed(3)} (correzione applicata)');
      } else {
        appLog('   ✅ Gamma normale - GARANTITO gamma=1.0 (nessuna modifica)');
        optimizedFilters = optimizedFilters.copyWith(
          gamma: 1.0,  // FORZA a 1.0 per video normali
        );
      }
    }

    if (issues.contains('low_resolution')) {
      appLog('   → Low resolution: enabling FFmpeg super-resolution (scale) + detail');
      optimizedFilters = optimizedFilters.copyWith(
        superResolutionMethod: optimizedFilters.superResolutionMethod == 'none'
            ? 'nnedi3'
            : optimizedFilters.superResolutionMethod,
        enableDetailEnhancement: true,
      );
    }

    if (issues.contains('low_bitrate') || issues.contains('heavy_compression')) {
      appLog('   → Enhancing compression cleanup');
      optimizedFilters = optimizedFilters.copyWith(
        enableArtifactRemoval: true,
        compressionCleanup: 0.7,
        advancedDebandingMethod: 'gradfun',
      );
    }

    if (issues.contains('interlaced')) {
      appLog('   → Enabling deinterlacing');
      optimizedFilters = optimizedFilters.copyWith(enableDeinterlace: true);
    }

    if (issues.contains('old_codec')) {
      appLog('   → Enhancing detail recovery');
      optimizedFilters = optimizedFilters.copyWith(
        detailEnhanceStrength: 0.6,
        enableEdgeSharpening: true,
      );
    }

    if (issues.contains('hdr_content')) {
      appLog('   → Enabling HDR tone mapping');
      optimizedFilters = optimizedFilters.copyWith(enableHdrToneMapping: true);
    }
    
    if (issues.contains('too_dark')) {
      appLog('   → Video troppo scuro, aumentando luminosità automaticamente');
      final currentBrightness = optimizedFilters.brightness;
      optimizedFilters = optimizedFilters.copyWith(
        brightness: (currentBrightness + 0.15).clamp(0.0, 0.3),  // Solo positivo, mai negativo
        gamma: (optimizedFilters.gamma * 1.1).clamp(1.0, 1.3),  // Gamma >= 1.0 (mai < 1.0 che scurisce)
      );
    }
    
    
    if (issues.contains('low_contrast')) {
      appLog('   → Contrasto basso, aumentando automaticamente');
      final currentContrast = optimizedFilters.contrast;
      optimizedFilters = optimizedFilters.copyWith(
        contrast: (currentContrast * 1.15).clamp(0.8, 1.4),
      );
    }

    return optimizedFilters;
  }


  Future<String> _buildOptimizedVideoFilterChain(
    String inputPath, 
    VideoFilters filters, 
    bool usingGpu,
    Map<String, dynamic>? analysis
  ) async {
    // IMPORTANTE: Preserva il color range originale per evitare scurimento
    // I video possono essere full range (0-255) o limited range (16-235)
    // La conversione errata può scurire i video
    final stages = <List<String>>[];
    
    appLog('🎨 Building optimized filter chain...');

    stages.add(await _buildPreProcessingStage(filters, inputPath, analysis));
    
    stages.add(_buildOptimizedNoiseReductionStage(filters, usingGpu, analysis));
    
    stages.add(await _buildOptimizedDetailRecoveryStage(filters, inputPath, analysis));
    
    stages.add(_buildOptimizedColorCorrectionStage(filters, analysis));
    
    stages.add(_buildOptimizedPostProcessStage(filters, analysis));

    final filterChain = _combineFilterStages(stages, usingGpu);
    
    final simplifiedChain = _simplifyFilterChain(filterChain);
    appLog('🔗 Final filter chain: $simplifiedChain');
    
    return simplifiedChain;
  }

  Future<List<String>> _buildPreProcessingStage(
    VideoFilters filters, 
    String inputPath, 
    Map<String, dynamic>? analysis
  ) async {
    final filtersList = <String>[];
    
    if (filters.enableDeinterlace || (analysis?['quality_issues']?.contains('interlaced') == true)) {
      final deinterlaceFilter = _getDeinterlaceFilter(filters.enableGpuAcceleration);
      if (deinterlaceFilter.isNotEmpty) {
        filtersList.add(deinterlaceFilter);
        appLog('   → Added deinterlacing filter');
      }
    }

    if (filters.enableStabilization && !filters.enableGpuAcceleration) {
      final stabilizationFilter = _getStabilizationFilter();
      if (stabilizationFilter.isNotEmpty) {
        filtersList.add(stabilizationFilter);
      }
    }

    return filtersList;
  }

  List<String> _buildOptimizedNoiseReductionStage(
    VideoFilters filters, 
    bool usingGpu,
    Map<String, dynamic>? analysis
  ) {
    final filtersList = <String>[];
    
    final needsStrongDenoise = analysis?['quality_issues']?.contains('heavy_compression') == true ||
                              analysis?['quality_issues']?.contains('low_bitrate') == true ||
                              analysis?['quality_issues']?.contains('high_noise') == true;

    double denoiseStrength = filters.denoiseStrength;
    if (analysis != null && analysis['frame_analysis'] != null) {
      final frameAnalysis = analysis['frame_analysis'] as Map<String, dynamic>?;
      final recommendedDenoise = frameAnalysis?['recommended_denoise_strength'] as double?;
      if (recommendedDenoise != null && recommendedDenoise > 0) {
        denoiseStrength = recommendedDenoise;
        appLog('   📊 Usando denoising ottimizzato basato su analisi frame-per-frame: ${denoiseStrength.toStringAsFixed(2)}');
      }
    }
    
    if (denoiseStrength <= 0 && !needsStrongDenoise) {
      return filtersList;  // Nessun denoising necessario
    }

    String denoiseMethod = filters.advancedDenoiseMethod;
    if (denoiseMethod == 'none' && (denoiseStrength > 0 || needsStrongDenoise)) {
      denoiseMethod = 'hqdn3d';
    }

    switch (denoiseMethod) {
      case 'nlmeans':
        appLog('   ⚠️ NL-Means disabilitato (troppo pesante), usando HQDN3D invece');
        final luma = needsStrongDenoise 
            ? 4.0  // Ridotto per velocità
            : (filters.denoiseStrength * 3.0).clamp(1.0, 6.0);  // Ridotto
        final chroma = luma * 0.75;
        filtersList.add('hqdn3d=$luma:$chroma:$luma:$chroma');
        appLog('   → Using HQDN3D denoising (luma: $luma, chroma: $chroma) - più veloce');
        break;

      case 'fftdnoiz':
        if (_isFilterAvailable('fftdnoiz')) {
          final sigma = needsStrongDenoise 
              ? 4.5 
              : (filters.denoiseStrength * 5.0).clamp(1.0, 5.0);
          final amount = needsStrongDenoise ? 1.0 : (filters.denoiseStrength * 0.9).clamp(0.3, 1.0);
          filtersList.add('fftdnoiz=sigma=$sigma:amount=$amount:block=8:overlap=0.5:prev=1:next=1');
          appLog('   → Using FFT Denoising (sigma: $sigma)');
        } else {
          appLog('   ⚠️ FFT Denoising not available, falling back to HQDN3D');
          final luma = needsStrongDenoise ? 6.0 : (filters.denoiseStrength * 4.0).clamp(1.0, 8.0);
          final chroma = luma * 0.75;
          filtersList.add('hqdn3d=$luma:$chroma:$luma:$chroma');
        }
        break;

      case 'vaguedenoiser':
        if (_isFilterAvailable('vaguedenoiser')) {
          final threshold = needsStrongDenoise 
              ? 0.3 
              : (filters.denoiseStrength * 0.4).clamp(0.1, 0.4);
          final method = needsStrongDenoise ? 2 : 1;
          filtersList.add('vaguedenoiser=threshold=$threshold:method=$method:nsteps=6');
          appLog('   → Using Vague Denoiser (threshold: $threshold)');
        } else {
          appLog('   ⚠️ Vague Denoiser not available, falling back to HQDN3D');
          final luma = needsStrongDenoise ? 6.0 : (filters.denoiseStrength * 4.0).clamp(1.0, 8.0);
          final chroma = luma * 0.75;
          filtersList.add('hqdn3d=$luma:$chroma:$luma:$chroma');
        }
        break;

      case 'hqdn3d':
      default:
        final effectiveStrength = denoiseStrength > 0 ? denoiseStrength : filters.denoiseStrength;
        
        if (needsStrongDenoise || effectiveStrength > 0.3) {
          final luma = needsStrongDenoise 
              ? 4.0  // RIDOTTO da 6.0 per evitare scurimento
              : (effectiveStrength * 4.0).clamp(1.5, 5.0);  // RIDOTTO da 6.0
          final chroma = luma * 0.7;  // RIDOTTO da 0.75 per evitare scurimento cromatico
          filtersList.add('hqdn3d=$luma:$chroma:$luma:$chroma');
          appLog('   → Using HQDN3D denoising (luma: $luma, chroma: $chroma) - strength: ${effectiveStrength.toStringAsFixed(2)}');
        } else if (effectiveStrength > 0.1) {
          final luma = (effectiveStrength * 2.5).clamp(0.3, 3.0);  // RIDOTTO da 3.0
          final chroma = luma * 0.7;  // RIDOTTO da 0.75
          filtersList.add('hqdn3d=$luma:$chroma:$luma:$chroma');
          appLog('   → Using HQDN3D light denoising (luma: $luma, chroma: $chroma) - strength: ${effectiveStrength.toStringAsFixed(2)}');
        }
        break;
    }

    if (filters.temporalDenoise > 0) {
      if (_isFilterAvailable('minideen')) {
        final tempStrength = (filters.temporalDenoise * 0.5).clamp(0.1, 0.5);
        filtersList.add('minideen=radius=2:threshold=$tempStrength');
        appLog('   → Adding temporal denoising (minideen, strength: $tempStrength)');
      } else if (_isFilterAvailable('atadenoise')) {
        final a = (0.02 + filters.temporalDenoise * 0.07).toStringAsFixed(3);
        filtersList.add('atadenoise=$a:$a:$a');
        appLog('   → Adding temporal denoising (atadenoise, plane thresholds: $a)');
      } else {
        final extra = (filters.temporalDenoise * 1.8).clamp(0.4, 3.5);
        filtersList.add(
          'hqdn3d=${extra.toStringAsFixed(2)}:${(extra * 0.65).toStringAsFixed(2)}:'
          '${extra.toStringAsFixed(2)}:${(extra * 0.65).toStringAsFixed(2)}',
        );
        appLog('   → Temporal smoothing fallback (hqdn3d tail, strength ~$extra)');
      }
    }

    if (denoiseMethod == 'none' && filters.noiseReductionMethod != 'none') {
      switch (filters.noiseReductionMethod) {
        case 'light':
          filtersList.add('hqdn3d=2:1.5:2:1.5');
          break;
        case 'medium':
          filtersList.add('hqdn3d=4:3:4:3');
          break;
        case 'strong':
          filtersList.add('hqdn3d=6:4.5:6:4.5');
          break;
      }
    }

    return filtersList;
  }

  Future<List<String>> _buildOptimizedDetailRecoveryStage(
    VideoFilters filters, 
    String inputPath,
    Map<String, dynamic>? analysis
  ) async {
    final filtersList = <String>[];
    
    if (filters.superResolutionMethod != 'none') {
      final upscale = await _getScaleFilter(inputPath, 2.0);
      if (upscale != null) {
        filtersList.add(upscale);
        appLog('   → Super-resolution pipeline (${filters.superResolutionMethod}): scale 2x');
      }
    }

    double totalSharpness = 0.0;
    String sharpnessDescription = '';
    
    if (filters.textureBoost > 0) {
      totalSharpness += (filters.textureBoost * 0.15).clamp(0.0, 0.15);
      sharpnessDescription += 'texture boost ';
    }
    
    if (filters.enableDetailEnhancement && filters.detailEnhanceStrength > 0) {
      totalSharpness += (filters.detailEnhanceStrength * 0.5).clamp(0.0, 0.5);
      sharpnessDescription += 'detail enhancement ';
    }
    
    if (filters.enableEdgeSharpening) {
      totalSharpness += (filters.sharpness * 0.2).clamp(0.0, 0.3);
      sharpnessDescription += 'edge sharpening ';
    }
    
    if (filters.sharpness != 1.0 && !filters.enableEdgeSharpening) {
      totalSharpness += ((filters.sharpness - 1.0) * 0.3).clamp(0.0, 0.4);
      sharpnessDescription += 'general sharpness ';
    }
    
    if (filters.unsharpMask > 0) {
      totalSharpness += (filters.unsharpMask * 0.4).clamp(0.0, 0.4);
      sharpnessDescription += 'unsharp mask ';
    }
    
    if (totalSharpness > 0.05) {
      final finalStrength = totalSharpness.clamp(0.05, 0.6);  // Limita a 0.6 per evitare artefatti
      filtersList.add('unsharp=5:5:${finalStrength.toStringAsFixed(2)}');
      appLog('   → Adding combined sharpening (strength: ${finalStrength.toStringAsFixed(2)}, sources: $sharpnessDescription)');
    }

    return filtersList;
  }

  List<String> _buildOptimizedColorCorrectionStage(VideoFilters filters, Map<String, dynamic>? analysis) {
    final filtersList = <String>[];
    
    if (filters.enableHdrToneMapping) {
      final isHdr = analysis?['quality_issues']?.contains('hdr_content') == true;
      if (isHdr && _isFilterAvailable('zscale') && _isFilterAvailable('tonemap')) {
        filtersList.add('zscale=t=linear:npl=100,format=gbrpf32le,zscale=p=bt709,tonemap=tonemap=hable:desat=0,zscale=t=bt709:m=bt709:r=tv,format=yuv420p');
        appLog('   → Applying HDR tone mapping (video HDR rilevato)');
      } else if (filters.enableHdrToneMapping && !isHdr) {
        appLog('   ⚠️ HDR tone mapping richiesto ma video non è HDR - DISABILITATO per evitare scurimento');
      } else {
        appLog('   ⚠️ HDR tone mapping not available');
      }
    }

    final brightness = filters.brightness;
    final contrast = filters.contrast;
    final saturation = filters.saturation;
    final gamma = filters.gamma;
    
    bool needsEq = (brightness.abs() > 0.01) || 
                   (contrast - 1.0).abs() > 0.01 || 
                   (saturation - 1.0).abs() > 0.01 ||
                   (gamma - 1.0).abs() > 0.01;
    
    if (needsEq) {
      final brightnessStr = brightness.toStringAsFixed(2);
      final contrastStr = contrast.toStringAsFixed(2);
      final saturationStr = saturation.toStringAsFixed(2);
      final gammaStr = gamma.toStringAsFixed(2);
      
      filtersList.add('eq=brightness=$brightnessStr:contrast=$contrastStr:saturation=$saturationStr:gamma=$gammaStr');
      appLog('   → Applying color correction (brightness: $brightnessStr, contrast: $contrastStr, saturation: $saturationStr, gamma: $gammaStr)');
    } else {
      appLog('   ✅ Nessuna correzione colore necessaria (valori di default)');
    }

    if (filters.colorBalanceR != 0.0 || filters.colorBalanceG != 0.0 || filters.colorBalanceB != 0.0) {
      if (_isFilterAvailable('colorbalance')) {
        final r = (1.0 + filters.colorBalanceR).toStringAsFixed(3);
        final g = (1.0 + filters.colorBalanceG).toStringAsFixed(3);
        final b = (1.0 + filters.colorBalanceB).toStringAsFixed(3);
        filtersList.add('colorbalance=rs=$r:gs=$g:bs=$b');
        appLog('   → Applying color balance (R: $r, G: $g, B: $b)');
      } else {
        appLog('   ⚠️ Color balance not available, using eq instead');
        final rBoost = filters.colorBalanceR > 0 ? 1.05 : 0.95;
        final gBoost = filters.colorBalanceG > 0 ? 1.05 : 0.95;
        final bBoost = filters.colorBalanceB > 0 ? 1.05 : 0.95;
        filtersList.add(
            'eq=contrast=$rBoost:saturation=$gBoost:bgamma=${bBoost.toStringAsFixed(3)}');
      }
    }

    if (filters.hue != 0.0 || filters.saturationAdvanced != 1.0 || filters.value != 1.0) {
      final hueStr = filters.hue.toStringAsFixed(1);
      final satStr = filters.saturationAdvanced.toStringAsFixed(2);
      final valStr = filters.value.toStringAsFixed(2);
      filtersList.add('hue=h=$hueStr:s=$satStr,eq=brightness=${((filters.value - 1.0) * 0.3).toStringAsFixed(2)}');
      appLog('   → Applying HSV correction (hue: $hueStr, saturation: $satStr, value: $valStr)');
    }

    if (filters.enableColorVibrance) {
      final vibrance = (filters.saturation * 0.2).clamp(0.0, 0.3);
      filtersList.add('eq=saturation=${(1.0 + vibrance).toStringAsFixed(2)}');
      appLog('   → Applying color vibrance');
    }

    if (filters.curvesPreset != 'none') {
      if (_isFilterAvailable('curves')) {
        final curvesFilter = _getCurvesFilter(filters.curvesPreset);
        if (curvesFilter.isNotEmpty) {
          filtersList.add(curvesFilter);
          appLog('   → Applying curves preset: ${filters.curvesPreset}');
        }
      } else {
        appLog('   ⚠️ Curves filter not available, using eq instead');
        switch (filters.curvesPreset) {
          case 'contrast':
            filtersList.add('eq=contrast=1.15');
            break;
          case 'vivid':
            filtersList.add('eq=contrast=1.1:saturation=1.2');
            break;
          case 'cinematic':
            filtersList.add('eq=contrast=1.1:saturation=0.95');
            break;
        }
      }
    }

    if (filters.colorProfile != 'none') {
      final profileFilter = _getColorProfileFilter(filters.colorProfile);
      if (profileFilter.isNotEmpty) {
        filtersList.add(profileFilter);
        appLog('   → Applying color profile: ${filters.colorProfile}');
      }
    }

    return filtersList;
  }

  List<String> _buildOptimizedPostProcessStage(VideoFilters filters, Map<String, dynamic>? analysis) {
    final filtersList = <String>[];
    
    // DEBANDING AVANZATO PER COMPRESSIONE PESANTE
    final needsDebanding = filters.enableArtifactRemoval || 
                          filters.advancedDebandingMethod != 'none' ||
                          (analysis?['quality_issues']?.contains('heavy_compression') == true);
    
    if (needsDebanding) {
      switch (filters.advancedDebandingMethod) {
        case 'gradfun':
          final strength = filters.compressionCleanup > 0 
              ? (filters.compressionCleanup * 8.0).clamp(4.0, 12.0)
              : 6.0;
          filtersList.add('gradfun=strength=$strength:radius=16');
          appLog('   → Using gradfun debanding (strength: $strength)');
          break;
        
        case 'deblock':
          // Deblocking per artefatti da compressione
          filtersList.add('deblock=filter:alpha=0.12:beta=0.07:gamma=0.06:delta=0.05');
          appLog('   → Using deblock filter');
          break;
        
        case 'avgbits':
          // Average bits per ridurre banding
          filtersList.add('gradfun=strength=8:radius=20');
          appLog('   → Using advanced debanding');
          break;
        
        default:
          // Default debanding
          filtersList.add('gradfun=strength=6:radius=16');
          appLog('   → Using default debanding');
          break;
      }
    }

    // COMPRESSION CLEANUP AVANZATO
    if (filters.compressionCleanup > 0) {
      final cleanupStrength = (filters.compressionCleanup * 0.5).clamp(0.1, 0.5);
      // Combina debanding con cleanup leggero
      if (!needsDebanding) {
        filtersList.add('gradfun=strength=${(cleanupStrength * 12.0).toStringAsFixed(1)}:radius=16');
      }
      appLog('   → Applying compression cleanup (strength: $cleanupStrength)');
    }

    // CHROMA UPSCALING MIGLIORATO
    if (filters.chromaUpsampling != 'lanczos') {
      // Il chroma upsampling è gestito automaticamente da FFmpeg
      // ma possiamo forzare un metodo specifico se necessario
      appLog('   → Using chroma upsampling: ${filters.chromaUpsampling}');
    }

    // FILM GRAIN (opzionale): usa filtro 'noise' solo se disponibile
    if (filters.filmGrain > 0) {
      if (_isFilterAvailable('noise')) {
        final grain = (filters.filmGrain * 0.1).clamp(0.0, 0.1);
        filtersList.add('noise=alls=$grain:allf=t+u');
        appLog('   → Adding film grain (strength: $grain)');
      } else {
        appLog('   ⚠️ Noise filter not available, skipping film grain');
      }
    }

    return filtersList;
  }


  String _getOptimizedVideoCodec(String originalCodec, Map<String, dynamic>? analysis, bool useGpu) {
    // Se l'analisi rileva problemi di compatibilità, usa codec più compatibili
    if (analysis?['quality_issues']?.contains('old_codec') == true && !useGpu) {
      return 'libx264'; // Massima compatibilità
    }
    
    // Se GPU è abilitata, usa codec hardware-accelerated
    if (useGpu && _availableGpuAccelerations != null) {
      final detectedGpu = _availableGpuAccelerations!['detected_gpu'] as String?;
      
      // Determina il codec target (H.264 o HEVC)
      final isHevc = originalCodec.toLowerCase().contains('hevc') || 
                     originalCodec.toLowerCase().contains('x265') ||
                     originalCodec.toLowerCase().contains('h265');
      final isAv1 = originalCodec.toLowerCase().contains('av1');
      
      // Seleziona codec hardware in base alla GPU rilevata
      switch (detectedGpu) {
        case 'nvidia':
          if (isAv1 && _availableGpuAccelerations!['nvidia_av1_enc'] == true) {
            return 'av1_nvenc';
          } else if (isHevc && _availableGpuAccelerations!['nvidia_hevc_enc'] == true) {
            return 'hevc_nvenc';
          } else if (_availableGpuAccelerations!['nvidia_h264_enc'] == true) {
            return 'h264_nvenc';
          }
          break;
          
        case 'intel':
          if (isAv1 && _availableGpuAccelerations!['intel_av1_enc'] == true) {
            return 'av1_qsv';
          } else if (isHevc && _availableGpuAccelerations!['intel_hevc_enc'] == true) {
            return 'hevc_qsv';
          } else if (_availableGpuAccelerations!['intel_h264_enc'] == true) {
            return 'h264_qsv';
          }
          break;
          
        case 'amd':
          if (isAv1 && _availableGpuAccelerations!['amd_av1_enc'] == true) {
            return 'av1_amf';
          } else if (isHevc && _availableGpuAccelerations!['amd_hevc_enc'] == true) {
            return 'hevc_amf';
          } else if (_availableGpuAccelerations!['amd_h264_enc'] == true) {
            return 'h264_amf';
          }
          break;
          
        case 'apple':
          if (isHevc && _availableGpuAccelerations!['apple_hevc_enc'] == true) {
            return 'hevc_videotoolbox';
          } else if (_availableGpuAccelerations!['apple_h264_enc'] == true) {
            return 'h264_videotoolbox';
          }
          break;
          
        case 'vaapi':
          if (isAv1 && _availableGpuAccelerations!['vaapi_av1_enc'] == true) {
            return 'av1_vaapi';
          } else if (isHevc && _availableGpuAccelerations!['vaapi_hevc_enc'] == true) {
            return 'hevc_vaapi';
          } else if (_availableGpuAccelerations!['vaapi_h264_enc'] == true) {
            return 'h264_vaapi';
          }
          break;
      }
    }
    
    // Fallback al codec originale se GPU non disponibile o non supportata
    return originalCodec;
  }

  int _getOptimizedVideoQuality(int originalQuality, String bitrateMode, Map<String, dynamic>? analysis) {
    if (analysis == null) return originalQuality;

    // Regola la qualità in base all'analisi
    if (bitrateMode == 'crf') {
      // Per video con molti artefatti, usa CRF più basso (migliore qualità)
      if (analysis['quality_issues']?.contains('heavy_compression') == true ||
          analysis['quality_issues']?.contains('low_bitrate') == true) {
        return originalQuality.clamp(18, 23);
      }
      // Per video già di buona qualità, mantieni le impostazioni dell'utente
      return originalQuality.clamp(20, 28);
    } else {
      // Per bitrate mode, aggiusta il bitrate in base alla complessità
      final originalBitrate = originalQuality;
      if (analysis['quality_issues']?.contains('low_bitrate') == true) {
        return (originalBitrate * 1.5).clamp(2000, 20000).toInt();
      }
      return originalBitrate.clamp(1000, 50000);
    }
  }


  Future<Map<String, dynamic>> _validateAndSanitizeOutputPath(
    String outputPath, 
    MediaType mediaType, {
    bool overwriteExisting = false,
  }) async {
    try {
      final sanitizedPath = _sanitizeFilePath(outputPath);
      final outputFile = File(sanitizedPath);
      final outputDir = outputFile.parent;

      // Crea directory se non esiste
      if (!await outputDir.exists()) {
        await outputDir.create(recursive: true);
      }

      // Verifica permessi scrittura con nome file univoco per evitare race conditions
      // quando più conversioni scrivono nella stessa directory
      try {
        final uniqueTestFileName = '.write_test_${DateTime.now().millisecondsSinceEpoch}_${sanitizedPath.hashCode}';
        final testFile = File('${outputDir.path}/$uniqueTestFileName');
        await testFile.writeAsString('test');
        await testFile.delete();
      } catch (e) {
        return {
          'success': false,
          'error': 'Permessi di scrittura insufficienti'
        };
      }

      // CHECK FILE ESISTENTE
      if (await outputFile.exists()) {
        if (!overwriteExisting) {
          return {
            'success': false,
            'error': 'file_exists',
            'file_path': sanitizedPath,
            'message': 'Un file con lo stesso nome esiste già. Vuoi sovrascriverlo?'
          };
        } else {
          // File esiste e si vuole sovrascrivere
          appLog('⚠️ File esistente verrà sovrascritto: $sanitizedPath');
        }
      }

      return {
        'success': true,
        'sanitized_path': sanitizedPath
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Errore validazione output: $e'
      };
    }
  }

  String _sanitizeFilePath(String path) {
    final invalidChars = RegExp(r'[<>:"|?*\\\x00-\x1f]');
    var sanitized = path.replaceAll(invalidChars, '_');
    
    if (!sanitized.startsWith('/')) {
      sanitized = '${Directory.current.path}/$sanitized';
    }
    
    return sanitized;
  }

  Future<Map<String, dynamic>> _validateInputFile(String inputPath) async {
    try {
      final file = File(inputPath);
      if (!await file.exists()) {
        return {'success': false, 'error': 'File non trovato'};
      }
      return {'success': true};
    } catch (e) {
      return {'success': false, 'error': 'Errore validazione input: $e'};
    }
  }


  String _getDeinterlaceFilter(bool usingGpu) {
    if (usingGpu) return '';
    return 'yadif=0:-1:0';
  }

  String _getStabilizationFilter() {
    return 'deshake=rx=16:ry=16';
  }

  Future<String?> _getScaleFilter(String inputPath, double upscaleFactor) async {
    if (upscaleFactor <= 1.0) return null;

    try {
      // Usa il servizio ottimizzato per upscaling video
      final dimensions = await _videoUpscaler.getVideoDimensions(inputPath);
      if (dimensions == null) return null;

      final originalWidth = dimensions['width']!;
      final originalHeight = dimensions['height']!;

      // Calcola risoluzione target ottimizzata
      final targetRes = _videoUpscaler.calculateTargetResolution(
        originalWidth: originalWidth,
        originalHeight: originalHeight,
        scaleFactor: upscaleFactor,
      );

      // Verifica se l'upscaling è necessario
      if (!_videoUpscaler.shouldUpscale(
        originalWidth: originalWidth,
        originalHeight: originalHeight,
        targetWidth: targetRes['width']!,
        targetHeight: targetRes['height']!,
      )) {
        return null;
      }

      // Usa algoritmo ottimizzato (lanczos avanzato per qualità superiore)
      return _videoUpscaler.buildOptimizedUpscaleFilter(
        originalWidth: originalWidth,
        originalHeight: originalHeight,
        targetWidth: targetRes['width']!,
        targetHeight: targetRes['height']!,
        algorithm: 'lanczos', // Usa lanczos per qualità ottimale
        useAdvancedFlags: true,
      );
    } catch (e) {
      appLog('❌ [FFmpegService] Errore generazione filtro scale: $e');
      return null;
    }
  }

  /// Ottiene il filtro curves per color grading.
  /// Solo preset FFmpeg validi: strong_contrast, increase_contrast, medium_contrast, lighter, darker, vintage, etc.
  String _getCurvesFilter(String preset) {
    switch (preset) {
      case 'contrast':
        return 'curves=preset=strong_contrast';
      case 'vivid':
        return 'curves=preset=increase_contrast';
      case 'cinematic':
        return 'curves=preset=medium_contrast';
      case 'lighter':
        return 'curves=preset=lighter';
      case 'darker':
        return 'curves=preset=darker';
      case 'vintage':
        return 'curves=preset=vintage';
      case 'linear_contrast':
        return 'curves=preset=linear_contrast';
      default:
        return '';
    }
  }

  /// Ottiene il filtro per i profili colore
  String _getColorProfileFilter(String profile) {
    switch (profile) {
      case 'vivid':
        // Profilo vivace: aumenta saturazione e contrasto
        return 'eq=saturation=1.3:contrast=1.1';
      
      case 'cinematic':
        // Profilo cinematografico: contrasto aumentato, saturazione leggermente ridotta
        return 'eq=contrast=1.15:saturation=0.95:gamma=1.05';
      
      case 'bw':
        // Bianco e nero
        return 'hue=s=0';
      
      case 'sepia':
        // Effetto seppia
        return 'colorchannelmixer=.393:.769:.189:0:.349:.686:.168:0:.272:.534:.131';
      
      case 'cool':
        // Tonalità fredde (blu)
        return 'colorbalance=rs=0.9:gs=1.0:bs=1.1';
      
      case 'warm':
        // Tonalità calde (arancione/rosso)
        return 'colorbalance=rs=1.1:gs=1.0:bs=0.9';
      
      default:
        return '';
    }
  }

  /// Semplifica la catena di filtri per evitare blocchi
  /// Rimuove filtri troppo pesanti o riduce la complessità
  String _simplifyFilterChain(String filterChain) {
    if (filterChain.isEmpty) return filterChain;
    
    final filters = filterChain.split(',');
    final simplified = <String>[];
    int filterCount = 0;
    const maxFilters = 5;  // Limite massimo di filtri per evitare blocchi
    
    for (final filter in filters) {
      final trimmed = filter.trim();
      if (trimmed.isEmpty) continue;
      
      // Salta filtri troppo pesanti o complessi
      if (trimmed.contains('nlmeans')) {
        // nlmeans è troppo pesante, salta
        appLog('   ⚠️ Rimuovendo nlmeans dalla catena (troppo pesante)');
        continue;
      }
      
      if (trimmed.contains('zscale') && filterChain.contains('tonemap')) {
        // HDR tone mapping è troppo complesso, salta
        appLog('   ⚠️ Rimuovendo HDR tone mapping dalla catena (troppo pesante)');
        continue;
      }
      
      // Limita il numero totale di filtri
      if (filterCount >= maxFilters) {
        appLog('   ⚠️ Limite filtri raggiunto ($maxFilters), saltando filtri aggiuntivi');
        break;
      }
      
      simplified.add(trimmed);
      filterCount++;
    }
    
    return simplified.join(',');
  }

  String _combineFilterStages(List<List<String>> stages, bool usingGpu) {
    final allFilters = <String>[];
    for (final stage in stages) {
      allFilters.addAll(stage);
    }
    
    if (allFilters.isEmpty) return '';
    return allFilters.join(',');
  }
  
  /// Ottimizza la catena di filtri per migliori prestazioni
  String _optimizeFilterChainForPerformance(String filterChain, bool usingGpu) {
    if (filterChain.isEmpty) return filterChain;
    
    // Se si usa GPU, i filtri vengono eseguiti sulla CPU in parallelo con encoding GPU
    // Possiamo ottimizzare la catena per ridurre overhead
    
    // Rimuovi filtri duplicati o ridondanti
    final filters = filterChain.split(',');
    final optimizedFilters = <String>[];
    final seenFilters = <String>{};
    
    for (final filter in filters) {
      final filterName = filter.split(':').first.split('=').first.trim();
      
      // Evita duplicati dello stesso tipo di filtro
      if (!seenFilters.contains(filterName) || filterName == 'scale' || filterName == 'eq') {
        optimizedFilters.add(filter);
        seenFilters.add(filterName);
      }
    }
    
    // Se si usa GPU, possiamo parallelizzare alcuni filtri usando filter_complex
    // ma per semplicità manteniamo la catena lineare ottimizzata
    return optimizedFilters.join(',');
  }


  Future<Map<String, dynamic>> getVideoInfo(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return {'success': false, 'error': 'File non trovato: $filePath'};
      }

      final process = await Process.run('ffprobe', [
        '-v', 'error',
        '-select_streams', 'v:0',
        '-show_entries', 'stream=width,height,codec_name,duration,r_frame_rate',
        '-show_entries', 'format=bit_rate,size',
        '-of', 'json',
        filePath
      ]);

      if (process.exitCode == 0) {
        final Map<String, dynamic> info = json.decode(process.stdout);
        return {'success': true, 'info': info};
      } else {
        return {'success': false, 'error': 'ffprobe failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Errore analisi video: $e'};
    }
  }

  String buildAudioFilterChain(AudioFilters filters) {
    final filtersList = <String>[];

    if (filters.volume != 1.0) {
      final volumeValue = filters.volume.clamp(0.1, 10.0).toStringAsFixed(2);
      filtersList.add('volume=$volumeValue');
    }

    // Equalizzatore multi-banda (10 bande: 31Hz, 62Hz, 125Hz, 250Hz, 500Hz, 1kHz, 2kHz, 4kHz, 8kHz, 16kHz)
    final hasEqBands = filters.eqBands.any((band) => band != 0.0);
    if (hasEqBands) {
      // Usa il filtro 'equalizer' di FFmpeg con 10 bande
      // Formato: equalizer=f=freq:width_type=w:width=width:g=gain
      final eqFilters = <String>[];
      final frequencies = [31, 62, 125, 250, 500, 1000, 2000, 4000, 8000, 16000];
      for (int i = 0; i < filters.eqBands.length && i < frequencies.length; i++) {
        if (filters.eqBands[i] != 0.0) {
          final gain = filters.eqBands[i].clamp(-20.0, 20.0);
          final freq = frequencies[i];
          // Usa una larghezza proporzionale alla frequenza (1/3 ottava)
          final width = freq * 0.23; // Circa 1/3 di ottava
          eqFilters.add('equalizer=f=$freq:width_type=h:width=$width:g=$gain');
        }
      }
      if (eqFilters.isNotEmpty) {
        filtersList.addAll(eqFilters);
      }
    } else if (filters.bass != 0.0 || filters.treble != 0.0) {
      // Fallback per compatibilità con vecchi filtri bass/treble
      if (filters.bass != 0.0) {
        final gain = filters.bass.clamp(-20.0, 20.0);
        filtersList.add('equalizer=f=60:width_type=h:width=30:g=$gain');
        filtersList.add('equalizer=f=170:width_type=h:width=80:g=${gain * 0.7}');
      }
      if (filters.treble != 0.0) {
        final gain = filters.treble.clamp(-20.0, 20.0);
        filtersList.add('equalizer=f=8000:width_type=h:width=4000:g=$gain');
        filtersList.add('equalizer=f=12000:width_type=h:width=6000:g=${gain * 0.7}');
      }
    }

    if (filters.normalize) {
      // Usa loudnorm solo se disponibile, altrimenti usa volume
      if (_isFilterAvailable('loudnorm')) {
        filtersList.add('loudnorm=I=-16:TP=-1.5:LRA=11');
      } else {
        // Fallback a normalizzazione semplice
        filtersList.add('volume=0dB');
      }
    }

    if (filters.removeNoise) {
      final threshold = (filters.noiseThreshold * 0.3).clamp(0.0, 0.3);
      filtersList.add('highpass=f=80,lowpass=f=15000');
      // Usa afftdn solo se disponibile
      if (_isFilterAvailable('afftdn')) {
        filtersList.add('afftdn=nr=${threshold.toStringAsFixed(2)}');
      } else {
        // Fallback a filtri più semplici
        filtersList.add('anlmdn=s=${threshold.toStringAsFixed(2)}');
      }
    }

    if (filters.compression > 0.0) {
      final ratio = 2.0 + (filters.compression * 8.0); // 2:1 to 10:1
      filtersList.add('acompressor=threshold=0.05:ratio=$ratio:attack=5:release=50');
    }

    if (filters.reverb > 0.0) {
      final roomSize = 0.3 + (filters.reverb * 0.7);
      filtersList.add('aecho=0.8:0.88:${(60 * roomSize).toInt()}:0.4');
    }

    return filtersList.join(',');
  }

  // Metodo comune per determinare codec e impostare bitrate/qualità audio
  void _addAudioCodecAndQuality(
    List<String> command,
    String outputPath,
    int audioQuality,
    String audioCodec,
  ) {
    final safeAudioQuality = audioQuality.clamp(128, 320);
    
    // DETERMINA IL CODEC IN BASE AL FORMATO DI OUTPUT SE NON SPECIFICATO
    String effectiveCodec = audioCodec;
    final outputExt = outputPath.toLowerCase().split('.').last;
    if (audioCodec.isEmpty || audioCodec == 'auto' || 
        (outputExt == 'mp3' && audioCodec != 'mp3') ||
        (outputExt == 'aac' && audioCodec != 'aac' && audioCodec != 'mp3') ||
        (outputExt == 'm4a' && audioCodec != 'aac' && audioCodec != 'mp3') ||
        (outputExt == 'ogg' && audioCodec != 'vorbis' && audioCodec != 'opus') ||
        (outputExt == 'opus' && audioCodec != 'opus')) {
      // Determina codec in base all'estensione
      switch (outputExt) {
        case 'mp3':
          effectiveCodec = 'mp3';
          break;
        case 'aac':
        case 'm4a':
          effectiveCodec = 'aac';
          break;
        case 'ogg':
          effectiveCodec = 'vorbis';
          break;
        case 'opus':
          effectiveCodec = 'opus';
          break;
        case 'flac':
          effectiveCodec = 'flac';
          break;
        case 'wav':
          effectiveCodec = 'pcm_s16le';
          break;
        default:
          // Mantieni il codec originale se non riconosciuto
          break;
      }
      appLog('🔄 [FFmpegService] Codec auto-determinato da estensione: $effectiveCodec (da .$outputExt)');
    }
    
    String ffmpegCodec = effectiveCodec;
    if (effectiveCodec == 'mp3') {
      ffmpegCodec = 'libmp3lame';
    } else if (effectiveCodec == 'aac') {
      ffmpegCodec = 'aac';
    } else if (effectiveCodec == 'opus') {
      ffmpegCodec = 'libopus';
    } else if (effectiveCodec == 'vorbis') {
      ffmpegCodec = 'libvorbis';
    } else if (effectiveCodec == 'flac') {
      ffmpegCodec = 'flac';
    } else if (effectiveCodec == 'pcm_s16le') {
      ffmpegCodec = 'pcm_s16le';
    }
    
    command.addAll(['-c:a', ffmpegCodec]);
    
    // Imposta bitrate/qualità in base al codec.
    // Obiettivo: rispettare esattamente il bitrate utente per i codec lossy.
    if (ffmpegCodec == 'libmp3lame') {
      command.addAll(['-b:a', '${safeAudioQuality}k']);
      command.addAll(['-f', 'mp3']); // Forza formato MP3
    } else if (ffmpegCodec == 'aac') {
      command.addAll(['-b:a', '${safeAudioQuality}k']);
    } else if (ffmpegCodec == 'libopus') {
      command.addAll(['-b:a', '${safeAudioQuality}k']);
      command.addAll(['-vbr', 'off']); // CBR per rispettare bitrate impostato
    } else if (ffmpegCodec == 'libvorbis') {
      command.addAll(['-b:a', '${safeAudioQuality}k']);
    } else if (ffmpegCodec == 'pcm_s16le') {
      // WAV: nessun -b:a, FFmpeg usa sample rate dell'input (Baeldung)
    } else if (ffmpegCodec == 'flac') {
      command.addAll(['-compression_level', '12']);
    } else {
      command.addAll(['-b:a', '${safeAudioQuality}k']);
    }
    
    appLog('   Codec: $ffmpegCodec, Quality: $safeAudioQuality');
  }

  List<String> _buildAudioCommand({
    required List<String> command,
    required String outputPath,
    required int audioQuality,
    required String audioCodec,
    required AudioFilters audioFilters,
  }) {
    // Baeldung: -vn per escludere video quando input è video
    command.addAll(['-vn']);
    final audioFilterChain = buildAudioFilterChain(audioFilters);
    if (audioFilterChain.isNotEmpty) {
      command.addAll(['-af', audioFilterChain]);
    }

    _addAudioCodecAndQuality(command, outputPath, audioQuality, audioCodec);
    command.add(outputPath);
    
    appLog('🎵 [FFmpegService] Audio conversion command built');
    
    return command;
  }

  /// Estrae la traccia audio da un file video.
  /// Ricerca: SavvyAdmin/SuperUser - comando minimalissimo per WAV evita output silenzioso.
  /// WAV: ffmpeg -i input -vn -acodec pcm_s16le -ac 2 output.wav
  /// MP3: ffmpeg -i input -vn -acodec libmp3lame -b:a 192k output.mp3
  List<String> _buildAudioExtractionCommand({
    required String inputPath,
    required String outputPath,
    required int audioQuality,
    required String audioCodec,
    required AudioFilters audioFilters,
  }) {
    final outputExt = outputPath.toLowerCase().split('.').last;
    
    // WAV: preserva impostazioni utente (es. EQ) se presenti; evita downmix forzato.
    if (outputExt == 'wav') {
      final audioFilterChain = buildAudioFilterChain(audioFilters);
      final command = <String>[
        'ffmpeg', '-y', '-loglevel', 'warning',
        '-i', inputPath,
        '-vn',           // Solo audio, no video
        '-acodec', 'pcm_s16le',  // PCM 16-bit per WAV
      ];
      if (audioFilterChain.isNotEmpty) {
        command.addAll(['-af', audioFilterChain]);
      }
      command.add(outputPath);
      appLog('🎵 [FFmpegService] WAV extraction: -i -vn -acodec pcm_s16le ${audioFilterChain.isNotEmpty ? "-af ..." : ""}');
      return command;
    }
    
    // MP3 e altri formati: comando standard
    final command = <String>[
      'ffmpeg', '-y', '-loglevel', 'warning',
      '-i', inputPath,
      '-vn',
    ];
    
    final audioFilterChain = buildAudioFilterChain(audioFilters);
    if (audioFilterChain.isNotEmpty) {
      command.addAll(['-af', audioFilterChain]);
    }
    _addAudioCodecAndQuality(command, outputPath, audioQuality, audioCodec);
    if (outputExt == 'mp3') {
      command.addAll(['-f', 'mp3']);
    }
    command.add(outputPath);
    
    appLog('🎵 [FFmpegService] Audio extraction: -i -vn -c:a -f $outputExt');
    return command;
  }

  Future<List<String>> _buildImageCommand({
    required List<String> command,
    required String inputPath,
    required String outputPath,
    required ImageFilters imageFilters,
    void Function(double progress, String message)? onProgress,
  }) async {
    String workingInputPath = inputPath;
    String workingOutputPath = outputPath;
    
    // STEP 1: UPSCALING CON AI (se abilitato e non si usa risoluzione personalizzata)
    if (!imageFilters.useCustomResolution && 
        imageFilters.enableUpscaling && 
        imageFilters.upscaleFactor > 1.0) {
      appLog('   🚀 Starting AI upscaling by ${imageFilters.upscaleFactor}x...');
      
      // Inizializza l'upscaler se non già fatto
      await _imageUpscaler.initialize();
      
      // Crea un file temporaneo per l'immagine upscalata
      final tempDir = Directory.systemTemp;
      final upscaledPath = '${tempDir.path}/upscaled_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final upscaledResult = await _imageUpscaler.upscaleImage(
        inputPath,
        upscaledPath,
        imageFilters.upscaleFactor,
        onProgress: onProgress,
      );
      
      if (upscaledResult != null && File(upscaledResult).existsSync()) {
        workingInputPath = upscaledResult;
        appLog('   ✅ AI upscaling completed: $upscaledResult');
      } else {
        appLog('   ⚠️ AI upscaling failed, using FFmpeg fallback');
        // Fallback a FFmpeg per upscaling
      }
    }
    
    final List<String> filtersList = [];

    // STEP 2: RISOLUZIONE PERSONALIZZATA (se non già upscalata)
    if (imageFilters.useCustomResolution && (imageFilters.customWidth > 0 || imageFilters.customHeight > 0)) {
        // Risoluzione personalizzata (es. 1920x1080)
        try {
          // Ottieni dimensioni originali
          final infoResult = await getVideoInfo(workingInputPath);
          if (infoResult['success'] == true) {
            final mediaInfo = infoResult['info'];
            final streams = mediaInfo['streams'] as List<dynamic>?;
            if (streams != null && streams.isNotEmpty) {
              final videoStream = streams.firstWhere(
                (stream) => stream['codec_type'] == 'video' || stream['codec_type'] == null,
                orElse: () => null,
              );
              
              if (videoStream != null) {
                final originalWidth = videoStream['width'] as int? ?? 0;
                final originalHeight = videoStream['height'] as int? ?? 0;
                
                if (originalWidth > 0 && originalHeight > 0) {
                  int targetWidth = imageFilters.customWidth;
                  int targetHeight = imageFilters.customHeight;
                  
                  // Se solo uno è specificato, mantieni aspect ratio
                  if (targetWidth > 0 && targetHeight == 0) {
                    final aspectRatio = originalHeight / originalWidth;
                    targetHeight = (targetWidth * aspectRatio).round();
                    targetHeight = targetHeight.isEven ? targetHeight : targetHeight + 1;
                  } else if (targetWidth == 0 && targetHeight > 0) {
                    final aspectRatio = originalWidth / originalHeight;
                    targetWidth = (targetHeight * aspectRatio).round();
                    targetWidth = targetWidth.isEven ? targetWidth : targetWidth + 1;
                  } else if (targetWidth > 0 && targetHeight > 0) {
                    targetWidth = targetWidth.isEven ? targetWidth : targetWidth + 1;
                    targetHeight = targetHeight.isEven ? targetHeight : targetHeight + 1;
                  }
                  
                  if (targetWidth > 0 && targetHeight > 0) {
                    filtersList.add('scale=$targetWidth:$targetHeight:flags=lanczos');
                    appLog('   → Resizing image to ${targetWidth}x${targetHeight} (original: ${originalWidth}x${originalHeight})');
                  }
                }
              }
            }
          }
        } catch (e) {
          appLog('   ⚠️ Error getting image dimensions: $e');
        }
    } else if (imageFilters.enableUpscaling && imageFilters.upscaleFactor > 1.0 && workingInputPath == inputPath) {
      // Fallback FFmpeg upscaling se AI non disponibile
      filtersList.add('scale=iw*${imageFilters.upscaleFactor}:ih*${imageFilters.upscaleFactor}:flags=lanczos');
      appLog('   → FFmpeg upscaling image by ${imageFilters.upscaleFactor}x');
    }

    // STEP 3: DENOISE (prima degli altri filtri colore)
    if (imageFilters.denoiseStrength > 0.0) {
      final strength = (imageFilters.denoiseStrength * 5.0).clamp(0.0, 5.0);
      filtersList.add('hqdn3d=${strength.toStringAsFixed(2)}:${strength.toStringAsFixed(2)}:${(strength * 0.8).toStringAsFixed(2)}:${(strength * 0.8).toStringAsFixed(2)}');
      appLog('   → Denoise strength: ${imageFilters.denoiseStrength}');
    }

    // STEP 4: BRIGHTNESS, CONTRAST, SATURATION (prima del color profile)
    if (imageFilters.brightness != 0.0 || imageFilters.contrast != 1.0 || imageFilters.saturation != 1.0) {
      final brightnessStr = imageFilters.brightness.toStringAsFixed(2);
      final contrastStr = imageFilters.contrast.toStringAsFixed(2);
      final saturationStr = imageFilters.saturation.toStringAsFixed(2);
      filtersList.add('eq=brightness=$brightnessStr:contrast=$contrastStr:saturation=$saturationStr');
      appLog('   → Color adjustments: brightness=$brightnessStr, contrast=$contrastStr, saturation=$saturationStr');
    }

    // STEP 5: GAMMA
    if (imageFilters.gamma != 1.0) {
      filtersList.add('eq=gamma=${imageFilters.gamma.toStringAsFixed(2)}');
      appLog('   → Gamma: ${imageFilters.gamma}');
    }

    // STEP 6: SHARPNESS
    if (imageFilters.sharpness != 1.0) {
      final strength = ((imageFilters.sharpness - 1.0) * 0.5).clamp(-0.5, 0.5);
      filtersList.add('unsharp=5:5:${strength.toStringAsFixed(2)}:5:5:${strength.toStringAsFixed(2)}');
      appLog('   → Sharpness: ${imageFilters.sharpness}');
    }

    // STEP 7: COLOR PROFILE (applicato per ultimo, dopo tutti gli altri filtri colore)
    if (imageFilters.colorProfile != 'none') {
      switch (imageFilters.colorProfile) {
        case 'vivid':
          filtersList.add('eq=saturation=1.3:gamma=1.1');
          break;
        case 'cinematic':
          filtersList.add('eq=contrast=1.1:gamma=0.9:saturation=0.9');
          break;
        case 'bw':
          // Converti in scala di grigi usando colorchannelmixer (più affidabile di hue=s=0)
          filtersList.add('colorchannelmixer=.299:.587:.114:0:.299:.587:.114:0:.299:.587:.114');
          break;
        case 'sepia':
          filtersList.add('colorchannelmixer=.393:.769:.189:0:.349:.686:.168:0:.272:.534:.131');
          break;
      }
      appLog('   → Color profile: ${imageFilters.colorProfile}');
    }

    // Aggiorna il comando con il nuovo input path se è stato upscalato
    if (workingInputPath != inputPath) {
      // Trova l'indice di -i nel comando e sostituisci il path
      final inputIndex = command.indexOf('-i');
      if (inputIndex >= 0 && inputIndex + 1 < command.length) {
        command[inputIndex + 1] = workingInputPath;
      }
    }

    if (filtersList.isNotEmpty) {
      command.addAll(['-vf', filtersList.join(',')]);
      appLog('   ✅ Applied ${filtersList.length} image filter(s)');
    } else {
      appLog('   ⚠️ No filters to apply');
    }

    // PARAMETRI QUALITÀ PER IMMAGINI
    // Determina il formato di output dall'estensione
    final outputExt = workingOutputPath.toLowerCase().split('.').last;
    
    if (outputExt == 'jpg' || outputExt == 'jpeg') {
      // Per JPG, usa -q:v (quality value) 1-31, dove 2-5 è alta qualità
      command.addAll(['-q:v', '2']);
      // Specifica il formato JPG esplicitamente
      command.addAll(['-f', 'image2']);
    } else if (outputExt == 'png') {
      // Per PNG, usa compression level 0-9 (0 = nessuna compressione, 9 = massima)
      command.addAll(['-compression_level', '6']);
      command.addAll(['-f', 'image2']);
    } else if (outputExt == 'webp') {
      // Per WebP, usa quality 0-100
      command.addAll(['-quality', '90']);
      command.addAll(['-f', 'webp']);
    } else {
      // Per altri formati, usa qscale come fallback
      command.addAll(['-qscale:v', '2']);
    }
    
    command.add(workingOutputPath);
    
    appLog('   📸 Image output format: $outputExt');
    return command;
  }

  Future<void> _checkAvailableFilters() async {
    // Se già controllato, ritorna immediatamente
    if (_filtersChecked) return;
    
    // Se c'è già un controllo in corso, aspetta che finisca
    if (_filtersCheckCompleter != null) {
      await _filtersCheckCompleter!.future;
      return;
    }
    
    // Crea un nuovo completer per questo controllo
    _filtersCheckCompleter = Completer<void>();
    
    try {
      _availableFilters = {};
      
      // Verifica quali filtri sono disponibili in FFmpeg
      final process = await Process.run('ffmpeg', ['-filters']);
      final output = process.stdout.toString();
      
      // Controlla filtri avanzati (video e audio)
      _availableFilters = {
        // Video filters
        'nlmeans': output.contains('nlmeans'),
        'fftdnoiz': output.contains('fftdnoiz'),
        'vaguedenoiser': output.contains('vaguedenoiser'),
        'hqdn3d': output.contains('hqdn3d'),
        'minideen': output.contains('minideen'),
        'atadenoise': output.contains('atadenoise'),
        'gradfun': output.contains('gradfun'),
        'deblock': output.contains('deblock'),
        'unsharp': output.contains('unsharp'),
        'colorbalance': output.contains('colorbalance'),
        'curves': output.contains('curves'),
        'hue': output.contains('hue'),
        'zscale': output.contains('zscale'),
        'tonemap': output.contains('tonemap'),
        'noise': output.contains(' noise '),  // film grain (evita match su "denoise")
        'eq': output.contains(' eq '),
        // Audio filters
        'loudnorm': output.contains('loudnorm'),
        'afftdn': output.contains('afftdn'),
        'anlmdn': output.contains('anlmdn'),
        'acompressor': output.contains('acompressor'),
        'aecho': output.contains('aecho'),
        'equalizer': output.contains('equalizer'),
        'volume': output.contains('volume'),
      };
      
      appLog('📋 Available filters: $_availableFilters');
    } catch (e) {
      appLog('⚠️ Error checking filters: $e');
      // Default: assume che i filtri base siano disponibili
      _availableFilters = {
        'hqdn3d': true,
        'unsharp': true,
        'gradfun': true,
        'eq': true,
        'noise': true,
        'curves': true,
        'hue': true,
      };
    }
    
    _filtersChecked = true;
    _filtersCheckCompleter!.complete();
    _filtersCheckCompleter = null;
  }
  
  bool _isFilterAvailable(String filterName) {
    // Se i filtri non sono stati ancora controllati, assume che siano disponibili
    // (fallback ottimistico - il controllo verrà fatto prima dell'uso in convertMedia)
    // IMPORTANTE: _checkAvailableFilters() viene sempre chiamato prima di costruire i comandi
    if (_availableFilters == null || !_filtersChecked) {
      // Se il controllo è in corso, aspetta che finisca (sincrono, quindi restituisce true come fallback)
      // In pratica, questo non dovrebbe mai accadere perché _checkAvailableFilters() 
      // viene chiamato prima di costruire i comandi
      return true;
    }
    
    return _availableFilters![filterName] == true;
  }

  Future<void> _checkGpuAcceleration() async {
    // Se già controllato, ritorna immediatamente
    if (_gpuChecked) return;
    
    // Se c'è già un controllo in corso, aspetta che finisca
    if (_gpuCheckCompleter != null) {
      await _gpuCheckCompleter!.future;
      return;
    }
    
    // Crea un nuovo completer per questo controllo
    _gpuCheckCompleter = Completer<void>();
    
    try {
      _availableGpuAccelerations = {};
      appLog('🔍 Checking available GPU accelerations...');
      
      // Controlla encoder disponibili
      final encodersResult = await Process.run('ffmpeg', ['-hide_banner', '-encoders']);
      final encodersOutput = encodersResult.stdout.toString();
      
      // Controlla decoder disponibili
      final decodersResult = await Process.run('ffmpeg', ['-hide_banner', '-decoders']);
      final decodersOutput = decodersResult.stdout.toString();
      
      // Rilevamento NVIDIA (NVENC)
      final nvencH264 = encodersOutput.contains('h264_nvenc');
      final nvencHevc = encodersOutput.contains('hevc_nvenc');
      final nvencAv1 = encodersOutput.contains('av1_nvenc');
      final nvdecH264 = decodersOutput.contains('h264_cuvid') || decodersOutput.contains('h264_nvdec');
      final nvdecHevc = decodersOutput.contains('hevc_cuvid') || decodersOutput.contains('hevc_nvdec');
      
      // Rilevamento Intel (QSV)
      final qsvH264 = encodersOutput.contains('h264_qsv');
      final qsvHevc = encodersOutput.contains('hevc_qsv');
      final qsvAv1 = encodersOutput.contains('av1_qsv');
      final qsvDecH264 = decodersOutput.contains('h264_qsv');
      final qsvDecHevc = decodersOutput.contains('hevc_qsv');
      
      // Rilevamento AMD (AMF)
      final amfH264 = encodersOutput.contains('h264_amf');
      final amfHevc = encodersOutput.contains('hevc_amf');
      final amfAv1 = encodersOutput.contains('av1_amf');
      
      // Rilevamento Apple (VideoToolbox)
      final vtH264 = encodersOutput.contains('h264_videotoolbox');
      final vtHevc = encodersOutput.contains('hevc_videotoolbox');
      final vtProRes = encodersOutput.contains('prores_videotoolbox');
      
      // Rilevamento VAAPI (Linux)
      final vaapiH264 = encodersOutput.contains('h264_vaapi');
      final vaapiHevc = encodersOutput.contains('hevc_vaapi');
      final vaapiAv1 = encodersOutput.contains('av1_vaapi');
      
      // Rilevamento VDPAU (Linux legacy)
      final vdpauH264 = decodersOutput.contains('h264_vdpau');
      final vdpauHevc = decodersOutput.contains('hevc_vdpau');
      
      // Rilevamento OpenCL per filtri GPU
      final openclAvailable = encodersOutput.contains('opencl') || 
                             await _checkOpenCLAvailable();
      
      // Rilevamento CUDA per filtri GPU
      final cudaAvailable = encodersOutput.contains('cuda') || 
                           await _checkCudaAvailable();
      
      _availableGpuAccelerations = {
        'nvidia': nvencH264 || nvencHevc || nvencAv1,
        'nvidia_h264_enc': nvencH264,
        'nvidia_hevc_enc': nvencHevc,
        'nvidia_av1_enc': nvencAv1,
        'nvidia_h264_dec': nvdecH264,
        'nvidia_hevc_dec': nvdecHevc,
        'nvidia_cuda': cudaAvailable,
        
        'intel': qsvH264 || qsvHevc || qsvAv1,
        'intel_h264_enc': qsvH264,
        'intel_hevc_enc': qsvHevc,
        'intel_av1_enc': qsvAv1,
        'intel_h264_dec': qsvDecH264,
        'intel_hevc_dec': qsvDecHevc,
        
        'amd': amfH264 || amfHevc || amfAv1,
        'amd_h264_enc': amfH264,
        'amd_hevc_enc': amfHevc,
        'amd_av1_enc': amfAv1,
        
        'apple': vtH264 || vtHevc || vtProRes,
        'apple_h264_enc': vtH264,
        'apple_hevc_enc': vtHevc,
        'apple_prores_enc': vtProRes,
        
        'vaapi': vaapiH264 || vaapiHevc || vaapiAv1,
        'vaapi_h264_enc': vaapiH264,
        'vaapi_hevc_enc': vaapiHevc,
        'vaapi_av1_enc': vaapiAv1,
        
        'vdpau': vdpauH264 || vdpauHevc,
        'vdpau_h264_dec': vdpauH264,
        'vdpau_hevc_dec': vdpauHevc,
        
        'opencl': openclAvailable,
        'cuda': cudaAvailable,
      };
      
      // Rilevamento automatico della GPU principale
      String? detectedGpu = 'none';
      if (_availableGpuAccelerations!['nvidia'] == true) {
        detectedGpu = 'nvidia';
      } else if (_availableGpuAccelerations!['intel'] == true) {
        detectedGpu = 'intel';
      } else if (_availableGpuAccelerations!['amd'] == true) {
        detectedGpu = 'amd';
      } else if (_availableGpuAccelerations!['apple'] == true) {
        detectedGpu = 'apple';
      } else if (_availableGpuAccelerations!['vaapi'] == true) {
        detectedGpu = 'vaapi';
      }
      
      _availableGpuAccelerations!['detected_gpu'] = detectedGpu;
      
      appLog('✅ GPU acceleration check completed:');
      appLog('   Detected GPU: $detectedGpu');
      appLog('   NVIDIA: ${_availableGpuAccelerations!['nvidia']}');
      appLog('   Intel: ${_availableGpuAccelerations!['intel']}');
      appLog('   AMD: ${_availableGpuAccelerations!['amd']}');
      appLog('   Apple: ${_availableGpuAccelerations!['apple']}');
      appLog('   VAAPI: ${_availableGpuAccelerations!['vaapi']}');
      
    } catch (e) {
      appLog('⚠️ Error checking GPU acceleration: $e');
      _availableGpuAccelerations = {
        'nvidia': false,
        'intel': false,
        'amd': false,
        'apple': false,
        'vaapi': false,
        'detected_gpu': 'none',
      };
    }
    
    _gpuChecked = true;
    _gpuCheckCompleter!.complete();
    _gpuCheckCompleter = null;
  }
  
  Future<bool> _checkOpenCLAvailable() async {
    try {
      if (Platform.isLinux) {
        final result = await Process.run('which', ['clinfo']);
        return result.exitCode == 0;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> _checkCudaAvailable() async {
    try {
      if (Platform.isLinux || Platform.isWindows) {
        final result = await Process.run('nvcc', ['--version']);
        return result.exitCode == 0;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  bool _vendorHasHardwareVideoEncoder(String vendor) {
    if (_availableGpuAccelerations == null) return false;
    switch (vendor) {
      case 'nvidia':
        return _availableGpuAccelerations!['nvidia'] == true;
      case 'intel':
        return _availableGpuAccelerations!['intel'] == true;
      case 'amd':
        return _availableGpuAccelerations!['amd'] == true;
      case 'apple':
        return _availableGpuAccelerations!['apple'] == true;
      case 'vaapi':
        return _availableGpuAccelerations!['vaapi'] == true;
      default:
        return false;
    }
  }

  /// Encode hardware (NVENC/QSV/AMF/…): indipendente dall’hwaccel decode.
  bool _shouldUseGpuVideoEncode(
    VideoFilters filters,
    bool useGpuUser,
    MediaType mediaType,
    bool isAudioExtraction,
  ) {
    if (!useGpuUser || !filters.enableGpuAcceleration) return false;
    if (mediaType != MediaType.video || isAudioExtraction) return false;
    if (_availableGpuAccelerations == null || !_gpuChecked) return false;
    var v = filters.gpuVendor;
    if (v == 'auto') {
      v = _availableGpuAccelerations!['detected_gpu'] as String? ?? 'none';
    }
    if (v == 'none') return false;
    return _vendorHasHardwareVideoEncoder(v);
  }

  /// Restituisce gli argomenti per l'accelerazione GPU COMPLETA.
  /// 
  /// Implementa tutti i parametri ottimizzati per accelerazione hardware:
  /// - NVIDIA: NVDEC (decode) + NVENC (encode) con parametri avanzati
  /// - Intel: QSV decode + encode
  /// - AMD: AMF encode
  /// - VAAPI: decode + encode per Linux
  /// 
  /// [hasVideoFilters]: Se true, **non** usa decode hw (NVDEC/QSV/VAAPI): i frame
  /// passano in software → meno errori driver e compatibilità con -vf / DRUNet / SR.
  /// L’encode hw (es. h264_nvenc) resta invariato.
  List<String> _getGpuAccelerationArgs(VideoFilters filters, {bool hasVideoFilters = false}) {
    if (_availableGpuAccelerations == null || !_gpuChecked) {
      return [];
    }

    final detectedGpu = _availableGpuAccelerations!['detected_gpu'] as String?;
    final gpuType = filters.gpuVendor == 'auto' ? detectedGpu : filters.gpuVendor;

    if (gpuType == null || gpuType == 'none') {
      return [];
    }

    final args = <String>[];
    
    // NVIDIA: NVDEC solo senza catena -vf pesante; con filtri → decode software + NVENC
    // (evita CUDA_ERROR_INVALID_VALUE / superfici NVDEC come nei log utente).
    if (gpuType == 'nvidia') {
      final decOk = _availableGpuAccelerations!['nvidia_h264_dec'] == true ||
          _availableGpuAccelerations!['nvidia_hevc_dec'] == true;
      if (decOk && !hasVideoFilters) {
        args.addAll(['-hwaccel', 'cuda', '-hwaccel_output_format', 'cuda']);
        appLog('🚀 NVIDIA: NVDEC decode (CUDA) — nessun filtro video');
      } else if (decOk && hasVideoFilters) {
        appLog('ℹ️ NVIDIA: decode software + filtri CPU — NVENC invariato (stabilità con -vf)');
      }
    }
    // Intel QSV: decode hw solo senza filtri (stesso principio)
    else if (gpuType == 'intel') {
      final decOk = _availableGpuAccelerations!['intel_h264_dec'] == true ||
          _availableGpuAccelerations!['intel_hevc_dec'] == true;
      if (decOk && !hasVideoFilters) {
        args.addAll(['-hwaccel', 'qsv']);
        appLog('🚀 Intel: QSV decode (nessun filtro video)');
      } else if (decOk && hasVideoFilters) {
        appLog('ℹ️ Intel: decode software — filtri attivi (encode hw se codec lo consente)');
      }
    }
    // VAAPI
    else if (gpuType == 'vaapi') {
      if (!hasVideoFilters) {
        args.addAll([
          '-hwaccel', 'vaapi',
          '-hwaccel_device', '/dev/dri/renderD128',
          '-hwaccel_output_format', 'vaapi',
        ]);
        appLog('🚀 VAAPI: decode hw (nessun filtro video)');
      } else {
        appLog('ℹ️ VAAPI: decode software — filtri attivi');
      }
    }
    
    if (args.isNotEmpty) {
      appLog('✅ GPU acceleration args: ${args.join(" ")}');
    } else {
      appLog('ℹ️ GPU detected ($gpuType) ma usando solo hardware codec (no hwaccel flags)');
    }
    
    return args;
  }

  int _getSafeThreadCount(int requestedThreads, bool usingGpu) {
    final platform = Platform.numberOfProcessors.clamp(1, 256);
    final gpuSuggested = (platform / 2).round().clamp(2, 16);
    // 0 = automatico: usa tutti i logical processor (vecchi e nuovi CPU, laptop e workstation)
    if (requestedThreads == 0) {
      final chosen = usingGpu ? gpuSuggested : platform;
      appLog(
        '💻 Thread FFmpeg (-threads): $chosen (tutti i logical processor; '
        'GPU encode: $usingGpu)',
      );
      return chosen;
    }
    final cappedMax = usingGpu ? gpuSuggested : platform;
    final capped = requestedThreads.clamp(1, cappedMax);
    appLog(
      '💻 Thread FFmpeg: $capped (richiesti: $requestedThreads, max: $cappedMax)',
    );
    return capped;
  }
  
  /// Metodo per convertire con sovrascrittura esplicita
  Future<Map<String, dynamic>> convertMediaWithOverwrite({
    required String taskId,
    required String inputPath,
    required String outputPath,
    required MediaType mediaType,
    required int videoQuality,
    required int audioQuality,
    required String audioCodec,
    required String videoCodec,
    required int videoBitrate,
    required String videoBitrateMode,
    required VideoFilters videoFilters,
    required AudioFilters audioFilters,
    required ImageFilters imageFilters,
    required int cpuThreads,
    required bool useGpu,
    required String gpuType,
    required bool overwriteExisting,
    required MediaConvertOnProgress onProgress,
    bool extractAudioFromVideo = false,
  }) async {
    // Chiama il metodo normale di conversione con sovrascrittura abilitata
    return convertMedia(
      taskId: taskId,
      inputPath: inputPath,
      outputPath: outputPath,
      mediaType: mediaType,
      videoQuality: videoQuality,
      audioQuality: audioQuality,
      audioCodec: audioCodec,
      videoCodec: videoCodec,
      videoBitrate: videoBitrate,
      videoBitrateMode: videoBitrateMode,
      videoFilters: videoFilters,
      audioFilters: audioFilters,
      imageFilters: imageFilters,
      cpuThreads: cpuThreads,
      useGpu: useGpu,
      gpuType: gpuType,
      overwriteExisting: overwriteExisting,
      onProgress: onProgress,
      extractAudioFromVideo: extractAudioFromVideo,
    );
  }

  Future<Map<String, dynamic>> _runFFmpegCommand({
    required String taskId,
    required List<String> command,
    required String inputPath,
    required String outputPath,
    required MediaConvertOnProgress onProgress,
    required bool useGpu,
    int hardwareRetryStage = 0,
  }) async {
    Process? process;
    
    try {
      appLog('🚀 Executing FFmpeg command...');
      
      final outputFile = File(outputPath);
      if (await outputFile.exists()) {
        await outputFile.delete();
      }

      // Log comando completo per debug
      appLog('🔧 [FFmpeg] Comando completo: ${command.join(" ")}');
      
      process = await Process.start(command[0], command.sublist(1));
      _activeProcesses[taskId] = process;

      final stderrBuffer = StringBuffer();
      final stdoutBuffer = StringBuffer();
      bool hasDuration = false;
      double duration = 0.0;
      var lastEncTimeSec = 0.0;
      var lastEncWall = DateTime.now();
      var encTimeSampleStarted = false;
      double? wallClockFps;
      // NON usare euristiche su stderr (es. "failed", "invalid" da NVDEC/CUDA):
      // FFmpeg le stampa anche quando ripiega su decode software e termina con exit 0.

      // Cattura anche stdout per debug con gestione errori
      process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            (String line) {
              try {
                stdoutBuffer.writeln(line);
                // Log stdout per debug
                if (line.trim().isNotEmpty) {
                  appLog('📤 [FFmpeg stdout] $line');
                }
              } catch (e) {
                appLog('⚠️ [FFmpeg] Errore processamento stdout: $e');
              }
            },
            onError: (error) {
              appLog('⚠️ [FFmpeg] Errore stream stdout: $error');
              // Non bloccare la conversione per errori di stream
            },
            onDone: () {
              // Stream completato normalmente
            },
            cancelOnError: false, // Continua anche se c'è un errore
          );

      _outputSubscriptions[taskId] = process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            (String line) {
              try {
                // Cattura TUTTI gli errori, non solo alcuni
                if (line.trim().isNotEmpty) {
                  stderrBuffer.writeln(line);
                  appLog('⚠️ [FFmpeg stderr] $line');
                }

                // Parsing durata con gestione errori
                if (!hasDuration) {
                  try {
                    final durationMatch = RegExp(r'Duration:\s*(\d{2}):(\d{2}):(\d{2})\.(\d{2})').firstMatch(line);
                    if (durationMatch != null) {
                      final hours = int.parse(durationMatch.group(1)!);
                      final minutes = int.parse(durationMatch.group(2)!);
                      final seconds = int.parse(durationMatch.group(3)!);
                      final milliseconds = int.parse(durationMatch.group(4)!);
                      duration = hours * 3600 + minutes * 60 + seconds + milliseconds / 100;
                      hasDuration = true;
                    }
                  } catch (e) {
                    // Ignora errori di parsing durata
                    appLog('⚠️ [FFmpeg] Errore parsing durata: $e');
                  }
                }

                // Parsing progresso con gestione errori
                if (hasDuration && duration > 0) {
                  try {
                    final progressMatch = RegExp(r'time=(\d{2}):(\d{2}):(\d{2})\.(\d{2})').firstMatch(line);
                    if (progressMatch != null) {
                      final hours = int.parse(progressMatch.group(1)!);
                      final minutes = int.parse(progressMatch.group(2)!);
                      final seconds = int.parse(progressMatch.group(3)!);
                      final milliseconds = int.parse(progressMatch.group(4)!);
                      final currentTime = hours * 3600 + minutes * 60 + seconds + milliseconds / 100;
                      final progress = (currentTime / duration).clamp(0.0, 1.0);

                      // Stima tempo rimanente basata sulla posizione corrente nel video
                      final remainingSeconds = (duration - currentTime).clamp(0.0, duration);
                      final remHours = remainingSeconds ~/ 3600;
                      final remMinutes = (remainingSeconds % 3600) ~/ 60;
                      final remSecs = (remainingSeconds % 60).round();
                      final etaString = remHours > 0
                          ? '${remHours.toString().padLeft(2, '0')}:${remMinutes.toString().padLeft(2, '0')}:${remSecs.toString().padLeft(2, '0')}'
                          : '${remMinutes.toString().padLeft(2, '0')}:${remSecs.toString().padLeft(2, '0')}';

                      final nowEnc = DateTime.now();
                      if (!encTimeSampleStarted) {
                        encTimeSampleStarted = true;
                        lastEncTimeSec = currentTime;
                        lastEncWall = nowEnc;
                      } else {
                        final wallDt = nowEnc.difference(lastEncWall).inMicroseconds / 1e6;
                        final inst = ProcessingFpsSanitize.fromMediaTimeDelta(
                          prevTimeSec: lastEncTimeSec,
                          timeSec: currentTime,
                          wallDtSec: wallDt,
                        );
                        if (inst != null) {
                          wallClockFps = wallClockFps == null
                              ? inst
                              : (wallClockFps! * 0.75 + inst * 0.25);
                        }
                        lastEncTimeSec = currentTime;
                        lastEncWall = nowEnc;
                      }

                      double? stderrFps;
                      final fpsM = RegExp(r'\bfps=\s*([0-9]+(?:\.[0-9]+)?)').firstMatch(line);
                      if (fpsM != null) {
                        stderrFps = ProcessingFpsSanitize.fromReported(
                          double.tryParse(fpsM.group(1)!),
                        );
                      }

                        onProgress(
                          progress,
                          '${_progressLabel('remaining')} ~ $etaString',
                          processingFps: stderrFps ?? wallClockFps,
                        );
                    }
                  } catch (e) {
                    // Ignora errori di parsing progresso
                    appLog('⚠️ [FFmpeg] Errore parsing progresso: $e');
                  }
                }
              } catch (e) {
                appLog('⚠️ [FFmpeg] Errore processamento stderr: $e');
              }
            },
            onError: (error) {
              appLog('⚠️ [FFmpeg] Errore stream stderr: $error');
              // Non bloccare la conversione per errori di stream
            },
            onDone: () {
              // Stream completato normalmente
            },
            cancelOnError: false, // Continua anche se c'è un errore
          );

      // Attendi exit code con gestione errori
      int exitCode = 1;
      try {
        exitCode = await process.exitCode;
      } catch (e) {
        appLog('⚠️ [FFmpeg] Errore ottenimento exit code: $e');
        // Se il processo è stato terminato, prova a killarlo
        try {
          process.kill();
        } catch (killError) {
          appLog('⚠️ [FFmpeg] Errore kill processo: $killError');
        }
      }
      
      // Pulisci risorse in modo sicuro
      try {
        _outputSubscriptions.remove(taskId)?.cancel();
      } catch (e) {
        appLog('⚠️ [FFmpeg] Errore cancellazione subscription: $e');
      }
      
      try {
        _activeProcesses.remove(taskId);
      } catch (e) {
        appLog('⚠️ [FFmpeg] Errore rimozione processo: $e');
      }

      // Solo exit code + file output: stderr contiene anche avvisi innocui (CUDA/NVDEC, progress)
      if (exitCode == 0) {
        if (await outputFile.exists()) {
          final stat = await outputFile.stat();
          if (stat.size > 0) {
            onProgress(1.0, _progressLabel('completed'));
            return {
              'success': true,
              'outputPath': outputPath,
              'fileSize': stat.size,
              'usedGpu': useGpu,
            };
          }
        }
      }

      final errorMessage = stderrBuffer.toString();
      final stdoutMessage = stdoutBuffer.toString();
      
      // Exit 255 = processo terminato (kill/SIGTERM/OOM); 130 = SIGINT; 137 = SIGKILL
      final interruptedExit = exitCode == 255 || exitCode == 130 || exitCode == 137;
      
      // Se stderr è vuoto ma exitCode != 0, usa stdout o mostra comando
      String finalErrorMessage = errorMessage;
      if (finalErrorMessage.isEmpty && exitCode != 0) {
        if (stdoutMessage.isNotEmpty) {
          finalErrorMessage = stdoutMessage;
        } else {
          finalErrorMessage = 'FFmpeg fallito senza output di errore. Exit code: $exitCode';
          appLog('⚠️ [FFmpeg] Nessun output stderr, ma exit code = $exitCode');
          appLog('⚠️ [FFmpeg] Comando eseguito: ${command.join(" ")}');
        }
      }

      if (hardwareRetryStage == 0 &&
          useGpu &&
          _stderrSuggestsUnsupportedHwEncoderOption(finalErrorMessage)) {
        final safeCommand = _buildSafeHardwareRetryCommand(command);
        if (!_commandsEquivalent(command, safeCommand)) {
          appLog('⚠️ [FFmpeg] Retry safe hardware profile (unsupported HW option)');
          return _runFFmpegCommand(
            taskId: taskId,
            command: safeCommand,
            inputPath: inputPath,
            outputPath: outputPath,
            onProgress: onProgress,
            useGpu: useGpu,
            hardwareRetryStage: 1,
          );
        }
      }

      final looksLikeCodecIssue = finalErrorMessage.toLowerCase().contains('unknown encoder') ||
          finalErrorMessage.toLowerCase().contains('encoder') ||
          finalErrorMessage.toLowerCase().contains('codec');

      if (hardwareRetryStage <= 1 && useGpu && looksLikeCodecIssue) {
        final minimalGpuCommand = _buildMinimalGpuRetryCommand(command);
        if (!_commandsEquivalent(command, minimalGpuCommand)) {
          appLog('⚠️ [FFmpeg] Retry minimal GPU profile');
          return _runFFmpegCommand(
            taskId: taskId,
            command: minimalGpuCommand,
            inputPath: inputPath,
            outputPath: outputPath,
            onProgress: onProgress,
            useGpu: true,
            hardwareRetryStage: 2,
          );
        }
      }

      if (hardwareRetryStage <= 2 && useGpu && looksLikeCodecIssue) {
        final cpuFallbackCommand = _buildCpuFallbackRetryCommand(command);
        if (!_commandsEquivalent(command, cpuFallbackCommand)) {
          appLog('⚠️ [FFmpeg] Retry CPU fallback profile');
          return _runFFmpegCommand(
            taskId: taskId,
            command: cpuFallbackCommand,
            inputPath: inputPath,
            outputPath: outputPath,
            onProgress: onProgress,
            useGpu: false,
            hardwareRetryStage: 3,
          );
        }
      }
      
      String userFriendlyError = 'Conversione fallita';
      
      if (interruptedExit) {
        userFriendlyError = 'Conversione interrotta (exit $exitCode). '
            'Il processo potrebbe essere stato fermato dall\'utente o dal sistema (es. memoria insufficiente).';
        // Evita di stampare l'intero stderr (solo log FFmpeg/progress)
        final preview = finalErrorMessage.length > 400
            ? '${finalErrorMessage.substring(0, 400)}...'
            : finalErrorMessage;
        appLog('❌ FFmpeg error (exit code: $exitCode, interrupted): $preview');
      }
      // Analizza l'errore per fornire messaggi più informativi
      else if (finalErrorMessage.contains('No such file or directory')) {
        userFriendlyError = 'File non trovato. Verifica che il file di input esista.';
      } else if (finalErrorMessage.contains('Invalid argument') || finalErrorMessage.contains('Invalid data') ||
          finalErrorMessage.contains('Invalid') || finalErrorMessage.contains('invalid')) {
        if (_stderrIsBenignCudaNvdecNoise(finalErrorMessage)) {
          userFriendlyError = _appendFfmpegDetail(
            'Conversione non riuscita. Se usi GPU, prova a disattivare l’accelerazione hardware '
            'o ridurre i thread; vedi dettaglio FFmpeg sotto.',
            finalErrorMessage,
          );
        } else if (_stderrSuggestsVideoFilterChainFailure(finalErrorMessage)) {
          userFriendlyError = _appendFfmpegDetail(
            'Errore nei parametri di conversione. Alcuni filtri potrebbero non essere supportati.',
            finalErrorMessage,
          );
        } else if (finalErrorMessage.contains('codec') || finalErrorMessage.contains('encoder') ||
            finalErrorMessage.contains('decoder')) {
          userFriendlyError = _appendFfmpegDetail(
            'Codec non supportato. Prova a cambiare il codec video o audio.',
            finalErrorMessage,
          );
        } else {
          userFriendlyError = _appendFfmpegDetail(
            'Errore nei parametri di conversione. Verifica che i parametri siano corretti.',
            finalErrorMessage,
          );
        }
      } else if (finalErrorMessage.contains('Permission denied')) {
        userFriendlyError = 'Permessi insufficienti. Verifica i permessi di scrittura per la directory di output.';
      } else if (finalErrorMessage.contains('codec') || finalErrorMessage.contains('encoder') ||
          finalErrorMessage.contains('decoder')) {
        userFriendlyError = _appendFfmpegDetail(
          'Codec non supportato. Prova a cambiare il codec video o audio.',
          finalErrorMessage,
        );
      } else if (finalErrorMessage.contains('filter') || finalErrorMessage.contains('Filter')) {
        userFriendlyError = _appendFfmpegDetail(
          'Filtro non supportato. Alcuni filtri avanzati potrebbero non essere disponibili in questa versione di FFmpeg.',
          finalErrorMessage,
        );
      } else if (finalErrorMessage.isNotEmpty) {
        // Estrai la prima riga significativa dell'errore
        final lines = finalErrorMessage.split('\n').where((line) => 
          line.trim().isNotEmpty && 
          !line.contains('ffmpeg version') &&
          !line.contains('built with') &&
          !line.contains('configuration:')
        ).take(3).toList();
        if (lines.isNotEmpty) {
          userFriendlyError = 'Errore: ${lines.first.trim()}';
          if (lines.length > 1) {
            userFriendlyError += '\n${lines[1].trim()}';
          }
        }
      } else {
        userFriendlyError = 'Conversione fallita (exit code: $exitCode)';
      }
      
      if (!interruptedExit) {
        appLog('❌ FFmpeg error (exit code: $exitCode): $finalErrorMessage');
      }
      if (finalErrorMessage.isEmpty && !interruptedExit) {
        appLog('⚠️ [FFmpeg] Nessun messaggio di errore catturato. Verifica il comando FFmpeg.');
      }
      
      return {
        'success': false,
        'error': userFriendlyError,
        'raw_error': finalErrorMessage,
        'exit_code': exitCode,
        'usedGpu': useGpu,
      };
    } catch (e, stackTrace) {
      // Gestione errori robusta per prevenire crash
      appLog('❌ [FFmpeg] Errore critico in _runFFmpegCommand: $e');
      appLog('📚 [FFmpeg] Stack trace: $stackTrace');
      
      // Pulisci risorse in modo sicuro
      try {
        _outputSubscriptions.remove(taskId)?.cancel();
      } catch (cleanupError) {
        appLog('⚠️ [FFmpeg] Errore durante cleanup subscription: $cleanupError');
      }
      
      try {
        final process = _activeProcesses.remove(taskId);
        if (process != null) {
          try {
            process.kill();
          } catch (killError) {
            appLog('⚠️ [FFmpeg] Errore durante kill processo: $killError');
          }
        }
      } catch (cleanupError) {
        appLog('⚠️ [FFmpeg] Errore durante cleanup processo: $cleanupError');
      }
      
      return {
        'success': false,
        'error': 'Errore esecuzione FFmpeg: $e'
      };
    } finally {
      // Assicurati che le risorse siano sempre pulite
      try {
        _outputSubscriptions.remove(taskId)?.cancel();
        _activeProcesses.remove(taskId);
      } catch (e) {
        // Ignora errori nel finally
      }
    }
  }

  /// Ottiene le opzioni ottimizzate per codec hardware
  List<String> _getHardwareCodecOptions(
    String codec,
    bool useGpu,
    VideoFilters filters,
    Map<String, dynamic>? analysis,
  ) {
    final options = <String>[];
    
    if (!useGpu) return options;
    
    final policy = _resolveEncodePolicy(codec, filters, analysis);
    final preset = switch (policy) {
      _EncodePolicy.speed => 'fast',
      _EncodePolicy.balanced => 'medium',
      _EncodePolicy.quality => 'high_quality',
    };
    
    if (codec.contains('nvenc')) {
      // NVIDIA NVENC: OTTIMIZZAZIONI COMPLETE
      // Preset: p1 (fastest) a p7 (slowest/highest quality)
      final nvencPreset = _getNvencPreset(preset);
      options.addAll(['-preset', nvencPreset]);
      options.addAll(['-rc', preset == 'high_quality' ? 'vbr_hq' : 'vbr']);
      options.addAll(['-b_ref_mode', 'middle']); // B-frame reference mode
      if (policy == _EncodePolicy.quality) {
        options.addAll(['-rc-lookahead', '24']);
        options.addAll(['-temporal-aq', '1', '-spatial-aq', '1', '-aq-strength', '8']);
        options.addAll(['-multipass', 'qres']);
        options.addAll(['-bf', '3']);
      } else if (policy == _EncodePolicy.balanced) {
        options.addAll(['-rc-lookahead', '12']);
        options.addAll(['-temporal-aq', '1', '-spatial-aq', '1', '-aq-strength', '6']);
        options.addAll(['-bf', '2']);
      } else {
        options.addAll(['-rc-lookahead', '0']);
        options.addAll(['-temporal-aq', '0', '-spatial-aq', '0']);
        options.addAll(['-bf', '2']);
        options.addAll(['-zerolatency', '1']);
      }
      
      // GPU ID esplicito
      options.addAll(['-gpu', '0']);
      
      // Surfaces per parallelismo
      options.addAll(['-surfaces', policy == _EncodePolicy.speed ? '32' : '48']);
      
    } else if (codec.contains('qsv')) {
      // Intel QSV: OTTIMIZZAZIONI COMPLETE
      final qsvPreset = _getQsvPreset(preset);
      options.addAll(['-preset', qsvPreset]);
      options.addAll(['-global_quality', policy == _EncodePolicy.quality ? '20' : '23']);
      
      // Look-ahead per migliore qualità
      if (policy == _EncodePolicy.quality) {
        options.addAll(['-look_ahead', '1']);
        options.addAll(['-look_ahead_depth', '30']);
      } else if (policy == _EncodePolicy.balanced) {
        options.addAll(['-look_ahead', '1']);
        options.addAll(['-look_ahead_depth', '16']);
      } else {
        options.addAll(['-look_ahead', '0']);
      }
      
      // Trellis quantization per qualità
      if (policy == _EncodePolicy.quality) {
        options.addAll(['-trellis', '1']);
      }
      
      // IDR interval
      options.addAll(['-g', '250']); // GOP size
      
      // Async depth per parallelismo
      options.addAll(['-async_depth', policy == _EncodePolicy.speed ? '6' : '4']);
      
    } else if (codec.contains('amf')) {
      // AMD AMF: OTTIMIZZAZIONI COMPLETE
      final amfPreset = _getAmfPreset(preset);
      options.addAll(['-quality', amfPreset]);
      options.addAll(['-rc', 'vbr_peak']); // Variable bitrate peak
      options.addAll(['-usage', 'transcoding']); // Ottimizzato per transcoding
      
      // Pre-analysis per qualità
      if (policy == _EncodePolicy.quality) {
        options.addAll(['-preanalysis', '1']);
        options.addAll(['-preanalysis_quality', 'high']);
      } else if (policy == _EncodePolicy.balanced) {
        options.addAll(['-preanalysis', '1']);
        options.addAll(['-preanalysis_quality', 'medium']);
      } else {
        options.addAll(['-preanalysis', '0']);
      }
      
      // Enforce HRD per compatibilità
      options.addAll(['-enforce_hrd', '1']);
      
      // Maximum reference frames
      if (policy == _EncodePolicy.quality) {
        options.addAll(['-ref', '4']); // Più reference frames
      } else {
        options.addAll(['-ref', '2']);
      }
      
      // Maximum B-frames
      options.addAll(['-bf', '3']);
      
      // Rate control method
      options.addAll(['-rc', 'vbr_peak']);
      
      // Quality preset
      if (policy == _EncodePolicy.quality) {
        options.addAll(['-quality', 'balanced']);
      } else if (policy == _EncodePolicy.balanced) {
        options.addAll(['-quality', 'speed']);
      } else {
        options.addAll(['-quality', 'speed']);
      }
      
    } else if (codec.contains('vaapi')) {
      // VAAPI: OTTIMIZZAZIONI COMPLETE
      // Quality level (18-28, più basso = migliore qualità)
      if (policy == _EncodePolicy.quality) {
        options.addAll(['-qp', '18']); // Alta qualità
      } else if (policy == _EncodePolicy.balanced) {
        options.addAll(['-qp', '23']); // Qualità media
      } else {
        options.addAll(['-qp', '26']); // Qualità veloce
      }
      
      // IDR interval
      options.addAll(['-g', '250']);
      
      // Rate control
      options.addAll(['-rc_mode', 'VBR']); // Variable bitrate
      
      // Max frame size
      if (policy == _EncodePolicy.quality) {
        options.addAll(['-max_frame_size', '0']); // Nessun limite
      }
      
      // Compression level
      final vaapiPreset = _getVaapiPreset(preset);
      options.addAll(['-compression_level', vaapiPreset]);
      
      // Low power mode (disabilitato per qualità)
      if (policy == _EncodePolicy.speed) {
        options.addAll(['-low_power', '1']);
      }
      
    } else if (codec.contains('videotoolbox')) {
      // Apple VideoToolbox opzioni
      options.addAll(['-allow_sw', '1']); // Permetti software fallback
      options.addAll(['-realtime', '0']); // Non realtime per migliore qualità
    }
    
    return options;
  }

  bool _commandsEquivalent(List<String> a, List<String> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  List<String> _buildSafeHardwareRetryCommand(List<String> original) {
    final dropWithValue = <String>{
      '-preset',
      '-rc',
      '-rc-lookahead',
      '-temporal-aq',
      '-spatial-aq',
      '-aq-strength',
      '-multipass',
      '-b_ref_mode',
      '-surfaces',
      '-look_ahead',
      '-look_ahead_depth',
      '-trellis',
      '-async_depth',
      '-preanalysis',
      '-preanalysis_quality',
      '-enforce_hrd',
      '-ref',
      '-bf',
      '-rc_mode',
      '-compression_level',
      '-low_power',
      '-max_frame_size',
      '-usage',
      '-quality',
      '-zerolatency',
      '-gpu',
      '-global_quality',
      '-qp',
      '-realtime',
      '-allow_sw',
    };
    final out = <String>[];
    for (var i = 0; i < original.length; i++) {
      final token = original[i];
      if (dropWithValue.contains(token)) {
        i += 1;
        continue;
      }
      out.add(token);
    }
    return out;
  }

  List<String> _buildMinimalGpuRetryCommand(List<String> original) {
    final out = _buildSafeHardwareRetryCommand(original);
    final cidx = out.indexOf('-c:v');
    if (cidx >= 0 && cidx + 1 < out.length) {
      final current = out[cidx + 1];
      if (current.contains('nvenc')) {
        out[cidx + 1] = 'h264_nvenc';
      } else if (current.contains('qsv')) {
        out[cidx + 1] = 'h264_qsv';
      } else if (current.contains('amf')) {
        out[cidx + 1] = 'h264_amf';
      } else if (current.contains('vaapi')) {
        out[cidx + 1] = 'h264_vaapi';
      }
    }
    return out;
  }

  List<String> _buildCpuFallbackRetryCommand(List<String> original) {
    final out = <String>[];
    for (var i = 0; i < original.length; i++) {
      final t = original[i];
      if (t == '-c:v') {
        out.add(t);
        out.add('libx264');
        i += 1;
        continue;
      }
      out.add(t);
    }
    return _buildSafeHardwareRetryCommand(out);
  }

  _EncodePolicy _resolveEncodePolicy(
    String codec,
    VideoFilters filters,
    Map<String, dynamic>? analysis,
  ) {
    if (filters.gpuEncodingPreset == 'fast') return _EncodePolicy.speed;
    if (filters.gpuEncodingPreset == 'high_quality') return _EncodePolicy.quality;
    if (filters.gpuEncodingPreset == 'slow') return _EncodePolicy.quality;

    // Auto policy (default when preset == medium): push speed on heavy pipelines.
    // DRUNet is a Python pre-pass, not FFmpeg filter load; do not force NVENC speed for it.
    final heavyFilters = filters.hasActiveFilters ||
        filters.advancedDenoiseMethod == 'nlmeans' ||
        filters.superResolutionMethod != 'none' ||
        filters.temporalDenoise > 0.45;
    final heavyAnalysis = analysis?['needs_advanced_processing'] == true ||
        analysis?['quality_issues']?.contains('heavy_compression') == true;
    if (heavyFilters || heavyAnalysis) {
      appLog('⚡ Auto policy: SPEED (heavy filter chain detected)');
      return _EncodePolicy.speed;
    }

    final highDetailSource =
        analysis?['quality_issues']?.contains('low_bitrate') == true ||
        analysis?['quality_issues']?.contains('old_codec') == true;
    if (highDetailSource && !codec.contains('av1')) {
      appLog('🎯 Auto policy: QUALITY (source needs cleanup)');
      return _EncodePolicy.quality;
    }

    appLog('⚖️ Auto policy: BALANCED');
    return _EncodePolicy.balanced;
  }
  
  String _getNvencPreset(String preset) {
    switch (preset) {
      case 'fast':
        return 'p1';
      case 'medium':
        return 'p4';
      case 'slow':
        return 'p6';
      case 'high_quality':
        return 'p7';
      default:
        return 'p4';
    }
  }
  
  String _getQsvPreset(String preset) {
    switch (preset) {
      case 'fast':
        return 'veryfast';
      case 'medium':
        return 'medium';
      case 'slow':
        return 'slow';
      case 'high_quality':
        return 'veryslow';
      default:
        return 'medium';
    }
  }
  
  String _getAmfPreset(String preset) {
    switch (preset) {
      case 'fast':
        return 'speed';
      case 'medium':
        return 'balanced';
      case 'slow':
        return 'quality';
      case 'high_quality':
        return 'quality';
      default:
        return 'balanced';
    }
  }
  
  String _getVaapiPreset(String preset) {
    switch (preset) {
      case 'fast':
        return '1';
      case 'medium':
        return '4';
      case 'slow':
        return '6';
      case 'high_quality':
        return '8';
      default:
        return '4';
    }
  }
  
  /// Ottiene il pixel format ottimale per il codec
  /// IMPORTANTE: Preserva il formato originale quando possibile per evitare conversioni che scuriscono
  String? _getOptimalPixelFormat(String codec, bool useGpu, Map<String, dynamic>? analysis) {
    // Per codec software, preserva il formato originale invece di forzare yuv420p
    // La conversione può causare problemi di luminosità
    if (!useGpu) {
      // Solo se il codec richiede esplicitamente un formato specifico
      return null; // Preserva originale
    }
    
    // Per codec hardware, usa il formato richiesto ma solo se necessario
    if (codec.contains('nvenc')) {
      // NVENC supporta nv12 (YUV420) e p010le (10-bit)
      // Usa nv12 solo se necessario, altrimenti preserva
      return 'nv12';
    } else if (codec.contains('qsv')) {
      // QSV supporta nv12
      return 'nv12';
    } else if (codec.contains('amf')) {
      // AMF supporta nv12
      return 'nv12';
    } else if (codec.contains('vaapi')) {
      // VAAPI supporta nv12
      return 'nv12';
    } else if (codec.contains('videotoolbox')) {
      // VideoToolbox gestisce automaticamente
      return null; // Lascia che VideoToolbox scelga
    }
    
    // Fallback: preserva originale invece di forzare yuv420p
    return null;
  }

  Future<Map<String, dynamic>> getGpuAccelerationInfo() async {
    await _checkGpuAcceleration();
    
    if (_availableGpuAccelerations == null) {
      return {
        'success': false,
        'error': 'GPU acceleration not checked yet',
      };
    }
    
    final detectedGpu = _availableGpuAccelerations!['detected_gpu'] as String? ?? 'none';
    final availableAccelerations = <String>[];
    
    if (_availableGpuAccelerations!['nvidia'] == true) {
      availableAccelerations.add('NVIDIA NVENC');
    }
    if (_availableGpuAccelerations!['intel'] == true) {
      availableAccelerations.add('Intel QSV');
    }
    if (_availableGpuAccelerations!['amd'] == true) {
      availableAccelerations.add('AMD AMF');
    }
    if (_availableGpuAccelerations!['apple'] == true) {
      availableAccelerations.add('Apple VideoToolbox');
    }
    if (_availableGpuAccelerations!['vaapi'] == true) {
      availableAccelerations.add('VAAPI');
    }
    
    return {
      'success': true,
      'gpu_acceleration': _availableGpuAccelerations,
      'detected_gpu': detectedGpu,
      'available_accelerations': availableAccelerations,
      'acceleration_count': availableAccelerations.length,
    };
  }

  void killProcess(String taskId) {
    _outputSubscriptions[taskId]?.cancel();
    _outputSubscriptions.remove(taskId);
    final process = _activeProcesses[taskId];
    if (process != null) {
      process.kill();
      _activeProcesses.remove(taskId);
    }
  }

  void killAllProcesses() {
    for (final subscription in _outputSubscriptions.values) {
      subscription.cancel();
    }
    _outputSubscriptions.clear();
    for (final process in _activeProcesses.values) {
      process.kill();
    }
    _activeProcesses.clear();
  }
}