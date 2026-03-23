import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:video_converter_pro/providers/conversion_provider.dart';
import 'package:video_converter_pro/providers/settings_provider.dart';
import 'package:video_converter_pro/providers/language_provider.dart';
import 'package:video_converter_pro/screens/home_screen.dart';
import 'package:video_converter_pro/screens/dependency_check_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_converter_pro/l10n/app_localizations.dart';
import 'package:video_converter_pro/services/dependency_checker.dart';
import 'package:video_converter_pro/services/models_manager_service.dart';
import 'package:video_converter_pro/widgets/models_download_dialog.dart';
import 'package:video_converter_pro/widgets/python_env_setup_dialog.dart';
import 'package:video_converter_pro/services/python_env_setup_service.dart';
import 'package:video_converter_pro/utils/app_log.dart';

/// Applica fix specifici per driver NVIDIA 580/590 su Ubuntu/Zorin OS
/// Questi fix prevengono crash e freeze causati da incompatibilità tra
/// Flutter e driver NVIDIA proprietari
Future<void> applyNvidiaFixes() async {
  try {
    bool nvidiaDetected = false;
    String? nvidiaDriverVersion;
    
    try {
      final nvidiaSmiResult = await Process.run('nvidia-smi', ['--query-gpu=driver_version', '--format=csv,noheader'], runInShell: true);
      if (nvidiaSmiResult.exitCode == 0 && nvidiaSmiResult.stdout.toString().trim().isNotEmpty) {
        nvidiaDetected = true;
        nvidiaDriverVersion = nvidiaSmiResult.stdout.toString().trim();
        appLog('🔍 [NVIDIA] Rilevato driver NVIDIA versione: $nvidiaDriverVersion');
      }
    } catch (_) {}

    if (!nvidiaDetected) {
      try {
        final nvidiaProcFile = File('/proc/driver/nvidia/version');
        if (await nvidiaProcFile.exists()) {
          final content = await nvidiaProcFile.readAsString();
          final versionMatch = RegExp(r'NVRM version:\s+([\d.]+)').firstMatch(content);
          if (versionMatch != null) {
            nvidiaDetected = true;
            nvidiaDriverVersion = versionMatch.group(1);
            appLog('🔍 [NVIDIA] Rilevato driver NVIDIA versione: $nvidiaDriverVersion');
          }
        }
      } catch (_) {}
    }

    if (!nvidiaDetected) {
      try {
        final lspciResult = await Process.run('lspci', [], runInShell: true);
        if (lspciResult.exitCode == 0) {
          final output = lspciResult.stdout.toString().toLowerCase();
          if (output.contains('nvidia') && (output.contains('vga') || output.contains('display'))) {
            nvidiaDetected = true;
            appLog('🔍 [NVIDIA] Rilevata GPU NVIDIA tramite lspci');
          }
        }
      } catch (_) {}
    }

    if (nvidiaDetected) {
      appLog('⚠️ [NVIDIA] Driver NVIDIA rilevato. Applicazione fix per compatibilità Flutter...');
      
      bool isProblematicDriver = false;
      if (nvidiaDriverVersion != null) {
        final majorVersion = int.tryParse(nvidiaDriverVersion.split('.').first);
        if (majorVersion != null && (majorVersion == 580 || majorVersion == 590)) {
          isProblematicDriver = true;
          appLog('⚠️ [NVIDIA] Rilevato driver problematico (${majorVersion}xx). Applicazione fix specifici...');
        }
      }
      
      appLog('✅ [NVIDIA] Fix applicati tramite variabili d\'ambiente:');
      appLog('   - __GL_SYNC_TO_VBLANK=0 (disabilita VSync per evitare freeze)');
      appLog('   - __GL_THREADED_OPTIMIZATIONS=0 (disabilita ottimizzazioni threaded)');
      appLog('   - __GL_ALLOW_UNOFFICIAL_PROTOCOL=0 (forza protocolli ufficiali)');
      if (isProblematicDriver) {
        appLog('   - LIBGL_ALWAYS_INDIRECT=1 (forza rendering indiretto per driver 580/590)');
      }
      appLog('   - GDK_BACKEND=x11 (forza X11 invece di Wayland)');
    }
  } catch (e) {
    appLog('⚠️ [NVIDIA] Errore durante rilevamento NVIDIA: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (Platform.isLinux) {
    try {
      final waylandDisplay = Platform.environment['WAYLAND_DISPLAY'];
      final gdkBackend = Platform.environment['GDK_BACKEND'];
      
      if (waylandDisplay != null && gdkBackend != 'x11') {
        appLog('⚠️ [Wayland] Rilevato Wayland. Per migliori prestazioni, considera di usare X11.');
        appLog('⚠️ [Wayland] L\'app tenterà di usare X11 automaticamente se disponibile.');
      }
      
      await applyNvidiaFixes();
    } catch (e) {
      appLog('⚠️ [Wayland] Errore durante check Wayland: $e');
    }
  }

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    appLog('❌ [FlutterError] ${details.exception}');
    appLog('📚 [FlutterError] Stack: ${details.stack}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    appLog('❌ [PlatformError] $error');
    appLog('📚 [PlatformError] Stack: $stack');
    return true; // Previene il crash
  };

  runZonedGuarded(
    () async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final Map<String, dynamic> dependencyStatus = await DependencyChecker.checkDependencies();

      List<String>? initialFiles;
      if (Platform.isLinux) {
        try {
          await Future.delayed(const Duration(milliseconds: 300));
          
          const methodChannel = MethodChannel('com.videoconverterpro/args');
          final result = await methodChannel.invokeMethod<List>('getCommandLineArguments').timeout(
            const Duration(seconds: 2),
            onTimeout: () {
              if (kDebugMode) {
                appLog('Timeout lettura argomenti riga di comando');
              }
              return null;
            },
          );
          
          if (kDebugMode && result != null) {
            appLog('Argomenti ricevuti: $result');
          }
          
          if (result != null && result.isNotEmpty) {
            initialFiles = <String>[];
            for (final arg in result) {
              if (arg is String) {
                String filePath = arg;
                
                if (filePath.startsWith('file://')) {
                  filePath = filePath.substring(7);
                  filePath = Uri.decodeComponent(filePath);
                }
                
                if (!filePath.startsWith('/')) {
                  filePath = '${Directory.current.path}/$filePath';
                }
                
                filePath = filePath.trim();
                if (filePath.endsWith('/')) {
                  filePath = filePath.substring(0, filePath.length - 1);
                }
                
                final file = File(filePath);
                if (await file.exists()) {
                  initialFiles.add(filePath);
                  if (kDebugMode) {
                    appLog('File valido aggiunto: $filePath');
                  }
                } else if (kDebugMode) {
                  appLog('File non trovato: $filePath');
                }
              }
            }
            if (initialFiles.isEmpty) {
              initialFiles = null;
            } else if (kDebugMode) {
              appLog('Totale file validi: ${initialFiles.length}');
            }
          }
        } catch (e, stackTrace) {
          if (kDebugMode) {
            appLog('Errore lettura argomenti riga di comando: $e');
            appLog('Stack trace: $stackTrace');
          }
        }
      }

      final settingsProvider = SettingsProvider(prefs);
      
      runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider(
          create: (_) {
            final conversionProvider = ConversionProvider();
            conversionProvider.setSettingsProvider(settingsProvider);
            return conversionProvider;
          },
        ),
        ChangeNotifierProvider(create: (_) => LanguageProvider(prefs)),
      ],
      child: VideoConverterApp(dependencyStatus: dependencyStatus, initialFiles: initialFiles),
    ),
      );
    },
    (error, stack) {
      appLog('❌ [ZoneError] $error');
      appLog('📚 [ZoneError] Stack: $stack');
    },
  );
}

class VideoConverterApp extends StatefulWidget {
  final Map<String, dynamic> dependencyStatus;
  final List<String>? initialFiles;

  const VideoConverterApp({super.key, required this.dependencyStatus, this.initialFiles});

  @override
  State<VideoConverterApp> createState() => _VideoConverterAppState();
}

class _VideoConverterAppState extends State<VideoConverterApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  
  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }
  
  BuildContext? get _dialogContext => _navigatorKey.currentContext;
  
  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('first_launch') ?? true;
    final languageSelected = prefs.getBool('language_selected') ?? false;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (_dialogContext == null) return;

      if (isFirstLaunch && !languageSelected) {
        await _showLanguageSelectionDialog();
        if (!mounted) return;
      }

      await _ensurePythonEnvAtStartup();
      if (!mounted) return;

      await _ensureDrunetModelAtStartup();
    });
  }

  /// Optional Python venv + pip deps (DRUNet / scene tools): off .deb postinst, first launch with dialog.
  Future<void> _ensurePythonEnvAtStartup() async {
    if (!mounted) return;
    if (widget.dependencyStatus['available'] != true) return;
    if (!PythonEnvSetupService.shouldOfferSetup()) return;

    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    if (prefs.getBool(PythonEnvSetupService.prefsKeyCompleted) == true) return;
    if (prefs.getBool(PythonEnvSetupService.prefsKeySkipped) == true) return;

    final ctx = _dialogContext;
    if (ctx == null || !mounted) return;

    await showDialog<void>(
      context: ctx,
      barrierDismissible: false,
      builder: (context) => const PythonEnvSetupDialog(),
    );
  }

  /// Ad ogni avvio: se FFmpeg/dipendenze ok e manca il modello DRUNet, scarica automaticamente (~125 MB).
  Future<void> _ensureDrunetModelAtStartup() async {
    if (!mounted) return;
    if (widget.dependencyStatus['available'] != true) return;

    final ctx = _dialogContext;
    if (ctx == null) return;

    final settings = Provider.of<SettingsProvider>(ctx, listen: false);
    final modelsDir =
        settings.modelsDirectory.isEmpty ? null : settings.modelsDirectory;

    final ready =
        await ModelsManagerService.isDRUNetModelReady(modelsDirectory: modelsDir);
    if (!mounted) return;
    if (ready) return;

    await showDialog<void>(
      context: ctx,
      barrierDismissible: false,
      builder: (context) => const ModelsDownloadDialog(),
    );
  }
  
  Future<void> _showLanguageSelectionDialog() async {
    final ctx = _dialogContext;
    if (!mounted || ctx == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    String? selectedLanguage;
    
    await showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (dialogContext) {
        final languageProvider = Provider.of<LanguageProvider>(dialogContext, listen: false);
        final currentLang = languageProvider.currentLocale.languageCode;
        selectedLanguage = currentLang;
        
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Select Language / Seleziona Lingua'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Please select your preferred language.\nPer favore seleziona la tua lingua preferita.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ...['en', 'it', 'fr', 'de', 'es', 'pt'].map((langCode) {
                    final langName = SettingsProvider.getLanguageName(langCode);
                    return ListTile(
                      title: Text(langName),
                      leading: Radio<String>(
                        value: langCode,
                        groupValue: selectedLanguage,
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() {
                              selectedLanguage = value;
                            });
                          }
                        },
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (selectedLanguage != null && selectedLanguage != currentLang) {
                    await languageProvider.setLanguage(selectedLanguage!);
                    await prefs.setBool('language_selected', true);
                  } else {
                    await prefs.setBool('language_selected', true);
                  }
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    if (mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => VideoConverterApp(
                            dependencyStatus: widget.dependencyStatus,
                            initialFiles: widget.initialFiles,
                          ),
                        ),
                      );
                    }
                  }
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final languageProvider = context.watch<LanguageProvider>();

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'FE MEDIA CONVERTER',
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: settingsProvider.themeMode,

      locale: languageProvider.currentLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('it', ''),
        Locale('fr', ''),
        Locale('de', ''),
        Locale('es', ''),
        Locale('pt', ''),
      ],

      home: widget.dependencyStatus['available'] == true
      ? HomeScreen(initialFiles: widget.initialFiles)
      : DependencyCheckScreen(
        dependencyStatus: widget.dependencyStatus,
        onRetry: () async {
          final status = await DependencyChecker.checkDependencies();
          setState(() {
            widget.dependencyStatus.clear();
            widget.dependencyStatus.addAll(status);
          });
        },
      ),
    );
  }

  ThemeData _buildLightTheme() {
    final lightColorScheme = ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    );

    return ThemeData(
      colorScheme: lightColorScheme,
      useMaterial3: true,
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey.shade200,
        selectedColor: Colors.blue.shade300,
        labelStyle: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        checkmarkColor: Colors.white,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    );

    final cardColor = Colors.grey[850]!;
    final scaffoldColor = Colors.grey[900]!;

    return ThemeData(
      colorScheme: darkColorScheme.copyWith(
        surface: cardColor,
        surfaceContainerHighest: Colors.grey[800]!,
        onSurface: Colors.white,
        onSurfaceVariant: Colors.grey[300]!,
        primary: Colors.blue[400]!,
        onPrimary: Colors.white,
        secondary: Colors.blue[300]!,
        onSecondary: Colors.white,
        error: Colors.red[400]!,
        onError: Colors.white,
      ),
      useMaterial3: true,

      cardColor: cardColor,
      scaffoldBackgroundColor: scaffoldColor,

      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: cardColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldColor,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.grey[800],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          color: Colors.grey[200],
          fontSize: 14,
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: Colors.grey[200],
        textColor: Colors.white,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        subtitleTextStyle: TextStyle(
          color: Colors.grey[300],
          fontSize: 14,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: Colors.blue[400]!,
        inactiveTrackColor: Colors.grey[600]!,
        thumbColor: Colors.blue[400]!,
        overlayColor: Colors.blue[400]!.withValues(alpha: 0.2),
        valueIndicatorColor: Colors.blue[400]!,
        valueIndicatorTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.all(Colors.white),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.blue[400];
          }
          return Colors.grey[700];
        }),
      ),
      textTheme: TextTheme(
        bodyLarge: const TextStyle(color: Colors.white),
        bodyMedium: const TextStyle(color: Colors.white),
        bodySmall: TextStyle(color: Colors.grey[300]),
        titleLarge: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        titleMedium: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        titleSmall: const TextStyle(color: Colors.white),
        labelLarge: const TextStyle(color: Colors.white),
        labelMedium: const TextStyle(color: Colors.white),
        labelSmall: TextStyle(color: Colors.grey[300]),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey[700],
        selectedColor: Colors.blue[600]!,
        disabledColor: Colors.grey[800]!,
        labelStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        checkmarkColor: Colors.white,
        deleteIconColor: Colors.grey[300]!,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue[600]!,
          textStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.blue[300]!,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.grey[600]!),
          textStyle: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
