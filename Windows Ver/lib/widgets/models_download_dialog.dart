import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_converter_pro/services/models_manager_service.dart';
import 'package:video_converter_pro/providers/settings_provider.dart';
import 'package:provider/provider.dart';

enum _DialogState { checking, choice, downloading, success, error }

class ModelsDownloadDialog extends StatefulWidget {
  const ModelsDownloadDialog({super.key});

  @override
  State<ModelsDownloadDialog> createState() => _ModelsDownloadDialogState();
}

class _ModelsDownloadDialogState extends State<ModelsDownloadDialog> {
  _DialogState _state = _DialogState.checking;
  double _progress = 0;
  String _status = 'Verifica modello DRUNet…';
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkModel());
  }

  Future<void> _checkModel() async {
    final settingsProvider = context.read<SettingsProvider>();
    final modelsDir = settingsProvider.modelsDirectory.isEmpty
        ? null
        : settingsProvider.modelsDirectory;

    final ready = await ModelsManagerService.isDRUNetModelReady(
      modelsDirectory: modelsDir,
    );
    if (!mounted) return;

    if (ready) {
      final st = await ModelsManagerService.getModelsStatus(modelsDirectory: modelsDir);
      final p = (st['drunet'] as Map<String, dynamic>?)?['path'] ?? '';
      setState(() {
        _state = _DialogState.success;
        _status = 'Modello DRUNet già installato.\n\nPercorso: $p';
      });
      return;
    }

    setState(() {
      _state = _DialogState.choice;
      _status = '';
    });
  }

  Future<void> _startDownload() async {
    setState(() {
      _state = _DialogState.downloading;
      _error = null;
      _status = 'Download del modello DRUNet (~125 MB)…';
      _progress = 0;
    });

    final settingsProvider = context.read<SettingsProvider>();
    final modelsDir = settingsProvider.modelsDirectory.isEmpty
        ? null
        : settingsProvider.modelsDirectory;

    try {
      final result = await ModelsManagerService.downloadDRUNetModel(
        modelsDirectory: modelsDir,
        onProgress: (p, msg) {
          if (mounted) {
            setState(() {
              _progress = p.clamp(0.0, 1.0);
              _status = msg;
            });
          }
        },
      );

      if (!mounted) return;

      if (result['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('models_auto_downloaded', true);
        await prefs.setBool('first_launch', false);
        await prefs.setBool(ModelsManagerService.prefsKeyDRUNetSkipped, false);

        if (mounted) {
          setState(() {
            _state = _DialogState.success;
            _progress = 1;
            _status = 'Modello DRUNet scaricato e pronto.\n\n${result['path'] ?? ''}';
          });
        }
      } else {
        setState(() {
          _state = _DialogState.error;
          _error = result['error']?.toString() ?? 'Download fallito';
          _status = 'Download non riuscito.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = _DialogState.error;
          _error = e.toString();
          _status = 'Errore durante il download.';
        });
      }
    }
  }

  Future<void> _skipDownload() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(ModelsManagerService.prefsKeyDRUNetSkipped, true);
    if (mounted) Navigator.of(context).pop(false);
  }

  Future<void> _retry() async {
    await _startDownload();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.cloud_download, color: Colors.blue),
          SizedBox(width: 8),
          Expanded(child: Text('Modello DRUNet (offline)')),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_state == _DialogState.checking) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Verifica modello DRUNet…'),
            ],
            if (_state == _DialogState.choice) ...[
              const Text(
                'Il modello DRUNet (~125 MB) è necessario per la denoising AI avanzato.\n\n'
                'Puoi scaricarlo ora oppure saltare e scaricarlo in seguito dalle impostazioni.',
              ),
            ],
            if (_state == _DialogState.downloading) ...[
              LinearProgressIndicator(value: _progress > 0 && _progress < 1 ? _progress : null),
              const SizedBox(height: 8),
              Text(
                '${(_progress * 100).toStringAsFixed(0)}%',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Text(_status),
            ],
            if (_state == _DialogState.error) ...[
              Text(_status),
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
              ),
            ],
            if (_state == _DialogState.success)
              Text(_status),
          ],
        ),
      ),
      actions: [
        if (_state == _DialogState.choice) ...[
          TextButton(
            onPressed: _skipDownload,
            child: const Text('Non ora'),
          ),
          FilledButton(
            onPressed: _startDownload,
            child: const Text('Scarica'),
          ),
        ],
        if (_state == _DialogState.downloading)
          TextButton(
            onPressed: null,
            child: const Text('Download in corso…'),
          ),
        if (_state == _DialogState.error) ...[
          TextButton(
            onPressed: _retry,
            child: const Text('Riprova'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Chiudi'),
          ),
        ],
        if (_state == _DialogState.success)
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('OK'),
          ),
      ],
    );
  }
}
