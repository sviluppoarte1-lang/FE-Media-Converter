import 'dart:io';
import 'package:path/path.dart' as path;

class PlatformPaths {
  static String get scriptsDirName => 'scripts';
  static String get pythonScriptsDirName => 'python';

  static String get venvDirName => 'venv';
  static String get venvBinDir => Platform.isWindows ? 'Scripts' : 'bin';
  static String get pythonExeName => Platform.isWindows ? 'python.exe' : 'python3';
  static String get pythonFallback => Platform.isWindows ? 'python' : 'python3';

  static String get setupScriptName =>
      Platform.isWindows ? 'setup_python_env.bat' : 'setup_python_env.sh';

  static String? getBundledAppRoot() {
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

      var dir = executableDir;
      for (var i = 0; i < 12; i++) {
        final scriptsPath = path.join(dir, scriptsDirName, pythonScriptsDirName);
        if (Directory(scriptsPath).existsSync()) return dir;
        final parent = path.dirname(dir);
        if (parent == dir) break;
        dir = parent;
      }
      if (Directory(path.join(Directory.current.path, scriptsDirName, pythonScriptsDirName))
          .existsSync()) {
        return Directory.current.path;
      }
    } catch (_) {}
    return null;
  }

  static String? getPythonScriptsDirectory() {
    final root = getBundledAppRoot();
    if (root == null) return null;
    final p = path.join(root, scriptsDirName, pythonScriptsDirName);
    return Directory(p).existsSync() ? p : null;
  }

  static bool isVenvReady(String scriptsDir) {
    final py = File(path.join(scriptsDir, venvDirName, venvBinDir, pythonExeName));
    return py.existsSync();
  }

  static String getVenvPythonPath(String scriptsDir) {
    return path.join(scriptsDir, venvDirName, venvBinDir, pythonExeName);
  }

  static String getDefaultModelsDir() {
    if (Platform.isWindows) {
      final appData = Platform.environment['APPDATA'] ?? '';
      if (appData.isNotEmpty) {
        return path.join(appData, 'video-converter-pro', 'models');
      }
    }
    final homeDir =
        Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'] ?? '';
    if (homeDir.isNotEmpty) {
      return path.join(homeDir, '.video-converter-pro', 'models');
    }
    return path.join(Directory.current.path, scriptsDirName, pythonScriptsDirName, 'models');
  }
}
