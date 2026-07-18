import 'package:flutter/material.dart';
import 'package:video_converter_pro/l10n/app_localizations.dart';
import 'package:video_converter_pro/services/ffmpeg_installer_service.dart';

class FFmpegInstallDialog extends StatefulWidget {
  final String? currentVersion;
  final bool needsUpdate;

  const FFmpegInstallDialog({
    super.key,
    this.currentVersion,
    required this.needsUpdate,
  });

  @override
  State<FFmpegInstallDialog> createState() => _FFmpegInstallDialogState();
}

class _FFmpegInstallDialogState extends State<FFmpegInstallDialog> {
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isInstalling = false;
  String? _progressMessage;
  String? _errorMessage;
  String? _detectedDistro;
  String? _ffmpegInstallSource;
  String? _ffmpegBinaryPath;

  @override
  void initState() {
    super.initState();
    _loadStoredPassword();
    _detectDistribution();
    _loadFfmpegInstallInfo();
  }

  /// Mostra come è installato ffmpeg (apt/snap/flatpak/rpm/…) per allineare le aspettative.
  Future<void> _loadFfmpegInstallInfo() async {
    try {
      final v = await FFmpegInstallerService.checkFFmpegVersion();
      if (!mounted) return;
      setState(() {
        _ffmpegInstallSource = v['installSource'] as String?;
        _ffmpegBinaryPath = v['binaryPath'] as String?;
      });
    } catch (_) {}
  }

  Future<void> _loadStoredPassword() async {
    final storedPassword = await FFmpegInstallerService.getStoredSudoPassword();
    if (storedPassword != null && mounted) {
      _passwordController.text = storedPassword;
    }
  }

  Future<void> _detectDistribution() async {
    final distro = await FFmpegInstallerService.detectLinuxDistribution();
    if (mounted) {
      setState(() {
        _detectedDistro = distro;
      });
    }
  }

  Future<void> _installFFmpeg() async {
    final l10n = AppLocalizations.of(context)!;
    if (_passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = l10n.passwordRequired;
      });
      return;
    }

    setState(() {
      _isInstalling = true;
      _errorMessage = null;
      _progressMessage = l10n.detectedDistribution(_detectedDistro ?? 'unknown');
    });

    try {
      final result = await FFmpegInstallerService.installFFmpeg(
        sudoPassword: _passwordController.text,
        onProgress: (message) {
          if (mounted) {
            setState(() {
              _progressMessage = message;
            });
          }
        },
      );

      if (mounted) {
        if (result['success'] == true) {
          // Successo
          await FFmpegInstallerService.markInstallAttempted();
          Navigator.of(context).pop(true); // true = installazione riuscita
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.ffmpegInstallSuccess),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Errore
          setState(() {
            _isInstalling = false;
            _errorMessage = result['error'] ?? 'Installation failed';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInstalling = false;
          _errorMessage = 'Error: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return AlertDialog(
      title: Text(l10n.ffmpegVersionCheck),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.currentVersion != null) ...[
              Text(
                l10n.ffmpegCurrentVersion(widget.currentVersion!),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
            ],
            if (_ffmpegInstallSource != null && _ffmpegInstallSource != 'unknown') ...[
              Text(
                'Rilevamento: $_ffmpegInstallSource'
                '${_ffmpegBinaryPath != null ? '\n$_ffmpegBinaryPath' : ''}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade700,
                    ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              'Versione minima richiesta: 5.0.0\nVersione consigliata: 8.0.1',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'L\'app funziona con FFmpeg versione 5.0.0 o superiore. La versione 8.0.1 è consigliata per le migliori prestazioni.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.installFFmpegDesc,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: l10n.enterSudoPassword,
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              enabled: !_isInstalling,
            ),
            if (_progressMessage != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  if (_isInstalling) const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  if (_isInstalling) const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _progressMessage!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (!_isInstalling) ...[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.skipInstallation),
          ),
          ElevatedButton(
            onPressed: _installFFmpeg,
            child: Text(l10n.installFFmpeg),
          ),
        ] else
          TextButton(
            onPressed: null,
            child: Text(l10n.cancel),
          ),
      ],
    );
  }
}

