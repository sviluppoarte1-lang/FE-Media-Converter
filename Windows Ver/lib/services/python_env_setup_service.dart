import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:video_converter_pro/utils/platform_paths.dart';

class PythonEnvSetupService {
  static const String prefsKeyCompleted = 'python_env_setup_completed';
  static const String prefsKeySkipped = 'python_env_setup_skipped';

  static String? getBundledAppRoot() {
    return PlatformPaths.getBundledAppRoot();
  }

  static String? getPythonScriptsDirectory() {
    return PlatformPaths.getPythonScriptsDirectory();
  }

  static bool isVenvReady(String scriptsDir) {
    return PlatformPaths.isVenvReady(scriptsDir);
  }

  static bool shouldOfferSetup() {
    if (!Platform.isLinux && !Platform.isWindows) return false;
    final dir = getPythonScriptsDirectory();
    if (dir == null) return false;
    final setup = File(path.join(dir, PlatformPaths.setupScriptName));
    if (!setup.existsSync()) return false;
    return !isVenvReady(dir);
  }

  static Future<int> runSetup({
    required void Function(String line) onLine,
  }) async {
    final dir = getPythonScriptsDirectory();
    if (dir == null) return -1;

    final Process process;
    if (Platform.isWindows) {
      process = await Process.start(
        'cmd.exe',
        ['/c', PlatformPaths.setupScriptName],
        workingDirectory: dir,
        environment: Map<String, String>.from(Platform.environment),
        runInShell: true,
      );
    } else {
      process = await Process.start(
        '/bin/bash',
        ['./' + PlatformPaths.setupScriptName],
        workingDirectory: dir,
        environment: Map<String, String>.from(Platform.environment),
        runInShell: false,
      );
    }

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
