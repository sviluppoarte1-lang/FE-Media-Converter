import 'package:video_converter_pro/utils/app_log.dart';
// Basato su tecniche da video_upscaler (https://github.com/MatheusFL99/video_upscaler)
import 'package:video_converter_pro/services/ffmpeg_service.dart';

class VideoUpscalerService {
  final FFmpegService _ffmpegService;

  VideoUpscalerService(this._ffmpegService);

  /// Ottiene le informazioni del video per calcolare la risoluzione target
  Future<Map<String, int>?> getVideoDimensions(String inputPath) async {
    try {
      final infoResult = await _ffmpegService.getVideoInfo(inputPath);
      if (infoResult['success'] != true) return null;

      final mediaInfo = infoResult['info'];
      final streams = mediaInfo['streams'] as List<dynamic>?;
      if (streams == null || streams.isEmpty) return null;

      final videoStream = streams.firstWhere(
        (stream) => stream['codec_type'] == 'video',
        orElse: () => null,
      );

      if (videoStream == null) return null;

      final width = videoStream['width'] as int?;
      final height = videoStream['height'] as int?;

      if (width == null || height == null || width <= 0 || height <= 0) {
        return null;
      }

      return {'width': width, 'height': height};
    } catch (e) {
      appLog('❌ [VideoUpscaler] Errore ottenimento dimensioni: $e');
      return null;
    }
  }

  /// Calcola la risoluzione target ottimizzata per upscaling
  /// Basato su algoritmi di video_upscaler per garantire qualità ottimale
  Map<String, int> calculateTargetResolution({
    required int originalWidth,
    required int originalHeight,
    required double scaleFactor,
    String? preset, // 'hd', 'fullhd', '4k', 'custom'
  }) {
    int targetWidth;
    int targetHeight;

    if (preset != null && preset != 'custom') {
      // Usa preset standard per qualità ottimale
      switch (preset.toLowerCase()) {
        case 'hd':
          targetWidth = 1280;
          targetHeight = 720;
          break;
        case 'fullhd':
          targetWidth = 1920;
          targetHeight = 1080;
          break;
        case '4k':
          targetWidth = 3840;
          targetHeight = 2160;
          break;
        default:
          // Calcola basandosi sul fattore di scala
          targetWidth = (originalWidth * scaleFactor).round();
          targetHeight = (originalHeight * scaleFactor).round();
      }
    } else {
      // Calcola basandosi sul fattore di scala
      targetWidth = (originalWidth * scaleFactor).round();
      targetHeight = (originalHeight * scaleFactor).round();
    }

    // Assicura che le dimensioni siano pari (richiesto da molti codec)
    targetWidth = targetWidth.isEven ? targetWidth : targetWidth + 1;
    targetHeight = targetHeight.isEven ? targetHeight : targetHeight + 1;

    // Mantieni aspect ratio se necessario
    final originalAspectRatio = originalWidth / originalHeight;
    final targetAspectRatio = targetWidth / targetHeight;

    if ((targetAspectRatio - originalAspectRatio).abs() > 0.01) {
      // Ricalcola per mantenere aspect ratio
      if (targetWidth / originalAspectRatio <= targetHeight) {
        targetHeight = (targetWidth / originalAspectRatio).round();
      } else {
        targetWidth = (targetHeight * originalAspectRatio).round();
      }
      targetWidth = targetWidth.isEven ? targetWidth : targetWidth + 1;
      targetHeight = targetHeight.isEven ? targetHeight : targetHeight + 1;
    }

    return {'width': targetWidth, 'height': targetHeight};
  }

  /// Genera il filtro FFmpeg ottimizzato per upscaling video
  /// Usa algoritmi avanzati basati su video_upscaler per qualità superiore
  String buildOptimizedUpscaleFilter({
    required int originalWidth,
    required int originalHeight,
    required int targetWidth,
    required int targetHeight,
    String algorithm = 'lanczos', // 'lanczos', 'spline', 'bicubic', 'neighbor'
    bool useAdvancedFlags = true,
  }) {
    // Algoritmi di upscaling ottimizzati basati su video_upscaler
    String flags;
    
    switch (algorithm.toLowerCase()) {
      case 'spline':
        // Spline offre un buon compromesso qualità/velocità
        flags = useAdvancedFlags 
            ? 'spline+accurate_rnd+full_chroma_int+print_info'
            : 'spline';
        break;
      case 'bicubic':
        // Bicubic per qualità media-alta
        flags = useAdvancedFlags
            ? 'bicubic+accurate_rnd+full_chroma_int'
            : 'bicubic';
        break;
      case 'neighbor':
        // Nearest neighbor per velocità massima (qualità bassa)
        flags = 'neighbor';
        break;
      case 'lanczos':
      default:
        // Lanczos è il default - ottima qualità
        flags = useAdvancedFlags
            ? 'lanczos+accurate_rnd+full_chroma_int+print_info'
            : 'lanczos';
        break;
    }

    // Costruisci il filtro scale ottimizzato
    return 'scale=$targetWidth:$targetHeight:flags=$flags';
  }

  /// Genera il filtro FFmpeg per upscaling con algoritmo multiplo (2-pass)
  /// Tecnica avanzata per qualità superiore
  List<String> buildMultiPassUpscaleFilter({
    required int originalWidth,
    required int originalHeight,
    required int targetWidth,
    required int targetHeight,
  }) {
    // Se il fattore di scala è > 2x, usa upscaling in 2 passaggi
    final scaleFactor = targetWidth / originalWidth;
    
    if (scaleFactor > 2.0) {
      // Primo passaggio: scala a 2x
      final intermediateWidth = (originalWidth * 2.0).round();
      final intermediateHeight = (originalHeight * 2.0).round();
      final intermediateWidthEven = intermediateWidth.isEven ? intermediateWidth : intermediateWidth + 1;
      final intermediateHeightEven = intermediateHeight.isEven ? intermediateHeight : intermediateHeight + 1;
      
      final firstPass = buildOptimizedUpscaleFilter(
        originalWidth: originalWidth,
        originalHeight: originalHeight,
        targetWidth: intermediateWidthEven,
        targetHeight: intermediateHeightEven,
        algorithm: 'lanczos',
      );
      
      // Secondo passaggio: scala dal 2x al target
      final secondPass = buildOptimizedUpscaleFilter(
        originalWidth: intermediateWidthEven,
        originalHeight: intermediateHeightEven,
        targetWidth: targetWidth,
        targetHeight: targetHeight,
        algorithm: 'spline', // Usa spline per il secondo passaggio (più veloce)
      );
      
      return [firstPass, secondPass];
    } else {
      // Singolo passaggio per fattori <= 2x
      return [
        buildOptimizedUpscaleFilter(
          originalWidth: originalWidth,
          originalHeight: originalHeight,
          targetWidth: targetWidth,
          targetHeight: targetHeight,
          algorithm: 'lanczos',
        ),
      ];
    }
  }

  /// Verifica se l'upscaling è necessario e ottimale
  bool shouldUpscale({
    required int originalWidth,
    required int originalHeight,
    required int targetWidth,
    required int targetHeight,
  }) {
    // Non upscalare se le dimensioni target sono <= originali
    if (targetWidth <= originalWidth && targetHeight <= originalHeight) {
      return false;
    }

    // Non upscalare se il fattore è troppo alto (>4x può degradare la qualità)
    final widthFactor = targetWidth / originalWidth;
    final heightFactor = targetHeight / originalHeight;
    
    if (widthFactor > 4.0 || heightFactor > 4.0) {
      appLog('⚠️ [VideoUpscaler] Fattore di upscaling troppo alto (>4x), potrebbe degradare la qualità');
      return false;
    }

    return true;
  }
}

