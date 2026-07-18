enum MediaType {
  video,
  audio,
  image,
}

extension MediaTypeExtension on MediaType {
  String get name {
    switch (this) {
      case MediaType.video:
        return 'Video';
      case MediaType.audio:
        return 'Audio';
      case MediaType.image:
        return 'Image';
    }
  }

  String get icon {
    switch (this) {
      case MediaType.video:
        return '🎬';
      case MediaType.audio:
        return '🎵';
      case MediaType.image:
        return '🖼️';
    }
  }

  List<String> get supportedFormats {
    switch (this) {
      case MediaType.video:
        return ['mp4', 'avi', 'mkv', 'webm', 'mov', 'flv', 'wmv', 'mpeg', 'ts'];
      case MediaType.audio:
        return ['mp3', 'wav', 'aac', 'flac', 'ogg', 'm4a', 'wma', 'opus'];
      case MediaType.image:
        return ['jpg', 'jpeg', 'png', 'webp', 'bmp', 'tiff', 'heic'];
    }
  }

  List<String> get supportedAudioCodecs {
    switch (this) {
      case MediaType.video:
        return ['aac', 'mp3', 'flac', 'opus', 'vorbis', 'pcm'];
      case MediaType.audio:
        return ['aac', 'mp3', 'flac', 'opus', 'vorbis', 'pcm'];
      case MediaType.image:
        return [];
    }
  }

  List<String> get supportedVideoCodecs {
    switch (this) {
      case MediaType.video:
        return ['libx264', 'libx265', 'libvpx', 'libvpx-vp9', 'mpeg4', 'libaom-av1'];
      case MediaType.audio:
        return [];
      case MediaType.image:
        return [];
    }
  }

  String getDefaultExtension() {
    switch (this) {
      case MediaType.video:
        return 'mp4';
      case MediaType.audio:
        return 'mp3';
      case MediaType.image:
        return 'jpg';
    }
  }
}

class VideoCodecHelper {
  static String getVideoCodecName(String codec) {
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

  static String getVideoCodecDescription(String codec) {
    switch (codec) {
      case 'libx264':
        return 'Ottima compatibilità, buona compressione';
      case 'libx265':
        return 'Migliore compressione, compatibilità limitata';
      case 'libvpx':
        return 'Codec open source per Web';
      case 'libvpx-vp9':
        return 'Codec moderno per alta qualità';
      case 'mpeg4':
        return 'Compatibilità universale';
      case 'libaom-av1':
        return 'Codec next-gen, compressione avanzata';
      default:
        return 'Codec video';
    }
  }
}