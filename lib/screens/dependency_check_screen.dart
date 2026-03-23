import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_converter_pro/l10n/app_localizations.dart';
import 'package:video_converter_pro/widgets/ffmpeg_install_dialog.dart';
import 'package:video_converter_pro/services/ffmpeg_installer_service.dart';
import 'dart:io';

class DependencyCheckScreen extends StatefulWidget {
  final Map<String, dynamic> dependencyStatus;
  final VoidCallback onRetry;

  const DependencyCheckScreen({
    super.key,
    required this.dependencyStatus,
    required this.onRetry,
  });

  @override
  State<DependencyCheckScreen> createState() => _DependencyCheckScreenState();
}

class _DependencyCheckScreenState extends State<DependencyCheckScreen> {
  bool _hasShownInstallDialog = false;

  @override
  void initState() {
    super.initState();
    // Mostra dialog di installazione automatica se su Linux e FFmpeg non è disponibile/aggiornato
    // L'app accetta versioni >= 5.0.0, ma mostra il dialog solo se la versione è < 5.0.0
    if (Platform.isLinux && 
        (widget.dependencyStatus['available'] != true || 
         widget.dependencyStatus['needsUpdate'] == true) &&
        !_hasShownInstallDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showInstallDialog();
      });
    }
  }

  Future<void> _showInstallDialog() async {
    if (_hasShownInstallDialog) return;
    
    final hasAttempted = await FFmpegInstallerService.hasInstallAttempted();
    if (hasAttempted) return; // Non mostrare di nuovo se già tentato
    
    _hasShownInstallDialog = true;
    
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => FFmpegInstallDialog(
        currentVersion: widget.dependencyStatus['currentVersion'] as String?,
        needsUpdate: widget.dependencyStatus['needsUpdate'] == true,
      ),
    );

    if (result == true) {
      // Installazione riuscita, ricontrolla dipendenze
      widget.onRetry();
    }
  }

  Future<void> _launchFFmpegWebsite() async {
    final Uri url = Uri.parse('https://ffmpeg.org/download.html');
    if (!await launchUrl(url)) {
      throw Exception('Impossibile aprire: $url');
    }
  }

  Future<void> _launchFedoraGuide() async {
    final Uri url = Uri.parse('https://docs.fedoraproject.org/en-US/quick-docs/ffmpeg/');
    if (!await launchUrl(url)) {
      throw Exception('Impossibile aprire: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final error = widget.dependencyStatus['error'] ?? 'Dipendenza non trovata';

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icona di errore
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 24),
            
            // Titolo
            Text(
              l10n.ffmpegNotInstalled,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Descrizione
            Text(
              l10n.ffmpegNotInstalled,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // Messaggio di errore dettagliato
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                error,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            
            // Istruzioni per l'installazione
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.howToInstallFfmpeg,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Fedora
                    _buildInstallStep(
                      context,
                      l10n.onFedora,
                      l10n.openTerminalAndRun,
                      'sudo dnf install ffmpeg ffmpeg-devel',
                      onTap: _launchFedoraGuide,
                      l10n: l10n,
                    ),
                    const SizedBox(height: 16),
                    
                    // Ubuntu/Debian
                    _buildInstallStep(
                      context,
                      l10n.onUbuntuDebian,
                      l10n.openTerminalAndRun,
                      'sudo apt install ffmpeg',
                      l10n: l10n,
                    ),
                    const SizedBox(height: 16),
                    
                    // Windows
                    _buildInstallStep(
                      context,
                      l10n.onWindows,
                      l10n.downloadFromFfmpeg,
                      'winget install ffmpeg',
                      onTap: _launchFFmpegWebsite,
                      l10n: l10n,
                    ),
                    const SizedBox(height: 16),
                    
                    // macOS
                    _buildInstallStep(
                      context,
                      l10n.onMacOS,
                      l10n.useHomebrew,
                      'brew install ffmpeg',
                      l10n: l10n,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Pulsanti di azione
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: widget.onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.ok),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                if (Platform.isLinux && (widget.dependencyStatus['needsUpdate'] == true || widget.dependencyStatus['available'] != true)) ...[
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _showInstallDialog,
                    icon: const Icon(Icons.download),
                    label: Text(l10n.installFFmpeg),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: _launchFFmpegWebsite,
                  icon: const Icon(Icons.open_in_new),
                  label: Text(l10n.browse),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Nota
            Text(
              l10n.afterInstallingRestart,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstallStep(
    BuildContext context,
    String title,
    String description,
    String command, {
    VoidCallback? onTap,
    required AppLocalizations l10n,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              command,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Monospace',
                fontSize: 14,
              ),
            ),
          ),
        ),
        if (onTap != null) ...[
          const SizedBox(height: 4),
          Text(
            l10n.clickToOpenGuide,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.blue.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}