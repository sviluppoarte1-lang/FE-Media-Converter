import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:video_converter_pro/models/audio_filters.dart';
import 'package:video_converter_pro/l10n/app_localizations.dart';
import 'package:video_converter_pro/services/ffmpeg_service.dart';

class AudioFiltersPanel extends StatefulWidget {
  final AudioFilters filters;
  final ValueChanged<AudioFilters> onFiltersChanged;
  final String? inputFilePath;

  const AudioFiltersPanel({
    super.key,
    required this.filters,
    required this.onFiltersChanged,
    this.inputFilePath,
  });

  @override
  State<AudioFiltersPanel> createState() => _AudioFiltersPanelState();
}

class _AudioFiltersPanelState extends State<AudioFiltersPanel> {
  late AudioFilters _filters;
  bool _expanded = false;
  final FFmpegService _ffmpegService = FFmpegService();
  
  // Player per preview originale
  Process? _originalPlayerProcess;
  Timer? _originalPositionTimer;
  bool _originalIsPlaying = false;
  Duration _originalDuration = Duration.zero;
  Duration _originalPosition = Duration.zero;
  String? _originalPreviewPath;
  bool _originalLoading = false;
  
  // Player per preview modificato
  Process? _modifiedPlayerProcess;
  Timer? _modifiedPositionTimer;
  bool _modifiedIsPlaying = false;
  Duration _modifiedDuration = Duration.zero;
  Duration _modifiedPosition = Duration.zero;
  String? _modifiedPreviewPath;
  bool _modifiedLoading = false;
  StreamSubscription? _modifiedProcessSubscription;

  @override
  void initState() {
    super.initState();
    _filters = widget.filters;
    // Inizializza eqBands se non presente
    if (_filters.eqBands.length != 10) {
      _filters = _filters.copyWith(eqBands: List.filled(10, 0.0));
    }
    
    // Prepara i file di preview se c'è un file di input
    if (widget.inputFilePath != null) {
      _prepareOriginalPreview();
      _prepareModifiedPreview();
    }
  }

  @override
  void dispose() {
    try {
      _stopOriginalPlayback();
    } catch (e) {
      // Ignora errori durante dispose
    }
    
    try {
      _stopModifiedPlayback();
    } catch (e) {
      // Ignora errori durante dispose
    }
    
    try {
      _originalPositionTimer?.cancel();
    } catch (e) {
      // Ignora errori
    }
    
    try {
      _modifiedPositionTimer?.cancel();
    } catch (e) {
      // Ignora errori
    }
    
    try {
      _modifiedProcessSubscription?.cancel();
    } catch (e) {
      // Ignora errori
    }
    
    // Pulisci file temporanei
    try {
      _cleanupPreviewFiles();
    } catch (e) {
      // Ignora errori durante cleanup
    }
    
    super.dispose();
  }


  void _updateFilters(AudioFilters newFilters) {
    if (!mounted) return;
    setState(() {
      _filters = newFilters;
    });
    widget.onFiltersChanged(newFilters);
    
    // Aggiorna la preview modificata in tempo reale se sta riproducendo
    if (_modifiedIsPlaying) {
      _updateModifiedPreview();
    } else {
      // Prepara la nuova preview per quando verrà riprodotta
      _prepareModifiedPreview();
    }
  }

  void _resetFilters() {
    final newFilters = AudioFilters();
    _updateFilters(newFilters);
  }

  void _toggleExpanded() {
    if (!mounted) return;
    setState(() {
      _expanded = !_expanded;
    });
  }

  void _applyEqualizerPreset(String preset) {
    final newFilters = _filters.copyWith(equalizerPreset: preset);
    newFilters.applyEqualizerPreset(preset);
    _updateFilters(newFilters);
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (widget.inputFilePath != null) ...[
              _buildAudioPreviewSection(l10n),
              const SizedBox(height: 16),
            ],

            ListTile(
              leading: Icon(Icons.audiotrack, color: Theme.of(context).colorScheme.primary),
              title: Text(
                l10n.audioFilters,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              trailing: IconButton(
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                onPressed: _toggleExpanded,
              ),
              onTap: _toggleExpanded,
            ),
            
            if (_expanded) ...[
              if (_filters.hasActiveFilters)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        l10n.filtersActive,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _resetFilters,
                        child: Text(l10n.resetAll),
                      ),
                    ],
                  ),
                ),

              // VOLUME E COMPRESSIONE
              _buildFilterSection(
                title: l10n.volumeDynamics,
                icon: Icons.volume_up,
                children: [
                  _buildSlider(
                    label: l10n.volume,
                    value: _filters.volume,
                    min: 0.0,
                    max: 2.0,
                    divisions: 20,
                    onChanged: (value) => _updateFilters(_filters.copyWith(volume: value)),
                    valueLabel: '${(_filters.volume * 100).toInt()}%',
                  ),
                  _buildSlider(
                    label: l10n.compression,
                    value: _filters.compression,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    onChanged: (value) => _updateFilters(_filters.copyWith(compression: value)),
                    valueLabel: '${(_filters.compression * 100).toInt()}%',
                  ),
                  SwitchListTile(
                    title: Text(l10n.normalization),
                    subtitle: Text(l10n.levelsVolumeAutomatically),
                    value: _filters.normalize,
                    onChanged: (value) => _updateFilters(_filters.copyWith(normalize: value)),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // EQUALIZZATORE GRAFICO
              _buildFilterSection(
                title: l10n.equalizer,
                icon: Icons.graphic_eq,
                children: [
                  // Preset
                  Text(
                    l10n.equalizerPreset,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _EqualizerPresetChip(
                        label: l10n.none,
                        isSelected: _filters.equalizerPreset == 'none' || _filters.equalizerPreset == 'flat',
                        onSelected: () => _applyEqualizerPreset('flat'),
                      ),
                      _EqualizerPresetChip(
                        label: l10n.bassBoost,
                        isSelected: _filters.equalizerPreset == 'bass_boost',
                        onSelected: () => _applyEqualizerPreset('bass_boost'),
                      ),
                      _EqualizerPresetChip(
                        label: l10n.trebleBoost,
                        isSelected: _filters.equalizerPreset == 'treble_boost',
                        onSelected: () => _applyEqualizerPreset('treble_boost'),
                      ),
                      _EqualizerPresetChip(
                        label: l10n.voice,
                        isSelected: _filters.equalizerPreset == 'voice',
                        onSelected: () => _applyEqualizerPreset('voice'),
                      ),
                      _EqualizerPresetChip(
                        label: 'Rock',
                        isSelected: _filters.equalizerPreset == 'rock',
                        onSelected: () => _applyEqualizerPreset('rock'),
                      ),
                      _EqualizerPresetChip(
                        label: 'Pop',
                        isSelected: _filters.equalizerPreset == 'pop',
                        onSelected: () => _applyEqualizerPreset('pop'),
                      ),
                      _EqualizerPresetChip(
                        label: 'Jazz',
                        isSelected: _filters.equalizerPreset == 'jazz',
                        onSelected: () => _applyEqualizerPreset('jazz'),
                      ),
                      _EqualizerPresetChip(
                        label: 'Classical',
                        isSelected: _filters.equalizerPreset == 'classical',
                        onSelected: () => _applyEqualizerPreset('classical'),
                      ),
                    ],
                  ),
              const SizedBox(height: 16),
              // Equalizzatore grafico
              _buildGraphicEqualizer(),
                ],
              ),

              const SizedBox(height: 16),

              // PULIZIA AUDIO
              _buildFilterSection(
                title: l10n.audioCleaning,
                icon: Icons.clean_hands,
                children: [
                  SwitchListTile(
                    title: Text(l10n.removeNoise),
                    subtitle: Text(l10n.reducesBackgroundHiss),
                    value: _filters.removeNoise,
                    onChanged: (value) => _updateFilters(_filters.copyWith(removeNoise: value)),
                  ),
                  if (_filters.removeNoise) ...[
                    _buildSlider(
                      label: l10n.noiseThreshold,
                      value: _filters.noiseThreshold,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      onChanged: (value) => _updateFilters(_filters.copyWith(noiseThreshold: value)),
                      valueLabel: '${(_filters.noiseThreshold * 100).toInt()}%',
                    ),
                  ],
                  _buildSlider(
                    label: l10n.reverb,
                    value: _filters.reverb,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    onChanged: (value) => _updateFilters(_filters.copyWith(reverb: value)),
                    valueLabel: '${(_filters.reverb * 100).toInt()}%',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ANTEPRIMA EFFETTI AUDIO
              _buildAudioEffectPreview(l10n),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAudioPreviewSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.audioPreview,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // Player originale
        _buildInlinePlayer(
          title: l10n.previewOriginal,
          icon: Icons.play_circle_outline,
          isPlaying: _originalIsPlaying,
          isLoading: _originalLoading,
          duration: _originalDuration,
          position: _originalPosition,
          onTogglePlayback: _toggleOriginalPlayback,
          onSeek: _seekOriginal,
        ),
        const SizedBox(height: 16),
        // Player modificato
        _buildInlinePlayer(
          title: l10n.previewModified,
          icon: Icons.graphic_eq,
          isPlaying: _modifiedIsPlaying,
          isLoading: _modifiedLoading,
          duration: _modifiedDuration,
          position: _modifiedPosition,
          onTogglePlayback: _toggleModifiedPlayback,
          onSeek: _seekModified,
        ),
      ],
    );
  }

  Widget _buildInlinePlayer({
    required String title,
    required IconData icon,
    required bool isPlaying,
    required bool isLoading,
    required Duration duration,
    required Duration position,
    required VoidCallback onTogglePlayback,
    required ValueChanged<Duration> onSeek,
  }) {
    return Card(
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              Row(
                children: [
                  IconButton(
                    icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                    iconSize: 32,
                    onPressed: onTogglePlayback,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      children: [
                        if (duration > Duration.zero) ...[
                          Slider(
                            value: position.inMilliseconds.toDouble().clamp(0.0, duration.inMilliseconds.toDouble()),
                            min: 0.0,
                            max: duration.inMilliseconds.toDouble(),
                            onChanged: (value) {
                              onSeek(Duration(milliseconds: value.toInt()));
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(position),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                _formatDuration(duration),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ] else
                          Text(
                            'Pronto',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Widget _buildGraphicEqualizer() {
    final frequencies = ['31', '62', '125', '250', '500', '1k', '2k', '4k', '8k', '16k'];
    
    return Column(
      children: [
        // Visualizzazione grafica
        Container(
          height: 200,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(10, (index) {
              final value = _filters.eqBands[index];
              final normalizedValue = (value + 20.0) / 40.0; // Normalizza da -20/+20 a 0/1
              final barHeight = normalizedValue.clamp(0.0, 1.0) * 160;
              
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Barra verticale
                      Container(
                        width: double.infinity,
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: value > 0 
                              ? Theme.of(context).colorScheme.primary
                              : value < 0 
                                  ? Theme.of(context).colorScheme.error
                                  : Theme.of(context).colorScheme.outline,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Etichetta frequenza
                      Text(
                        frequencies[index],
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      // Valore dB
                      Text(
                        '${value.toInt()}',
                        style: TextStyle(
                          fontSize: 9,
                          color: value != 0 
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 16),
        // Slider per ogni banda
        ...List.generate(10, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    frequencies[index],
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: _filters.eqBands[index],
                    min: -20.0,
                    max: 20.0,
                    divisions: 80,
                    onChanged: (value) {
                      final newBands = List<double>.from(_filters.eqBands);
                      newBands[index] = value;
                      _updateFilters(_filters.copyWith(eqBands: newBands, equalizerPreset: 'custom'));
                    },
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    '${_filters.eqBands[index].toInt()}dB',
                    style: const TextStyle(fontSize: 11),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  
  Future<void> _prepareOriginalPreview() async {
    if (widget.inputFilePath == null) return;
    if (!mounted) return;
    
    setState(() {
      _originalLoading = true;
    });

    try {
      final inputFile = File(widget.inputFilePath!);
      if (!await inputFile.exists()) {
        throw Exception('File non trovato: ${widget.inputFilePath}');
      }

      final extension = widget.inputFilePath!.toLowerCase().split('.').last;
      final isAudioOnly = ['mp3', 'wav', 'aac', 'ogg', 'flac', 'm4a', 'wma'].contains(extension);
      
      if (isAudioOnly) {
        _originalPreviewPath = widget.inputFilePath!;
      } else {
        final tempDir = Directory.systemTemp;
        final previewFile = File('${tempDir.path}/audio_preview_original_${DateTime.now().millisecondsSinceEpoch}.mp3');
        
        final command = [
          '-y', '-i', widget.inputFilePath!,
          '-t', '60', '-vn',
          '-c:a', 'libmp3lame', '-b:a', '192k',
          previewFile.path,
        ];

        final process = await Process.run('ffmpeg', command);
        
        if (process.exitCode == 0 && previewFile.existsSync()) {
          _originalPreviewPath = previewFile.path;
        } else {
          throw Exception('Errore estrazione audio: ${process.stderr}');
        }
      }
      
      if (mounted) {
        setState(() {
          _originalLoading = false;
        });
        await _getOriginalDuration();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _originalLoading = false;
        });
      }
    }
  }

  Future<void> _getOriginalDuration() async {
    if (_originalPreviewPath == null) return;
    
    try {
      final process = await Process.run('ffprobe', [
        '-v', 'error',
        '-show_entries', 'format=duration',
        '-of', 'default=noprint_wrappers=1:nokey=1',
        _originalPreviewPath!,
      ]);
      
      if (process.exitCode == 0) {
        final durationStr = process.stdout.toString().trim();
        final durationSeconds = double.tryParse(durationStr);
        if (durationSeconds != null && mounted) {
          setState(() {
            _originalDuration = Duration(milliseconds: (durationSeconds * 1000).toInt());
          });
        }
      }
    } catch (e) {
      // Ignora errori
    }
  }

  Future<void> _toggleOriginalPlayback() async {
    if (_originalIsPlaying) {
      _stopOriginalPlayback();
    } else {
      await _startOriginalPlayback();
    }
  }

  Future<void> _startOriginalPlayback() async {
    // Se il file non è ancora pronto, preparalo prima
    if (_originalPreviewPath == null) {
      await _prepareOriginalPreview();
      if (_originalPreviewPath == null) return;
    }

    try {
      _stopOriginalPlayback();
      await Future.delayed(const Duration(milliseconds: 150));

      final seekPosition = _originalPosition.inSeconds + (_originalPosition.inMilliseconds % 1000) / 1000.0;
      final command = <String>['-nodisp', '-autoexit', '-loglevel', 'quiet'];
      if (seekPosition > 0) {
        command.addAll(['-ss', seekPosition.toString()]);
      }
      command.add(_originalPreviewPath!);
      
      _originalPlayerProcess = await Process.start('ffplay', command);
      
      if (!mounted) {
        _stopOriginalPlayback();
        return;
      }
      
      setState(() {
        _originalIsPlaying = true;
      });

      final startPosition = _originalPosition;
      final startTime = DateTime.now();
      
      _originalPositionTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (!mounted || !_originalIsPlaying || _originalPlayerProcess == null) {
          timer.cancel();
          return;
        }
        
        try {
          final elapsed = DateTime.now().difference(startTime);
          final newPosition = startPosition + elapsed;
          
          if (mounted) {
            setState(() {
              if (_originalDuration > Duration.zero && newPosition >= _originalDuration) {
                _originalPosition = _originalDuration;
                _stopOriginalPlayback();
              } else {
                _originalPosition = newPosition;
              }
            });
          }
        } catch (e) {
          timer.cancel();
        }
      });

      _originalPlayerProcess!.exitCode.then((_) {
        if (mounted) {
          _stopOriginalPlayback();
        }
      }).catchError((e) {
        // Ignora errori di exit code
        if (mounted) {
          _stopOriginalPlayback();
        }
      });

      // Gestisci stderr per evitare errori non gestiti
      try {
        _originalPlayerProcess!.stderr.listen(
          (_) {},
          onError: (e) {
            // Ignora errori di stream
          },
          cancelOnError: false,
        );
      } catch (e) {
        // Ignora errori durante setup stream
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _originalIsPlaying = false;
        });
      }
    }
  }

  void _stopOriginalPlayback() {
    try {
      _originalPlayerProcess?.kill();
    } catch (e) {
      // Ignora errori durante kill
    }
    _originalPlayerProcess = null;
    
    try {
      _originalPositionTimer?.cancel();
    } catch (e) {
      // Ignora errori durante cancel
    }
    _originalPositionTimer = null;
    
    if (mounted) {
      try {
        setState(() {
          _originalIsPlaying = false;
        });
      } catch (e) {
        // Ignora errori durante setState
      }
    }
  }

  Future<void> _seekOriginal(Duration position) async {
    if (_originalPreviewPath == null) return;
    
    final wasPlaying = _originalIsPlaying;
    _stopOriginalPlayback();
    
    Duration newPosition;
    if (position < Duration.zero) {
      newPosition = Duration.zero;
    } else if (_originalDuration > Duration.zero && position > _originalDuration) {
      newPosition = _originalDuration;
    } else {
      newPosition = position;
    }
    
    if (mounted) {
      setState(() {
        _originalPosition = newPosition;
      });
    }
    
    if (wasPlaying) {
      await Future.delayed(const Duration(milliseconds: 100));
      await _startOriginalPlayback();
    }
  }

  
  Future<void> _prepareModifiedPreview() async {
    if (widget.inputFilePath == null) return;
    // Prepara sempre la preview modificata, anche se non ci sono filtri attivi
    await _generateModifiedPreview();
  }

  Future<void> _updateModifiedPreview() async {
    final wasPlaying = _modifiedIsPlaying;
    final currentPosition = _modifiedPosition;
    
    _stopModifiedPlayback();
    await _generateModifiedPreview();
    
    if (wasPlaying && mounted) {
      setState(() {
        _modifiedPosition = currentPosition;
      });
      await _startModifiedPlayback();
    }
  }

  Future<void> _generateModifiedPreview() async {
    if (widget.inputFilePath == null) return;
    if (!mounted) return;

    setState(() {
      _modifiedLoading = true;
    });

    try {
      if (_modifiedPreviewPath != null && _modifiedPreviewPath != widget.inputFilePath) {
        try {
          File(_modifiedPreviewPath!).deleteSync();
        } catch (e) {}
      }

      final tempDir = Directory.systemTemp;
      final previewFile = File('${tempDir.path}/audio_preview_modified_${DateTime.now().millisecondsSinceEpoch}.mp3');
      
      final command = [
        '-y', '-i', widget.inputFilePath!,
        '-t', '60', '-vn',
      ];

      final audioFilterChain = _ffmpegService.buildAudioFilterChain(_filters);
      if (audioFilterChain.isNotEmpty) {
        command.addAll(['-af', audioFilterChain]);
      }

      command.addAll(['-c:a', 'libmp3lame', '-b:a', '192k', previewFile.path]);

      final process = await Process.run('ffmpeg', command);
      
      if (process.exitCode == 0 && previewFile.existsSync() && mounted) {
        setState(() {
          _modifiedPreviewPath = previewFile.path;
          _modifiedLoading = false;
        });
        await _getModifiedDuration();
      } else {
        throw Exception('Errore generazione preview: ${process.stderr}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _modifiedLoading = false;
        });
      }
    }
  }

  Future<void> _getModifiedDuration() async {
    if (_modifiedPreviewPath == null) return;
    
    try {
      final process = await Process.run('ffprobe', [
        '-v', 'error',
        '-show_entries', 'format=duration',
        '-of', 'default=noprint_wrappers=1:nokey=1',
        _modifiedPreviewPath!,
      ]);
      
      if (process.exitCode == 0) {
        final durationStr = process.stdout.toString().trim();
        final durationSeconds = double.tryParse(durationStr);
        if (durationSeconds != null && mounted) {
          setState(() {
            _modifiedDuration = Duration(milliseconds: (durationSeconds * 1000).toInt());
          });
        }
      }
    } catch (e) {
      // Ignora errori
    }
  }

  Future<void> _toggleModifiedPlayback() async {
    if (_modifiedIsPlaying) {
      _stopModifiedPlayback();
    } else {
      await _startModifiedPlayback();
    }
  }

  Future<void> _startModifiedPlayback() async {
    // Se il file non è ancora pronto, preparalo prima
    if (_modifiedPreviewPath == null) {
      await _prepareModifiedPreview();
      if (_modifiedPreviewPath == null) return;
    }

    try {
      _stopModifiedPlayback();
      await Future.delayed(const Duration(milliseconds: 150));

      final seekPosition = _modifiedPosition.inSeconds + (_modifiedPosition.inMilliseconds % 1000) / 1000.0;
      final command = <String>['-nodisp', '-autoexit', '-loglevel', 'quiet'];
      if (seekPosition > 0) {
        command.addAll(['-ss', seekPosition.toString()]);
      }
      command.add(_modifiedPreviewPath!);
      
      _modifiedPlayerProcess = await Process.start('ffplay', command);
      
      if (!mounted) {
        _stopModifiedPlayback();
        return;
      }
      
      setState(() {
        _modifiedIsPlaying = true;
      });

      final startPosition = _modifiedPosition;
      final startTime = DateTime.now();
      
      _modifiedPositionTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (!mounted || !_modifiedIsPlaying || _modifiedPlayerProcess == null) {
          timer.cancel();
          return;
        }
        
        try {
          final elapsed = DateTime.now().difference(startTime);
          final newPosition = startPosition + elapsed;
          
          if (mounted) {
            setState(() {
              if (_modifiedDuration > Duration.zero && newPosition >= _modifiedDuration) {
                _modifiedPosition = _modifiedDuration;
                _stopModifiedPlayback();
              } else {
                _modifiedPosition = newPosition;
              }
            });
          }
        } catch (e) {
          timer.cancel();
        }
      });

      _modifiedPlayerProcess!.exitCode.then((_) {
        if (mounted) {
          _stopModifiedPlayback();
        }
      }).catchError((e) {
        // Ignora errori di exit code
        if (mounted) {
          _stopModifiedPlayback();
        }
      });

      _modifiedProcessSubscription = _modifiedPlayerProcess!.stderr.listen(
        (_) {},
        onError: (e) {
          // Ignora errori di stream
        },
        cancelOnError: false,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _modifiedIsPlaying = false;
        });
      }
    }
  }

  void _stopModifiedPlayback() {
    try {
      _modifiedPlayerProcess?.kill();
    } catch (e) {
      // Ignora errori durante kill
    }
    _modifiedPlayerProcess = null;
    
    try {
      _modifiedPositionTimer?.cancel();
    } catch (e) {
      // Ignora errori durante cancel
    }
    _modifiedPositionTimer = null;
    
    try {
      _modifiedProcessSubscription?.cancel();
    } catch (e) {
      // Ignora errori durante cancel
    }
    _modifiedProcessSubscription = null;
    
    if (mounted) {
      try {
        setState(() {
          _modifiedIsPlaying = false;
        });
      } catch (e) {
        // Ignora errori durante setState
      }
    }
  }

  Future<void> _seekModified(Duration position) async {
    if (_modifiedPreviewPath == null) return;
    
    final wasPlaying = _modifiedIsPlaying;
    _stopModifiedPlayback();
    
    Duration newPosition;
    if (position < Duration.zero) {
      newPosition = Duration.zero;
    } else if (_modifiedDuration > Duration.zero && position > _modifiedDuration) {
      newPosition = _modifiedDuration;
    } else {
      newPosition = position;
    }
    
    if (mounted) {
      setState(() {
        _modifiedPosition = newPosition;
      });
    }
    
    if (wasPlaying) {
      await Future.delayed(const Duration(milliseconds: 100));
      await _startModifiedPlayback();
    }
  }

  void _cleanupPreviewFiles() {
    if (_originalPreviewPath != null && _originalPreviewPath != widget.inputFilePath) {
      try {
        File(_originalPreviewPath!).deleteSync();
      } catch (e) {}
    }
    if (_modifiedPreviewPath != null && _modifiedPreviewPath != widget.inputFilePath) {
      try {
        File(_modifiedPreviewPath!).deleteSync();
      } catch (e) {}
    }
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
                Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
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

  Widget _buildAudioEffectPreview(AppLocalizations l10n) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.activeAudioEffects,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            if (!_filters.hasActiveFilters)
              Text(
                l10n.noActiveAudioFilters,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            if (_filters.volume != 1.0)
              _buildEffectItem('${l10n.volume}: ${(_filters.volume * 100).toInt()}%'),
            if (_filters.eqBands.any((band) => band != 0.0))
              _buildEffectItem('${l10n.equalizer}: ${_filters.equalizerPreset}'),
            if (_filters.normalize)
              _buildEffectItem('${l10n.normalization}: ON'),
            if (_filters.removeNoise)
              _buildEffectItem('${l10n.removeNoise}: ${(_filters.noiseThreshold * 100).toInt()}%'),
            if (_filters.compression > 0.0)
              _buildEffectItem('${l10n.compression}: ${(_filters.compression * 100).toInt()}%'),
            if (_filters.reverb > 0.0)
              _buildEffectItem('${l10n.reverb}: ${(_filters.reverb * 100).toInt()}%'),
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
          Icon(
            Icons.check,
            color: Theme.of(context).colorScheme.primary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _EqualizerPresetChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _EqualizerPresetChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: Theme.of(context).chipTheme.backgroundColor,
      selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
      checkmarkColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
