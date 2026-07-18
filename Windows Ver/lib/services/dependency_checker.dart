import 'dart:io';
import 'package:video_converter_pro/services/ffmpeg_installer_service.dart';
import 'package:video_converter_pro/utils/app_log.dart';

class DependencyChecker {
  static String _combinedEncodersOutput(ProcessResult r) {
    return '${r.stdout}${r.stderr}';
  }

  static Future<Map<String, dynamic>> checkDependencies() async {
    try {
      final versionCheck = await FFmpegInstallerService.checkFFmpegVersion();
      
      final needsMandatoryUpdate = versionCheck['needsUpdate'] == true;
      final meetsMinimum = versionCheck['meetsMinimum'] == true ||
          (versionCheck['installed'] == true && needsMandatoryUpdate == false);

      if (!versionCheck['installed'] || !meetsMinimum) {
        return {
          'available': false,
          'error': versionCheck['error'] ?? 'FFmpeg non trovato o versione non supportata (minima richiesta: 5.0.0)',
          'os': _getCurrentOS(),
          'needsUpdate': needsMandatoryUpdate,
          'currentVersion': versionCheck['version'],
          'requiredVersion': '5.0.0',
          'recommendedVersion': '8.0.1',
          'isRecommendedVersion': versionCheck['isRecommendedVersion'] == true,
          'installSource': versionCheck['installSource'],
          'installDetail': versionCheck['installDetail'],
          'binaryPath': versionCheck['binaryPath'],
        };
      }

      final encodersResult = await Process.run('ffmpeg', ['-hide_banner', '-encoders']);
      final encodersOutput = _combinedEncodersOutput(encodersResult);

      return {
        'available': true,
        'version': versionCheck['version'],
        'gpu_nvidia': encodersOutput.contains('h264_nvenc'),
        'gpu_intel': encodersOutput.contains('h264_qsv'),
        'gpu_amd': encodersOutput.contains('h264_amf'),
        'cpu': encodersOutput.contains('libx264'),
        'os': _getCurrentOS(),
        'needsUpdate': false,
        'isRecommendedVersion': versionCheck['isRecommendedVersion'] == true,
        'installSource': versionCheck['installSource'],
        'installDetail': versionCheck['installDetail'],
        'binaryPath': versionCheck['binaryPath'],
      };
    } catch (e) {
      appLog('Errore nel controllo dipendenze: $e');
      return {
        'available': false,
        'error': 'Impossibile eseguire FFmpeg: $e',
        'os': _getCurrentOS(),
        'needsUpdate': true,
      };
    }
  }

  static String _getCurrentOS() {
    if (Platform.isLinux) {
      try {
        final result = Process.runSync('cat', ['/etc/os-release']);
        final output = result.stdout.toString();
        if (output.contains('ubuntu') || output.contains('Ubuntu')) {
          return 'ubuntu';
        } else if (output.contains('fedora') || output.contains('Fedora')) {
          return 'fedora';
        } else if (output.contains('arch') || output.contains('Arch')) {
          return 'arch';
        } else if (output.contains('debian') || output.contains('Debian')) {
          return 'debian';
        }
      } catch (e) {
        appLog('Impossibile rilevare la distribuzione Linux: $e');
      }
      return 'linux';
    } else if (Platform.isWindows) {
      return 'windows';
    } else if (Platform.isMacOS) {
      return 'macos';
    }
    return 'unknown';
  }

  static String getInstallGuide(String os) {
    switch (os.toLowerCase()) {
      case 'fedora':
        return 'sudo dnf install ffmpeg ffmpeg-devel';
      case 'ubuntu':
      case 'debian':
        return 'sudo apt update && sudo apt install ffmpeg';
      case 'arch':
        return 'sudo pacman -S ffmpeg';
      case 'linux':
        return 'sudo apt update && sudo apt install ffmpeg';
      case 'windows':
        return 'winget install ffmpeg';
      case 'macos':
        return 'brew install ffmpeg';
      default:
        return 'Visita https://ffmpeg.org/download.html per le istruzioni di installazione';
    }
  }

  static String getOSName(String os) {
    switch (os.toLowerCase()) {
      case 'fedora':
        return 'Fedora';
      case 'ubuntu':
        return 'Ubuntu';
      case 'debian':
        return 'Debian';
      case 'arch':
        return 'Arch Linux';
      case 'linux':
        return 'Linux';
      case 'windows':
        return 'Windows';
      case 'macos':
        return 'macOS';
      default:
        return os;
    }
  }
}