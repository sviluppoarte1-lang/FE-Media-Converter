import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

/// Detects bundled `scripts/python` (deb install or dev tree) and runs [setup_python_env.sh].
class PythonEnvSetupService {
  static const String prefsKeyCompleted = 'python_env_setup_completed';
  static const String prefsKeySkipped = 'python_env_setup_skipped';

  /// App root: `/usr/share/video-converter-pro` when installed from .deb, else walk up from executable.
  static String? getBundledAppRoot() {
    try {
      final executable = Platform.resolvedExecutable;
      final executableDir = path.dirname(executable);
      if (executableDir.contains('/usr/share/video-converter-pro')) {
        return '/usr/share/video-converter-pro';
      }
      var dir = executableDir;
      for (var i = 0; i < 12; i++) {
        final scriptsPath = path.join(dir, 'scripts', 'python');
        if (Directory(scriptsPath).existsSync()) return dir;
        final parent = path.dirname(dir);
        if (parent == dir) break;
        dir = parent;
      }
      if (Directory(path.join(Directory.current.path, 'scripts', 'python')).existsSync()) {
        return Directory.current.path;
      }
    } catch (_) {}
    return null;
  }

  static String? getPythonScriptsDirectory() {
    final root = getBundledAppRoot();
    if (root == null) return null;
    final p = path.join(root, 'scripts', 'python');
    return Directory(p).existsSync() ? p : null;
  }

  static bool isVenvReady(String scriptsDir) {
    final py = File(path.join(scriptsDir, 'venv', 'bin', 'python3'));
    return py.existsSync();
  }

  /// Linux + bundled scripts + no venv → show first-run dialog (unless skipped/done).
  static bool shouldOfferSetup() {
    if (!Platform.isLinux) return false;
    final dir = getPythonScriptsDirectory();
    if (dir == null) return false;
    final setup = File(path.join(dir, 'setup_python_env.sh'));
    if (!setup.existsSync()) return false;
    return !isVenvReady(dir);
  }

  /// Runs [setup_python_env.sh]; streams combined stdout/stderr as lines.
  static Future<int> runSetup({
    required void Function(String line) onLine,
  }) async {
    final dir = getPythonScriptsDirectory();
    if (dir == null) return -1;

    final process = await Process.start(
      '/bin/bash',
      ['./setup_python_env.sh'],
      workingDirectory: dir,
      environment: Map<String, String>.from(Platform.environment),
      runInShell: false,
    );

    void addStream(Stream<List<int>> stream) {
      stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        if (line.isNotEmpty) onLine(line);
      });
    }

    addStream(process.stdout);
    addStream(process.stderr);

    return process.exitCode;
  }
}
