// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'FE Media Converter 🎬🎵🖼️';

  @override
  String get conversion => 'Conversion';

  @override
  String get queue => 'File d\'attente';

  @override
  String get settings => 'Paramètres';

  @override
  String get about => 'À propos';

  @override
  String get close => 'Fermer';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Annuler';

  @override
  String get remove => 'Retirer';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Reprendre';

  @override
  String get stop => 'Arrêter';

  @override
  String get clear => 'Effacer';

  @override
  String get clearAll => 'Tout effacer';

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
  String get browse => 'Parcourir';

  @override
  String get addToQueue => 'Ajouter à la file';

  @override
  String get clearSelection => 'Effacer la sélection';

  @override
  String get videoCodec => 'Codec vidéo';

  @override
  String get videoBitrate => 'Débit vidéo';

  @override
  String get qualityMode => 'Mode qualité';

  @override
  String get constantQuality => 'Qualité constante';

  @override
  String get constantBitrate => 'Débit constant';

  @override
  String get crfDescription => 'Maintient une qualité constante, taille de fichier variable';

  @override
  String get bitrateDescription => 'Maintient une taille de fichier constante, qualité variable';

  @override
  String get videoSettings => 'Paramètres vidéo';

  @override
  String get advancedVideoSettings => 'Paramètres vidéo avancés';

  @override
  String get codecDescription => 'Sélectionner le format de compression vidéo';

  @override
  String get bitrateMode => 'Mode débit';

  @override
  String get mediaType => 'Type de média';

  @override
  String selectMedia(Object mediaType) {
    return 'Sélectionner $mediaType';
  }

  @override
  String get noFilesSelected => 'Aucun fichier sélectionné';

  @override
  String clickToBrowse(Object mediaType) {
    return 'Cliquez sur \"Parcourir $mediaType\" pour sélectionner des fichiers';
  }

  @override
  String filesSelected(Object count) {
    return '$count fichiers sélectionnés';
  }

  @override
  String get selectionCleared => 'Sélection effacée';

  @override
  String filesAddedToQueue(Object count) {
    return '$count fichiers ajoutés à la file';
  }

  @override
  String get dropFilesHere => 'Déposez les fichiers ici pour les ajouter';

  @override
  String get dragAndDropSupported => 'Glissez-déposez les fichiers ici';

  @override
  String outputFormat(Object mediaType) {
    return 'Format de sortie - $mediaType';
  }

  @override
  String get qualitySettings => 'Paramètres de qualité';

  @override
  String get videoQuality => 'Qualité vidéo :';

  @override
  String get audioQuality => 'Qualité audio :';

  @override
  String get videoFilters => 'Filtres vidéo avancés';

  @override
  String get audioFilters => 'Filtres audio professionnels';

  @override
  String get conversionQueue => 'File de conversion';

  @override
  String completedCount(Object completed, Object total) {
    return '$completed/$total terminés';
  }

  @override
  String get converting => 'Conversion en cours...';

  @override
  String get noFilesInQueue => 'Aucun fichier dans la file';

  @override
  String get addFilesFromConversion => 'Ajoutez des fichiers depuis la page Conversion\npour commencer la conversion';

  @override
  String get removeFromQueue => 'Retirer de la file';

  @override
  String get pauseConversion => 'Mettre en pause la conversion';

  @override
  String get stopConversion => 'Arrêter la conversion';

  @override
  String fileRemoved(Object fileName) {
    return '\"$fileName\" retiré de la file';
  }

  @override
  String filePaused(Object fileName) {
    return '\"$fileName\" en pause';
  }

  @override
  String fileStopped(Object fileName) {
    return '\"$fileName\" arrêté';
  }

  @override
  String get pending => 'En attente';

  @override
  String get processing => 'Traitement';

  @override
  String get paused => 'En pause';

  @override
  String get completed => 'Terminé';

  @override
  String get failed => 'Échoué';

  @override
  String get calculating => 'Calcul en cours...';

  @override
  String get waiting => 'En attente';

  @override
  String get conversionInProgress => 'Conversion en cours';

  @override
  String pausedAt(Object time) {
    return 'En pause à $time';
  }

  @override
  String completedAt(Object time) {
    return 'Terminé $time';
  }

  @override
  String failedAt(Object time) {
    return 'Échoué $time';
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
  String get theme => 'Thème';

  @override
  String get system => 'Système';

  @override
  String get light => 'Clair';

  @override
  String get dark => 'Sombre';

  @override
  String get language => 'Langue';

  @override
  String get outputFolder => 'Dossier de sortie';

  @override
  String get sameAsInput => 'Identique au dossier d\'entrée';

  @override
  String get cpuThreads => 'Threads CPU';

  @override
  String get autoDetect => 'Détection automatique';

  @override
  String get concurrentConversions => 'Conversions simultanées';

  @override
  String get concurrentConversionsDesc => 'Nombre de fichiers à convertir simultanément';

  @override
  String get gpuAcceleration => 'Accélération GPU';

  @override
  String get useGpu => 'Utiliser le GPU pour la conversion';

  @override
  String get gpuCompatibility => 'Meilleures performances mais compatibilité limitée';

  @override
  String get requiresCompatibleHardware => 'Nécessite un matériel et des pilotes compatibles';

  @override
  String get gpuType => 'Type de GPU';

  @override
  String get autoDetection => 'Détection automatique';

  @override
  String get selectGpuType => 'Sélectionner le type de carte graphique installée';

  @override
  String get information => 'Informations';

  @override
  String get version => 'Version';

  @override
  String get professionalMediaConversion => 'Application professionnelle de conversion multimédia';

  @override
  String get usesFfmpeg => 'Utilise FFmpeg pour les conversions. Assurez-vous que FFmpeg est installé sur votre système.';

  @override
  String get extractAudioOnly => 'Extraire uniquement l\'audio';

  @override
  String get extractAudioFromVideo => 'Extraire l\'audio des fichiers vidéo (ex. MP4 vers MP3, MOV vers WAV)';

  @override
  String get video => 'Vidéo';

  @override
  String get audio => 'Audio';

  @override
  String get image => 'Image';

  @override
  String get videos => 'Vidéos';

  @override
  String get audios => 'Audios';

  @override
  String get images => 'Images';

  @override
  String get formats => 'formats';

  @override
  String get filtersActive => 'Filtres actifs';

  @override
  String get resetAll => 'Tout réinitialiser';

  @override
  String get noiseReduction => 'Réduction du bruit';

  @override
  String get noiseReductionStrength => 'Intensité de réduction du bruit';

  @override
  String get reducesDigitalNoise => 'Réduit le bruit numérique et le grain. Des valeurs élevées peuvent adoucir l\'image.';

  @override
  String get qualityEnhancement => 'Amélioration de la qualité';

  @override
  String get sharpness => 'Netteté';

  @override
  String get brightness => 'Luminosité';

  @override
  String get contrast => 'Contraste';

  @override
  String get saturation => 'Saturation';

  @override
  String get gamma => 'Gamma';

  @override
  String get advancedCorrections => 'Corrections avancées';

  @override
  String get videoStabilization => 'Stabilisation vidéo';

  @override
  String get reducesCameraShake => 'Réduit les tremblements de caméra';

  @override
  String get deinterlacing => 'Désentrelacement';

  @override
  String get removesInterlacedLines => 'Supprime les lignes des vidéos entrelacées';

  @override
  String get colorProfiles => 'Profils de couleur';

  @override
  String get none => 'Aucun';

  @override
  String get vivid => 'Vif';

  @override
  String get cinematic => 'Cinématique';

  @override
  String get blackWhite => 'Noir et blanc';

  @override
  String get sepia => 'Sépia';

  @override
  String get activeEffectsPreview => 'Aperçu des effets actifs :';

  @override
  String get noActiveFilters => 'Aucun filtre actif';

  @override
  String get volumeDynamics => 'Volume et dynamique';

  @override
  String get volume => 'Volume';

  @override
  String get compression => 'Compression';

  @override
  String get normalization => 'Normalisation';

  @override
  String get levelsVolumeAutomatically => 'Égalise le volume automatiquement';

  @override
  String get equalizer => 'Égaliseur';

  @override
  String get bass => 'Graves';

  @override
  String get treble => 'Aigus';

  @override
  String get equalizerPreset => 'Préréglage égaliseur :';

  @override
  String get bassBoost => 'Renforcement des graves';

  @override
  String get trebleBoost => 'Renforcement des aigus';

  @override
  String get voice => 'Voix';

  @override
  String get audioCleaning => 'Nettoyage audio';

  @override
  String get removeNoise => 'Supprimer le bruit';

  @override
  String get reducesBackgroundHiss => 'Réduit le sifflement de fond';

  @override
  String get noiseThreshold => 'Seuil de bruit';

  @override
  String get reverb => 'Réverbération';

  @override
  String get activeAudioEffects => 'Effets audio actifs :';

  @override
  String get noActiveAudioFilters => 'Aucun filtre audio actif';

  @override
  String excellentQuality(Object crf) {
    return 'Excellent (CRF : $crf)';
  }

  @override
  String greatQuality(Object crf) {
    return 'Très bon (CRF : $crf)';
  }

  @override
  String goodQuality(Object crf) {
    return 'Bon (CRF : $crf)';
  }

  @override
  String averageQuality(Object crf) {
    return 'Moyen (CRF : $crf)';
  }

  @override
  String lowQualityLabel(Object crf) {
    return 'Faible (CRF: $crf)';
  }

  @override
  String get crfScale => 'CRF : 0 (Meilleur) - 51 (Pire)';

  @override
  String get bitrateScale => 'Débit : 64 kbps - 320 kbps';

  @override
  String get audioCodec => 'Codec audio';

  @override
  String get audioCodecDesc => 'Sélectionner le codec audio pour le fichier de sortie';

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
  String get error => 'Erreur';

  @override
  String get files => 'fichiers';

  @override
  String get customResolution => 'Résolution personnalisée';

  @override
  String get customWidth => 'Largeur (px)';

  @override
  String get customHeight => 'Hauteur (px)';

  @override
  String get originalResolution => 'Résolution de l\'image';

  @override
  String get previewOriginal => 'Aperçu original';

  @override
  String get previewModified => 'Aperçu modifié';

  @override
  String get useCustomResolution => 'Utiliser une résolution personnalisée';

  @override
  String get customResolutionDesc => 'Définir une largeur et une hauteur spécifiques (ex. 1920x1080)';

  @override
  String get loadingResolution => 'Chargement de la résolution...';

  @override
  String get resolutionNotAvailable => 'Résolution non disponible';

  @override
  String get selectImageForResolution => 'Sélectionner une image pour voir la résolution';

  @override
  String get resolutionDescription => 'Définir une résolution spécifique. Si vous définissez uniquement la largeur ou la hauteur, le ratio d\'aspect est maintenu.';

  @override
  String get previewDescription => 'Voir l\'image originale ou avec les filtres appliqués';

  @override
  String get advancedUpscalingAlgorithms => 'Double or quadruple the image resolution. Uses advanced upscaling algorithms.';

  @override
  String audioCodecSection(Object mediaType) {
    return 'Audio Codec - $mediaType';
  }

  @override
  String get ffmpegVersionCheck => 'Vérification de la version FFmpeg';

  @override
  String get ffmpegNotInstalled => 'FFmpeg n\'est pas installé ou la version est obsolète';

  @override
  String get ffmpegVersionRequired => 'Version requise : 8.0.1';

  @override
  String ffmpegCurrentVersion(Object version) {
    return 'Version actuelle : $version';
  }

  @override
  String get ffmpegNeedsUpdate => 'FFmpeg doit être mis à jour vers la version 8.0.1';

  @override
  String get installFFmpeg => 'Installer FFmpeg 8.0.1';

  @override
  String get installFFmpegDesc => 'Cela installera FFmpeg 8.0.1 en utilisant les privilèges d\'administrateur. Le mot de passe sera stocké de manière sécurisée pour une utilisation future.';

  @override
  String get enterSudoPassword => 'Entrer le mot de passe administrateur';

  @override
  String get passwordRequired => 'Le mot de passe est requis';

  @override
  String get installingFFmpeg => 'Installation de FFmpeg...';

  @override
  String get ffmpegInstallSuccess => 'FFmpeg 8.0.1 installé avec succès !';

  @override
  String ffmpegInstallFailed(Object error) {
    return 'Échec de l\'installation de FFmpeg : $error';
  }

  @override
  String detectedDistribution(Object distro) {
    return 'Distribution détectée : $distro';
  }

  @override
  String get addingRepository => 'Ajout du dépôt...';

  @override
  String get updatingPackages => 'Mise à jour de la liste des paquets...';

  @override
  String get installingPackage => 'Installation de FFmpeg...';

  @override
  String get passwordStored => 'Mot de passe stocké de manière sécurisée pour les installations futures';

  @override
  String get skipInstallation => 'Ignorer l\'installation';

  @override
  String get manualInstall => 'Installation manuelle';

  @override
  String get manualInstallDesc => 'Vous pouvez installer FFmpeg manuellement en utilisant les commandes ci-dessous';

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
  String get audioPreview => 'Aperçu audio';

  @override
  String get audioPreviewDescription => 'Écouter l\'audio original ou avec les filtres appliqués';

  @override
  String get openWithSystemPlayer => 'Ouvrir avec le lecteur système';

  @override
  String get audioFileReady => 'Fichier audio prêt pour la lecture';

  @override
  String get modifiedAudioGenerated => 'Audio modifié généré (10 premières secondes)';

  @override
  String get fileWillOpenWithDefaultPlayer => 'Le fichier s\'ouvrira avec le lecteur audio par défaut du système';

  @override
  String get videoQualityMode => 'Mode qualité vidéo';

  @override
  String get constantQualityLabel => 'CRF (Qualité constante)';

  @override
  String get constantBitrateLabel => 'Débit (Taille de fichier)';

  @override
  String get videoBitrateLabel => 'Débit vidéo';

  @override
  String get crfQualityRange => 'CRF : 0 (Meilleure qualité) - 51 (Pire qualité)';

  @override
  String get bitrateQualityRange => 'Débit : 500 kbps (Faible qualité) - 20,000 kbps (Très haute qualité)';

  @override
  String get qualityLabel => 'Qualité :';

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
  String get audioQualityHighest => 'Qualité la plus élevée (Sans perte)';

  @override
  String get audioQualityHigh => 'Haute qualité (Transparence)';

  @override
  String get audioQualityMedium => 'Qualité moyenne (Bon équilibre)';

  @override
  String get audioQualityLow => 'Faible qualité (Compatibilité)';

  @override
  String get selectVideoForAnalysis => 'Sélectionner une vidéo pour l\'analyse automatique';

  @override
  String get analyzeVideoQuality => 'Analyser la qualité vidéo';

  @override
  String get analyzingVideoQuality => 'Analyse de la qualité vidéo...';

  @override
  String get videoAnalyzedNoIssues => 'Vidéo analysée - Aucun problème critique';

  @override
  String problemsDetectedRecommendations(Object problems, Object recommendations) {
    return '$problems problèmes détectés - $recommendations recommandations';
  }

  @override
  String get intelligentVideoAnalysis => 'Analyse vidéo intelligente';

  @override
  String get automaticOptimizations => 'Optimisations automatiques';

  @override
  String get autoOptimization => 'Optimisation automatique';

  @override
  String get autoOptimizationDesc => 'Appliquer les meilleurs paramètres basés sur l\'analyse';

  @override
  String get lowQuality => 'Basse qualité ⭐';

  @override
  String get lowQualityDesc => 'OPTIMISATION MAXIMALE pour vidéos de basse qualité avec beaucoup de bruit';

  @override
  String get ultraQuality => 'Qualité ultra';

  @override
  String get ultraQualityDesc => 'Amélioration professionnelle avec tous les filtres avancés';

  @override
  String get lowLight => 'Faible éclairage';

  @override
  String get lowLightDesc => 'Améliore les vidéos en conditions de faible éclairage';

  @override
  String get detailRecovery => 'Restauration des détails';

  @override
  String get detailRecoveryDesc => 'Récupère les détails et textures perdus';

  @override
  String get compressionFix => 'Correction de compression';

  @override
  String get compressionFixDesc => 'Supprime les artefacts de compression lourde';

  @override
  String get filmRestoration => 'Restauration de film';

  @override
  String get filmRestorationDesc => 'Optimisé pour vidéos anciennes et films';

  @override
  String get fundamentalFilters => 'Filtres fondamentaux';

  @override
  String get qualityAndDetails => 'Qualité et détails';

  @override
  String get noiseReductionLabel => 'Réduction du bruit';

  @override
  String get colorAndLight => 'Couleur et lumière';

  @override
  String get redBalance => 'Équilibre rouge';

  @override
  String get greenBalance => 'Équilibre vert';

  @override
  String get blueBalance => 'Équilibre bleu';

  @override
  String get deinterlacingLabel => 'Désentrelacement';

  @override
  String get deinterlacingDesc => 'Supprime les lignes entrelacées des vidéos plus anciennes';

  @override
  String get stabilizationLabel => 'Stabilisation';

  @override
  String get stabilizationDesc => 'Réduit les tremblements de la caméra';

  @override
  String get detailEnhancement => 'Amélioration des détails';

  @override
  String get detailEnhancementDesc => 'Améliore la définition des détails';

  @override
  String get gpuAccelerationLabel => 'Accélération GPU';

  @override
  String get useGpuForConversion => 'Utiliser GPU pour la conversion';

  @override
  String get useGpuForConversionDesc => 'Déplace l\'encodage vidéo vers la carte graphique (si disponible)';

  @override
  String get gpuPreset => 'Préréglage GPU (vitesse vs qualité)';

  @override
  String get gpuPresetFast => 'Rapide';

  @override
  String get gpuPresetFastDesc => 'Vitesse maximale, qualité légèrement inférieure';

  @override
  String get gpuPresetMedium => 'Moyen';

  @override
  String get gpuPresetMediumDesc => 'Équilibré entre vitesse et qualité (recommandé)';

  @override
  String get gpuPresetHighQuality => 'Haute qualité';

  @override
  String get gpuPresetHighQualityDesc => 'Meilleure qualité possible, conversion plus lente';

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
  String get noneLabel => 'Aucun';

  @override
  String get vividLabel => 'Vif';

  @override
  String get cinematicLabel => 'Cinématographique';

  @override
  String get blackWhiteLabel => 'Noir et blanc';

  @override
  String get sepiaLabel => 'Sépia';

  @override
  String get imageFiltersTitle => 'Filtres d\'image';

  @override
  String get qualityEnhancementLabel => 'Amélioration de la qualité';

  @override
  String get imageUpscaling => 'Upscaling d\'image';

  @override
  String get enableImageUpscaling => 'Activer l\'upscaling';

  @override
  String get enableImageUpscalingDesc => 'Augmenter la résolution de l\'image';

  @override
  String get upscalingFactor => 'Facteur d\'upscaling';

  @override
  String get upscalingDisabledWithCustom => 'L\'upscaling est désactivé lors de l\'utilisation de la résolution personnalisée.';

  @override
  String get imageColorProfiles => 'Profils de couleur';

  @override
  String get userGuideMenu => 'Guide';

  @override
  String get userGuideTitle => 'Guide d\'utilisation';

  @override
  String get userGuideIntro => 'Ce guide résume FE Media Converter : choisissez le type de média, ajoutez des fichiers, le format et la qualité, ajustez les filtres si besoin, puis utilisez la file d\'attente. Les réglages sont conservés entre les sessions.';

  @override
  String get guideSectionQuickStartTitle => 'Démarrage rapide';

  @override
  String get guideSectionQuickStartBody => '1) Choisissez Vidéo, Audio ou Image à gauche.\n2) Parcourez ou glissez-déposez des fichiers.\n3) Choisissez le format de sortie et les codecs.\n4) Ajustez la qualité (CRF ou débit).\n5) Ajoutez à la file, ouvrez l\'onglet File d\'attente et lancez la conversion.\n6) Paramètres : dossier de sortie, thème, langue, threads CPU et GPU.';

  @override
  String get guideSectionFormatsTitle => 'Formats et codecs';

  @override
  String get guideSectionFormatsBody => 'Chaque mode a ses préréglages. Vidéo : H.264, HEVC, VP9, AV1, etc. Audio : AAC, MP3, Opus, FLAC… Images : PNG, JPEG, WebP… Vous pouvez n\'extraire que l\'audio des vidéos si l\'option est activée dans les paramètres.';

  @override
  String get guideSectionVideoTitle => 'Vidéo : filtres et IA';

  @override
  String get guideSectionVideoBody => 'Filtres avancés : réduction de bruit, netteté, couleur (luminosité, contraste, saturation, gamma, RGB), stabilisation, désentrelacement, profils créatifs. L\'analyse intelligente peut proposer des optimisations (faible lumière, forte compression, aspect vieux film).\nLe débruitage DRUNet optionnel télécharge un modèle neuronal. La détection de scènes (PySceneDetect) analyse les coupures ; activez l\'optimisation par scène pour appliquer ses suggestions.\nL\'accélération GPU déplace l\'encodage sur la carte graphique ; choisissez un préréglage vitesse/qualité.';

  @override
  String get guideSectionAudioTitle => 'Filtres audio';

  @override
  String get guideSectionAudioBody => 'Volume, compression, normalisation. Égaliseur graves/aigus et préréglages (ex. renfort des basses, voix). Réduction du souffle de fond ; réverbération. L\'aperçu compare l\'original et le signal traité lorsque c\'est disponible.';

  @override
  String get guideSectionImageTitle => 'Images : résolution et upscaling';

  @override
  String get guideSectionImageBody => 'Ajustements qualité/couleur proches de la vidéo. Largeur/hauteur personnalisées ou conservation des proportions. La super-résolution augmente la définition ; elle est désactivée si elle entre en conflit avec une résolution fixe. Profils de couleur pour des styles rapides.';

  @override
  String get guideSectionQueueTitle => 'File et parallélisme';

  @override
  String get guideSectionQueueBody => 'La file liste les tâches en attente, actives, en pause, terminées ou en échec. Pause, reprise, arrêt ou suppression. Le nombre de conversions simultanées dans les paramètres limite la charge CPU.';

  @override
  String get guideSectionSettingsTitle => 'Paramètres';

  @override
  String get guideSectionSettingsBody => 'Dossier de sortie vide = à côté de chaque fichier source. Threads CPU : 0 = auto. Thème et langue après confirmation. Formats et codecs par défaut sont mémorisés par type de média.';

  @override
  String get guideSectionModelsTitle => 'Modèles et Python';

  @override
  String get guideSectionModelsBody => 'DRUNet et les scripts de scènes utilisent l\'environnement Python de l\'app. Au premier lancement, téléchargement possible des poids DRUNet (~125 Mo). Dossier des modèles configurable ; cache par défaut dans le dossier personnel.';

  @override
  String get guideSectionDepsTitle => 'FFmpeg et vérification';

  @override
  String get guideSectionDepsBody => 'FFmpeg doit être installé et à jour. Si l\'écran des dépendances s\'affiche, suivez l\'installation guidée ou manuelle puis réessayez. Python 3 et pip/venv améliorent les fonctions optionnelles.';

  @override
  String get pythonSetupTitle => 'Composants Python optionnels';

  @override
  String get pythonSetupIntro => 'Le débruitage DRUNet et la détection de scènes utilisent un environnement Python local (PyTorch, etc.). Le téléchargement peut être volumineux et se fait au premier lancement, pas pendant l\'installation du paquet.\n\nInstallez maintenant ou ignorez pour utiliser le reste sans ces fonctions.';

  @override
  String get pythonSetupInstall => 'Télécharger et installer';

  @override
  String get pythonSetupSkip => 'Ignorer pour l\'instant';

  @override
  String get pythonSetupRunning => 'Installation des paquets (plusieurs minutes possibles)…';

  @override
  String get pythonSetupPleaseWait => 'Veuillez patienter…';

  @override
  String get pythonSetupSuccess => 'Environnement Python prêt. DRUNet et les outils de scènes sont disponibles.';

  @override
  String pythonSetupFailed(int code) {
    return 'Échec (code : $code). Réessayez ou lancez scripts/python/setup_python_env.sh manuellement.';
  }

  @override
  String get pythonSetupRetry => 'Réessayer';
}
