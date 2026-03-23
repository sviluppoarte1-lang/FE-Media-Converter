import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_converter_pro/models/media_type.dart';
import 'package:video_converter_pro/providers/settings_provider.dart';
import 'package:video_converter_pro/l10n/app_localizations.dart';

class FormatSelector extends StatelessWidget {
  final MediaType mediaType;

  const FormatSelector({super.key, required this.mediaType});

  String _getCurrentFormat(SettingsProvider provider, MediaType type) {
    switch (type) {
      case MediaType.video:
        return provider.defaultVideoFormat;
      case MediaType.audio:
        return provider.defaultAudioFormat;
      case MediaType.image:
        return provider.defaultImageFormat;
    }
  }

  String _getCurrentAudioCodec(SettingsProvider provider, MediaType type) {
    return provider.defaultAudioCodec;
  }

  String _getMediaTypeName(AppLocalizations l10n) {
    switch (mediaType) {
      case MediaType.video:
        return l10n.video;
      case MediaType.audio:
        return l10n.audio;
      case MediaType.image:
        return l10n.image;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final l10n = AppLocalizations.of(context)!;
    final String currentFormat = _getCurrentFormat(settingsProvider, mediaType);
    final String currentAudioCodec = _getCurrentAudioCodec(settingsProvider, mediaType);
    final bool extractAudio = settingsProvider.extractAudioFromVideo;

    return Column(
      children: [
        // Menu a tendina: Output Format (Video / Audio / Image)
        Card(
          child: ExpansionTile(
            initiallyExpanded: true,
            leading: Icon(
              mediaType == MediaType.video ? Icons.video_file : (mediaType == MediaType.audio ? Icons.audiotrack : Icons.image),
              color: Colors.blue,
            ),
            title: Text(
              l10n.outputFormat(_getMediaTypeName(l10n)),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (mediaType == MediaType.video) ...[
                      Row(
                        children: [
                          Checkbox(
                            value: extractAudio,
                            onChanged: (value) {
                              settingsProvider.setExtractAudioFromVideo(value ?? false);
                            },
                          ),
                          Expanded(
                            child: Text(
                              l10n.extractAudioOnly,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (extractAudio && mediaType == MediaType.video
                          ? MediaType.audio.supportedFormats
                          : mediaType.supportedFormats).map((format) {
                        return _FormatChip(
                          format: format,
                          label: format.toUpperCase(),
                          isSelected: extractAudio && mediaType == MediaType.video
                              ? settingsProvider.defaultAudioFormat == format
                              : currentFormat == format,
                          onSelected: () {
                            if (extractAudio && mediaType == MediaType.video) {
                              settingsProvider.setDefaultAudioFormat(format);
                            } else {
                              switch (mediaType) {
                                case MediaType.video:
                                  settingsProvider.setDefaultVideoFormat(format);
                                  break;
                                case MediaType.audio:
                                  settingsProvider.setDefaultAudioFormat(format);
                                  break;
                                case MediaType.image:
                                  settingsProvider.setDefaultImageFormat(format);
                                  break;
                              }
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Menu a tendina: Audio Codec (solo per Video)
        if (mediaType == MediaType.video) ...[
          const SizedBox(height: 8),
          Card(
            child: ExpansionTile(
              initiallyExpanded: false,
              leading: const Icon(Icons.audiotrack, color: Colors.blue),
              title: Text(
                l10n.audioCodecSection(_getMediaTypeName(l10n)),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: mediaType.supportedAudioCodecs.map((codec) {
                          return _AudioCodecChip(
                            codec: codec,
                            label: codec.toUpperCase(),
                            isSelected: currentAudioCodec == codec,
                            onSelected: () {
                              settingsProvider.setDefaultAudioCodec(codec);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _getCodecDescription(currentAudioCodec, l10n),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _getCodecDescription(String codec, AppLocalizations l10n) {
    switch (codec) {
      case 'aac':
        return l10n.aacDescription;
      case 'mp3':
        return l10n.mp3Description;
      case 'flac':
        return l10n.flacDescription;
      case 'opus':
        return l10n.opusDescription;
      case 'vorbis':
        return l10n.vorbisDescription;
      case 'pcm':
        return l10n.pcmDescription;
      default:
        return l10n.audioCodecDefaultDescription(codec.toUpperCase());
    }
  }
}

class _FormatChip extends StatelessWidget {
  final String format;
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FormatChip({
    required this.format,
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  Color _getColorForFormat(String format) {
    final colors = {
      // Video
      'mp4': Colors.blue,
      'avi': Colors.indigo,
      'mkv': Colors.deepOrange,
      'webm': Colors.green,
      'mov': Colors.purple,
      'flv': Colors.red,
      'wmv': Colors.teal,
      'mpeg': Colors.amber,
      'ts': Colors.cyan,
      // Audio
      'mp3': Colors.red,
      'wav': Colors.blue,
      'aac': Colors.purple,
      'flac': Colors.orange,
      'ogg': Colors.pink,
      'm4a': Colors.teal,
      'wma': Colors.blueGrey,
      'opus': Colors.teal,
      // Image
      'jpg': Colors.green,
      'jpeg': Colors.blue,
      'png': Colors.orange,
      'webp': Colors.purple,
      'bmp': Colors.red,
      'tiff': Colors.brown,
      'heic': Colors.blueGrey,
    };
    return colors[format] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      // CORREZIONE: Usa il colore di sfondo del tema Chip
      backgroundColor: Theme.of(context).chipTheme.backgroundColor,
      selectedColor: _getColorForFormat(format).withOpacity(isDark ? 0.7 : 1.0),
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        // CORREZIONE: Usa il colore del testo del tema Chip se non selezionato
        color: isSelected
            ? Colors.white
            : Theme.of(context).chipTheme.labelStyle?.color,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _AudioCodecChip extends StatelessWidget {
  final String codec;
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _AudioCodecChip({
    required this.codec,
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  Color _getColorForCodec(String codec) {
    final colors = {
      'aac': Colors.purple,
      'mp3': Colors.red,
      'flac': Colors.orange,
      'opus': Colors.teal,
      'vorbis': Colors.pink,
      'pcm': Colors.blue,
    };
    return colors[codec] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      // CORREZIONE: Usa il colore di sfondo del tema Chip
      backgroundColor: Theme.of(context).chipTheme.backgroundColor,
      selectedColor: _getColorForCodec(codec).withOpacity(isDark ? 0.7 : 1.0),
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        // CORREZIONE: Usa il colore del testo del tema Chip se non selezionato
        color: isSelected
            ? Colors.white
            : Theme.of(context).chipTheme.labelStyle?.color,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}