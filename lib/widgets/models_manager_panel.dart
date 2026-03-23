import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_converter_pro/providers/settings_provider.dart';
import 'package:video_converter_pro/services/models_manager_service.dart';

class ModelsManagerPanel extends StatefulWidget {
  const ModelsManagerPanel({super.key});

  @override
  State<ModelsManagerPanel> createState() => _ModelsManagerPanelState();
}

class _ModelsManagerPanelState extends State<ModelsManagerPanel> {
  bool _isLoading = false;
  bool _isDownloading = false;
  Map<String, dynamic>? _modelsStatus;
  Map<String, dynamic>? _modelsSize;

  @override
  void initState() {
    super.initState();
    _loadModelsStatus();
  }

  Future<void> _loadModelsStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final settingsProvider = context.read<SettingsProvider>();
      final status = await ModelsManagerService.getModelsStatus(
        modelsDirectory: settingsProvider.modelsDirectory.isEmpty
            ? null
            : settingsProvider.modelsDirectory,
      );
      final size = await ModelsManagerService.getModelsSize(
        modelsDirectory: settingsProvider.modelsDirectory.isEmpty
            ? null
            : settingsProvider.modelsDirectory,
      );

      setState(() {
        _modelsStatus = status;
        _modelsSize = size;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading models status: $e')),
        );
      }
    }
  }

  Future<void> _downloadDrunet() async {
    final settingsProvider = context.read<SettingsProvider>();
    setState(() => _isDownloading = true);
    try {
      final result = await ModelsManagerService.downloadDRUNetModel(
        modelsDirectory: settingsProvider.modelsDirectory.isEmpty
            ? null
            : settingsProvider.modelsDirectory,
        force: true,
        onProgress: (_, __) {},
      );
      if (!mounted) return;
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('DRUNet model downloaded successfully.'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadModelsStatus();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: ${result['error'] ?? 'unknown'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();

    return Card(
      margin: const EdgeInsets.all(8),
      child: ExpansionTile(
        leading: const Icon(Icons.model_training),
        title: const Text('AI Models Management'),
        subtitle: _modelsSize != null
            ? Text(
                '${_modelsSize!['installed_count']}/${_modelsSize!['total_count']} optional models (${_modelsSize!['total_size_mb']} MB)')
            : const Text('Loading...'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const Icon(Icons.folder),
                  title: const Text('Models Directory'),
                  subtitle: Text(
                    settingsProvider.modelsDirectory.isEmpty
                        ? 'Default: ~/.video-converter-pro/models'
                        : settingsProvider.modelsDirectory,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.folder_open),
                    onPressed: () async {
                      final String? selectedDirectory =
                          await FilePicker.platform.getDirectoryPath();
                      if (selectedDirectory != null) {
                        await settingsProvider.setModelsDirectory(selectedDirectory);
                        await _loadModelsStatus();
                      }
                    },
                  ),
                ),
                const Divider(),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_modelsStatus != null) ...[
                  const Text(
                    'DRUNet (optional denoising)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ..._buildDRUNetCard(),
                  const SizedBox(height: 12),
                  const Text(
                    'Scarica automaticamente da Internet (~125 MB) o posiziona drunet_model.pth in models/drunet/.',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        icon: _isDownloading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.download),
                        label: Text(_isDownloading ? 'Downloading…' : 'Download DRUNet'),
                        onPressed: (_isLoading || _isDownloading) ? null : _downloadDrunet,
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh Status'),
                        onPressed: (_isLoading || _isDownloading) ? null : _loadModelsStatus,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDRUNetCard() {
    if (_modelsStatus == null) return [];

    final drunet = _modelsStatus!['drunet'] as Map<String, dynamic>?;
    if (drunet == null) return [];

    final exists = drunet['exists'] == true;
    final size = drunet['size_mb'] as String? ?? '0';
    final path = drunet['path'] as String? ?? '';

    return [
      Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          leading: Icon(
            exists ? Icons.check_circle : Icons.cancel,
            color: exists ? Colors.green : Colors.grey,
          ),
          title: const Text('DRUNet model'),
          subtitle: Text(
            exists
                ? 'Installed (${size} MB)\n$path'
                : 'Not installed — add drunet_model.pth manually',
          ),
          isThreeLine: true,
        ),
      ),
    ];
  }
}



