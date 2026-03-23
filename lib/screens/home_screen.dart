import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:video_converter_pro/models/conversion_task.dart';
import 'package:video_converter_pro/models/media_type.dart';
import 'package:video_converter_pro/models/video_filters.dart';
import 'package:video_converter_pro/models/audio_filters.dart';
import 'package:video_converter_pro/models/image_filters.dart';
import 'package:video_converter_pro/providers/conversion_provider.dart';
import 'package:video_converter_pro/providers/settings_provider.dart';
import 'package:video_converter_pro/widgets/conversion_queue.dart';
import 'package:video_converter_pro/widgets/format_selector.dart';
import 'package:video_converter_pro/widgets/quality_settings.dart';
import 'package:video_converter_pro/widgets/video_filters_panel.dart';
import 'package:video_converter_pro/widgets/media_type_selector.dart';
import 'package:video_converter_pro/widgets/audio_filters_panel.dart';
import 'package:video_converter_pro/widgets/image_filters_panel.dart';
import 'package:video_converter_pro/widgets/file_drop_target.dart';
import 'package:video_converter_pro/widgets/models_manager_panel.dart';
import 'package:video_converter_pro/l10n/app_localizations.dart';
import 'package:video_converter_pro/providers/language_provider.dart';
import 'package:video_converter_pro/screens/user_guide_screen.dart';
import 'package:video_converter_pro/utils/app_log.dart';
import 'package:url_launcher/url_launcher.dart';

class ConversionStateProvider with ChangeNotifier {
  final List<String> _selectedFiles = [];
  MediaType _selectedMediaType = MediaType.video;
  VideoFilters _currentVideoFilters = VideoFilters.maximumQualityDefaults();
  AudioFilters _currentAudioFilters = AudioFilters();
  ImageFilters _currentImageFilters = ImageFilters();
  SettingsProvider? _settingsProvider;

  List<String> get selectedFiles => _selectedFiles;
  MediaType get selectedMediaType => _selectedMediaType;
  VideoFilters get currentVideoFilters => _currentVideoFilters;
  AudioFilters get currentAudioFilters => _currentAudioFilters;
  ImageFilters get currentImageFilters => _currentImageFilters;

  void setSettingsProvider(SettingsProvider provider) {
    _settingsProvider = provider;
    _loadSavedFilters();
  }

  void _loadSavedFilters() {
    if (_settingsProvider == null) return;
    
    final savedVideoFilters = _settingsProvider!.loadVideoFilters();
    _currentVideoFilters = savedVideoFilters ?? VideoFilters.maximumQualityDefaults();
    
    final savedAudioFilters = _settingsProvider!.loadAudioFilters();
    if (savedAudioFilters != null) {
      _currentAudioFilters = savedAudioFilters;
    }
    
    final savedImageFilters = _settingsProvider!.loadImageFilters();
    if (savedImageFilters != null) {
      _currentImageFilters = savedImageFilters;
    }
    
    notifyListeners();
  }

  void setSelectedFiles(List<String> files) {
    _selectedFiles.clear();
    _selectedFiles.addAll(files);
    notifyListeners();
  }

  void addFiles(List<String> files) {
    for (final f in files) {
      if (!_selectedFiles.contains(f)) _selectedFiles.add(f);
    }
    notifyListeners();
  }

  void setSelectedMediaType(MediaType type) {
    _selectedMediaType = type;
    notifyListeners();
  }

  void setVideoFilters(VideoFilters filters) {
    _currentVideoFilters = filters;
    _settingsProvider?.saveVideoFilters(filters);
    notifyListeners();
  }

  void setAudioFilters(AudioFilters filters) {
    _currentAudioFilters = filters;
    _settingsProvider?.saveAudioFilters(filters);
    notifyListeners();
  }

  void setImageFilters(ImageFilters filters) {
    _currentImageFilters = filters;
    _settingsProvider?.saveImageFilters(filters);
    notifyListeners();
  }

  void clearSelectedFiles() {
    _selectedFiles.clear();
    notifyListeners();
  }

  void removeFile(String filePath) {
    _selectedFiles.remove(filePath);
    notifyListeners();
  }

  void resetAll() {
    _selectedFiles.clear();
    _selectedMediaType = MediaType.video;
    _currentVideoFilters = VideoFilters.maximumQualityDefaults();
    _currentAudioFilters = AudioFilters();
    _currentImageFilters = ImageFilters();
    notifyListeners();
  }
}

class HomeScreen extends StatefulWidget {
  final List<String>? initialFiles;
  
  const HomeScreen({super.key, this.initialFiles});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    if (widget.initialFiles != null && widget.initialFiles!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleInitialFiles().then((_) {
          if (mounted) {
            setState(() {});
          }
        });
      });
    }
  }
  
  Future<void> _handleInitialFiles() async {
    final conversionState = context.read<ConversionStateProvider>();
    final filesByType = <MediaType, List<String>>{};

    for (final filePath in widget.initialFiles!) {
      try {
        final file = File(filePath);
        if (file.existsSync()) {
          final extension = filePath.toLowerCase().split('.').last;
          final mediaType = _getMediaTypeFromExtensionStatic(extension);
          
          if (!filesByType.containsKey(mediaType)) {
            filesByType[mediaType] = <String>[];
          }
          filesByType[mediaType]!.add(filePath);
        }
      } catch (e) {
        appLog('Errore verifica file $filePath: $e');
      }
    }

    if (filesByType.isNotEmpty) {
      late final MediaType targetMediaType;
      if (filesByType.length == 1) {
        targetMediaType = filesByType.keys.first;
      } else {
        final firstFilePath = widget.initialFiles!.first;
        final firstExtension = firstFilePath.toLowerCase().split('.').last;
        targetMediaType = _getMediaTypeFromExtensionStatic(firstExtension);
      }

      conversionState.clearSelectedFiles();
      conversionState.setSelectedMediaType(targetMediaType);
      await Future.delayed(const Duration(milliseconds: 100));
      final validFiles = filesByType[targetMediaType] ?? [];

      if (validFiles.isNotEmpty) {
        conversionState.setSelectedFiles(validFiles);
        if (_tabController.index != 0) {
          _tabController.animateTo(0);
        }

        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.filesSelected(validFiles.length)),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else if (filesByType.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File di tipo diverso rilevati. Usato il tipo del primo file.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }
  
  static MediaType _getMediaTypeFromExtensionStatic(String extension) {
    const videoExtensions = ['mp4', 'avi', 'mkv', 'mov', 'wmv', 'flv', 'webm', 'm4v', '3gp', 'ts', 'mts', 'm2ts'];
    const audioExtensions = ['mp3', 'wav', 'aac', 'flac', 'ogg', 'm4a', 'wma', 'opus', 'aiff', 'au'];
    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'tiff', 'tif', 'ico', 'svg'];
    
    if (videoExtensions.contains(extension)) {
      return MediaType.video;
    } else if (audioExtensions.contains(extension)) {
      return MediaType.audio;
    } else if (imageExtensions.contains(extension)) {
      return MediaType.image;
    }
    
    return MediaType.video;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProxyProvider<SettingsProvider, ConversionStateProvider>(
          create: (_) => ConversionStateProvider(),
          update: (_, settingsProvider, previous) {
            final provider = previous ?? ConversionStateProvider();
            provider.setSettingsProvider(settingsProvider);
            return provider;
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return Scaffold(
            body: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(icon: const Icon(Icons.video_library), text: l10n.conversion),
                    Tab(icon: const Icon(Icons.playlist_play), text: l10n.queue),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      _ConversionTab(),
                      _QueueTab(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

}

class _ConversionTab extends StatefulWidget {
  const _ConversionTab();

  @override
  State<_ConversionTab> createState() => _ConversionTabState();
}

class _ConversionTabState extends State<_ConversionTab> {
  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.settings),
        content: const _SettingsDialogContent(),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  Future<void> _showAboutDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.information),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FE MEDIA CONVERTER', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('${l10n.version}: 2.0.2'),
            const SizedBox(height: 4),
            Text('Created by: Marco Di Giangiacomo', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 8),
            SelectableText(
              kAppRepositoryUrl,
              style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
            ),
            const SizedBox(height: 8),
            Text(l10n.professionalMediaConversion),
            const SizedBox(height: 16),
            Text(l10n.usesFfmpeg),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final uri = Uri.parse(kAppRepositoryUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: const Text('GitHub'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final conversionState = context.watch<ConversionStateProvider>();
    final l10n = AppLocalizations.of(context)!;
    
    return FileDropTarget(
      onFilesDropped: (filePaths) => _handleDroppedFiles(filePaths, conversionState),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 260,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MediaTypeSelector(
                  selectedType: conversionState.selectedMediaType,
                  onTypeChanged: (type) {
                    conversionState.setSelectedMediaType(type);
                    conversionState.clearSelectedFiles();
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.settings, size: 18),
                        label: Text(l10n.settings, style: const TextStyle(fontSize: 13)),
                        onPressed: () => _showSettingsDialog(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.info_outline, size: 18),
                        label: Text(l10n.information, style: const TextStyle(fontSize: 13)),
                        onPressed: () => _showAboutDialog(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.menu_book_outlined, size: 18),
                    label: Text(l10n.userGuideMenu, style: const TextStyle(fontSize: 13)),
                    onPressed: () {
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => const UserGuideScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFileSelectionPanel(conversionState, l10n),
                  const SizedBox(height: 20),
                  
                  FormatSelector(mediaType: conversionState.selectedMediaType),
                  const SizedBox(height: 16),
                  
                  if (conversionState.selectedMediaType == MediaType.video || conversionState.selectedMediaType == MediaType.audio)
                    QualitySettings(mediaType: conversionState.selectedMediaType),
                  if (conversionState.selectedMediaType == MediaType.video || conversionState.selectedMediaType == MediaType.audio)
                    const SizedBox(height: 16),
                  
                  if (conversionState.selectedMediaType == MediaType.video) ...[
                    VideoFiltersPanel(
                      filters: conversionState.currentVideoFilters,
                      onFiltersChanged: (newFilters) {
                        conversionState.setVideoFilters(newFilters);
                      },
                      inputFilePath: conversionState.selectedFiles.isNotEmpty ? conversionState.selectedFiles.first : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  if (conversionState.selectedMediaType == MediaType.video || conversionState.selectedMediaType == MediaType.audio) ...[
                    AudioFiltersPanel(
                      filters: conversionState.currentAudioFilters,
                      onFiltersChanged: (newFilters) {
                        conversionState.setAudioFilters(newFilters);
                      },
                      inputFilePath: conversionState.selectedFiles.isNotEmpty ? conversionState.selectedFiles.first : null,
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (conversionState.selectedMediaType == MediaType.image) ...[
                    ImageFiltersPanel(
                      filters: conversionState.currentImageFilters,
                      onFiltersChanged: (newFilters) {
                        conversionState.setImageFilters(newFilters);
                      },
                      inputFilePath: conversionState.selectedFiles.isNotEmpty ? conversionState.selectedFiles.first : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _handleDroppedFiles(List<String> filePaths, ConversionStateProvider conversionState) async {
    final l10n = AppLocalizations.of(context)!;
    
    final validFiles = <String>[];
    
    for (final filePath in filePaths) {
      try {
        final file = File(filePath);
        if (!await file.exists()) continue;
        
        final extension = filePath.toLowerCase().split('.').last;
        final fileMediaType = _getMediaTypeFromExtension(extension);
        
        // (i video MKV, MP4, ecc. possono essere convertiti in WAV/MP3)
        final isAccepted = fileMediaType == conversionState.selectedMediaType ||
            (conversionState.selectedMediaType == MediaType.audio &&
                _isVideoExtension(extension));
        
        if (isAccepted) {
          validFiles.add(filePath);
        }
      } catch (e) {
        appLog('Errore verifica file $filePath: $e');
      }
    }
    
    if (validFiles.isNotEmpty) {
      conversionState.addFiles(validFiles);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
                content: Text(l10n.filesSelected(conversionState.selectedFiles.length)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.dropFilesHere),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
  
  static const List<String> _videoExtensions = ['mp4', 'avi', 'mkv', 'mov', 'wmv', 'flv', 'webm', 'm4v', '3gp', 'ts', 'mts', 'm2ts'];
  static const List<String> _audioExtensions = ['mp3', 'wav', 'aac', 'flac', 'ogg', 'm4a', 'wma', 'opus', 'aiff', 'au'];
  static const List<String> _imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'tiff', 'tif', 'ico', 'svg'];

  bool _isVideoExtension(String extension) => _videoExtensions.contains(extension);

  MediaType _getMediaTypeFromExtension(String extension) {
    if (_videoExtensions.contains(extension)) {
      return MediaType.video;
    } else if (_audioExtensions.contains(extension)) {
      return MediaType.audio;
    } else if (_imageExtensions.contains(extension)) {
      return MediaType.image;
    }
    
    return MediaType.video;
  }

  Widget _buildFileSelectionPanel(ConversionStateProvider conversionState, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.selectMedia(_getMediaTypeName(conversionState.selectedMediaType, l10n)),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            if (conversionState.selectedFiles.isNotEmpty) ...[
              _buildSelectedFilesList(conversionState),
              const SizedBox(height: 16),
            ] else ...[
              _buildEmptyFileSelection(l10n, conversionState.selectedMediaType),
              const SizedBox(height: 16),
            ],
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickMediaFiles(conversionState),
                    icon: Icon(_getIconForMediaType(conversionState.selectedMediaType)),
                    label: Text('${l10n.browse} ${_getMediaTypeName(conversionState.selectedMediaType, l10n)}'),
                  ),
                ),
                const SizedBox(width: 8),
                if (conversionState.selectedFiles.isNotEmpty) ...[
                  ElevatedButton.icon(
                    onPressed: () => _addFilesToQueue(conversionState),
                    icon: const Icon(Icons.playlist_add),
                    label: Text(l10n.addToQueue),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => conversionState.clearSelectedFiles(),
                    icon: const Icon(Icons.clear),
                    tooltip: l10n.clearSelection,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickMediaFiles(ConversionStateProvider conversionState) async {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Apertura file browser...'),
              ],
            ),
          ),
        ),
      ),
    );
    
    try {
      FileType fileType;
      List<String>? allowedExtensions;
      switch (conversionState.selectedMediaType) {
        case MediaType.video:
          fileType = FileType.video;
          break;
        case MediaType.audio:
          fileType = FileType.custom;
          allowedExtensions = [..._videoExtensions, ..._audioExtensions];
          break;
        case MediaType.image:
          fileType = FileType.image;
          break;
      }

      if (kIsWeb) {
        throw Exception('File Picker non supportato su Web');
      }

      final result = await FilePicker.platform.pickFiles(
        type: fileType,
        allowedExtensions: allowedExtensions,
        allowMultiple: true,
        withData: false,
        withReadStream: false,
      );

      if (mounted) {
        Navigator.of(context).pop();
      }

      if (result != null && result.files.isNotEmpty) {
        await _processSelectedFiles(result.files, conversionState, l10n);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      
      appLog('Errore File Picker: $e');
    }
  }

  Future<void> _processSelectedFiles(List<PlatformFile> files, ConversionStateProvider conversionState, AppLocalizations l10n) async {
    final validFiles = <String>[];
    
    final fileChecks = files.map((file) async {
      if (file.path != null) {
        try {
          final fileObj = File(file.path!);
          if (await fileObj.exists()) {
            return file.path!;
          }
        } catch (e) {
          appLog('Errore verifica file ${file.path}: $e');
        }
      }
      return null;
    }).toList();
    
    final results = await Future.wait(fileChecks);
    validFiles.addAll(results.whereType<String>());

    if (validFiles.isNotEmpty) {
      conversionState.setSelectedFiles(validFiles);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
                content: Text(l10n.filesSelected(validFiles.length)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Nessun file valido selezionato'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _addFilesToQueue(ConversionStateProvider conversionState) async {
    final l10n = AppLocalizations.of(context)!;

    if (conversionState.selectedFiles.isEmpty) return;

    final conversionProvider = context.read<ConversionProvider>();
    final settingsProvider = context.read<SettingsProvider>();

    final filesCount = conversionState.selectedFiles.length;

    for (final filePath in conversionState.selectedFiles) {
      final outputPath = _getOutputPath(filePath, _getFormatForMediaType(settingsProvider, conversionState.selectedMediaType));

      final task = ConversionTask(
        inputPath: filePath,
        outputPath: outputPath,
        mediaType: conversionState.selectedMediaType,
        format: _getFormatForMediaType(settingsProvider, conversionState.selectedMediaType),
        videoQuality: settingsProvider.videoQuality,
        // per evitare mismatch in eventuali codepath legacy.
        audioQuality: settingsProvider.audioBitrate,
        audioBitrate: settingsProvider.audioBitrate,
        audioCodec: settingsProvider.defaultAudioCodec,
        videoCodec: settingsProvider.defaultVideoCodec,
        videoBitrate: settingsProvider.videoBitrate,
        videoBitrateMode: settingsProvider.videoBitrateMode,
        videoFilters: conversionState.currentVideoFilters,
        audioFilters: conversionState.currentAudioFilters,
        imageFilters: conversionState.currentImageFilters,
        extractAudioFromVideo: conversionState.selectedMediaType == MediaType.video && settingsProvider.extractAudioFromVideo,
      );

      conversionProvider.addToQueue(task);
    }
    
    conversionState.clearSelectedFiles();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.filesAddedToQueue(filesCount)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  String _getFormatForMediaType(SettingsProvider settings, MediaType mediaType) {
    if (mediaType == MediaType.video && settings.extractAudioFromVideo) {
      return settings.defaultAudioFormat;
    }
    
    switch (mediaType) {
      case MediaType.video:
        return settings.defaultVideoFormat;
      case MediaType.audio:
        return settings.defaultAudioFormat;
      case MediaType.image:
        return settings.defaultImageFormat;
    }
  }

  String _getOutputPath(String inputPath, String format) {
    final settingsProvider = context.read<SettingsProvider>();
    final pathWithoutExtension = inputPath.replaceAll(RegExp(r'\.[^\.]+$'), '');
    final fileName = '${pathWithoutExtension.split('/').last}_converted.$format';
    
    if (settingsProvider.outputFolder.isNotEmpty) {
      return '${settingsProvider.outputFolder}/$fileName';
    } else {
      final directory = inputPath.split('/').sublist(0, inputPath.split('/').length - 1).join('/');
      return '$directory/$fileName';
    }
  }

  Widget _buildEmptyFileSelection(AppLocalizations l10n, MediaType mediaType) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade50,
      ),
      child: Column(
        children: [
          Icon(
            _getIconForMediaType(mediaType),
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noFilesSelected,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.clickToBrowse(_getMediaTypeName(mediaType, l10n)),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedFilesList(ConversionStateProvider conversionState) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 150),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: conversionState.selectedFiles.length,
        itemBuilder: (context, index) {
          final filePath = conversionState.selectedFiles[index];
          final fileName = filePath.split('/').last;
          
          return ListTile(
            leading: Icon(_getIconForMediaType(conversionState.selectedMediaType)),
            title: Text(
              fileName,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              filePath,
              style: const TextStyle(fontSize: 10),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              onPressed: () {
                conversionState.removeFile(filePath);
              },
            ),
          );
        },
      ),
    );
  }

  String _getMediaTypeName(MediaType type, AppLocalizations l10n) {
    switch (type) {
      case MediaType.video:
        return l10n.videos;
      case MediaType.audio:
        return l10n.audios;
      case MediaType.image:
        return l10n.images;
    }
  }

  IconData _getIconForMediaType(MediaType type) {
    switch (type) {
      case MediaType.video:
        return Icons.video_file;
      case MediaType.audio:
        return Icons.audiotrack;
      case MediaType.image:
        return Icons.image;
    }
  }
}

class _QueueTab extends StatelessWidget {
  const _QueueTab();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: ConversionQueue(),
    );
  }
}

class _SettingsDialogContent extends StatefulWidget {
  const _SettingsDialogContent();

  @override
  State<_SettingsDialogContent> createState() => __SettingsDialogContentState();
}

class __SettingsDialogContentState extends State<_SettingsDialogContent> {
  void _showLanguageChangeDialog(BuildContext context, String newLanguage, SettingsProvider settingsProvider) {
    final l10n = AppLocalizations.of(context)!;
    final isItalian = Localizations.localeOf(context).languageCode == 'it';
    final newLanguageName = SettingsProvider.getLanguageName(newLanguage);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isItalian
                  ? 'La lingua sarà cambiata in: $newLanguageName'
                  : 'Language will be changed to: $newLanguageName',
            ),
            const SizedBox(height: 8),
            Text(
              isItalian
                  ? 'Riavvia l\'applicazione per applicare completamente le modifiche.'
                  : 'Restart the application to fully apply the changes.',
              style: TextStyle(
                color: Colors.orange[700],
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              settingsProvider.setLanguage(newLanguage);
              final languageProvider = context.read<LanguageProvider>();
              languageProvider.setLanguage(newLanguage);
              Navigator.of(context).pop();
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isItalian
                        ? 'Lingua cambiata. Riavvia l\'app per completare.'
                        : 'Language changed. Restart the app to complete.',
                  ),
                  duration: const Duration(seconds: 3),
                  action: SnackBarAction(
                    label: l10n.ok,
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    },
                  ),
                ),
              );
            },
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  String _getVideoCodecName(String codec) {
    switch (codec) {
      case 'libx264': return 'H.264 (AVC)';
      case 'libx265': return 'H.265 (HEVC)';
      case 'libvpx': return 'VP8';
      case 'libvpx-vp9': return 'VP9';
      case 'mpeg4': return 'MPEG-4';
      case 'libaom-av1': return 'AV1';
      default: return codec;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final l10n = AppLocalizations.of(context)!;
    
    return SizedBox(
      width: double.maxFinite,
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            trailing: DropdownButton<String>(
              value: settingsProvider.language,
              onChanged: (String? newValue) {
                if (newValue != null && newValue != settingsProvider.language) {
                  _showLanguageChangeDialog(context, newValue, settingsProvider);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: 'en',
                  child: Text('English'),
                ),
                DropdownMenuItem(
                  value: 'it',
                  child: Text('Italiano'),
                ),
                DropdownMenuItem(
                  value: 'fr',
                  child: Text('Français'),
                ),
                DropdownMenuItem(
                  value: 'de',
                  child: Text('Deutsch'),
                ),
                DropdownMenuItem(
                  value: 'es',
                  child: Text('Español'),
                ),
                DropdownMenuItem(
                  value: 'pt',
                  child: Text('Português'),
                ),
              ],
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.palette),
            title: Text(l10n.theme),
            trailing: DropdownButton<ThemeMode>(
              value: settingsProvider.themeMode,
              onChanged: (ThemeMode? newValue) {
                if (newValue != null) {
                  settingsProvider.setThemeMode(newValue);
                }
              },
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text(l10n.system),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(l10n.light),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text(l10n.dark),
                ),
              ],
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.folder),
            title: Text(l10n.outputFolder),
            subtitle: Text(settingsProvider.outputFolder.isEmpty ? 
              l10n.sameAsInput : settingsProvider.outputFolder),
            trailing: IconButton(
              icon: const Icon(Icons.folder_open),
              onPressed: () async {
                final String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
                if (selectedDirectory != null) {
                  settingsProvider.setOutputFolder(selectedDirectory);
                }
              },
            ),
          ),
          
          const ModelsManagerPanel(),

          Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.cpuThreads,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: settingsProvider.cpuThreads.toDouble(),
                          min: 0,
                          max: 16,
                          divisions: 16,
                          label: settingsProvider.cpuThreads == 0 
                              ? l10n.autoDetect 
                              : '${settingsProvider.cpuThreads} threads',
                          onChanged: (value) {
                            settingsProvider.setCpuThreads(value.toInt());
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        settingsProvider.cpuThreads == 0 
                            ? l10n.autoDetect 
                            : '${settingsProvider.cpuThreads}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Text(
                    '0 = ${l10n.autoDetect}. Threads CPU da utilizzare per la conversione',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),

          Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.concurrentConversions,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: settingsProvider.concurrentConversions.toDouble(),
                          min: 1,
                          max: 4,
                          divisions: 3,
                          label: '${settingsProvider.concurrentConversions} ${l10n.files.toLowerCase()}',
                          onChanged: (value) {
                            settingsProvider.setConcurrentConversions(value.toInt());
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${settingsProvider.concurrentConversions}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Text(
                    l10n.concurrentConversionsDesc,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),

          Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.gpuAcceleration,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: Text(l10n.useGpu),
                    subtitle: Text(l10n.gpuCompatibility),
                    value: settingsProvider.useGpu,
                    onChanged: (value) {
                      settingsProvider.setUseGpu(value);
                    },
                  ),
                  Text(
                    l10n.requiresCompatibleHardware,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),

          if (settingsProvider.useGpu) ...[
            Card(
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.gpuType,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: settingsProvider.gpuType,
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          settingsProvider.setGpuType(newValue);
                        }
                      },
                      items: [
                        DropdownMenuItem(
                          value: 'auto',
                          child: Text(l10n.autoDetection),
                        ),
                        const DropdownMenuItem(
                          value: 'nvidia',
                          child: Text('NVIDIA'),
                        ),
                        const DropdownMenuItem(
                          value: 'intel',
                          child: Text('Intel'),
                        ),
                        const DropdownMenuItem(
                          value: 'amd',
                          child: Text('AMD'),
                        ),
                      ],
                    ),
                    Text(
                      l10n.selectGpuType,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
          ],

          Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Formati Predefiniti',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  
                  ListTile(
                    title: Text('${l10n.video} ${l10n.formats.toLowerCase()}'),
                    trailing: DropdownButton<String>(
                      value: settingsProvider.defaultVideoFormat,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          settingsProvider.setDefaultVideoFormat(newValue);
                        }
                      },
                      items: MediaType.video.supportedFormats.map((format) {
                        return DropdownMenuItem(
                          value: format,
                          child: Text(format.toUpperCase()),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  ListTile(
                    title: Text('${l10n.audio} ${l10n.formats.toLowerCase()}'),
                    trailing: DropdownButton<String>(
                      value: settingsProvider.defaultAudioFormat,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          settingsProvider.setDefaultAudioFormat(newValue);
                        }
                      },
                      items: MediaType.audio.supportedFormats.map((format) {
                        return DropdownMenuItem(
                          value: format,
                          child: Text(format.toUpperCase()),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  ListTile(
                    title: Text('${l10n.image} ${l10n.formats.toLowerCase()}'),
                    trailing: DropdownButton<String>(
                      value: settingsProvider.defaultImageFormat,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          settingsProvider.setDefaultImageFormat(newValue);
                        }
                      },
                      items: MediaType.image.supportedFormats.map((format) {
                        return DropdownMenuItem(
                          value: format,
                          child: Text(format.toUpperCase()),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  ListTile(
                    title: Text(l10n.audioCodec),
                    subtitle: Text(l10n.audioCodecDesc),
                    trailing: DropdownButton<String>(
                      value: settingsProvider.defaultAudioCodec,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          settingsProvider.setDefaultAudioCodec(newValue);
                        }
                      },
                      items: MediaType.video.supportedAudioCodecs.map((codec) {
                        return DropdownMenuItem(
                          value: codec,
                          child: Text(codec.toUpperCase()),
                        );
                      }).toList(),
                    ),
                  ),

                  ListTile(
                    title: Text('Codec Video'),
                    subtitle: Text('Seleziona il codec video predefinito'),
                    trailing: DropdownButton<String>(
                      value: settingsProvider.defaultVideoCodec,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          settingsProvider.setDefaultVideoCodec(newValue);
                        }
                      },
                      items: MediaType.video.supportedVideoCodecs.map((codec) {
                        return DropdownMenuItem(
                          value: codec,
                          child: Text(_getVideoCodecName(codec)),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}