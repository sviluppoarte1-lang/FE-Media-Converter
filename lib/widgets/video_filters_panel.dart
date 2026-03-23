import 'package:flutter/material.dart';
import 'package:video_converter_pro/models/video_filters.dart';
import 'package:video_converter_pro/l10n/app_localizations.dart';
import 'package:video_converter_pro/services/video_pre_processor.dart';

class VideoFiltersPanel extends StatefulWidget {
  final VideoFilters filters;
  final ValueChanged<VideoFilters> onFiltersChanged;
  final String? inputFilePath;

  const VideoFiltersPanel({
    super.key,
    required this.filters,
    required this.onFiltersChanged,
    this.inputFilePath,
  });

  @override
  State<VideoFiltersPanel> createState() => _VideoFiltersPanelState();
}

class _VideoFiltersPanelState extends State<VideoFiltersPanel> {
  late VideoFilters _filters;
  bool _expanded = true;
  Map<String, dynamic>? _qualityAnalysis;
  bool _isAnalyzingQuality = false;
  List<String> _detectedIssues = [];
  List<String> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _filters = widget.filters;
    if (widget.inputFilePath != null) {
      _analyzeVideoQuality();
    }
  }

  Future<void> _analyzeVideoQuality() async {
    if (widget.inputFilePath == null) return;
    if (!mounted) return;
    
    setState(() {
      _isAnalyzingQuality = true;
      _detectedIssues = [];
      _recommendations = [];
    });

    try {
      final analysis = await VideoPreProcessor.analyzeVideoQuality(widget.inputFilePath!);
      if (mounted) {
        setState(() {
          _qualityAnalysis = analysis;
          _isAnalyzingQuality = false;
          
          if (analysis['success'] == true) {
            _detectedIssues = List<String>.from(analysis['quality_issues'] ?? []);
            _recommendations = List<String>.from(analysis['recommendations'] ?? []);
            
            // Applica ottimizzazioni automatiche basate sull'analisi
            _applyAnalysisOptimizations(analysis);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzingQuality = false;
        });
      }
    }
  }

  void _applyAnalysisOptimizations(Map<String, dynamic> analysis) {
    if (analysis['auto_preset'] != null) {
      final autoPreset = VideoFilters.fromMap(analysis['auto_preset']);

      // Migliora l'analisi: NON toccare luminosità/luce per evitare che i video
      // già ben esposti vengano scuriti.
      //
      // Manteniamo:
      // - brightness
      // - gamma
      // - colorProfile
      // - saturation
      //
      // e applichiamo solo ottimizzazioni su denoise / dettagli / artefatti.
      final mergedPreset = autoPreset.copyWith(
        brightness: _filters.brightness,
        gamma: _filters.gamma,
        colorProfile: _filters.colorProfile,
        saturation: _filters.saturation,
      );

      _updateFilters(mergedPreset);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Applicate ottimizzazioni automatiche basate sull\'analisi del video'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _updateFilters(VideoFilters newFilters) {
    if (!mounted) return;
    setState(() {
      _filters = newFilters;
    });
    widget.onFiltersChanged(newFilters);
  }

  void _resetFilters() {
    _updateFilters(VideoFilters.maximumQualityDefaults());
  }

  void _toggleExpanded() {
    if (!mounted) return;
    setState(() {
      _expanded = !_expanded;
    });
  }

  void _applyOptimization(String optimizationType) {
    VideoFilters newFilters;
    
    switch (optimizationType) {
      case 'auto_optimize':
        if (_qualityAnalysis != null && _qualityAnalysis!['auto_preset'] != null) {
          newFilters = VideoFilters.fromMap(_qualityAnalysis!['auto_preset']);
        } else {
          newFilters = VideoFilters.getProfessionalEnhancement();
        }
        break;
      case 'low_quality':
        newFilters = VideoFilters.getLowQualityOptimization();
        break;
      case 'low_light':
        newFilters = VideoFilters.getLowLightEnhancement();
        break;
      case 'compression_fix':
        newFilters = VideoFilters.getCompressionArtifactRemoval();
        break;
      case 'detail_recovery':
        newFilters = VideoFilters.getDetailRecoveryPreset();
        break;
      case 'film_restoration':
        newFilters = VideoFilters.getFilmRestoration();
        break;
      case 'ultra_quality':
        newFilters = VideoFilters.getUltraQualityPreset();
        break;
      default:
        newFilters = VideoFilters.maximumQualityDefaults();
    }
    
    _updateFilters(newFilters);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // HEADER CON ANALISI
            ListTile(
              leading: const Icon(Icons.photo_filter, color: Colors.blue),
              title: Text(
                l10n.videoFilters,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: _buildAnalysisSubtitle(),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_filters.hasActiveFilters)
                    TextButton(
                      onPressed: _resetFilters,
                      child: Text(l10n.resetAll),
                    ),
                  IconButton(
                    icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                    onPressed: _toggleExpanded,
                  ),
                ],
              ),
              onTap: _toggleExpanded,
            ),
            
            if (_expanded) ...[
              const Divider(),
              // Analisi e ottimizzazioni (sempre visibili in cima)
              _buildAnalysisSection(),
              const SizedBox(height: 8),
              _buildAutoOptimizationSection(),
              const SizedBox(height: 12),
              // Menu a tendina: Qualità e regolazioni video (filtri base + qualità + colore)
              _buildCollapsibleSection(
                title: l10n.qualityAndDetails,
                icon: Icons.hd,
                initiallyExpanded: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBasicFiltersSection(l10n),
                    _buildQualitySection(l10n),
                    _buildColorSection(l10n),
                  ],
                ),
              ),
              // Menu a tendina: Advanced corrections
              _buildCollapsibleSection(
                title: l10n.advancedCorrections,
                icon: Icons.auto_awesome,
                initiallyExpanded: false,
                child: _buildAdvancedCorrectionsContent(l10n),
              ),
              // Menu a tendina: GPU Acceleration + preset
              _buildCollapsibleSection(
                title: l10n.gpuAccelerationLabel,
                icon: Icons.memory,
                initiallyExpanded: false,
                child: _buildGpuAccelerationContent(l10n),
              ),
              // Menu a tendina: Color Profiles
              _buildCollapsibleSection(
                title: l10n.colorProfiles,
                icon: Icons.palette,
                initiallyExpanded: false,
                child: _buildColorProfilesContent(l10n),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Sezione con menu a tendina (ExpansionTile)
  Widget _buildCollapsibleSection({
    required String title,
    required IconData icon,
    required Widget child,
    bool initiallyExpanded = false,
  }) {
    return ExpansionTile(
      initiallyExpanded: initiallyExpanded,
      leading: Icon(icon, size: 22, color: Colors.blue),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 12),
          child: child,
        ),
      ],
    );
  }

  Widget _buildAnalysisSubtitle() {
    if (_isAnalyzingQuality) {
      return const Text('Analisi qualità video in corso...');
    } else if (_detectedIssues.isNotEmpty) {
      final l10n = AppLocalizations.of(context)!;
      return Text(l10n.problemsDetectedRecommendations(_detectedIssues.length, _recommendations.length));
    } else if (_qualityAnalysis != null) {
      final l10n = AppLocalizations.of(context)!;
      return Text(l10n.videoAnalyzedNoIssues);
    } else {
      final l10n = AppLocalizations.of(context)!;
      return Text(l10n.selectVideoForAnalysis);
    }
  }

  Widget _buildAnalysisSection() {
    final l10n = AppLocalizations.of(context)!;
    return _buildFilterSection(
      title: l10n.intelligentVideoAnalysis,
      icon: Icons.analytics,
      children: [
        if (_isAnalyzingQuality)
          Center(
            child: Column(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 8),
                Text(l10n.analyzingVideoQuality),
              ],
            ),
          )
        else if (_qualityAnalysis != null && _qualityAnalysis!['success'] == true)
          _buildAnalysisResults(l10n)
        else
          OutlinedButton(
            onPressed: _analyzeVideoQuality,
            child: Text(l10n.analyzeVideoQuality),
          ),
      ],
    );
  }

  Widget _buildAnalysisResults(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_detectedIssues.isNotEmpty) ...[
          const Text(
            'Problemi Rilevati:',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _detectedIssues.map((issue) => Chip(
              label: Text(issue),
              backgroundColor: Colors.red.shade100,
              labelStyle: const TextStyle(fontSize: 12, color: Colors.red),
            )).toList(),
          ),
          const SizedBox(height: 12),
        ] else ...[
          const Text(
            '✅ Nessun problema critico rilevato',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 8),
        ],
        
        if (_recommendations.isNotEmpty) ...[
          const Text(
            'Raccomandazioni:',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          ..._recommendations.map((rec) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.blue.shade600, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(rec, style: const TextStyle(fontSize: 12))),
              ],
            ),
          )).toList(),
        ],

        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: _analyzeVideoQuality,
          child: Text(l10n.analyzeVideoQuality),
        ),
      ],
    );
  }

  Widget _buildAutoOptimizationSection() {
    final l10n = AppLocalizations.of(context)!;
    return _buildFilterSection(
      title: l10n.automaticOptimizations,
      icon: Icons.auto_awesome,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _OptimizationChip(
              label: l10n.autoOptimization,
              description: l10n.autoOptimizationDesc,
              onSelected: () => _applyOptimization('auto_optimize'),
              color: Colors.green,
            ),
            _OptimizationChip(
              label: l10n.lowQuality,
              description: l10n.lowQualityDesc,
              onSelected: () => _applyOptimization('low_quality'),
              color: Colors.red,
            ),
            _OptimizationChip(
              label: l10n.ultraQuality,
              description: l10n.ultraQualityDesc,
              onSelected: () => _applyOptimization('ultra_quality'),
              color: Colors.deepPurple,
            ),
            _OptimizationChip(
              label: l10n.lowLight,
              description: l10n.lowLightDesc,
              onSelected: () => _applyOptimization('low_light'),
              color: Colors.orange,
            ),
            _OptimizationChip(
              label: l10n.detailRecovery,
              description: l10n.detailRecoveryDesc,
              onSelected: () => _applyOptimization('detail_recovery'),
              color: Colors.blue,
            ),
            _OptimizationChip(
              label: l10n.compressionFix,
              description: l10n.compressionFixDesc,
              onSelected: () => _applyOptimization('compression_fix'),
              color: Colors.purple,
            ),
            _OptimizationChip(
              label: l10n.filmRestoration,
              description: l10n.filmRestorationDesc,
              onSelected: () => _applyOptimization('film_restoration'),
              color: Colors.brown,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBasicFiltersSection(AppLocalizations l10n) {
    return _buildFilterSection(
      title: l10n.fundamentalFilters,
      icon: Icons.tune,
      children: [
        _buildSlider(
          label: l10n.brightness,
          value: _filters.brightness,
          min: -1.0,
          max: 1.0,
          divisions: 40,
          onChanged: (value) => _updateFilters(_filters.copyWith(brightness: value)),
          valueLabel: _filters.brightness.toStringAsFixed(2),
        ),
        _buildSlider(
          label: l10n.contrast,
          value: _filters.contrast,
          min: 0.0,
          max: 3.0,
          divisions: 30,
          onChanged: (value) => _updateFilters(_filters.copyWith(contrast: value)),
          valueLabel: _filters.contrast.toStringAsFixed(2),
        ),
        _buildSlider(
          label: l10n.saturation,
          value: _filters.saturation,
          min: 0.0,
          max: 3.0,
          divisions: 30,
          onChanged: (value) => _updateFilters(_filters.copyWith(saturation: value)),
          valueLabel: _filters.saturation.toStringAsFixed(2),
        ),
      ],
    );
  }

  Widget _buildQualitySection(AppLocalizations l10n) {
    return _buildFilterSection(
      title: l10n.qualityAndDetails,
      icon: Icons.hd,
      children: [
        _buildSlider(
          label: l10n.sharpness,
          value: _filters.sharpness,
          min: 0.0,
          max: 2.0,
          divisions: 20,
          onChanged: (value) => _updateFilters(_filters.copyWith(sharpness: value)),
          valueLabel: _filters.sharpness.toStringAsFixed(2),
        ),
        _buildSlider(
          label: l10n.noiseReductionLabel,
          value: _filters.denoiseStrength,
          min: 0.0,
          max: 1.0,
          divisions: 10,
          onChanged: (value) => _updateFilters(_filters.copyWith(denoiseStrength: value)),
          valueLabel: '${(_filters.denoiseStrength * 100).toInt()}%',
        ),
        _buildSlider(
          label: l10n.gamma,
          value: _filters.gamma,
          min: 0.5,
          max: 2.5,
          divisions: 20,
          onChanged: (value) => _updateFilters(_filters.copyWith(gamma: value)),
          valueLabel: _filters.gamma.toStringAsFixed(2),
        ),
      ],
    );
  }

  Widget _buildColorSection(AppLocalizations l10n) {
    return _buildFilterSection(
      title: l10n.colorAndLight,
      icon: Icons.color_lens,
      children: [
        _buildSlider(
          label: l10n.redBalance,
          value: _filters.colorBalanceR,
          min: -0.5,
          max: 0.5,
          divisions: 20,
          onChanged: (value) => _updateFilters(_filters.copyWith(colorBalanceR: value)),
          valueLabel: _filters.colorBalanceR.toStringAsFixed(2),
        ),
        _buildSlider(
          label: l10n.greenBalance,
          value: _filters.colorBalanceG,
          min: -0.5,
          max: 0.5,
          divisions: 20,
          onChanged: (value) => _updateFilters(_filters.copyWith(colorBalanceG: value)),
          valueLabel: _filters.colorBalanceG.toStringAsFixed(2),
        ),
        _buildSlider(
          label: l10n.blueBalance,
          value: _filters.colorBalanceB,
          min: -0.5,
          max: 0.5,
          divisions: 20,
          onChanged: (value) => _updateFilters(_filters.copyWith(colorBalanceB: value)),
          valueLabel: _filters.colorBalanceB.toStringAsFixed(2),
        ),
      ],
    );
  }

  Widget _buildAdvancedCorrectionsContent(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: Text(l10n.deinterlacingLabel),
          subtitle: Text(l10n.deinterlacingDesc),
          value: _filters.enableDeinterlace,
          onChanged: (value) => _updateFilters(_filters.copyWith(enableDeinterlace: value)),
        ),
        SwitchListTile(
          title: Text(l10n.stabilizationLabel),
          subtitle: Text(l10n.stabilizationDesc),
          value: _filters.enableStabilization,
          onChanged: (value) => _updateFilters(_filters.copyWith(enableStabilization: value)),
        ),
        SwitchListTile(
          title: Text(l10n.detailEnhancement),
          subtitle: Text(l10n.detailEnhancementDesc),
          value: _filters.enableDetailEnhancement,
          onChanged: (value) => _updateFilters(_filters.copyWith(enableDetailEnhancement: value)),
        ),
        SwitchListTile(
          title: Text(l10n.drunetDenoisingTitle),
          subtitle: Text(l10n.drunetDenoisingDesc),
          value: _filters.enableDRUNetDenoising,
          onChanged: (value) => _updateFilters(_filters.copyWith(enableDRUNetDenoising: value)),
        ),
        SwitchListTile(
          title: Text(l10n.sceneDetectionTitle),
          subtitle: Text(l10n.sceneDetectionDesc),
          value: _filters.enableSceneDetection,
          onChanged: (value) => _updateFilters(_filters.copyWith(enableSceneDetection: value)),
        ),
        SwitchListTile(
          title: Text(l10n.useSceneOptimizationTitle),
          subtitle: Text(l10n.useSceneOptimizationDesc),
          value: _filters.useSceneBasedOptimization,
          onChanged: (value) => _updateFilters(_filters.copyWith(useSceneBasedOptimization: value)),
        ),
      ],
    );
  }

  Widget _buildGpuAccelerationContent(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: Text(l10n.useGpuForConversion),
          subtitle: Text(l10n.useGpuForConversionDesc),
          value: _filters.enableGpuAcceleration,
          onChanged: (value) {
            _updateFilters(_filters.copyWith(enableGpuAcceleration: value));
          },
        ),
        if (_filters.enableGpuAcceleration) ...[
          const SizedBox(height: 8),
          Text(
            l10n.gpuPreset,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _GpuPresetChip(
                label: l10n.gpuPresetFast,
                description: l10n.gpuPresetFastDesc,
                value: 'fast',
                current: _filters.gpuEncodingPreset,
                color: Colors.green,
                onSelected: () => _updateFilters(
                  _filters.copyWith(
                    enableGpuAcceleration: true,
                    gpuEncodingPreset: 'fast',
                  ),
                ),
              ),
              _GpuPresetChip(
                label: l10n.gpuPresetMedium,
                description: l10n.gpuPresetMediumDesc,
                value: 'medium',
                current: _filters.gpuEncodingPreset,
                color: Colors.blue,
                onSelected: () => _updateFilters(
                  _filters.copyWith(
                    enableGpuAcceleration: true,
                    gpuEncodingPreset: 'medium',
                  ),
                ),
              ),
              _GpuPresetChip(
                label: l10n.gpuPresetHighQuality,
                description: l10n.gpuPresetHighQualityDesc,
                value: 'high_quality',
                current: _filters.gpuEncodingPreset,
                color: Colors.deepPurple,
                onSelected: () => _updateFilters(
                  _filters.copyWith(
                    enableGpuAcceleration: true,
                    gpuEncodingPreset: 'high_quality',
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildColorProfilesContent(AppLocalizations l10n) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _ColorProfileChip(label: l10n.noneLabel, isSelected: _filters.colorProfile == 'none', onSelected: () => _updateFilters(_filters.copyWith(colorProfile: 'none')), color: Colors.grey),
        _ColorProfileChip(label: l10n.vividLabel, isSelected: _filters.colorProfile == 'vivid', onSelected: () => _updateFilters(_filters.copyWith(colorProfile: 'vivid')), color: Colors.red),
        _ColorProfileChip(label: l10n.cinematicLabel, isSelected: _filters.colorProfile == 'cinematic', onSelected: () => _updateFilters(_filters.copyWith(colorProfile: 'cinematic')), color: Colors.amber),
        _ColorProfileChip(label: l10n.blackWhiteLabel, isSelected: _filters.colorProfile == 'bw', onSelected: () => _updateFilters(_filters.copyWith(colorProfile: 'bw')), color: Colors.grey),
        _ColorProfileChip(label: l10n.sepiaLabel, isSelected: _filters.colorProfile == 'sepia', onSelected: () => _updateFilters(_filters.copyWith(colorProfile: 'sepia')), color: Colors.brown),
      ],
    );
  }

  // COMPONENTI UI (mantenuti)
  Widget _buildFilterSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  valueLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
            activeColor: Colors.blue,
            inactiveColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected 
              ? color 
              : (isDark ? Colors.grey.shade600 : Colors.grey.shade300),
          width: isSelected ? 2 : 1,
        ),
      ),
    );
  }
}

class _GpuPresetChip extends StatelessWidget {
  final String label;
  final String description;
  final String value;
  final String current;
  final VoidCallback onSelected;
  final Color color;

  const _GpuPresetChip({
    required this.label,
    required this.description,
    required this.value,
    required this.current,
    required this.onSelected,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == current;
    return Tooltip(
      message: description,
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelected(),
        backgroundColor: isSelected ? color.withOpacity(0.2) : Colors.grey.shade100,
        selectedColor: color.withOpacity(0.3),
        checkmarkColor: color,
        labelStyle: TextStyle(
          color: isSelected ? color : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
      ),
    );
  }
}

class _OptimizationChip extends StatelessWidget {
  final String label;
  final String description;
  final VoidCallback onSelected;
  final Color color;

  const _OptimizationChip({
    required this.label,
    required this.description,
    required this.onSelected,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: description,
      child: FilterChip(
        label: Text(label),
        onSelected: (_) => onSelected(),
        backgroundColor: color.withOpacity(0.1),
        selectedColor: color.withOpacity(0.3),
        checkmarkColor: color,
        labelStyle: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: color.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
    );
  }
}