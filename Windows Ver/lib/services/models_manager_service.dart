import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as path;
import 'package:video_converter_pro/l10n/app_localizations.dart';
import 'package:video_converter_pro/utils/platform_paths.dart';

class ModelsManagerService {
  static const String prefsKeyDRUNetSkipped = 'drunet_download_skipped';

  static const List<String> drunetModelDownloadUrls = [
    'https://github.com/cszn/KAIR/releases/download/v1.0/drunet_color.pth',
    'https://huggingface.co/deepinv/drunet/resolve/main/drunet_color.pth',
  ];

  static const int _expectedDrunetBytes = 125 * 1024 * 1024;

  static String _progressText(String key, {String extra = ''}) {
    final lang = Platform.localeName.toLowerCase().split('_').first;
    final l10n = lookupAppLocalizations(Locale(lang));
    switch (key) {
      case 'connecting':
        return '${l10n.downloadConnecting} $extra';
      case 'downloading':
        return '${l10n.drunetDownloadingLabel}... $extra';
      case 'retry':
        return '${l10n.retryingWithMirror}... $extra';
      case 'python_script':
        return l10n.downloadViaPythonScript;
      case 'completed':
        return l10n.completed;
      default:
        return key;
    }
  }

  static String _getAppDirectory() {
    try {
      final executable = Platform.resolvedExecutable;
      final executableDir = path.dirname(executable);

      if (Platform.isLinux) {
        if (executableDir.contains('/usr/share/video-converter-pro')) {
          return '/usr/share/video-converter-pro';
        }
      } else if (Platform.isWindows) {
        if (executableDir.contains('video-converter-pro')) {
          return executableDir;
        }
      }

      return path.dirname(path.dirname(executableDir));
    } catch (e) {
      return Directory.current.path;
    }
  }

  static String _getScriptsDirectory() {
    final appDir = _getAppDirectory();
    final scriptsPath = path.join(appDir, 'scripts', 'python');

    if (Directory(scriptsPath).existsSync()) {
      return scriptsPath;
    }

    return 'scripts/python';
  }

  static String _getDefaultModelsDir() {
    return PlatformPaths.getDefaultModelsDir();
  }

  static String get _venvPath => path.join(_getScriptsDirectory(), 'venv');
  static String get _defaultModelsDir => _getDefaultModelsDir();

  static String get _downloadDrunetScriptPath =>
      path.join(_getScriptsDirectory(), 'download_drunet_model.py');

  static Future<String> getPythonExecutable() async {
    final venvPython = File(PlatformPaths.getVenvPythonPath(_getScriptsDirectory()));
    if (await venvPython.exists()) {
      return venvPython.absolute.path;
    }
    return PlatformPaths.pythonFallback;
  }

  static String getModelsDirectory(String? customPath) {
    if (customPath != null && customPath.isNotEmpty) {
      return customPath;
    }
    return _defaultModelsDir;
  }

  static Future<bool> checkModelExists(String modelPath) async {
    final file = File(modelPath);
    if (!await file.exists()) {
      return false;
    }
    final size = await file.length();
    return size > 1024 * 1024;
  }

  static Future<Map<String, dynamic>> getModelsStatus({
    String? modelsDirectory,
  }) async {
    final modelsDir = getModelsDirectory(modelsDirectory);

    final drunetModelPath = path.join(modelsDir, 'drunet', 'drunet_model.pth');
    final drunetExists = await checkModelExists(drunetModelPath);
    final drunetSize = drunetExists ? await File(drunetModelPath).length() : 0;

    return {
      'drunet': {
        'exists': drunetExists,
        'path': drunetModelPath,
        'size_mb': (drunetSize / (1024 * 1024)).toStringAsFixed(2),
        'filename': 'drunet_model.pth',
      },
      'models_directory': modelsDir,
    };
  }

  static Future<Map<String, dynamic>> getModelsSize({
    String? modelsDirectory,
  }) async {
    final status = await getModelsStatus(modelsDirectory: modelsDirectory);
    final drunet = status['drunet'] as Map<String, dynamic>;
    final exists = drunet['exists'] == true;
    final mb = double.tryParse(drunet['size_mb'] ?? '0') ?? 0;

    return {
      'total_size_mb': mb.toStringAsFixed(2),
      'installed_count': exists ? 1 : 0,
      'total_count': 1,
      'missing_count': exists ? 0 : 1,
    };
  }

  static Future<bool> isDRUNetModelReady({String? modelsDirectory}) async {
    final st = await getModelsStatus(modelsDirectory: modelsDirectory);
    final drunet = st['drunet'] as Map<String, dynamic>?;
    return drunet != null && drunet['exists'] == true;
  }

  static Future<Map<String, dynamic>> downloadDRUNetModel({
    String? modelsDirectory,
    void Function(double progress, String message)? onProgress,
    bool force = false,
  }) async {
    final modelsDir = getModelsDirectory(modelsDirectory);
    final drunetDir = path.join(modelsDir, 'drunet');
    final outPath = path.join(drunetDir, 'drunet_model.pth');

    if (!force && await checkModelExists(outPath)) {
      return {
        'success': true,
        'path': outPath,
        'skipped': true,
        'message': 'Model already present',
      };
    }

    await Directory(drunetDir).create(recursive: true);
    if (force && await File(outPath).exists()) {
      try {
        await File(outPath).delete();
      } catch (_) {}
    }

    for (var i = 0; i < drunetModelDownloadUrls.length; i++) {
      final url = drunetModelDownloadUrls[i];
      onProgress?.call(
        0.0,
        _progressText('connecting', extra: '(${i + 1}/${drunetModelDownloadUrls.length})...'),
      );
      HttpClient? client;
      try {
        final uri = Uri.parse(url);
        client = HttpClient();
        client.userAgent =
            'VideoConverterPro/2.0 (${Platform.operatingSystem}; Flutter DRUNet downloader)';
        final request = await client.getUrl(uri);
        final response = await request.close();
        if (response.statusCode != HttpStatus.ok) {
          continue;
        }

        final total = response.contentLength;
        final tmpPath = '$outPath.part';
        final sink = File(tmpPath).openWrite();
        var received = 0;
        await for (final chunk in response) {
          sink.add(chunk);
          received += chunk.length;
          double p;
          if (total > 0) {
            p = (received / total).clamp(0.0, 1.0);
          } else {
            p = (received / _expectedDrunetBytes).clamp(0.0, 0.99);
          }
          onProgress?.call(
            p,
            _progressText(
              'downloading',
              extra: '${(received / (1024 * 1024)).toStringAsFixed(1)} MB',
            ),
          );
        }
        await sink.close();

        final len = await File(tmpPath).length();
        if (len < 1024 * 1024) {
          await File(tmpPath).delete();
          continue;
        }
        await File(tmpPath).rename(outPath);
        onProgress?.call(1.0, _progressText('completed'));
        return {'success': true, 'path': outPath, 'bytes': len};
      } catch (e) {
        onProgress?.call(0.0, _progressText('retry', extra: '($e)'));
        continue;
      } finally {
        client?.close(force: true);
      }
    }

    final script = File(_downloadDrunetScriptPath);
    if (await script.exists()) {
      onProgress?.call(0.0, _progressText('python_script'));
      try {
        if (!Platform.isWindows) {
          await Process.run('chmod', ['+x', _downloadDrunetScriptPath]);
        }
        final python = await getPythonExecutable();
        final pr = await Process.run(
          python,
          [_downloadDrunetScriptPath, '--models-dir', modelsDir],
        );
        if (pr.exitCode == 0) {
          final out = pr.stdout.toString().trim();
          if (out.isNotEmpty) {
            try {
              final decoded = jsonDecode(out) as Map<String, dynamic>;
              if (decoded['success'] == true) {
                onProgress?.call(1.0, _progressText('completed'));
                return decoded;
              }
            } catch (_) {}
          }
        }
      } catch (_) {}
    }

    return {
      'success': false,
      'error':
          'Impossibile scaricare il modello DRUNet. Verifica la connessione e riprova.',
    };
  }
}
