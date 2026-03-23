// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'FE Media Converter 🎬🎵🖼️';

  @override
  String get conversion => 'Konvertierung';

  @override
  String get queue => 'Warteschlange';

  @override
  String get settings => 'Einstellungen';

  @override
  String get about => 'Über';

  @override
  String get close => 'Schließen';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get remove => 'Entfernen';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Fortsetzen';

  @override
  String get stop => 'Stoppen';

  @override
  String get clear => 'Löschen';

  @override
  String get clearAll => 'Alles löschen';

  @override
  String get removeCompletedFiles => 'Remove completed files from queue?';

  @override
  String get waitingForConversion => 'Waiting for conversion';

  @override
  String get emptyEntireQueue => 'Empty entire queue?';

  @override
  String get conversionCompleted => 'Conversion completed';

  @override
  String get conversionFailed => 'Conversion failed';

  @override
  String get conversionPausedStatus => 'Conversion paused';

  @override
  String get removeFromQueueQuestion => 'Remove from queue?';

  @override
  String areYouSureRemove(Object fileName) {
    return 'Are you sure you want to remove $fileName?';
  }

  @override
  String areYouSureStop(Object fileName) {
    return 'Are you sure you want to stop $fileName?';
  }

  @override
  String get pauseConversionQuestion => 'Pause conversion?';

  @override
  String areYouSurePause(Object fileName) {
    return 'Are you sure you want to pause $fileName?';
  }

  @override
  String get stopConversionQuestion => 'Stop conversion?';

  @override
  String get browse => 'Durchsuchen';

  @override
  String get addToQueue => 'Zur Warteschlange hinzufügen';

  @override
  String get clearSelection => 'Auswahl löschen';

  @override
  String get videoCodec => 'Video-Codec';

  @override
  String get videoBitrate => 'Video-Bitrate';

  @override
  String get qualityMode => 'Qualitätsmodus';

  @override
  String get constantQuality => 'Konstante Qualität';

  @override
  String get constantBitrate => 'Konstante Bitrate';

  @override
  String get crfDescription => 'Behält konstante Qualität, variable Dateigröße';

  @override
  String get bitrateDescription => 'Behält konstante Dateigröße, variable Qualität';

  @override
  String get videoSettings => 'Video-Einstellungen';

  @override
  String get advancedVideoSettings => 'Erweiterte Video-Einstellungen';

  @override
  String get codecDescription => 'Video-Komprimierungsformat auswählen';

  @override
  String get bitrateMode => 'Bitraten-Modus';

  @override
  String get mediaType => 'Medientyp';

  @override
  String selectMedia(Object mediaType) {
    return '$mediaType auswählen';
  }

  @override
  String get noFilesSelected => 'Keine Dateien ausgewählt';

  @override
  String clickToBrowse(Object mediaType) {
    return 'Klicken Sie auf \"$mediaType durchsuchen\" um Dateien auszuwählen';
  }

  @override
  String filesSelected(Object count) {
    return '$count Dateien ausgewählt';
  }

  @override
  String get selectionCleared => 'Auswahl gelöscht';

  @override
  String filesAddedToQueue(Object count) {
    return '$count Dateien zur Warteschlange hinzugefügt';
  }

  @override
  String get dropFilesHere => 'Dateien hier ablegen, um sie hinzuzufügen';

  @override
  String get dragAndDropSupported => 'Dateien hier ziehen und ablegen';

  @override
  String outputFormat(Object mediaType) {
    return 'Ausgabeformat - $mediaType';
  }

  @override
  String get qualitySettings => 'Qualitätseinstellungen';

  @override
  String get videoQuality => 'Videoqualität:';

  @override
  String get audioQuality => 'Audioqualität:';

  @override
  String get videoFilters => 'Erweiterte Video-Filter';

  @override
  String get audioFilters => 'Professionelle Audio-Filter';

  @override
  String get conversionQueue => 'Konvertierungs-Warteschlange';

  @override
  String completedCount(Object completed, Object total) {
    return '$completed/$total abgeschlossen';
  }

  @override
  String get converting => 'Konvertierung läuft...';

  @override
  String get noFilesInQueue => 'Keine Dateien in der Warteschlange';

  @override
  String get addFilesFromConversion => 'Dateien von der Konvertierungsseite hinzufügen\num mit der Konvertierung zu beginnen';

  @override
  String get removeFromQueue => 'Aus Warteschlange entfernen';

  @override
  String get pauseConversion => 'Konvertierung pausieren';

  @override
  String get stopConversion => 'Konvertierung stoppen';

  @override
  String fileRemoved(Object fileName) {
    return '\"$fileName\" aus Warteschlange entfernt';
  }

  @override
  String filePaused(Object fileName) {
    return '\"$fileName\" pausiert';
  }

  @override
  String fileStopped(Object fileName) {
    return '\"$fileName\" gestoppt';
  }

  @override
  String get pending => 'Ausstehend';

  @override
  String get processing => 'Verarbeitung';

  @override
  String get paused => 'Pausiert';

  @override
  String get completed => 'Abgeschlossen';

  @override
  String get failed => 'Fehlgeschlagen';

  @override
  String get calculating => 'Berechnung läuft...';

  @override
  String get waiting => 'Warten';

  @override
  String get conversionInProgress => 'Konvertierung läuft';

  @override
  String pausedAt(Object time) {
    return 'Pausiert um $time';
  }

  @override
  String completedAt(Object time) {
    return 'Abgeschlossen $time';
  }

  @override
  String failedAt(Object time) {
    return 'Fehlgeschlagen $time';
  }

  @override
  String pausedAtTime(Object time) {
    return 'Paused at $time';
  }

  @override
  String completedAtTime(Object time) {
    return 'Completed at $time';
  }

  @override
  String failedAtTime(Object time) {
    return 'Failed at $time';
  }

  @override
  String get theme => 'Design';

  @override
  String get system => 'System';

  @override
  String get light => 'Hell';

  @override
  String get dark => 'Dunkel';

  @override
  String get language => 'Sprache';

  @override
  String get outputFolder => 'Ausgabeordner';

  @override
  String get sameAsInput => 'Gleich wie Eingabeordner';

  @override
  String get cpuThreads => 'CPU-Threads';

  @override
  String get autoDetect => 'Automatisch erkennen';

  @override
  String get concurrentConversions => 'Gleichzeitige Konvertierungen';

  @override
  String get concurrentConversionsDesc => 'Anzahl der gleichzeitig zu konvertierenden Dateien';

  @override
  String get gpuAcceleration => 'GPU-Beschleunigung';

  @override
  String get useGpu => 'GPU für Konvertierung verwenden';

  @override
  String get gpuCompatibility => 'Bessere Leistung, aber begrenzte Kompatibilität';

  @override
  String get requiresCompatibleHardware => 'Erfordert kompatible Hardware und Treiber';

  @override
  String get gpuType => 'GPU-Typ';

  @override
  String get autoDetection => 'Automatische Erkennung';

  @override
  String get selectGpuType => 'Art der installierten Grafikkarte auswählen';

  @override
  String get information => 'Informationen';

  @override
  String get version => 'Version';

  @override
  String get professionalMediaConversion => 'Professionelle Medienkonvertierungsanwendung';

  @override
  String get usesFfmpeg => 'Verwendet FFmpeg für Konvertierungen. Stellen Sie sicher, dass FFmpeg auf Ihrem System installiert ist.';

  @override
  String get extractAudioOnly => 'Nur Audio extrahieren';

  @override
  String get extractAudioFromVideo => 'Audio aus Videodateien extrahieren (z.B. MP4 zu MP3, MOV zu WAV)';

  @override
  String get video => 'Video';

  @override
  String get audio => 'Audio';

  @override
  String get image => 'Bild';

  @override
  String get videos => 'Videos';

  @override
  String get audios => 'Audios';

  @override
  String get images => 'Bilder';

  @override
  String get formats => 'Formate';

  @override
  String get filtersActive => 'Aktive Filter';

  @override
  String get resetAll => 'Alles zurücksetzen';

  @override
  String get noiseReduction => 'Rauschreduzierung';

  @override
  String get noiseReductionStrength => 'Stärke der Rauschreduzierung';

  @override
  String get reducesDigitalNoise => 'Reduziert digitales Rauschen und Körnung. Hohe Werte können das Bild weicher machen.';

  @override
  String get qualityEnhancement => 'Qualitätsverbesserung';

  @override
  String get sharpness => 'Schärfe';

  @override
  String get brightness => 'Helligkeit';

  @override
  String get contrast => 'Kontrast';

  @override
  String get saturation => 'Sättigung';

  @override
  String get gamma => 'Gamma';

  @override
  String get advancedCorrections => 'Erweiterte Korrekturen';

  @override
  String get videoStabilization => 'Video-Stabilisierung';

  @override
  String get reducesCameraShake => 'Reduziert Kamerawackeln';

  @override
  String get deinterlacing => 'Deinterlacing';

  @override
  String get removesInterlacedLines => 'Entfernt Zeilen aus Zeilensprung-Videos';

  @override
  String get colorProfiles => 'Farbprofile';

  @override
  String get none => 'Keine';

  @override
  String get vivid => 'Lebhaft';

  @override
  String get cinematic => 'Kinematisch';

  @override
  String get blackWhite => 'Schwarz-Weiß';

  @override
  String get sepia => 'Sepia';

  @override
  String get activeEffectsPreview => 'Vorschau aktiver Effekte:';

  @override
  String get noActiveFilters => 'Keine aktiven Filter';

  @override
  String get volumeDynamics => 'Lautstärke und Dynamik';

  @override
  String get volume => 'Lautstärke';

  @override
  String get compression => 'Kompression';

  @override
  String get normalization => 'Normalisierung';

  @override
  String get levelsVolumeAutomatically => 'Gleicht Lautstärke automatisch aus';

  @override
  String get equalizer => 'Equalizer';

  @override
  String get bass => 'Bässe';

  @override
  String get treble => 'Höhen';

  @override
  String get equalizerPreset => 'Equalizer-Voreinstellung:';

  @override
  String get bassBoost => 'Bass-Verstärkung';

  @override
  String get trebleBoost => 'Höhen-Verstärkung';

  @override
  String get voice => 'Stimme';

  @override
  String get audioCleaning => 'Audio-Bereinigung';

  @override
  String get removeNoise => 'Rauschen entfernen';

  @override
  String get reducesBackgroundHiss => 'Reduziert Hintergrundrauschen';

  @override
  String get noiseThreshold => 'Rauschschwelle';

  @override
  String get reverb => 'Hall';

  @override
  String get activeAudioEffects => 'Aktive Audio-Effekte:';

  @override
  String get noActiveAudioFilters => 'Keine aktiven Audio-Filter';

  @override
  String excellentQuality(Object crf) {
    return 'Ausgezeichnet (CRF: $crf)';
  }

  @override
  String greatQuality(Object crf) {
    return 'Sehr gut (CRF: $crf)';
  }

  @override
  String goodQuality(Object crf) {
    return 'Gut (CRF: $crf)';
  }

  @override
  String averageQuality(Object crf) {
    return 'Durchschnittlich (CRF: $crf)';
  }

  @override
  String lowQualityLabel(Object crf) {
    return 'Niedrig (CRF: $crf)';
  }

  @override
  String get crfScale => 'CRF: 0 (Beste) - 51 (Schlechteste)';

  @override
  String get bitrateScale => 'Bitrate: 64 kbps - 320 kbps';

  @override
  String get audioCodec => 'Audio-Codec';

  @override
  String get audioCodecDesc => 'Audio-Codec für die Ausgabedatei auswählen';

  @override
  String get aacDescription => 'AAC - High compatibility, good quality';

  @override
  String get mp3Description => 'MP3 - Maximum compatibility';

  @override
  String get flacDescription => 'FLAC - Lossless, maximum quality';

  @override
  String get opusDescription => 'Opus - Excellent efficiency';

  @override
  String get vorbisDescription => 'Vorbis - Open source, good quality';

  @override
  String get pcmDescription => 'PCM - Uncompressed audio';

  @override
  String audioCodecDefaultDescription(Object codec) {
    return 'Selected audio codec: $codec';
  }

  @override
  String get justNow => 'just now';

  @override
  String minutesAgo(Object minutes) {
    return '$minutes min ago';
  }

  @override
  String hoursAgo(Object hours) {
    return '$hours hours ago';
  }

  @override
  String daysAgo(Object days) {
    return '$days days ago';
  }

  @override
  String get error => 'Fehler';

  @override
  String get files => 'Dateien';

  @override
  String get customResolution => 'Benutzerdefinierte Auflösung';

  @override
  String get customWidth => 'Breite (px)';

  @override
  String get customHeight => 'Höhe (px)';

  @override
  String get originalResolution => 'Bildauflösung';

  @override
  String get previewOriginal => 'Original-Vorschau';

  @override
  String get previewModified => 'Modifizierte Vorschau';

  @override
  String get useCustomResolution => 'Benutzerdefinierte Auflösung verwenden';

  @override
  String get customResolutionDesc => 'Spezifische Breite und Höhe festlegen (z.B. 1920x1080)';

  @override
  String get loadingResolution => 'Auflösung wird geladen...';

  @override
  String get resolutionNotAvailable => 'Auflösung nicht verfügbar';

  @override
  String get selectImageForResolution => 'Ein Bild auswählen, um die Auflösung zu sehen';

  @override
  String get resolutionDescription => 'Eine spezifische Auflösung festlegen. Wenn Sie nur Breite oder Höhe festlegen, wird das Seitenverhältnis beibehalten.';

  @override
  String get previewDescription => 'Das Originalbild oder mit angewendeten Filtern anzeigen';

  @override
  String get advancedUpscalingAlgorithms => 'Double or quadruple the image resolution. Uses advanced upscaling algorithms.';

  @override
  String audioCodecSection(Object mediaType) {
    return 'Audio Codec - $mediaType';
  }

  @override
  String get ffmpegVersionCheck => 'FFmpeg-Versionsprüfung';

  @override
  String get ffmpegNotInstalled => 'FFmpeg ist nicht installiert oder die Version ist veraltet';

  @override
  String get ffmpegVersionRequired => 'Erforderliche Version: 8.0.1';

  @override
  String ffmpegCurrentVersion(Object version) {
    return 'Aktuelle Version: $version';
  }

  @override
  String get ffmpegNeedsUpdate => 'FFmpeg muss auf Version 8.0.1 aktualisiert werden';

  @override
  String get installFFmpeg => 'FFmpeg 8.0.1 installieren';

  @override
  String get installFFmpegDesc => 'Dies installiert FFmpeg 8.0.1 mit Administratorrechten. Das Passwort wird sicher für zukünftige Verwendung gespeichert.';

  @override
  String get enterSudoPassword => 'Administrator-Passwort eingeben';

  @override
  String get passwordRequired => 'Passwort ist erforderlich';

  @override
  String get installingFFmpeg => 'FFmpeg wird installiert...';

  @override
  String get ffmpegInstallSuccess => 'FFmpeg 8.0.1 erfolgreich installiert!';

  @override
  String ffmpegInstallFailed(Object error) {
    return 'FFmpeg-Installation fehlgeschlagen: $error';
  }

  @override
  String detectedDistribution(Object distro) {
    return 'Erkannte Distribution: $distro';
  }

  @override
  String get addingRepository => 'Repository wird hinzugefügt...';

  @override
  String get updatingPackages => 'Paketliste wird aktualisiert...';

  @override
  String get installingPackage => 'FFmpeg wird installiert...';

  @override
  String get passwordStored => 'Passwort sicher für zukünftige Installationen gespeichert';

  @override
  String get skipInstallation => 'Installation überspringen';

  @override
  String get manualInstall => 'Manuelle Installation';

  @override
  String get manualInstallDesc => 'Sie können FFmpeg manuell mit den untenstehenden Befehlen installieren';

  @override
  String get howToInstallFfmpeg => 'How to install FFmpeg';

  @override
  String get onFedora => 'On Fedora';

  @override
  String get onUbuntuDebian => 'On Ubuntu/Debian';

  @override
  String get onWindows => 'On Windows';

  @override
  String get onMacOS => 'On macOS';

  @override
  String get openTerminalAndRun => 'Open terminal and run';

  @override
  String get downloadFromFfmpeg => 'Download from FFmpeg website';

  @override
  String get useHomebrew => 'Use Homebrew';

  @override
  String get afterInstallingRestart => 'After installing, restart the application';

  @override
  String get clickToOpenGuide => 'Click to open installation guide';

  @override
  String get audioPreview => 'Audio-Vorschau';

  @override
  String get audioPreviewDescription => 'Hören Sie das Original-Audio oder mit angewendeten Filtern';

  @override
  String get openWithSystemPlayer => 'Mit System-Player öffnen';

  @override
  String get audioFileReady => 'Audio-Datei bereit für Wiedergabe';

  @override
  String get modifiedAudioGenerated => 'Modifiziertes Audio generiert (erste 10 Sekunden)';

  @override
  String get fileWillOpenWithDefaultPlayer => 'Die Datei wird mit dem Standard-Audio-Player des Systems geöffnet';

  @override
  String get videoQualityMode => 'Videoqualitätsmodus';

  @override
  String get constantQualityLabel => 'CRF (Konstante Qualität)';

  @override
  String get constantBitrateLabel => 'Bitrate (Dateigröße)';

  @override
  String get videoBitrateLabel => 'Video-Bitrate';

  @override
  String get crfQualityRange => 'CRF: 0 (Beste Qualität) - 51 (Schlechteste Qualität)';

  @override
  String get bitrateQualityRange => 'Bitrate: 500 kbps (Niedrige Qualität) - 20,000 kbps (Sehr hohe Qualität)';

  @override
  String get qualityLabel => 'Qualität:';

  @override
  String get videoCodecDescriptionLibx264 => 'Excellent compatibility, good compression';

  @override
  String get videoCodecDescriptionLibx265 => 'Better compression, limited compatibility';

  @override
  String get videoCodecDescriptionLibvpx => 'Open source codec for Web';

  @override
  String get videoCodecDescriptionLibvpxVp9 => 'Modern codec for high quality';

  @override
  String get videoCodecDescriptionMpeg4 => 'Universal compatibility';

  @override
  String get videoCodecDescriptionLibaomAv1 => 'Next-gen codec, advanced compression';

  @override
  String get videoCodecDescriptionDefault => 'Video codec';

  @override
  String get audioQualityHighest => 'Höchste Qualität (Verlustfrei)';

  @override
  String get audioQualityHigh => 'Hohe Qualität (Transparenz)';

  @override
  String get audioQualityMedium => 'Mittlere Qualität (Gutes Gleichgewicht)';

  @override
  String get audioQualityLow => 'Niedrige Qualität (Kompatibilität)';

  @override
  String get selectVideoForAnalysis => 'Wählen Sie ein Video für die automatische Analyse';

  @override
  String get analyzeVideoQuality => 'Videoqualität analysieren';

  @override
  String get analyzingVideoQuality => 'Videoqualität wird analysiert...';

  @override
  String get videoAnalyzedNoIssues => 'Video analysiert - Keine kritischen Probleme';

  @override
  String problemsDetectedRecommendations(Object problems, Object recommendations) {
    return '$problems Probleme erkannt - $recommendations Empfehlungen';
  }

  @override
  String get intelligentVideoAnalysis => 'Intelligente Videoanalyse';

  @override
  String get automaticOptimizations => 'Automatische Optimierungen';

  @override
  String get autoOptimization => 'Automatische Optimierung';

  @override
  String get autoOptimizationDesc => 'Beste Einstellungen basierend auf Analyse anwenden';

  @override
  String get lowQuality => 'Niedrige Qualität ⭐';

  @override
  String get lowQualityDesc => 'MAXIMALE OPTIMIERUNG für Videos niedriger Qualität mit viel Rauschen';

  @override
  String get ultraQuality => 'Ultra-Qualität';

  @override
  String get ultraQualityDesc => 'Professionelle Verbesserung mit allen erweiterten Filtern';

  @override
  String get lowLight => 'Schwaches Licht';

  @override
  String get lowLightDesc => 'Verbessert Videos bei schlechten Lichtverhältnissen';

  @override
  String get detailRecovery => 'Detailwiederherstellung';

  @override
  String get detailRecoveryDesc => 'Wiederherstellung verlorener Details und Texturen';

  @override
  String get compressionFix => 'Komprimierungsfehler beheben';

  @override
  String get compressionFixDesc => 'Entfernt Artefakte von starker Komprimierung';

  @override
  String get filmRestoration => 'Filmrestaurierung';

  @override
  String get filmRestorationDesc => 'Optimiert für alte Videos und Filme';

  @override
  String get fundamentalFilters => 'Grundlegende Filter';

  @override
  String get qualityAndDetails => 'Qualität und Details';

  @override
  String get noiseReductionLabel => 'Rauschreduzierung';

  @override
  String get colorAndLight => 'Farbe und Licht';

  @override
  String get redBalance => 'Rot-Balance';

  @override
  String get greenBalance => 'Grün-Balance';

  @override
  String get blueBalance => 'Blau-Balance';

  @override
  String get deinterlacingLabel => 'Deinterlacing';

  @override
  String get deinterlacingDesc => 'Entfernt Zeilensprung von älteren Videos';

  @override
  String get stabilizationLabel => 'Stabilisierung';

  @override
  String get stabilizationDesc => 'Reduziert Kamerawackeln';

  @override
  String get detailEnhancement => 'Detailverbesserung';

  @override
  String get detailEnhancementDesc => 'Verbessert die Detaildefinition';

  @override
  String get gpuAccelerationLabel => 'GPU-Beschleunigung';

  @override
  String get useGpuForConversion => 'GPU für Konvertierung verwenden';

  @override
  String get useGpuForConversionDesc => 'Verschiebt Video-Encoding auf Grafikkarte (falls verfügbar)';

  @override
  String get gpuPreset => 'GPU-Voreinstellung (Geschwindigkeit vs. Qualität)';

  @override
  String get gpuPresetFast => 'Schnell';

  @override
  String get gpuPresetFastDesc => 'Maximale Geschwindigkeit, leicht niedrigere Qualität';

  @override
  String get gpuPresetMedium => 'Mittel';

  @override
  String get gpuPresetMediumDesc => 'Ausgewogen zwischen Geschwindigkeit und Qualität (empfohlen)';

  @override
  String get gpuPresetHighQuality => 'Hohe Qualität';

  @override
  String get gpuPresetHighQualityDesc => 'Beste mögliche Qualität, langsamere Konvertierung';

  @override
  String get drunetDenoisingTitle => 'DRUNet (AI denoising)';

  @override
  String get drunetDenoisingDesc => 'Deep learning denoising when drunet_model.pth is in models/drunet/. On by default.';

  @override
  String get sceneDetectionTitle => 'Scene detection (PySceneDetect)';

  @override
  String get sceneDetectionDesc => 'Scene analysis for smarter encoding hints. On by default.';

  @override
  String get useSceneOptimizationTitle => 'Scene-based optimization';

  @override
  String get useSceneOptimizationDesc => 'Apply bitrate/quality recommendations from scene analysis.';

  @override
  String get noneLabel => 'Keine';

  @override
  String get vividLabel => 'Lebhaft';

  @override
  String get cinematicLabel => 'Kinematisch';

  @override
  String get blackWhiteLabel => 'Schwarz-Weiß';

  @override
  String get sepiaLabel => 'Sepia';

  @override
  String get imageFiltersTitle => 'Bildfilter';

  @override
  String get qualityEnhancementLabel => 'Qualitätsverbesserung';

  @override
  String get imageUpscaling => 'Bild-Upscaling';

  @override
  String get enableImageUpscaling => 'Upscaling aktivieren';

  @override
  String get enableImageUpscalingDesc => 'Erhöht die Bildauflösung';

  @override
  String get upscalingFactor => 'Upscaling-Faktor';

  @override
  String get upscalingDisabledWithCustom => 'Upscaling ist deaktiviert, wenn benutzerdefinierte Auflösung verwendet wird.';

  @override
  String get imageColorProfiles => 'Farbprofile';

  @override
  String get userGuideMenu => 'Anleitung';

  @override
  String get userGuideTitle => 'Benutzerhandbuch';

  @override
  String get userGuideIntro => 'Kurzüberblick über FE Media Converter: Medientyp wählen, Dateien hinzufügen, Format und Qualität festlegen, optional Filter anpassen, dann über die Warteschlange konvertieren. Einstellungen bleiben erhalten.';

  @override
  String get guideSectionQuickStartTitle => 'Schnellstart';

  @override
  String get guideSectionQuickStartBody => '1) Links Video, Audio oder Bild wählen.\n2) Durchsuchen oder Dateien per Drag & Drop hinzufügen.\n3) Ausgabeformat und Codecs wählen.\n4) Qualität (CRF oder Bitrate) anpassen.\n5) Zur Warteschlange hinzufügen, Tab „Warteschlange“ öffnen und starten.\n6) Einstellungen: Ausgabeordner, Thema, Sprache, CPU-Threads und GPU.';

  @override
  String get guideSectionFormatsTitle => 'Formate und Codecs';

  @override
  String get guideSectionFormatsBody => 'Jeder Modus hat eigene Presets. Video: z. B. H.264, HEVC, VP9, AV1. Audio: AAC, MP3, Opus, FLAC usw. Bilder: PNG, JPEG, WebP. Nur-Audio aus Video möglich, wenn in den Einstellungen aktiviert.';

  @override
  String get guideSectionVideoTitle => 'Video: Filter und KI';

  @override
  String get guideSectionVideoBody => 'Erweiterte Filter: Rauschreduzierung, Schärfe, Farbe (Helligkeit, Kontrast, Sättigung, Gamma, RGB), Stabilisierung, Deinterlacing, Farbprofile. Intelligente Analyse kann Optimierungen vorschlagen (wenig Licht, starke Kompression, alter Filmlook).\nOptionales DRUNet-Entrauschen lädt ein neuronales Modell. Szenenerkennung (PySceneDetect) analysiert Schnitte; Szenenoptimierung wendet Hinweise an.\nGPU-Beschleunigung nutzt die Grafikkarte; Preset für Tempo vs. Qualität wählen.';

  @override
  String get guideSectionAudioTitle => 'Audiofilter';

  @override
  String get guideSectionAudioBody => 'Lautstärke, Kompression, Normalisierung. Equalizer mit Bass/Höhen und Presets (z. B. Bass Boost, Stimme). Rauschreduzierung; Hall. Vorschau vergleicht Original und bearbeitetes Audio wo verfügbar.';

  @override
  String get guideSectionImageTitle => 'Bilder: Auflösung und Upscaling';

  @override
  String get guideSectionImageBody => 'Qualitäts- und Farbanpassungen ähnlich wie bei Video. Eigene Breite/Höhe oder Seitenverhältnis beibehalten. Superauflösung erhöht die Auflösung; deaktiviert bei Konflikt mit fester Auflösung. Farbprofile für schnelle Looks.';

  @override
  String get guideSectionQueueTitle => 'Warteschlange und Parallelität';

  @override
  String get guideSectionQueueBody => 'Die Warteschlange zeigt ausstehende, laufende, pausierte, fertige und fehlgeschlagene Jobs. Pausieren, fortsetzen, stoppen oder entfernen. Gleichzeitige Konvertierungen in den Einstellungen steuern die CPU-Last.';

  @override
  String get guideSectionSettingsTitle => 'Einstellungen';

  @override
  String get guideSectionSettingsBody => 'Leerer Ausgabeordner = neben jeder Quelldatei. CPU-Threads begrenzen FFmpeg (0 = automatisch). Thema und Sprache nach Bestätigung. Standardformate und Codecs werden pro Medientyp gespeichert.';

  @override
  String get guideSectionModelsTitle => 'Modelle und Python';

  @override
  String get guideSectionModelsBody => 'DRUNet und Szenen-Skripte nutzen die Python-Umgebung der App. Beim ersten Start Download der DRUNet-Gewichte (~125 MB) möglich. Modellordner in den Einstellungen ändern; Standard-Cache im Home-Verzeichnis.';

  @override
  String get guideSectionDepsTitle => 'FFmpeg und Startprüfung';

  @override
  String get guideSectionDepsBody => 'FFmpeg muss installiert und aktuell sein. Bei der Abhängigkeitsansicht geführte oder manuelle Installation, dann erneut versuchen. Python 3 und pip/venv für optionale Funktionen.';

  @override
  String get pythonSetupTitle => 'Optionale Python-Komponenten';

  @override
  String get pythonSetupIntro => 'DRUNet und Szenenerkennung nutzen eine lokale Python-venv mit PyTorch usw. Der Download kann groß sein und erfolgt beim ersten App-Start, nicht bei der Paketinstallation.\n\nJetzt installieren oder überspringen und die App ohne diese Funktionen nutzen.';

  @override
  String get pythonSetupInstall => 'Herunterladen und installieren';

  @override
  String get pythonSetupSkip => 'Vorerst überspringen';

  @override
  String get pythonSetupRunning => 'Pakete werden installiert (kann einige Minuten dauern)…';

  @override
  String get pythonSetupPleaseWait => 'Bitte warten…';

  @override
  String get pythonSetupSuccess => 'Python-Umgebung bereit. DRUNet und Szenen-Tools sind nutzbar.';

  @override
  String pythonSetupFailed(int code) {
    return 'Fehler (Exit-Code: $code). Erneut versuchen oder scripts/python/setup_python_env.sh manuell ausführen.';
  }

  @override
  String get pythonSetupRetry => 'Erneut versuchen';
}
