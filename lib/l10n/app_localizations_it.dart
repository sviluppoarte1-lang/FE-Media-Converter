// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'FE Media Converter 🎬🎵🖼️';

  @override
  String get conversion => 'Conversione';

  @override
  String get queue => 'Coda';

  @override
  String get settings => 'Impostazioni';

  @override
  String get about => 'Informazioni';

  @override
  String get close => 'CHIUDI';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'ANNULLA';

  @override
  String get remove => 'RIMUOVI';

  @override
  String get pause => 'PAUSA';

  @override
  String get resume => 'RIPRENDI';

  @override
  String get stop => 'FERMA';

  @override
  String get clear => 'Pulisci';

  @override
  String get clearAll => 'Svuota Tutto';

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
  String get browse => 'Sfoglia';

  @override
  String get addToQueue => 'Aggiungi alla Coda';

  @override
  String get clearSelection => 'Pulisci selezione';

  @override
  String get videoCodec => 'Codec Video';

  @override
  String get videoBitrate => 'Bitrate Video';

  @override
  String get qualityMode => 'Modalità Qualità';

  @override
  String get constantQuality => 'Qualità Costante';

  @override
  String get constantBitrate => 'Bitrate Costante';

  @override
  String get crfDescription => 'Mantiene qualità costante, dimensione file variabile';

  @override
  String get bitrateDescription => 'Mantiene dimensione file costante, qualità variabile';

  @override
  String get videoSettings => 'Impostazioni Video';

  @override
  String get advancedVideoSettings => 'Impostazioni Video Avanzate';

  @override
  String get codecDescription => 'Seleziona formato compressione video';

  @override
  String get bitrateMode => 'Modalità Bitrate';

  @override
  String get mediaType => 'Tipo Media';

  @override
  String selectMedia(Object mediaType) {
    return 'Seleziona $mediaType';
  }

  @override
  String get noFilesSelected => 'Nessun file selezionato';

  @override
  String clickToBrowse(Object mediaType) {
    return 'Clicca su \"Sfoglia $mediaType\" per selezionare i file';
  }

  @override
  String filesSelected(Object count) {
    return '$count file selezionati';
  }

  @override
  String get selectionCleared => 'Selezione file cancellata';

  @override
  String filesAddedToQueue(Object count) {
    return '$count file aggiunti alla coda';
  }

  @override
  String get dropFilesHere => 'Rilascia i file qui per aggiungerli';

  @override
  String get dragAndDropSupported => 'Trascina e rilascia i file qui';

  @override
  String outputFormat(Object mediaType) {
    return 'Formato di Output - $mediaType';
  }

  @override
  String get qualitySettings => 'Impostazioni Qualità';

  @override
  String get videoQuality => 'Qualità Video:';

  @override
  String get audioQuality => 'Qualità Audio:';

  @override
  String get videoFilters => 'Filtri Video Avanzati';

  @override
  String get audioFilters => 'Filtri Audio Professionali';

  @override
  String get conversionQueue => 'Coda di Conversione';

  @override
  String completedCount(Object completed, Object total) {
    return '$completed/$total completati';
  }

  @override
  String get converting => 'Conversione in corso...';

  @override
  String get noFilesInQueue => 'Nessun file in coda';

  @override
  String get addFilesFromConversion => 'Aggiungi dei file dalla pagina Conversione\nper iniziare la conversione';

  @override
  String get removeFromQueue => 'Rimuovi dalla coda';

  @override
  String get pauseConversion => 'Metti in pausa';

  @override
  String get stopConversion => 'Ferma conversione';

  @override
  String fileRemoved(Object fileName) {
    return '\"$fileName\" rimosso dalla coda';
  }

  @override
  String filePaused(Object fileName) {
    return '\"$fileName\" messo in pausa';
  }

  @override
  String fileStopped(Object fileName) {
    return '\"$fileName\" fermato';
  }

  @override
  String get pending => 'In attesa';

  @override
  String get processing => 'Elaborazione';

  @override
  String get paused => 'In pausa';

  @override
  String get completed => 'Completato';

  @override
  String get failed => 'Fallito';

  @override
  String get calculating => 'Calcolando...';

  @override
  String get waiting => 'In attesa';

  @override
  String get conversionInProgress => 'Conversione in corso';

  @override
  String pausedAt(Object time) {
    return 'In pausa $time';
  }

  @override
  String completedAt(Object time) {
    return 'Completato $time';
  }

  @override
  String failedAt(Object time) {
    return 'Fallito $time';
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
  String get theme => 'Tema';

  @override
  String get system => 'Sistema';

  @override
  String get light => 'Chiaro';

  @override
  String get dark => 'Scuro';

  @override
  String get language => 'Lingua';

  @override
  String get outputFolder => 'Cartella Output';

  @override
  String get sameAsInput => 'Stessa cartella input';

  @override
  String get cpuThreads => 'CPU Threads';

  @override
  String get autoDetect => 'Auto-detect';

  @override
  String get concurrentConversions => 'Conversioni Concurrenti';

  @override
  String get concurrentConversionsDesc => 'Numero di file da convertire in contemporanea';

  @override
  String get gpuAcceleration => 'Accelerazione GPU';

  @override
  String get useGpu => 'Usa GPU per la conversione';

  @override
  String get gpuCompatibility => 'Maggiori prestazioni ma compatibilità limitata';

  @override
  String get requiresCompatibleHardware => 'Richiede hardware e driver compatibili';

  @override
  String get gpuType => 'Tipo GPU';

  @override
  String get autoDetection => 'Auto-rilevamento';

  @override
  String get selectGpuType => 'Seleziona il tipo di scheda video installata';

  @override
  String get information => 'Informazioni';

  @override
  String get version => 'Versione';

  @override
  String get professionalMediaConversion => 'Applicazione professionale per conversione media';

  @override
  String get usesFfmpeg => 'Utilizza FFmpeg per le conversioni. Assicurati che FFmpeg sia installato sul sistema.';

  @override
  String get extractAudioOnly => 'Estrai Solo Audio';

  @override
  String get extractAudioFromVideo => 'Estrai audio da file video (es. MP4 a MP3, MOV a WAV)';

  @override
  String get video => 'Video';

  @override
  String get audio => 'Audio';

  @override
  String get image => 'Immagine';

  @override
  String get videos => 'Video';

  @override
  String get audios => 'Audio';

  @override
  String get images => 'Immagini';

  @override
  String get formats => 'formati';

  @override
  String get filtersActive => 'Filtri attivi';

  @override
  String get resetAll => 'Reset Tutto';

  @override
  String get noiseReduction => 'Riduzione Rumore';

  @override
  String get noiseReductionStrength => 'Forza Riduzione Rumore';

  @override
  String get reducesDigitalNoise => 'Riduce il rumore digitale e la grana. Valori alti possono ammorbidire l\'immagine.';

  @override
  String get qualityEnhancement => 'Miglioramento Qualità';

  @override
  String get sharpness => 'Nitidezza';

  @override
  String get brightness => 'Luminosità';

  @override
  String get contrast => 'Contrasto';

  @override
  String get saturation => 'Saturazione';

  @override
  String get gamma => 'Gamma';

  @override
  String get advancedCorrections => 'Correzioni Avanzate';

  @override
  String get videoStabilization => 'Stabilizzazione Video';

  @override
  String get reducesCameraShake => 'Riduce il tremolio della telecamera';

  @override
  String get deinterlacing => 'Deinterlacciamento';

  @override
  String get removesInterlacedLines => 'Rimuove le linee da video interlacciati';

  @override
  String get colorProfiles => 'Profili Colore';

  @override
  String get none => 'Nessuno';

  @override
  String get vivid => 'Vivace';

  @override
  String get cinematic => 'Cinematografico';

  @override
  String get blackWhite => 'Bianco e Nero';

  @override
  String get sepia => 'Seppia';

  @override
  String get activeEffectsPreview => 'Anteprima Effetti Attivi:';

  @override
  String get noActiveFilters => 'Nessun filtro attivo';

  @override
  String get volumeDynamics => 'Volume e Dinamica';

  @override
  String get volume => 'Volume';

  @override
  String get compression => 'Compressione';

  @override
  String get normalization => 'Normalizzazione';

  @override
  String get levelsVolumeAutomatically => 'Livella il volume automaticamente';

  @override
  String get equalizer => 'Equalizzatore';

  @override
  String get bass => 'Bassi';

  @override
  String get treble => 'Alti';

  @override
  String get equalizerPreset => 'Preset Equalizzatore:';

  @override
  String get bassBoost => 'Rinforzo Bassi';

  @override
  String get trebleBoost => 'Rinforzo Alti';

  @override
  String get voice => 'Voce';

  @override
  String get audioCleaning => 'Pulizia Audio';

  @override
  String get removeNoise => 'Rimuovi Rumore';

  @override
  String get reducesBackgroundHiss => 'Riduce il fruscio di fondo';

  @override
  String get noiseThreshold => 'Soglia Rumore';

  @override
  String get reverb => 'Riverbero';

  @override
  String get activeAudioEffects => 'Anteprima Effetti Audio Attivi:';

  @override
  String get noActiveAudioFilters => 'Nessun filtro audio attivo';

  @override
  String excellentQuality(Object crf) {
    return 'Eccellente (CRF: $crf)';
  }

  @override
  String greatQuality(Object crf) {
    return 'Ottima (CRF: $crf)';
  }

  @override
  String goodQuality(Object crf) {
    return 'Buona (CRF: $crf)';
  }

  @override
  String averageQuality(Object crf) {
    return 'Mediocre (CRF: $crf)';
  }

  @override
  String lowQualityLabel(Object crf) {
    return 'Bassa (CRF: $crf)';
  }

  @override
  String get crfScale => 'CRF: 0 (Migliore) - 51 (Peggiore)';

  @override
  String get bitrateScale => 'Bitrate Audio: 64 kbps - 320 kbps';

  @override
  String get audioCodec => 'Codec Audio';

  @override
  String get audioCodecDesc => 'Seleziona il codec audio per il file di output';

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
  String get error => 'Errore';

  @override
  String get files => 'file';

  @override
  String get customResolution => 'Risoluzione Personalizzata';

  @override
  String get customWidth => 'Larghezza (px)';

  @override
  String get customHeight => 'Altezza (px)';

  @override
  String get originalResolution => 'Risoluzione Immagine';

  @override
  String get previewOriginal => 'Anteprima Originale';

  @override
  String get previewModified => 'Anteprima Modificata';

  @override
  String get useCustomResolution => 'Usa Risoluzione Personalizzata';

  @override
  String get customResolutionDesc => 'Imposta larghezza e altezza specifiche (es. 1920x1080)';

  @override
  String get loadingResolution => 'Caricamento risoluzione...';

  @override
  String get resolutionNotAvailable => 'Risoluzione non disponibile';

  @override
  String get selectImageForResolution => 'Seleziona un\'immagine per vedere la risoluzione';

  @override
  String get resolutionDescription => 'Imposta una risoluzione specifica. Se imposti solo larghezza o altezza, l\'aspect ratio viene mantenuto.';

  @override
  String get previewDescription => 'Visualizza l\'immagine originale o con i filtri applicati';

  @override
  String get advancedUpscalingAlgorithms => 'Double or quadruple the image resolution. Uses advanced upscaling algorithms.';

  @override
  String audioCodecSection(Object mediaType) {
    return 'Audio Codec - $mediaType';
  }

  @override
  String get ffmpegVersionCheck => 'Verifica Versione FFmpeg';

  @override
  String get ffmpegNotInstalled => 'FFmpeg non è installato o la versione è obsoleta';

  @override
  String get ffmpegVersionRequired => 'Versione richiesta: 8.0.1';

  @override
  String ffmpegCurrentVersion(Object version) {
    return 'Versione attuale: $version';
  }

  @override
  String get ffmpegNeedsUpdate => 'FFmpeg deve essere aggiornato alla versione 8.0.1';

  @override
  String get installFFmpeg => 'Installa FFmpeg 8.0.1';

  @override
  String get installFFmpegDesc => 'Questo installerà FFmpeg 8.0.1 utilizzando i privilegi di amministratore. La password verrà memorizzata in modo sicuro per uso futuro.';

  @override
  String get enterSudoPassword => 'Inserisci password amministratore';

  @override
  String get passwordRequired => 'La password è richiesta';

  @override
  String get installingFFmpeg => 'Installazione FFmpeg...';

  @override
  String get ffmpegInstallSuccess => 'FFmpeg 8.0.1 installato con successo!';

  @override
  String ffmpegInstallFailed(Object error) {
    return 'Installazione FFmpeg fallita: $error';
  }

  @override
  String detectedDistribution(Object distro) {
    return 'Distribuzione rilevata: $distro';
  }

  @override
  String get addingRepository => 'Aggiunta repository...';

  @override
  String get updatingPackages => 'Aggiornamento lista pacchetti...';

  @override
  String get installingPackage => 'Installazione FFmpeg...';

  @override
  String get passwordStored => 'Password memorizzata in modo sicuro per installazioni future';

  @override
  String get skipInstallation => 'Salta Installazione';

  @override
  String get manualInstall => 'Installazione Manuale';

  @override
  String get manualInstallDesc => 'Puoi installare FFmpeg manualmente usando i comandi qui sotto';

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
  String get audioPreview => 'Anteprima Audio';

  @override
  String get audioPreviewDescription => 'Ascolta l\'audio originale o con i filtri applicati';

  @override
  String get openWithSystemPlayer => 'Apri con player di sistema';

  @override
  String get audioFileReady => 'File audio pronto per la riproduzione';

  @override
  String get modifiedAudioGenerated => 'File audio modificato generato (primi 10 secondi)';

  @override
  String get fileWillOpenWithDefaultPlayer => 'Il file verrà aperto con il player audio predefinito del sistema';

  @override
  String get videoQualityMode => 'Modalità Qualità Video';

  @override
  String get constantQualityLabel => 'CRF (Qualità Costante)';

  @override
  String get constantBitrateLabel => 'Bitrate (Dimensione File)';

  @override
  String get videoBitrateLabel => 'Bitrate Video';

  @override
  String get crfQualityRange => 'CRF: 0 (Migliore Qualità) - 51 (Peggiore Qualità)';

  @override
  String get bitrateQualityRange => 'Bitrate: 500 kbps (Bassa Qualità) - 20,000 kbps (Altissima Qualità)';

  @override
  String get qualityLabel => 'Qualità:';

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
  String get audioQualityHighest => 'Qualità Altissima (Lossless-like)';

  @override
  String get audioQualityHigh => 'Qualità Alta (Trasparenza)';

  @override
  String get audioQualityMedium => 'Qualità Media (Buon bilanciamento)';

  @override
  String get audioQualityLow => 'Qualità Bassa (Compatibilità)';

  @override
  String get selectVideoForAnalysis => 'Seleziona un video per l\'analisi automatica';

  @override
  String get analyzeVideoQuality => 'Analizza Qualità Video';

  @override
  String get analyzingVideoQuality => 'Analizzando la qualità del video...';

  @override
  String get videoAnalyzedNoIssues => 'Video analizzato - Nessun problema critico';

  @override
  String problemsDetectedRecommendations(Object problems, Object recommendations) {
    return '$problems problemi rilevati - $recommendations raccomandazioni';
  }

  @override
  String get intelligentVideoAnalysis => 'Analisi Video Intelligente';

  @override
  String get automaticOptimizations => 'Ottimizzazioni Automatiche';

  @override
  String get autoOptimization => 'Ottimizzazione Auto';

  @override
  String get autoOptimizationDesc => 'Applica le migliori impostazioni basate sull\'analisi';

  @override
  String get lowQuality => 'Bassa Qualità ⭐';

  @override
  String get lowQualityDesc => 'MASSIMA OTTIMIZZAZIONE per video di bassa qualità e con molto rumore';

  @override
  String get ultraQuality => 'Qualità Ultra';

  @override
  String get ultraQualityDesc => 'Enhancement professionale con tutti i filtri avanzati';

  @override
  String get lowLight => 'Scarsa Illuminazione';

  @override
  String get lowLightDesc => 'Migliora video in condizioni di luce bassa';

  @override
  String get detailRecovery => 'Ripristino Dettagli';

  @override
  String get detailRecoveryDesc => 'Recupera dettagli e texture perse';

  @override
  String get compressionFix => 'Fix Compressione';

  @override
  String get compressionFixDesc => 'Rimuove artefatti da compressione pesante';

  @override
  String get filmRestoration => 'Restauro Film';

  @override
  String get filmRestorationDesc => 'Ottimizzato per video vecchi e film';

  @override
  String get fundamentalFilters => 'Filtri Fondamentali';

  @override
  String get qualityAndDetails => 'Qualità e Dettagli';

  @override
  String get noiseReductionLabel => 'Riduzione Rumore';

  @override
  String get colorAndLight => 'Colore e Luce';

  @override
  String get redBalance => 'Bilanciamento Rosso';

  @override
  String get greenBalance => 'Bilanciamento Verde';

  @override
  String get blueBalance => 'Bilanciamento Blu';

  @override
  String get deinterlacingLabel => 'Deinterlacciamento';

  @override
  String get deinterlacingDesc => 'Rimuove le linee interlacciate dai video più vecchi';

  @override
  String get stabilizationLabel => 'Stabilizzazione';

  @override
  String get stabilizationDesc => 'Riduce il tremolio della camera';

  @override
  String get detailEnhancement => 'Miglioramento Dettagli';

  @override
  String get detailEnhancementDesc => 'Migliora la definizione dei dettagli';

  @override
  String get gpuAccelerationLabel => 'Accelerazione GPU';

  @override
  String get useGpuForConversion => 'Usa GPU per la conversione';

  @override
  String get useGpuForConversionDesc => 'Sposta l\'encoding video sulla scheda grafica (se disponibile)';

  @override
  String get gpuPreset => 'Preset GPU (velocità vs qualità)';

  @override
  String get gpuPresetFast => 'Fast';

  @override
  String get gpuPresetFastDesc => 'Massima velocità, qualità leggermente inferiore';

  @override
  String get gpuPresetMedium => 'Medium';

  @override
  String get gpuPresetMediumDesc => 'Bilanciato tra velocità e qualità (consigliato)';

  @override
  String get gpuPresetHighQuality => 'High Quality';

  @override
  String get gpuPresetHighQualityDesc => 'Migliore qualità possibile, conversione più lenta';

  @override
  String get drunetDenoisingTitle => 'DRUNet (denoising IA)';

  @override
  String get drunetDenoisingDesc => 'Denoising deep learning con drunet_model.pth in models/drunet/. Attivo di default.';

  @override
  String get sceneDetectionTitle => 'Rilevamento scene (PySceneDetect)';

  @override
  String get sceneDetectionDesc => 'Analisi scene per impostazioni più intelligenti. Attivo di default.';

  @override
  String get useSceneOptimizationTitle => 'Ottimizzazione basata sulle scene';

  @override
  String get useSceneOptimizationDesc => 'Applica suggerimenti bitrate/qualità dall\'analisi scene.';

  @override
  String get noneLabel => 'Nessuno';

  @override
  String get vividLabel => 'Vivace';

  @override
  String get cinematicLabel => 'Cinematografico';

  @override
  String get blackWhiteLabel => 'Bianco e Nero';

  @override
  String get sepiaLabel => 'Seppia';

  @override
  String get imageFiltersTitle => 'Filtri Immagine';

  @override
  String get qualityEnhancementLabel => 'Miglioramento Qualità';

  @override
  String get imageUpscaling => 'Upscaling Immagini';

  @override
  String get enableImageUpscaling => 'Abilita Upscaling';

  @override
  String get enableImageUpscalingDesc => 'Aumenta la risoluzione dell\'immagine';

  @override
  String get upscalingFactor => 'Fattore di Upscaling';

  @override
  String get upscalingDisabledWithCustom => 'L\'upscaling è disabilitato quando si usa la risoluzione personalizzata.';

  @override
  String get imageColorProfiles => 'Profili Colore';

  @override
  String get userGuideMenu => 'Guida';

  @override
  String get userGuideTitle => 'Guida all\'uso';

  @override
  String get userGuideIntro => 'Questa guida riassume il funzionamento di FE Media Converter: scegli il tipo di media, aggiungi i file, formato e qualità, opzionalmente i filtri, poi usa la coda per avviare i job. Le impostazioni restano salvate tra una sessione e l\'altra.';

  @override
  String get guideSectionQuickStartTitle => 'Avvio rapido';

  @override
  String get guideSectionQuickStartBody => '1) Scegli Video, Audio o Immagine a sinistra.\n2) Usa Sfoglia o trascina i file nella finestra.\n3) Scegli formato di uscita e codec.\n4) Regola la qualità (CRF o bitrate) se serve.\n5) Aggiungi alla coda, apri la scheda Coda e avvia la conversione.\n6) In Impostazioni: cartella di output, tema, lingua, thread CPU e GPU.';

  @override
  String get guideSectionFormatsTitle => 'Formati e codec';

  @override
  String get guideSectionFormatsBody => 'Ogni modalità ha i propri preset. Il video supporta codec comuni (es. H.264, HEVC, VP9, AV1). L\'audio include AAC, MP3, Opus, FLAC e altri. Le immagini: PNG, JPEG, WebP, ecc. Puoi estrarre solo l\'audio dai video se l\'opzione è attiva in Impostazioni.';

  @override
  String get guideSectionVideoTitle => 'Video: filtri e IA';

  @override
  String get guideSectionVideoBody => 'I filtri avanzati coprono riduzione rumore, nitidezza, colore (luminosità, contrasto, saturazione, gamma, bilanciamento RGB), stabilizzazione, deinterlacciamento e profili colore creativi. L\'analisi intelligente può suggerire ottimizzazioni per poca luce, compressione forte o aspetto da pellicola.\nIl denoising DRUNet opzionale usa un modello neurale scaricato. Il rilevamento scene (PySceneDetect) analizza i tagli per regolare l\'encoding; abilita l\'ottimizzazione basata sulle scene per applicare i suggerimenti.\nL\'accelerazione GPU (se supportata) sposta l\'encoding sulla scheda video—scegli un preset che bilanci velocità e qualità.';

  @override
  String get guideSectionAudioTitle => 'Filtri audio';

  @override
  String get guideSectionAudioBody => 'Regola volume, compressione e normalizzazione. Usa l\'equalizzatore con bassi/alti e preset (es. bass boost o voce). Gli strumenti di pulizia riduono il sibilo di fondo; il riverbero aggiunge spazio. L\'anteprima confronta originale e audio processato dove disponibile.';

  @override
  String get guideSectionImageTitle => 'Immagini: risoluzione e upscaling';

  @override
  String get guideSectionImageBody => 'Applica miglioramenti qualità/colore simili al video. Imposta larghezza/altezza personalizzate o mantieni le proporzioni compilando una sola dimensione. La super-risoluzione aumenta la risoluzione; è disabilitata se entra in conflitto con una risoluzione fissa. I profili colore offrono look rapidi.';

  @override
  String get guideSectionQueueTitle => 'Coda e parallelismo';

  @override
  String get guideSectionQueueBody => 'La coda elenca job in attesa, attivi, in pausa, completati o falliti. Puoi mettere in pausa, riprendere, fermare o rimuovere le attività. Le conversioni simultanee nelle Impostazioni controllano quanti file elaborare insieme—aumenta su CPU potenti, riduci per alleggerire il carico.';

  @override
  String get guideSectionSettingsTitle => 'Impostazioni';

  @override
  String get guideSectionSettingsBody => 'Cartella di output: lascia vuota per salvare accanto a ogni sorgente. I thread CPU limitano FFmpeg (0 = automatico). Tema e lingua dell\'interfaccia si applicano dopo la conferma. Formati e codec predefiniti sono memorizzati per tipo di media.';

  @override
  String get guideSectionModelsTitle => 'Modelli e script Python';

  @override
  String get guideSectionModelsBody => 'DRUNet e gli script per le scene usano l\'ambiente Python dell\'app. Al primo avvio potrebbe essere richiesto il download dei pesi DRUNet (~125 MB). Puoi cambiare la cartella modelli nelle Impostazioni; esiste anche una cartella predefinita nella home per la cache.';

  @override
  String get guideSectionDepsTitle => 'FFmpeg e controllo all\'avvio';

  @override
  String get guideSectionDepsBody => 'FFmpeg deve essere installato e sufficientemente aggiornato. Se compare la schermata dipendenze, segui l\'installazione guidata o le istruzioni manuali, poi riprova. L\'app trae beneficio anche da Python 3 e pip/venv per le funzioni opzionali.';

  @override
  String get pythonSetupTitle => 'Componenti Python opzionali';

  @override
  String get pythonSetupIntro => 'Il denoising DRUNet e il rilevamento scene usano un ambiente virtuale Python locale (PyTorch e altre librerie). Il download può essere pesante e viene preparato al primo avvio dell\'app, non durante l\'installazione del pacchetto.\n\nInstalla ora, oppure salta e usa il resto dell\'app senza queste funzioni.';

  @override
  String get pythonSetupInstall => 'Scarica e installa';

  @override
  String get pythonSetupSkip => 'Salta per ora';

  @override
  String get pythonSetupRunning => 'Installazione pacchetti (può richiedere diversi minuti)…';

  @override
  String get pythonSetupPleaseWait => 'Attendere…';

  @override
  String get pythonSetupSuccess => 'Ambiente Python pronto. Puoi usare DRUNet e gli strumenti per le scene.';

  @override
  String pythonSetupFailed(int code) {
    return 'Installazione non riuscita (codice: $code). Puoi riprovare o eseguire manualmente scripts/python/setup_python_env.sh.';
  }

  @override
  String get pythonSetupRetry => 'Riprova';
}
