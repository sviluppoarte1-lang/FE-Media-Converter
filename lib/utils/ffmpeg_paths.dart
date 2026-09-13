import 'dart:io';
import 'package:path/path.dart' as p;

/// Resolves paths to bundled FFmpeg binaries.
///
/// At build time, ffmpeg and ffprobe are copied next to the executable
/// by CMakeLists.txt. This service finds them at runtime.
class FFmpegPaths {
  static String? _cachedFfmpegPath;
  static String? _cachedFfprobePath;

  /// Returns the absolute path to the bundled ffmpeg binary.
  static String get ffmpegPath {
    if (_cachedFfmpegPath != null) return _cachedFfmpegPath!;
    _cachedFfmpegPath = _resolveBinary('ffmpeg');
    return _cachedFfmpegPath!;
  }

  /// Returns the absolute path to the bundled ffprobe binary.
  static String get ffprobePath {
    if (_cachedFfprobePath != null) return _cachedFfprobePath!;
    _cachedFfprobePath = _resolveBinary('ffprobe');
    return _cachedFfprobePath!;
  }

  static String _resolveBinary(String name) {
    // 1. Same directory as the executable (standard bundle layout)
    final exeDir = p.dirname(Platform.resolvedExecutable);
    final bundleCandidate = p.join(exeDir, name);
    if (File(bundleCandidate).existsSync()) {
      return bundleCandidate;
    }

    // 2.../bundled/ relative to executable (development layout)
    final devCandidate = p.join(exeDir, '..', 'bundled', name);
    if (File(devCandidate).existsSync()) {
      return p.canonicalize(devCandidate);
    }

    // 3. Project root linux/bundled/ (running from source)
    final sourceCandidate = p.join(
      Directory.current.path, 'linux', 'bundled', name,
    );
    if (File(sourceCandidate).existsSync()) {
      return sourceCandidate;
    }

    // 4. Fallback: bare command name (system PATH)
    return name;
  }
}
