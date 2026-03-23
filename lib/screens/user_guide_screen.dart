import 'package:flutter/material.dart';
import 'package:video_converter_pro/l10n/app_localizations.dart';

/// Localized in-app user guide (feature overview and workflow).
class UserGuideScreen extends StatelessWidget {
  const UserGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final sections = <({String title, String body})>[
      (title: l10n.guideSectionQuickStartTitle, body: l10n.guideSectionQuickStartBody),
      (title: l10n.guideSectionFormatsTitle, body: l10n.guideSectionFormatsBody),
      (title: l10n.guideSectionVideoTitle, body: l10n.guideSectionVideoBody),
      (title: l10n.guideSectionAudioTitle, body: l10n.guideSectionAudioBody),
      (title: l10n.guideSectionImageTitle, body: l10n.guideSectionImageBody),
      (title: l10n.guideSectionQueueTitle, body: l10n.guideSectionQueueBody),
      (title: l10n.guideSectionSettingsTitle, body: l10n.guideSectionSettingsBody),
      (title: l10n.guideSectionModelsTitle, body: l10n.guideSectionModelsBody),
      (title: l10n.guideSectionDepsTitle, body: l10n.guideSectionDepsBody),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.userGuideTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.userGuideIntro,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          ...sections.map(
            (s) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ExpansionTile(
                title: Text(s.title, style: theme.textTheme.titleSmall),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(
                        s.body,
                        style: theme.textTheme.bodyMedium,
                      ),
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
