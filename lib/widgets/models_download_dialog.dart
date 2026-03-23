import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_converter_pro/services/models_manager_service.dart';
import 'package:video_converter_pro/providers/settings_provider.dart';
import 'package:provider/provider.dart';

class ModelsDownloadDialog extends StatefulWidget {
  const ModelsDownloadDialog({super.key});

  @override
  State<ModelsDownloadDialog> createState() => _ModelsDownloadDialogState();
}

class _ModelsDownloadDialogState extends State<ModelsDownloadDialog> {
  bool _busy = true;
  bool _downloading = false;
  double _progress = 0;
  String _status = 'Verifica modello DRUNet…';
  bool _hasStarted = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _run();
    });
  }

  Future<void> _run() async {
    if (_hasStarted) return;
    _hasStarted = true;
    if (!mounted) return;

    final settingsProvider = context.read<SettingsProvider>();

    try {
      final modelsDir = settingsProvider.modelsDirectory.isEmpty
          ? null
          : settingsProvider.modelsDirectory;

      final ready = await ModelsManagerService.isDRUNetModelReady(
        modelsDirectory: modelsDir,
      );

      if (ready) {
        final st = await ModelsManagerService.getModelsStatus(modelsDirectory: modelsDir);
        final p = (st['drunet'] as Map<String, dynamic>?)?['path'] ?? '';
        if (mounted) {
          setState(() {
            _busy = false;
            _status =
                '✅ Modello DRUNet già installato (uso offline).\n\nPercorso: $p';
          });
        }
        await _markDone();
        return;
      }

      setState(() {
        _downloading = true;
        _status = 'Download automatico del modello DRUNet (~125 MB) per uso offline…';
        _progress = 0;
      });

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
        setState(() {
          _busy = false;
          _downloading = false;
          _progress = 1;
          _status = '✅ Modello DRUNet scaricato e pronto per l\'uso offline.\n\n'
              '${result['path'] ?? ''}';
        });
        await _markDone();
      } else {
        setState(() {
          _busy = false;
          _downloading = false;
          _error = result['error']?.toString() ?? 'Download fallito';
          _status = '⚠️ Download non riuscito.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _downloading = false;
          _error = e.toString();
          _status = '⚠️ Errore durante il download.';
        });
      }
    }
  }

  Future<void> _markDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('models_auto_downloaded', true);
    await prefs.setBool('first_launch', false);
  }

  Future<void> _retry() async {
    setState(() {
      _busy = true;
      _downloading = false;
      _error = null;
      _progress = 0;
      _status = 'Nuovo tentativo…';
    });
    _hasStarted = false;
    await _run();
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
            if (_busy && !_downloading) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 16),
            ],
            if (_downloading) ...[
              LinearProgressIndicator(value: _progress > 0 && _progress < 1 ? _progress : null),
              const SizedBox(height: 8),
              Text(
                '${(_progress * 100).toStringAsFixed(0)}%',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
            ],
            Text(_status),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (_error != null)
          TextButton(
            onPressed: _busy ? null : _retry,
            child: const Text('Riprova'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(_error != null ? 'Chiudi' : 'OK'),
        ),
      ],
    );
  }
}
