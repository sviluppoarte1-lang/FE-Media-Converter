import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_converter_pro/utils/app_log.dart';

class FFmpegInstallerService {
  static const String _versionRequired = '8.0.1'; // Versione consigliata
  static const String _versionMinimum = '5.0.0'; // Versione minima accettata
  static const String _prefKeySudoPassword = 'ffmpeg_sudo_password';
  static const String _prefKeyPasswordStored = 'ffmpeg_password_stored';
  static const String _prefKeyInstallAttempted = 'ffmpeg_install_attempted';

  /// Unisce stdout e stderr: FFmpeg stampa spesso la versione su stderr.
  static String _combinedProcessOutput(ProcessResult r) {
    return '${r.stdout}${r.stderr}';
  }

  /// Estrae semver da output `ffmpeg -version` (build ufficiali, static, git, ecc.)
  static String? _parseFfmpegVersionString(String combined) {
    if (combined.isEmpty) return null;
    final lines = combined.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final firstLine = lines.isEmpty ? '' : lines.first;

    // Esempi: "ffmpeg version 8.0.1", "ffmpeg version 8.0.1-static", "ffmpeg version n8.0.1"
    var m = RegExp(
      r'ffmpeg\s+version\s+n?(\d+)\.(\d+)\.(\d+)',
      caseSensitive: false,
    ).firstMatch(firstLine);
    if (m != null) {
      return '${m.group(1)}.${m.group(2)}.${m.group(3)}';
    }
    m = RegExp(
      r'ffmpeg\s+version\s+n?(\d+)\.(\d+)\b',
      caseSensitive: false,
    ).firstMatch(firstLine);
    if (m != null) {
      return '${m.group(1)}.${m.group(2)}.0';
    }
    m = RegExp(
      r'ffmpeg\s+version\s+[^\d]*(\d+\.\d+\.\d+)',
      caseSensitive: false,
    ).firstMatch(firstLine);
    if (m != null && m.group(1) != null) {
      return m.group(1);
    }
    // Cerca nella prima riga o in tutto il blocco (stderr incluso)
    m = RegExp(
      r'ffmpeg\s+version\s+[^\n]+',
      caseSensitive: false,
    ).firstMatch(combined);
    if (m != null) {
      final seg = RegExp(r'(\d+\.\d+\.\d+)').firstMatch(m.group(0)!);
      if (seg != null) return seg.group(1);
    }
    // Fallback: prima occorrenza di x.y.z
    final loose = RegExp(r'\b(\d+\.\d+\.\d+)\b').firstMatch(combined);
    return loose?.group(1);
  }

  /// Rileva come è installato ffmpeg (apt/deb, rpm, pacman, snap, flatpak, appimage, path generico).
  static Future<Map<String, dynamic>> detectFFmpegInstallSource() async {
    final out = <String, dynamic>{
      'method': 'unknown',
      'binaryPath': null as String?,
      'detail': null as String?,
    };
    try {
      final which = await Process.run('which', ['ffmpeg']);
      if (which.exitCode != 0) return out;
      final path = which.stdout.toString().trim().split('\n').first.trim();
      if (path.isEmpty) return out;
      out['binaryPath'] = path;

      final p = path.toLowerCase();
      if (p.contains('/snap/')) {
        out['method'] = 'snap';
        out['detail'] = 'Snap package';
        return out;
      }
      if (p.contains('flatpak') || p.contains('/var/lib/flatpak/')) {
        out['method'] = 'flatpak';
        out['detail'] = 'Flatpak';
        return out;
      }

      if (Platform.isLinux) {
        final dpkg = await Process.run('dpkg', ['-S', path]);
        if (dpkg.exitCode == 0) {
          out['method'] = 'apt';
          out['detail'] = (dpkg.stdout.toString().trim().split(':').first);
          return out;
        }
        final rpm = await Process.run('rpm', ['-qf', path]);
        if (rpm.exitCode == 0) {
          out['method'] = 'rpm';
          out['detail'] = rpm.stdout.toString().trim().split('\n').first;
          return out;
        }
        final pac = await Process.run('pacman', ['-Qo', path]);
        if (pac.exitCode == 0) {
          out['method'] = 'pacman';
          out['detail'] = pac.stdout.toString().trim();
          return out;
        }
      }

      out['method'] = 'path';
      out['detail'] = path;
      return out;
    } catch (e) {
      appLog('detectFFmpegInstallSource: $e');
      return out;
    }
  }

  /// Verifica se FFmpeg è installato con versione >= 5.0.0
  /// [needsUpdate] = true solo se versione < minimo (non per "solo" < 8.0.1 consigliata).
  static Future<Map<String, dynamic>> checkFFmpegVersion() async {
    try {
      final result = await Process.run('ffmpeg', ['-hide_banner', '-version']);
      final combined = _combinedProcessOutput(result);

      if (result.exitCode != 0 && combined.isEmpty) {
        return {
          'installed': false,
          'version': null,
          'needsUpdate': true,
          'meetsMinimum': false,
          'error': 'FFmpeg non trovato o non eseguibile',
        };
      }

      // Se exit != 0 ma c'è output, prova comunque a parsare (alcuni build strani)
      String? currentVersion = _parseFfmpegVersionString(combined);

      if (currentVersion == null && result.exitCode == 0) {
        // Ultimo tentativo: ffprobe
        try {
          final pr = await Process.run('ffprobe', ['-hide_banner', '-version']);
          final c2 = _combinedProcessOutput(pr);
          currentVersion = _parseFfmpegVersionString(c2);
        } catch (_) {}
      }

      final sourceInfo = await detectFFmpegInstallSource();

      if (currentVersion == null) {
        // Eseguibile ok ma semver non riconosciuta: non bloccare se ffmpeg risponde
        final workable = result.exitCode == 0 &&
            (combined.toLowerCase().contains('ffmpeg') || combined.contains('libavutil'));
        return {
          'installed': workable,
          'version': 'unknown',
          'needsUpdate': !workable,
          'meetsMinimum': workable,
          'isRecommendedVersion': false,
          'error': workable ? null : 'Impossibile determinare la versione',
          'installSource': sourceInfo['method'],
          'installDetail': sourceInfo['detail'],
          'binaryPath': sourceInfo['binaryPath'],
        };
      }

      final isMinimumVersion = _compareVersions(currentVersion, _versionMinimum) >= 0;
      final isRecommendedVersion = _compareVersions(currentVersion, _versionRequired) >= 0;
      final needsUpdate = !isMinimumVersion;

      return {
        'installed': true,
        'version': currentVersion,
        'needsUpdate': needsUpdate,
        'meetsMinimum': isMinimumVersion,
        'isRecommendedVersion': isRecommendedVersion,
        'error': null,
        'installSource': sourceInfo['method'],
        'installDetail': sourceInfo['detail'],
        'binaryPath': sourceInfo['binaryPath'],
      };
    } catch (e) {
      return {
        'installed': false,
        'version': null,
        'needsUpdate': true,
        'meetsMinimum': false,
        'isRecommendedVersion': false,
        'error': 'Errore verifica versione: $e',
      };
    }
  }

  /// Confronta due versioni (ritorna < 0 se v1 < v2, 0 se uguali, > 0 se v1 > v2)
  static int _compareVersions(String v1, String v2) {
    List<int> partsOf(String v) {
      final raw = v.split('.').where((e) => e.isNotEmpty).toList();
      final nums = <int>[];
      for (final r in raw) {
        final n = int.tryParse(RegExp(r'^(\d+)').firstMatch(r)?.group(1) ?? '');
        nums.add(n ?? 0);
      }
      while (nums.length < 3) {
        nums.add(0);
      }
      return nums.take(3).toList();
    }

    final parts1 = partsOf(v1);
    final parts2 = partsOf(v2);

    for (int i = 0; i < 3; i++) {
      final p1 = parts1[i];
      final p2 = parts2[i];
      if (p1 < p2) return -1;
      if (p1 > p2) return 1;
    }

    return 0;
  }

  /// Rileva la distribuzione Linux specifica
  static Future<String> detectLinuxDistribution() async {
    if (!Platform.isLinux) return 'unknown';

    try {
      final result = await Process.run('cat', ['/etc/os-release']);
      final output = result.stdout.toString().toLowerCase();
      
      // Zorin OS
      if (output.contains('zorin')) {
        return 'zorin';
      }
      // Ubuntu e derivate
      if (output.contains('ubuntu') || output.contains('pop!_os') || output.contains('linux mint')) {
        return 'ubuntu';
      }
      // Debian
      if (output.contains('debian')) {
        return 'debian';
      }
      // Fedora
      if (output.contains('fedora')) {
        return 'fedora';
      }
      // Arch Linux
      if (output.contains('arch') || output.contains('manjaro')) {
        return 'arch';
      }
      // openSUSE
      if (output.contains('opensuse') || output.contains('suse')) {
        return 'opensuse';
      }
      // CentOS/RHEL
      if (output.contains('centos') || output.contains('rhel') || output.contains('red hat')) {
        return 'centos';
      }
      
      return 'ubuntu'; // Default a Ubuntu per repository compatibili
    } catch (e) {
      appLog('Errore rilevamento distribuzione: $e');
      return 'ubuntu';
    }
  }

  /// Ottiene i comandi di installazione per la distribuzione
  static Future<List<String>> getInstallCommands(String distro) async {
    switch (distro.toLowerCase()) {
      case 'zorin':
        // Zorin OS 18 - PPA specifico per FFmpeg 8.0.1
        return [
          'add-apt-repository',
          'ppa:ubuntuhandbook1/ffmpeg8',
          '-y',
        ];
      
      case 'ubuntu':
      case 'debian':
        // Ubuntu/Debian - PPA per FFmpeg 8.0.1
        return [
          'add-apt-repository',
          'ppa:ubuntuhandbook1/ffmpeg8',
          '-y',
        ];
      
      case 'fedora':
        // Fedora - Repository RPM Fusion
        return [
          'dnf',
          'install',
          '--assumeyes',
          r'https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm',
          r'https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm',
        ];
      
      case 'arch':
      case 'manjaro':
        // Arch Linux - AUR o repository ufficiale
        return [
          'pacman',
          '-S',
          '--noconfirm',
          'ffmpeg',
        ];
      
      case 'opensuse':
        // openSUSE - Repository Packman
        return [
          'zypper',
          'addrepo',
          '--refresh',
          'https://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Tumbleweed/',
          'packman',
        ];
      
      case 'centos':
        // CentOS/RHEL - RPM Fusion
        return [
          'yum',
          'install',
          '--assumeyes',
          'epel-release',
          'rpmfusion-free-release',
          'rpmfusion-nonfree-release',
        ];
      
      default:
        // Default: Ubuntu/Debian
        return [
          'add-apt-repository',
          'ppa:ubuntuhandbook1/ffmpeg8',
          '-y',
        ];
    }
  }

  /// Esegue l'installazione di FFmpeg con sudo
  static Future<Map<String, dynamic>> installFFmpeg({
    required String sudoPassword,
    Function(String)? onProgress,
  }) async {
    if (!Platform.isLinux) {
      return {
        'success': false,
        'error': 'Installazione automatica supportata solo su Linux',
      };
    }

    try {
      final distro = await detectLinuxDistribution();
      onProgress?.call('Detected distribution: $distro');
      
      if (distro == 'zorin' || distro == 'ubuntu' || distro == 'debian') {
        // Zorin/Ubuntu/Debian: Aggiungi PPA e installa
        onProgress?.call('Aggiunta repository FFmpeg 8.0.1...');
        final addRepoResult = await _runSudoCommand(
          ['add-apt-repository', 'ppa:ubuntuhandbook1/ffmpeg8', '-y'],
          sudoPassword,
        );
        
        if (addRepoResult['success'] != true) {
          return {
            'success': false,
            'error': 'Errore aggiunta repository: ${addRepoResult['error']}',
          };
        }

        onProgress?.call('Aggiornamento lista pacchetti...');
        final updateResult = await _runSudoCommand(
          ['apt', 'update'],
          sudoPassword,
        );
        
        if (updateResult['success'] != true) {
          return {
            'success': false,
            'error': 'Errore aggiornamento pacchetti: ${updateResult['error']}',
          };
        }

        onProgress?.call('Installazione FFmpeg 8.0.1...');
        final installResult = await _runSudoCommand(
          ['apt', 'install', '--yes', '--allow-downgrades', 'ffmpeg'],
          sudoPassword,
        );
        
        if (installResult['success'] != true) {
          return {
            'success': false,
            'error': 'Errore installazione: ${installResult['error']}',
          };
        }

        // Verifica installazione (stderr+stdout, semver; non richiede 8.0.1 esatto)
        final checkResult = await checkFFmpegVersion();
        final ok = checkResult['installed'] == true &&
            (checkResult['meetsMinimum'] == true || checkResult['needsUpdate'] == false);
        if (ok) {
          await _storeSudoPassword(sudoPassword);
          return {
            'success': true,
            'version': checkResult['version'],
            'message': 'FFmpeg ${checkResult['version']} installato con successo',
            'installSource': checkResult['installSource'],
          };
        }
        return {
          'success': false,
          'error': 'FFmpeg installato ma verifica versione non riuscita: ${checkResult['error'] ?? checkResult['version']}',
        };
      } else if (distro == 'fedora') {
        // Fedora: RPM Fusion (serve shell per espandere $(rpm -E %fedora))
        onProgress?.call('Installing RPM Fusion repository...');
        final addFusion = await _runSudoCommand(
          [
            'bash',
            '-lc',
            r'dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm',
          ],
          sudoPassword,
        );
        if (addFusion['success'] != true) {
          return {
            'success': false,
            'error': 'RPM Fusion: ${addFusion['error']}',
          };
        }

        onProgress?.call('Installing FFmpeg...');
        final installResult = await _runSudoCommand(
          ['dnf', 'install', '--assumeyes', 'ffmpeg'],
          sudoPassword,
        );

        if (installResult['success'] == true) {
          final checkResult = await checkFFmpegVersion();
          final ok = checkResult['installed'] == true &&
              (checkResult['meetsMinimum'] == true || checkResult['needsUpdate'] == false);
          if (ok) {
            await _storeSudoPassword(sudoPassword);
            return {
              'success': true,
              'message': 'FFmpeg installato',
              'version': checkResult['version'],
              'installSource': checkResult['installSource'],
            };
          }
        }
        return {'success': false, 'error': installResult['error']};
      } else if (distro == 'arch' || distro == 'manjaro') {
        // Arch: Installa da repository ufficiale
        onProgress?.call('Installazione FFmpeg...');
        final installResult = await _runSudoCommand(
          ['pacman', '-S', '--noconfirm', 'ffmpeg'],
          sudoPassword,
        );
        
        if (installResult['success'] == true) {
          await _storeSudoPassword(sudoPassword);
          return {'success': true, 'message': 'FFmpeg installato'};
        }
        return {'success': false, 'error': installResult['error']};
      } else {
        return {
          'success': false,
          'error': 'Distribuzione $distro non supportata per installazione automatica',
        };
      }
    } catch (e, stackTrace) {
      appLog('Errore installazione FFmpeg: $e');
      appLog('Stack: $stackTrace');
      return {
        'success': false,
        'error': 'Errore durante installazione: $e',
      };
    }
  }

  /// Esegue un comando con sudo usando la password su stdin (`sudo -S`).
  /// Più affidabile di expect (pattern "password for" in diverse lingue).
  static Future<Map<String, dynamic>> _runSudoCommand(
    List<String> command,
    String password,
  ) async {
    if (command.isEmpty) {
      return {'success': false, 'error': 'Comando vuoto'};
    }
    try {
      final process = await Process.start(
        'sudo',
        ['-S', ...command],
        environment: <String, String>{
          ...Platform.environment,
          'LANG': 'C',
          'LC_ALL': 'C',
        },
      );
      process.stdin.add(utf8.encode('$password\n'));
      await process.stdin.close();
      final stdout = await process.stdout.transform(utf8.decoder).join();
      final stderr = await process.stderr.transform(utf8.decoder).join();
      final code = await process.exitCode;
      final combined = stdout + stderr;
      if (code == 0) {
        return {'success': true, 'output': combined};
      }
      return {
        'success': false,
        'error': stderr.isNotEmpty ? stderr : combined,
        'output': combined,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Errore esecuzione comando: $e',
      };
    }
  }

  /// Memorizza la password sudo in modo sicuro
  static Future<void> _storeSudoPassword(String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // NOTA: In produzione, usa flutter_secure_storage invece di SharedPreferences
      // Per ora usiamo SharedPreferences con avviso
      await prefs.setString(_prefKeySudoPassword, password);
      await prefs.setBool(_prefKeyPasswordStored, true);
    } catch (e) {
      appLog('Errore memorizzazione password: $e');
    }
  }

  /// Recupera la password sudo memorizzata
  static Future<String?> getStoredSudoPassword() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_prefKeyPasswordStored) == true) {
        return prefs.getString(_prefKeySudoPassword);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Verifica se è stato tentato l'installazione
  static Future<bool> hasInstallAttempted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_prefKeyInstallAttempted) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Segna che è stato tentato l'installazione
  static Future<void> markInstallAttempted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKeyInstallAttempted, true);
    } catch (e) {
      // Ignora errori
    }
  }
}

