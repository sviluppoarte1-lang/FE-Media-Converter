import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_converter_pro/l10n/app_localizations.dart';
import 'package:video_converter_pro/services/python_env_setup_service.dart';

/// First-run optional install: venv + pip deps for DRUNet / PySceneDetect (moved off .deb postinst).
class PythonEnvSetupDialog extends StatefulWidget {
  const PythonEnvSetupDialog({super.key});

  @override
  State<PythonEnvSetupDialog> createState() => _PythonEnvSetupDialogState();
}

class _PythonEnvSetupDialogState extends State<PythonEnvSetupDialog> {
  bool _running = false;
  bool _finished = false;
  bool _success = false;
  int? _exitCode;
  final List<String> _logLines = [];
  static const int _maxLogLines = 40;

  Future<void> _onInstall() async {
    setState(() {
      _running = true;
      _finished = false;
      _logLines.clear();
    });

    final code = await PythonEnvSetupService.runSetup(
      onLine: (line) {
        if (!mounted) return;
        setState(() {
          _logLines.add(line);
          while (_logLines.length > _maxLogLines) {
            _logLines.removeAt(0);
          }
        });
      },
    );

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    if (code == 0) {
      await prefs.setBool(PythonEnvSetupService.prefsKeyCompleted, true);
      await prefs.setBool(PythonEnvSetupService.prefsKeySkipped, false);
      setState(() {
        _running = false;
        _finished = true;
        _success = true;
        _exitCode = code;
      });
    } else {
      setState(() {
        _running = false;
        _finished = true;
        _success = false;
        _exitCode = code;
      });
    }
  }

  Future<void> _onSkip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PythonEnvSetupService.prefsKeySkipped, true);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(l10n.pythonSetupTitle),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_finished) Text(l10n.pythonSetupIntro),
              if (_running) ...[
                const SizedBox(height: 16),
                const LinearProgressIndicator(),
                const SizedBox(height: 8),
                Text(
                  l10n.pythonSetupRunning,
                  style: theme.textTheme.bodySmall,
                ),
              ],
              if (_logLines.isNotEmpty) ...[
                const SizedBox(height: 12),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: SelectableText(
                      _logLines.join('\n'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
              if (_finished) ...[
                const SizedBox(height: 12),
                Text(
                  _success ? l10n.pythonSetupSuccess : l10n.pythonSetupFailed(_exitCode ?? -1),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _success ? theme.colorScheme.primary : theme.colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        if (!_running && !_finished) ...[
          TextButton(
            onPressed: _onSkip,
            child: Text(l10n.pythonSetupSkip),
          ),
          FilledButton(
            onPressed: _onInstall,
            child: Text(l10n.pythonSetupInstall),
          ),
        ],
        if (_running)
          TextButton(
            onPressed: null,
            child: Text(l10n.pythonSetupPleaseWait),
          ),
        if (_finished) ...[
          if (!_success)
            TextButton(
              onPressed: () {
                setState(() {
                  _finished = false;
                  _success = false;
                  _exitCode = null;
                  _logLines.clear();
                });
              },
              child: Text(l10n.pythonSetupRetry),
            ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ],
    );
  }
}
