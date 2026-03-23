import 'media_type.dart';
import 'video_filters.dart';
import 'audio_filters.dart';
import 'image_filters.dart';
import 'conversion_status.dart';

class ConversionTask {
  final String id;
  final String inputPath;
  final String outputPath;
  final MediaType mediaType;
  final String format;
  final int videoQuality;
  final int audioQuality;
  final int audioBitrate;
  final String audioCodec;
  // AGGIUNGI QUESTI CAMPI
  final String videoCodec;
  final int videoBitrate;
  final String videoBitrateMode;
  final VideoFilters videoFilters;
  final AudioFilters audioFilters;
  final ImageFilters imageFilters;
  final bool extractAudioFromVideo;
  ConversionStatus status;
  double progress;
  String? error;
  String timeRemaining;
  final DateTime createdAt;
  bool get canPause => status == ConversionStatus.processing;
  bool get canResume => status == ConversionStatus.paused;
  bool get canStop => status == ConversionStatus.processing || status == ConversionStatus.paused;

  ConversionTask({
    required this.inputPath,
    required this.outputPath,
    required this.mediaType,
    required this.format,
    this.videoQuality = 23,
    this.audioQuality = 128,
    this.audioBitrate = 192,
    this.audioCodec = 'aac',
    // AGGIUNGI QUESTI PARAMETRI
    this.videoCodec = 'libx264',
    this.videoBitrate = 4000,
    this.videoBitrateMode = 'crf',
    required this.videoFilters,
    required this.audioFilters,
    required this.imageFilters,
    this.extractAudioFromVideo = false,
  })  : id = DateTime.now().millisecondsSinceEpoch.toString(),
        status = ConversionStatus.pending,
        progress = 0.0,
        timeRemaining = 'In attesa',
        createdAt = DateTime.now();

  String get fileName => inputPath.split('/').last;
  String get outputFileName => outputPath.split('/').last;
  
  String get statusText {
    switch (status) {
      case ConversionStatus.pending:
        return 'In attesa';
      case ConversionStatus.processing:
        return 'Elaborazione';
      case ConversionStatus.paused:
        return 'In pausa';
      case ConversionStatus.completed:
        return 'Completato';
      case ConversionStatus.failed:
        return 'Fallito';
    }
  }

  String get mediaTypeIcon {
    switch (mediaType) {
      case MediaType.video:
        return '🎬';
      case MediaType.audio:
        return '🎵';
      case MediaType.image:
        return '🖼️';
    }
  }

  // NUOVO: Descrizione codec video
  String get videoCodecName {
    return _getVideoCodecName(videoCodec);
  }

  // NUOVO: Descrizione qualità video
  String get videoQualityDescription {
    if (videoBitrateMode == 'crf') {
      return 'CRF: $videoQuality';
    } else {
      return '${videoBitrate} kbps';
    }
  }

  // METODI STATICI PER CODEC VIDEO (invece di MediaType.getVideoCodecName)
  static String _getVideoCodecName(String codec) {
    switch (codec) {
      case 'libx264':
        return 'H.264 (MPEG-4 AVC)';
      case 'libx265':
        return 'H.265 (HEVC)';
      case 'libvpx':
        return 'VP8 (WebM)';
      case 'libvpx-vp9':
        return 'VP9 (WebM)';
      case 'mpeg4':
        return 'MPEG-4';
      case 'libaom-av1':
        return 'AV1';
      default:
        return codec;
    }
  }

  void pause() {
    if (status == ConversionStatus.processing) {
      status = ConversionStatus.paused;
    }
  }

  void resume() {
    if (status == ConversionStatus.paused) {
      status = ConversionStatus.processing;
    }
  }

  void stop() {
    if (status == ConversionStatus.processing || status == ConversionStatus.paused) {
      status = ConversionStatus.failed;
      error = 'Conversione interrotta dall\'utente';
      timeRemaining = 'Interrotto';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'inputPath': inputPath,
      'outputPath': outputPath,
      'mediaType': mediaType.name,
      'format': format,
      'videoQuality': videoQuality,
      'audioQuality': audioQuality,
      'audioBitrate': audioBitrate,
      'audioCodec': audioCodec,
      // AGGIUNGI QUESTI CAMPI
      'videoCodec': videoCodec,
      'videoBitrate': videoBitrate,
      'videoBitrateMode': videoBitrateMode,
      'videoFilters': videoFilters.toMap(),
      'audioFilters': audioFilters.toMap(),
      'imageFilters': imageFilters.toMap(),
      'status': status.toString(),
      'progress': progress,
      'error': error,
      'timeRemaining': timeRemaining,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static ConversionTask fromMap(Map<String, dynamic> map) {
    final task = ConversionTask(
      inputPath: map['inputPath'],
      outputPath: map['outputPath'],
      mediaType: MediaType.values.firstWhere(
        (e) => e.name == map['mediaType'],
        orElse: () => MediaType.video,
      ),
      format: map['format'],
      videoQuality: map['videoQuality'] ?? 23,
      audioQuality: map['audioQuality'] ?? 128,
      audioBitrate: map['audioBitrate'] ?? 192,
      audioCodec: map['audioCodec'] ?? 'aac',
      // AGGIUNGI QUESTI CAMPI
      videoCodec: map['videoCodec'] ?? 'libx264',
      videoBitrate: map['videoBitrate'] ?? 4000,
      videoBitrateMode: map['videoBitrateMode'] ?? 'crf',
      videoFilters: VideoFilters.fromMap(Map<String, dynamic>.from(map['videoFilters'] ?? {})),
      audioFilters: AudioFilters.fromMap(Map<String, dynamic>.from(map['audioFilters'] ?? {})),
      imageFilters: ImageFilters.fromMap(Map<String, dynamic>.from(map['imageFilters'] ?? {})),
    );
    
    task.status = ConversionStatus.values.firstWhere(
      (e) => e.toString() == map['status'],
      orElse: () => ConversionStatus.pending,
    );
    task.progress = map['progress'] ?? 0.0;
    task.error = map['error'];
    task.timeRemaining = map['timeRemaining'] ?? 'In attesa';
    
    return task;
  }
}