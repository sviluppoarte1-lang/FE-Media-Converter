import 'package:flutter/material.dart';
import 'package:video_converter_pro/models/media_type.dart';
import 'package:video_converter_pro/l10n/app_localizations.dart';

class MediaTypeSelector extends StatelessWidget {
  final MediaType selectedType;
  final ValueChanged<MediaType> onTypeChanged;

  const MediaTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.mediaType,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Column(
              children: MediaType.values.map((type) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: _MediaTypeCard(
                    type: type,
                    isSelected: selectedType == type,
                    onTap: () => onTypeChanged(type),
                    l10n: l10n,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaTypeCard extends StatelessWidget {
  final MediaType type;
  final bool isSelected;
  final VoidCallback onTap;
  final AppLocalizations l10n;

  const _MediaTypeCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 1,
      // CORREZIONE 1: Usa cardColor del tema scuro quando non selezionato
      color: isSelected
      ? _getColorForType(type).withOpacity(0.1)
      : Theme.of(context).cardColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Text(
                type.icon,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTypeName(type, l10n),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        // CORREZIONE 2: Usa il colore del testo del tema quando non selezionato
                        color: isSelected
                        ? _getColorForType(type)
                        : Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${type.supportedFormats.length} ${l10n.formats.toLowerCase()}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: _getColorForType(type),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorForType(MediaType type) {
    switch (type) {
      case MediaType.video:
        return Colors.blue;
      case MediaType.audio:
        return Colors.green;
      case MediaType.image:
        return Colors.orange;
    }
  }

  String _getTypeName(MediaType type, AppLocalizations l10n) {
    switch (type) {
      case MediaType.video:
        return l10n.video;
      case MediaType.audio:
        return l10n.audio;
      case MediaType.image:
        return l10n.image;
    }
  }
}
