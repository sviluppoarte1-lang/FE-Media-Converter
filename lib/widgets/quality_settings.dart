import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_converter_pro/models/media_type.dart';
import 'package:video_converter_pro/providers/settings_provider.dart';
import 'package:video_converter_pro/l10n/app_localizations.dart';

class QualitySettings extends StatelessWidget {
  final MediaType? mediaType; // AGGIUNTO: Parametro per sapere il tipo di media

  const QualitySettings({super.key, this.mediaType});

  Future<void> _runBenchmark(BuildContext context, SettingsProvider provider) async {
    if (provider.isBenchmarkRunning) return;
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.benchmarkRunStart)),
    );
    final r = await provider.runUniversalBenchmark();
    if (!context.mounted) return;
    if (r['success'] == true) {
      final preset = r['bestPreset'] ?? 'medium';
      final codec = r['codec'] ?? 'unknown';
      messenger.showSnackBar(
        SnackBar(content: Text('${l10n.benchmarkDone}. Best preset: $preset ($codec)')),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text('${l10n.benchmarkFailed}: ${r['error'] ?? 'unknown error'}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              l10n.qualitySettings,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          // Menu a tendina: Video Quality
          if (mediaType == MediaType.video)
            ExpansionTile(
              initiallyExpanded: true,
              leading: const Icon(Icons.hd, color: Colors.blue),
              title: Text(
                l10n.videoQuality.trim().replaceAll(':', '').trim(),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildVideoCodecSelector(settingsProvider, l10n),
                      const SizedBox(height: 16),
                      _buildVideoQualityMode(settingsProvider, l10n),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: settingsProvider.isBenchmarkRunning
                                  ? null
                                  : () => _runBenchmark(context, settingsProvider),
                              icon: const Icon(Icons.speed),
                              label: Text(
                                settingsProvider.isBenchmarkRunning
                                    ? l10n.benchmarkRunningButton
                                    : l10n.benchmarkRunButton,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (settingsProvider.isBenchmarkRunning) ...[
                        const SizedBox(height: 8),
                        LinearProgressIndicator(value: settingsProvider.benchmarkProgress),
                        const SizedBox(height: 6),
                        Text(
                          settingsProvider.benchmarkPhase.isEmpty
                              ? l10n.benchmarkRunStart
                              : _localizePhase(settingsProvider.benchmarkPhase, l10n),
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                        ),
                      ],
                      const SizedBox(height: 10),
                      _buildBenchmarkHistory(settingsProvider, l10n),
                      const SizedBox(height: 16),
                      _buildVideoQualitySlider(settingsProvider, l10n),
                    ],
                  ),
                ),
              ],
            ),
          // Menu a tendina: Audio Quality
          ExpansionTile(
            initiallyExpanded: mediaType != MediaType.video,
            leading: const Icon(Icons.audiotrack, color: Colors.blue),
            title: Text(
              l10n.audioQuality.trim().replaceAll(':', '').trim(),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: _buildAudioQualitySlider(settingsProvider, l10n),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBenchmarkHistory(SettingsProvider provider, AppLocalizations l10n) {
    final history = provider.benchmarkHistory;
    if (history.isEmpty) {
      return Text(
        l10n.benchmarkHistoryEmpty,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.benchmarkHistoryTitle,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        ...history.take(3).map((entry) {
          final ts = entry['timestamp']?.toString() ?? '';
          final date = ts.isNotEmpty ? ts.replaceFirst('T', ' ').split('.').first : 'unknown';
          final best = entry['bestPreset']?.toString() ?? 'unknown';
          final codec = entry['codec']?.toString() ?? 'unknown';
          final scores = entry['scoresFps'] is Map
              ? Map<String, dynamic>.from(entry['scoresFps'] as Map)
              : <String, dynamic>{};
          final fast = (scores['fast'] as num?)?.toStringAsFixed(1) ?? '-';
          final med = (scores['medium'] as num?)?.toStringAsFixed(1) ?? '-';
          final hq = (scores['high_quality'] as num?)?.toStringAsFixed(1) ?? '-';
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '$date | $codec | best: $best | fps f/m/h: $fast / $med / $hq',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          );
        }),
      ],
    );
  }

  String _localizePhase(String phaseKey, AppLocalizations l10n) {
    switch (phaseKey) {
      case 'phase.starting':
        return l10n.benchmarkPhaseStarting;
      case 'phase.collecting':
        return l10n.benchmarkPhaseCollecting;
      case 'phase.benchmark_fast':
        return l10n.benchmarkPhaseFast;
      case 'phase.benchmark_medium':
        return l10n.benchmarkPhaseMedium;
      case 'phase.benchmark_high_quality':
        return l10n.benchmarkPhaseHighQuality;
      case 'phase.selecting_best':
        return l10n.benchmarkPhaseSelecting;
      case 'phase.done':
        return l10n.benchmarkPhaseDone;
      default:
        return phaseKey;
    }
  }

  Widget _buildVideoCodecSelector(SettingsProvider provider, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('${l10n.video} Codec'),
            const Spacer(),
            Text(
              _getVideoCodecName(provider.defaultVideoCodec),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButton<String>(
          value: provider.defaultVideoCodec,
          isExpanded: true,
          onChanged: (String? newValue) {
            if (newValue != null) {
              provider.setDefaultVideoCodec(newValue);
            }
          },
          items: MediaType.video.supportedVideoCodecs.map((codec) {
            return DropdownMenuItem(
              value: codec,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_getVideoCodecName(codec)),
                  Text(
                    _getVideoCodecDescription(codec, l10n),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildVideoQualityMode(SettingsProvider provider, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.videoQualityMode,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: [
            ButtonSegment(
              value: 'crf',
              label: Text(l10n.constantQualityLabel),
              icon: const Icon(Icons.high_quality),
            ),
            ButtonSegment(
              value: 'bitrate',
              label: Text(l10n.constantBitrateLabel),
              icon: const Icon(Icons.speed),
            ),
          ],
          selected: {provider.videoBitrateMode},
          onSelectionChanged: (Set<String> newSelection) {
            provider.setVideoBitrateMode(newSelection.first);
          },
        ),
        const SizedBox(height: 8),
        Text(
          provider.videoBitrateMode == 'crf'
              ? l10n.crfDescription
              : l10n.bitrateDescription,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildVideoQualitySlider(SettingsProvider provider, AppLocalizations l10n) {
    if (provider.videoBitrateMode == 'crf') {
      return _buildCrfSlider(provider, l10n);
    } else {
      return _buildBitrateSlider(provider, l10n);
    }
  }

  Widget _buildCrfSlider(SettingsProvider provider, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(l10n.videoQuality),
            const Spacer(),
            Text(
              _getCrfQualityLabel(provider.videoQuality, l10n),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: provider.videoQuality.toDouble(),
          min: 0,
          max: 51,
          divisions: 51,
          label: _getCrfQualityLabel(provider.videoQuality, l10n),
          onChanged: (value) {
            provider.setVideoQuality(value.toInt());
          },
        ),
        Text(
          l10n.crfQualityRange,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          '${l10n.qualityLabel} ${provider.getVideoQualityDescription(l10n)}',
          style: TextStyle(
            fontSize: 12,
            color: _getQualityColor(provider.videoQuality),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBitrateSlider(SettingsProvider provider, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(l10n.videoBitrateLabel),
            const Spacer(),
            Text(
              '${provider.videoBitrate} kbps',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: provider.videoBitrate.toDouble(),
          min: 500,
          max: 20000,
          divisions: 39,
          label: '${provider.videoBitrate} kbps',
          onChanged: (value) {
            provider.setVideoBitrate(value.toInt());
          },
        ),
        Text(
          l10n.bitrateQualityRange,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          '${l10n.qualityLabel} ${provider.getVideoQualityDescription(l10n)}',
          style: TextStyle(
            fontSize: 12,
            color: _getBitrateQualityColor(provider.videoBitrate),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAudioQualitySlider(SettingsProvider provider, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(l10n.audioQuality),
            const Spacer(),
            Text(
              '${provider.audioBitrate} kbps',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: provider.audioBitrate.toDouble(),
          min: 64,
          max: 320,
          divisions: (320 - 64) ~/ 32,
          label: '${provider.audioBitrate} kbps',
          onChanged: (value) {
            provider.setAudioBitrate(value.toInt());
          },
        ),
        Text(
          l10n.bitrateScale,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          _getAudioQualityDescription(provider.audioBitrate, l10n),
          style: TextStyle(
            fontSize: 12,
            color: _getAudioQualityColor(provider.audioBitrate),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // METODI LOCALI PER CODEC VIDEO
  String _getVideoCodecName(String codec) {
    switch (codec) {
      case 'libx264':
        return 'H.264 (MPEG-4 AVC)';
      case 'libx265':
        return 'H.265 (HEVC)';
      case 'libvpx':
        return 'VP8 (WebM)';
      case 'libvpx-vp9':
        return 'VP9 (WebM)';
      case 'mpeg4':
        return 'MPEG-4';
      case 'libaom-av1':
        return 'AV1';
      default:
        return codec;
    }
  }

  String _getVideoCodecDescription(String codec, AppLocalizations l10n) {
    switch (codec) {
      case 'libx264':
        return l10n.videoCodecDescriptionLibx264;
      case 'libx265':
        return l10n.videoCodecDescriptionLibx265;
      case 'libvpx':
        return l10n.videoCodecDescriptionLibvpx;
      case 'libvpx-vp9':
        return l10n.videoCodecDescriptionLibvpxVp9;
      case 'mpeg4':
        return l10n.videoCodecDescriptionMpeg4;
      case 'libaom-av1':
        return l10n.videoCodecDescriptionLibaomAv1;
      default:
        return l10n.videoCodecDescriptionDefault;
    }
  }

  String _getCrfQualityLabel(int crf, AppLocalizations l10n) {
    if (crf <= 18) return l10n.excellentQuality(crf);
    if (crf <= 23) return l10n.greatQuality(crf);
    if (crf <= 28) return l10n.goodQuality(crf);
    if (crf <= 35) return l10n.averageQuality(crf);
    return l10n.lowQualityLabel(crf);
  }

  Color _getQualityColor(int crf) {
    if (crf <= 18) return Colors.green;
    if (crf <= 23) return Colors.lightGreen;
    if (crf <= 28) return Colors.orange;
    if (crf <= 35) return Colors.orangeAccent;
    return Colors.red;
  }

  Color _getBitrateQualityColor(int bitrate) {
    if (bitrate >= 8000) return Colors.green;
    if (bitrate >= 4000) return Colors.lightGreen;
    if (bitrate >= 2000) return Colors.orange;
    if (bitrate >= 1000) return Colors.orangeAccent;
    return Colors.red;
  }

  Color _getAudioQualityColor(int bitrate) {
    if (bitrate >= 256) return Colors.green;
    if (bitrate >= 192) return Colors.lightGreen;
    if (bitrate >= 128) return Colors.orange;
    return Colors.red;
  }

  String _getAudioQualityDescription(int bitrate, AppLocalizations l10n) {
    if (bitrate >= 256) return l10n.audioQualityHighest;
    if (bitrate >= 192) return l10n.audioQualityHigh;
    if (bitrate >= 128) return l10n.audioQualityMedium;
    return l10n.audioQualityLow;
  }
}