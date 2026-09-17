import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// URL ufficiale del progetto (AppStream, GNOME Software, schermata Informazioni).
const String kAppRepositoryUrl =
    'https://github.com/sviluppoarte1-lang/Fe-Media-Converter';

/// Log solo in debug: in release non produce output (meno rumore in console / journal).
void appLog(String message, {String name = 'FEConverter', int level = 800}) {
  if (!kDebugMode) return;
  developer.log(message, name: name, level: level);
}
