import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:video_converter_pro/models/image_filters.dart';
import 'package:video_converter_pro/l10n/app_localizations.dart';
import 'package:video_converter_pro/services/ffmpeg_service.dart';
import 'package:video_converter_pro/utils/app_log.dart';

class ImageFiltersPanel extends StatefulWidget {
  final ImageFilters filters;
  final ValueChanged<ImageFilters> onFiltersChanged;
  final String? inputFilePath;

  const ImageFiltersPanel({
    super.key,
    required this.filters,
    required this.onFiltersChanged,
    this.inputFilePath,
  });

  @override
  State<ImageFiltersPanel> createState() => _ImageFiltersPanelState();
}

class _ImageFiltersPanelState extends State<ImageFiltersPanel> {
  late ImageFilters _filters;
  bool _expanded = false;
  late TextEditingController _widthController;
  late TextEditingController _heightController;
  String? _originalResolution;
  bool _loadingResolution = false;
  final FFmpegService _ffmpegService = FFmpegService();

  @override
  void initState() {
    super.initState();
    _filters = widget.filters;
    _widthController = TextEditingController(
      text: _filters.customWidth > 0 ? _filters.customWidth.toString() : '',
    );
    _heightController = TextEditingController(
      text: _filters.customHeight > 0 ? _filters.customHeight.toString() : '',
    );
    if (widget.inputFilePath != null) {
      _loadImageResolution();
    }
  }

  @override
  void didUpdateWidget(ImageFiltersPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Ricarica la risoluzione se il file path è cambiato
    if (widget.inputFilePath != null && widget.inputFilePath != oldWidget.inputFilePath) {
      _loadImageResolution();
    }
  }

  Future<void> _loadImageResolution() async {
    if (widget.inputFilePath == null) {
      setState(() {
        _originalResolution = null;
        _loadingResolution = false;
      });
      return;
    }
    
    if (!File(widget.inputFilePath!).existsSync()) {
      setState(() {
        _originalResolution = null;
        _loadingResolution = false;
      });
      return;
    }
    
    setState(() {
      _loadingResolution = true;
      _originalResolution = null;
    });

    try {
      // Usa ffprobe per ottenere le informazioni dell'immagine
      final process = await Process.run('ffprobe', [
        '-v', 'error',
        '-select_streams', 'v:0',
        '-show_entries', 'stream=width,height',
        '-of', 'json',
        widget.inputFilePath!,
      ]);

      if (process.exitCode == 0 && mounted) {
        final output = process.stdout.toString();
        try {
          final Map<String, dynamic> info = json.decode(output);
          final streams = info['streams'] as List<dynamic>?;
          if (streams != null && streams.isNotEmpty) {
            final stream = streams.first;
            final width = stream['width'] as int? ?? 0;
            final height = stream['height'] as int? ?? 0;
            if (width > 0 && height > 0 && mounted) {
              setState(() {
                _originalResolution = '${width}×${height}';
                _loadingResolution = false;
              });
              appLog('✅ Risoluzione caricata: $_originalResolution');
              return;
            }
          }
        } catch (e) {
          appLog('❌ Errore parsing JSON: $e');
        }
      } else {
        appLog('❌ ffprobe fallito: ${process.stderr}');
      }
    } catch (e) {
      if (mounted) {
        appLog('❌ Errore nel caricamento risoluzione: $e');
      }
    }
    
    if (mounted) {
      setState(() {
        _loadingResolution = false;
        if (_originalResolution == null) {
          appLog('⚠️ Risoluzione non trovata per: ${widget.inputFilePath}');
        }
      });
    }
  }

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _updateFilters(ImageFilters newFilters) {
    if (!mounted) return;
    setState(() {
      _filters = newFilters;
      // Aggiorna i controller quando i filtri cambiano
      if (_widthController.text != (newFilters.customWidth > 0 ? newFilters.customWidth.toString() : '')) {
        _widthController.text = newFilters.customWidth > 0 ? newFilters.customWidth.toString() : '';
      }
      if (_heightController.text != (newFilters.customHeight > 0 ? newFilters.customHeight.toString() : '')) {
        _heightController.text = newFilters.customHeight > 0 ? newFilters.customHeight.toString() : '';
      }
    });
    widget.onFiltersChanged(newFilters);
  }

  void _resetFilters() {
    final newFilters = ImageFilters();
    _updateFilters(newFilters);
  }

  void _toggleExpanded() {
    if (!mounted) return;
    setState(() {
      _expanded = !_expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.photo, color: Colors.orange),
              title: Text(
                l10n.imageFiltersTitle,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              trailing: IconButton(
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                onPressed: _toggleExpanded,
              ),
              onTap: _toggleExpanded,
            ),
            
            // RISOLUZIONE PERSONALIZZATA (prima voce, fuori dai filtri)
            _buildFilterSection(
              title: l10n.customResolution,
              icon: Icons.aspect_ratio,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 18, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _loadingResolution 
                            ? l10n.loadingResolution
                            : _originalResolution != null
                              ? '${l10n.originalResolution}: $_originalResolution'
                              : widget.inputFilePath != null
                                ? l10n.resolutionNotAvailable
                                : l10n.selectImageForResolution,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _originalResolution != null 
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                SwitchListTile(
                  title: Text(l10n.useCustomResolution),
                  subtitle: Text(l10n.customResolutionDesc),
                  value: _filters.useCustomResolution,
                  onChanged: (value) => _updateFilters(_filters.copyWith(useCustomResolution: value)),
                ),
                if (_filters.useCustomResolution) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: l10n.customWidth,
                            hintText: '1920',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          controller: _widthController,
                          onChanged: (value) {
                            final width = int.tryParse(value) ?? 0;
                            _updateFilters(_filters.copyWith(customWidth: width));
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text('×', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: l10n.customHeight,
                            hintText: '1080',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          controller: _heightController,
                          onChanged: (value) {
                            final height = int.tryParse(value) ?? 0;
                            _updateFilters(_filters.copyWith(customHeight: height));
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.resolutionDescription,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 16),

            // ANTEPRIMA IMMAGINI (fuori dai filtri)
            if (widget.inputFilePath != null)
              _buildFilterSection(
                title: l10n.previewDescription,
                icon: Icons.preview,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showImagePreview(widget.inputFilePath!, false),
                          icon: const Icon(Icons.image),
                          label: Text(l10n.previewOriginal),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showImagePreview(widget.inputFilePath!, true),
                          icon: const Icon(Icons.auto_fix_high),
                          label: Text(l10n.previewModified),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.previewDescription,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 16),
            
            if (_expanded) ...[
              if (_filters.hasActiveFilters)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        l10n.filtersActive,
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _resetFilters,
                        child: Text(l10n.resetAll),
                      ),
                    ],
                  ),
                ),

              // RIDUZIONE RUMORE
              _buildFilterSection(
                title: l10n.noiseReduction,
                icon: Icons.clean_hands,
                children: [
                    _buildSlider(
                      label: l10n.noiseReductionStrength,
                    value: _filters.denoiseStrength,
                    min: 0,
                    max: 1.0,
                    divisions: 10,
                    onChanged: (value) => _updateFilters(_filters.copyWith(denoiseStrength: value)),
                    valueLabel: '${(_filters.denoiseStrength * 100).toInt()}%',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.reducesDigitalNoise,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _buildFilterSection(
                title: l10n.qualityEnhancementLabel,
                icon: Icons.hd,
                children: [
                  _buildSlider(
                    label: l10n.sharpness,
                    value: _filters.sharpness,
                    min: 0,
                    max: 2.0,
                    divisions: 20,
                    onChanged: (value) => _updateFilters(_filters.copyWith(sharpness: value)),
                    valueLabel: _filters.sharpness.toStringAsFixed(1),
                  ),
                  _buildSlider(
                    label: l10n.brightness,
                    value: _filters.brightness,
                    min: -1.0,
                    max: 1.0,
                    divisions: 20,
                    onChanged: (value) => _updateFilters(_filters.copyWith(brightness: value)),
                    valueLabel: _filters.brightness.toStringAsFixed(1),
                  ),
                  _buildSlider(
                    label: l10n.contrast,
                    value: _filters.contrast,
                    min: 0,
                    max: 2.0,
                    divisions: 20,
                    onChanged: (value) => _updateFilters(_filters.copyWith(contrast: value)),
                    valueLabel: _filters.contrast.toStringAsFixed(1),
                  ),
                  _buildSlider(
                    label: l10n.saturation,
                    value: _filters.saturation,
                    min: 0,
                    max: 3.0,
                    divisions: 30,
                    onChanged: (value) => _updateFilters(_filters.copyWith(saturation: value)),
                    valueLabel: _filters.saturation.toStringAsFixed(1),
                  ),
                  _buildSlider(
                    label: l10n.gamma,
                    value: _filters.gamma,
                    min: 0.1,
                    max: 3.0,
                    divisions: 29,
                    onChanged: (value) => _updateFilters(_filters.copyWith(gamma: value)),
                    valueLabel: _filters.gamma.toStringAsFixed(1),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _buildFilterSection(
                title: l10n.imageUpscaling,
                icon: Icons.zoom_in,
                children: [
                  SwitchListTile(
                    title: Text(l10n.enableImageUpscaling),
                    subtitle: Text(l10n.enableImageUpscalingDesc),
                    value: _filters.enableUpscaling,
                    onChanged: (value) => _updateFilters(_filters.copyWith(enableUpscaling: value)),
                  ),
                  if (_filters.enableUpscaling && !_filters.useCustomResolution) ...[
                    _buildSlider(
                      label: l10n.upscalingFactor,
                      value: _filters.upscaleFactor,
                      min: 1.0,
                      max: 4.0,
                      divisions: 6,
                      onChanged: (value) => _updateFilters(_filters.copyWith(upscaleFactor: value)),
                      valueLabel: '${_filters.upscaleFactor}x',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.advancedUpscalingAlgorithms,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ] else if (_filters.enableUpscaling && _filters.useCustomResolution) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.upscalingDisabledWithCustom,
                      style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 16),

              _buildFilterSection(
                title: l10n.imageColorProfiles,
                icon: Icons.palette,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _ColorProfileChip(
                        label: 'Nessuno',
                        isSelected: _filters.colorProfile == 'none',
                        onSelected: () => _updateFilters(_filters.copyWith(colorProfile: 'none')),
                        color: Colors.grey,
                      ),
                      _ColorProfileChip(
                        label: 'Vivace',
                        isSelected: _filters.colorProfile == 'vivid',
                        onSelected: () => _updateFilters(_filters.copyWith(colorProfile: 'vivid')),
                        color: Colors.red,
                      ),
                      _ColorProfileChip(
                        label: 'Cinematografico',
                        isSelected: _filters.colorProfile == 'cinematic',
                        onSelected: () => _updateFilters(_filters.copyWith(colorProfile: 'cinematic')),
                        color: Colors.amber,
                      ),
                      _ColorProfileChip(
                        label: 'Bianco e Nero',
                        isSelected: _filters.colorProfile == 'bw',
                        onSelected: () => _updateFilters(_filters.copyWith(colorProfile: 'bw')),
                        color: Colors.grey,
                      ),
                      _ColorProfileChip(
                        label: 'Seppia',
                        isSelected: _filters.colorProfile == 'sepia',
                        onSelected: () => _updateFilters(_filters.copyWith(colorProfile: 'sepia')),
                        color: Colors.brown,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ANTEPRIMA EFFETTI
              _buildEffectPreview(),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showImagePreview(String imagePath, bool withFilters) async {
    final l10n = AppLocalizations.of(context)!;
    if (!File(imagePath).existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.error)),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _ImagePreviewDialog(
        imagePath: imagePath,
        filters: withFilters ? _filters : null,
        ffmpegService: _ffmpegService,
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required String valueLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label),
            const Spacer(),
            Text(
              valueLabel,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildEffectPreview() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.activeEffectsPreview,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            if (!_filters.hasActiveFilters)
              Text(
                l10n.noActiveFilters,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            if (_filters.denoiseStrength > 0)
              _buildEffectItem('${l10n.noiseReduction}: ${(_filters.denoiseStrength * 100).toInt()}%'),
            if (_filters.sharpness != 1.0)
              _buildEffectItem('${l10n.sharpness}: ${_filters.sharpness.toStringAsFixed(1)}'),
            if (_filters.brightness != 0.0)
              _buildEffectItem('${l10n.brightness}: ${_filters.brightness.toStringAsFixed(1)}'),
            if (_filters.contrast != 1.0)
              _buildEffectItem('${l10n.contrast}: ${_filters.contrast.toStringAsFixed(1)}'),
            if (_filters.saturation != 1.0)
              _buildEffectItem('${l10n.saturation}: ${_filters.saturation.toStringAsFixed(1)}'),
            if (_filters.gamma != 1.0)
              _buildEffectItem('${l10n.gamma}: ${_filters.gamma.toStringAsFixed(1)}'),
            if (_filters.enableUpscaling)
              _buildEffectItem(
                _filters.useCustomResolution && (_filters.customWidth > 0 || _filters.customHeight > 0)
                    ? '${l10n.customResolution}: ${_filters.customWidth > 0 ? _filters.customWidth : "auto"}×${_filters.customHeight > 0 ? _filters.customHeight : "auto"}'
                    : '${l10n.imageUpscaling}: ${_filters.upscaleFactor}x'
              ),
            if (_filters.colorProfile != 'none')
              _buildEffectItem('${l10n.colorProfiles}: ${_getColorProfileName(_filters.colorProfile)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildEffectItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(Icons.check, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  String _getColorProfileName(String profile) {
    switch (profile) {
      case 'none':
        return 'Nessuno';
      case 'vivid':
        return 'Vivace';
      case 'cinematic':
        return 'Cinematografico';
      case 'bw':
        return 'Bianco e Nero';
      case 'sepia':
        return 'Seppia';
      default:
        return profile;
    }
  }
}

class _ColorProfileChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;
  final Color color;

  const _ColorProfileChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
      selectedColor: color.withOpacity(isDark ? 0.3 : 0.2),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isSelected 
            ? color 
            : (isDark ? Colors.white : Colors.black87),
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _ImagePreviewDialog extends StatefulWidget {
  final String imagePath;
  final ImageFilters? filters;
  final FFmpegService ffmpegService;

  const _ImagePreviewDialog({
    required this.imagePath,
    this.filters,
    required this.ffmpegService,
  });

  @override
  State<_ImagePreviewDialog> createState() => _ImagePreviewDialogState();
}

class _ImagePreviewDialogState extends State<_ImagePreviewDialog> {
  String? _previewPath;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadPreview();
  }

  Future<void> _loadPreview() async {
    if (widget.filters == null) {
      // Mostra immagine originale
      setState(() {
        _previewPath = widget.imagePath;
        _loading = false;
      });
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      // Genera un file temporaneo per l'anteprima
      final tempDir = Directory.systemTemp;
      final previewFile = File('${tempDir.path}/preview_${DateTime.now().millisecondsSinceEpoch}.jpg');
      
      // Crea un comando FFmpeg per applicare i filtri (stesso ordine della conversione)
      final filtersList = <String>[];
      
      // STEP 1: RISOLUZIONE PERSONALIZZATA O UPSCALING
      if (widget.filters!.useCustomResolution && 
          (widget.filters!.customWidth > 0 || widget.filters!.customHeight > 0)) {
        // Risoluzione personalizzata
        final infoResult = await widget.ffmpegService.getVideoInfo(widget.imagePath);
        if (infoResult['success'] == true) {
          final mediaInfo = infoResult['info'];
          final streams = mediaInfo['streams'] as List<dynamic>?;
          if (streams != null && streams.isNotEmpty) {
            final videoStream = streams.firstWhere(
              (stream) => stream['codec_type'] == 'video' || stream['codec_type'] == null,
              orElse: () => null,
            );
            if (videoStream != null) {
              final originalWidth = videoStream['width'] as int? ?? 0;
              final originalHeight = videoStream['height'] as int? ?? 0;
              if (originalWidth > 0 && originalHeight > 0) {
                int targetWidth = widget.filters!.customWidth;
                int targetHeight = widget.filters!.customHeight;
                
                if (targetWidth > 0 && targetHeight == 0) {
                  final aspectRatio = originalHeight / originalWidth;
                  targetHeight = (targetWidth * aspectRatio).round();
                  targetHeight = targetHeight.isEven ? targetHeight : targetHeight + 1;
                } else if (targetWidth == 0 && targetHeight > 0) {
                  final aspectRatio = originalWidth / originalHeight;
                  targetWidth = (targetHeight * aspectRatio).round();
                  targetWidth = targetWidth.isEven ? targetWidth : targetWidth + 1;
                } else if (targetWidth > 0 && targetHeight > 0) {
                  targetWidth = targetWidth.isEven ? targetWidth : targetWidth + 1;
                  targetHeight = targetHeight.isEven ? targetHeight : targetHeight + 1;
                }
                
                if (targetWidth > 0 && targetHeight > 0) {
                  filtersList.add('scale=$targetWidth:$targetHeight:flags=lanczos');
                }
              }
            }
          }
        }
      } else if (widget.filters!.enableUpscaling && widget.filters!.upscaleFactor > 1.0) {
        // Upscaling con FFmpeg per l'anteprima
        filtersList.add('scale=iw*${widget.filters!.upscaleFactor}:ih*${widget.filters!.upscaleFactor}:flags=lanczos');
      }

      // STEP 2: DENOISE (prima degli altri filtri colore)
      if (widget.filters!.denoiseStrength > 0.0) {
        final strength = (widget.filters!.denoiseStrength * 5.0).clamp(0.0, 5.0);
        filtersList.add('hqdn3d=${strength.toStringAsFixed(2)}:${strength.toStringAsFixed(2)}:${(strength * 0.8).toStringAsFixed(2)}:${(strength * 0.8).toStringAsFixed(2)}');
      }

      // STEP 3: BRIGHTNESS, CONTRAST, SATURATION (prima del color profile)
      if (widget.filters!.brightness != 0.0 || 
          widget.filters!.contrast != 1.0 || 
          widget.filters!.saturation != 1.0) {
        final brightnessStr = widget.filters!.brightness.toStringAsFixed(2);
        final contrastStr = widget.filters!.contrast.toStringAsFixed(2);
        final saturationStr = widget.filters!.saturation.toStringAsFixed(2);
        filtersList.add('eq=brightness=$brightnessStr:contrast=$contrastStr:saturation=$saturationStr');
      }

      // STEP 4: GAMMA
      if (widget.filters!.gamma != 1.0) {
        filtersList.add('eq=gamma=${widget.filters!.gamma.toStringAsFixed(2)}');
      }

      // STEP 5: SHARPNESS
      if (widget.filters!.sharpness != 1.0) {
        final strength = ((widget.filters!.sharpness - 1.0) * 0.5).clamp(-0.5, 0.5);
        filtersList.add('unsharp=5:5:${strength.toStringAsFixed(2)}:5:5:${strength.toStringAsFixed(2)}');
      }

      // STEP 6: COLOR PROFILE (applicato per ultimo, dopo tutti gli altri filtri colore)
      if (widget.filters!.colorProfile != 'none') {
        switch (widget.filters!.colorProfile) {
          case 'vivid':
            filtersList.add('eq=saturation=1.3:gamma=1.1');
            break;
          case 'cinematic':
            filtersList.add('eq=contrast=1.1:gamma=0.9:saturation=0.9');
            break;
          case 'bw':
            // Converti in scala di grigi usando colorchannelmixer (più affidabile)
            filtersList.add('colorchannelmixer=.299:.587:.114:0:.299:.587:.114:0:.299:.587:.114');
            break;
          case 'sepia':
            filtersList.add('colorchannelmixer=.393:.769:.189:0:.349:.686:.168:0:.272:.534:.131');
            break;
        }
      }

      // Costruisci il comando FFmpeg (SENZA 'ffmpeg' nella lista, è già il comando)
      final command = <String>[
        '-y',
        '-i', widget.imagePath,
      ];
      
      // Aggiungi filtri se presenti
      if (filtersList.isNotEmpty) {
        command.addAll(['-vf', filtersList.join(',')]);
        appLog('🔍 [Preview] Applicando ${filtersList.length} filtri: ${filtersList.join(", ")}');
      } else {
        appLog('⚠️ [Preview] Nessun filtro da applicare');
      }
      
      command.addAll([
        '-frames:v', '1',
        '-qscale:v', '2',
        previewFile.path,
      ]);

      appLog('📋 [Preview] Comando FFmpeg: ffmpeg ${command.join(" ")}');
      appLog('📁 [Preview] Input: ${widget.imagePath}');
      appLog('📁 [Preview] Output: ${previewFile.path}');

      final process = await Process.run('ffmpeg', command);
      
      appLog('📊 [Preview] Exit code: ${process.exitCode}');
      if (process.stdout.toString().isNotEmpty) {
        appLog('📤 [Preview] Stdout: ${process.stdout}');
      }
      if (process.stderr.toString().isNotEmpty) {
        appLog('⚠️ [Preview] Stderr: ${process.stderr}');
      }
      
      // Verifica che il file sia stato creato
      if (previewFile.existsSync()) {
        final fileSize = await previewFile.length();
        appLog('✅ [Preview] File creato: ${previewFile.path} (${fileSize} bytes)');
        
        if (mounted) {
          setState(() {
            _previewPath = previewFile.path;
            _loading = false;
          });
        }
      } else if (process.exitCode == 0) {
        // FFmpeg ha successo ma il file non esiste - potrebbe essere un problema di percorso
        appLog('❌ [Preview] FFmpeg ha successo ma il file non esiste!');
        if (mounted) {
          setState(() {
            _previewPath = widget.imagePath;
            _loading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Errore: file anteprima non creato')),
          );
        }
      } else {
        // FFmpeg ha fallito
        appLog('❌ [Preview] FFmpeg fallito con exit code ${process.exitCode}');
        if (mounted) {
          setState(() {
            _previewPath = widget.imagePath;
            _loading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Errore generazione anteprima: ${process.stderr.toString().substring(0, process.stderr.toString().length > 100 ? 100 : process.stderr.toString().length)}')),
          );
        }
      }
    } catch (e, stackTrace) {
      appLog('❌ [Preview] Errore generazione anteprima: $e');
      appLog('📚 [Preview] Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _previewPath = widget.imagePath;
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  widget.filters == null 
                      ? AppLocalizations.of(context)!.previewOriginal 
                      : AppLocalizations.of(context)!.previewModified,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: _loading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Generazione anteprima...'),
                      ],
                    ),
                  )
                : _previewPath != null
                    ? Center(
                        child: InteractiveViewer(
                          minScale: 0.5,
                          maxScale: 4.0,
                          child: Image.file(
                            File(_previewPath!),
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              appLog('❌ [Preview] Errore caricamento immagine: $error');
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.error, size: 48, color: Colors.red),
                                    const SizedBox(height: 16),
                                    Text('Errore caricamento immagine: $error'),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('Chiudi'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    : const Center(
                        child: Text('Nessuna anteprima disponibile'),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Pulisci file temporaneo se creato
    if (_previewPath != null && 
        _previewPath != widget.imagePath && 
        File(_previewPath!).existsSync()) {
      try {
        File(_previewPath!).deleteSync();
      } catch (e) {
        appLog('Errore eliminazione file temporaneo: $e');
      }
    }
    super.dispose();
  }
}