// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'FE Media Converter 🎬🎵🖼️';

  @override
  String get conversion => 'Conversión';

  @override
  String get queue => 'Cola';

  @override
  String get settings => 'Configuración';

  @override
  String get about => 'Acerca de';

  @override
  String get close => 'Cerrar';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancelar';

  @override
  String get remove => 'Eliminar';

  @override
  String get pause => 'Pausar';

  @override
  String get resume => 'Reanudar';

  @override
  String get stop => 'Detener';

  @override
  String get clear => 'Limpiar';

  @override
  String get clearAll => 'Limpiar todo';

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
  String get browse => 'Examinar';

  @override
  String get addToQueue => 'Añadir a la cola';

  @override
  String get clearSelection => 'Limpiar selección';

  @override
  String get videoCodec => 'Códec de video';

  @override
  String get videoBitrate => 'Velocidad de bits de video';

  @override
  String get qualityMode => 'Modo de calidad';

  @override
  String get constantQuality => 'Calidad constante';

  @override
  String get constantBitrate => 'Velocidad de bits constante';

  @override
  String get crfDescription => 'Mantiene calidad constante, tamaño de archivo variable';

  @override
  String get bitrateDescription => 'Mantiene tamaño de archivo constante, calidad variable';

  @override
  String get videoSettings => 'Configuración de video';

  @override
  String get advancedVideoSettings => 'Configuración avanzada de video';

  @override
  String get codecDescription => 'Seleccionar formato de compresión de video';

  @override
  String get bitrateMode => 'Modo de velocidad de bits';

  @override
  String get mediaType => 'Tipo de medio';

  @override
  String selectMedia(Object mediaType) {
    return 'Seleccionar $mediaType';
  }

  @override
  String get noFilesSelected => 'No hay archivos seleccionados';

  @override
  String clickToBrowse(Object mediaType) {
    return 'Haga clic en \"Examinar $mediaType\" para seleccionar archivos';
  }

  @override
  String filesSelected(Object count) {
    return '$count archivos seleccionados';
  }

  @override
  String get selectionCleared => 'Selección limpiada';

  @override
  String filesAddedToQueue(Object count) {
    return '$count archivos añadidos a la cola';
  }

  @override
  String get dropFilesHere => 'Arrastre archivos aquí para añadirlos';

  @override
  String get dragAndDropSupported => 'Arrastre y suelte archivos aquí';

  @override
  String outputFormat(Object mediaType) {
    return 'Formato de salida - $mediaType';
  }

  @override
  String get qualitySettings => 'Configuración de calidad';

  @override
  String get videoQuality => 'Calidad de video:';

  @override
  String get audioQuality => 'Calidad de audio:';

  @override
  String get videoFilters => 'Filtros avanzados de video';

  @override
  String get audioFilters => 'Filtros profesionales de audio';

  @override
  String get conversionQueue => 'Cola de conversión';

  @override
  String completedCount(Object completed, Object total) {
    return '$completed/$total completados';
  }

  @override
  String get converting => 'Convirtiendo...';

  @override
  String get noFilesInQueue => 'No hay archivos en la cola';

  @override
  String get addFilesFromConversion => 'Añada archivos desde la página de Conversión\npara comenzar a convertir';

  @override
  String get removeFromQueue => 'Eliminar de la cola';

  @override
  String get pauseConversion => 'Pausar conversión';

  @override
  String get stopConversion => 'Detener conversión';

  @override
  String fileRemoved(Object fileName) {
    return '\"$fileName\" eliminado de la cola';
  }

  @override
  String filePaused(Object fileName) {
    return '\"$fileName\" pausado';
  }

  @override
  String fileStopped(Object fileName) {
    return '\"$fileName\" detenido';
  }

  @override
  String get pending => 'Pendiente';

  @override
  String get processing => 'Procesando';

  @override
  String get paused => 'En pausa';

  @override
  String get completed => 'Completado';

  @override
  String get failed => 'Fallido';

  @override
  String get calculating => 'Calculando...';

  @override
  String get waiting => 'Esperando';

  @override
  String get conversionInProgress => 'Conversión en progreso';

  @override
  String pausedAt(Object time) {
    return 'Pausado a las $time';
  }

  @override
  String completedAt(Object time) {
    return 'Completado $time';
  }

  @override
  String failedAt(Object time) {
    return 'Fallido $time';
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
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String get language => 'Idioma';

  @override
  String get outputFolder => 'Carpeta de salida';

  @override
  String get sameAsInput => 'Igual que la carpeta de entrada';

  @override
  String get cpuThreads => 'Hilos de CPU';

  @override
  String get autoDetect => 'Detección automática';

  @override
  String get concurrentConversions => 'Conversiones simultáneas';

  @override
  String get concurrentConversionsDesc => 'Número de archivos a convertir simultáneamente';

  @override
  String get gpuAcceleration => 'Aceleración GPU';

  @override
  String get useGpu => 'Usar GPU para la conversión';

  @override
  String get gpuCompatibility => 'Mejor rendimiento pero compatibilidad limitada';

  @override
  String get requiresCompatibleHardware => 'Requiere hardware y controladores compatibles';

  @override
  String get gpuType => 'Tipo de GPU';

  @override
  String get autoDetection => 'Detección automática';

  @override
  String get selectGpuType => 'Seleccionar el tipo de tarjeta gráfica instalada';

  @override
  String get information => 'Información';

  @override
  String get version => 'Versión';

  @override
  String get professionalMediaConversion => 'Aplicación profesional de conversión de medios';

  @override
  String get usesFfmpeg => 'Usa FFmpeg para las conversiones. Asegúrese de que FFmpeg esté instalado en su sistema.';

  @override
  String get extractAudioOnly => 'Extraer solo audio';

  @override
  String get extractAudioFromVideo => 'Extraer audio de archivos de video (ej. MP4 a MP3, MOV a WAV)';

  @override
  String get video => 'Video';

  @override
  String get audio => 'Audio';

  @override
  String get image => 'Imagen';

  @override
  String get videos => 'Videos';

  @override
  String get audios => 'Audios';

  @override
  String get images => 'Imágenes';

  @override
  String get formats => 'formatos';

  @override
  String get filtersActive => 'Filtros activos';

  @override
  String get resetAll => 'Restablecer todo';

  @override
  String get noiseReduction => 'Reducción de ruido';

  @override
  String get noiseReductionStrength => 'Intensidad de reducción de ruido';

  @override
  String get reducesDigitalNoise => 'Reduce el ruido digital y el grano. Valores altos pueden suavizar la imagen.';

  @override
  String get qualityEnhancement => 'Mejora de calidad';

  @override
  String get sharpness => 'Nitidez';

  @override
  String get brightness => 'Brillo';

  @override
  String get contrast => 'Contraste';

  @override
  String get saturation => 'Saturación';

  @override
  String get gamma => 'Gamma';

  @override
  String get advancedCorrections => 'Correcciones avanzadas';

  @override
  String get videoStabilization => 'Estabilización de video';

  @override
  String get reducesCameraShake => 'Reduce las vibraciones de la cámara';

  @override
  String get deinterlacing => 'Desentrelazado';

  @override
  String get removesInterlacedLines => 'Elimina líneas de videos entrelazados';

  @override
  String get colorProfiles => 'Perfiles de color';

  @override
  String get none => 'Ninguno';

  @override
  String get vivid => 'Vívido';

  @override
  String get cinematic => 'Cinematográfico';

  @override
  String get blackWhite => 'Blanco y negro';

  @override
  String get sepia => 'Sépia';

  @override
  String get activeEffectsPreview => 'Vista previa de efectos activos:';

  @override
  String get noActiveFilters => 'No hay filtros activos';

  @override
  String get volumeDynamics => 'Volumen y dinámica';

  @override
  String get volume => 'Volumen';

  @override
  String get compression => 'Compresión';

  @override
  String get normalization => 'Normalización';

  @override
  String get levelsVolumeAutomatically => 'Nivela el volumen automáticamente';

  @override
  String get equalizer => 'Ecualizador';

  @override
  String get bass => 'Graves';

  @override
  String get treble => 'Agudos';

  @override
  String get equalizerPreset => 'Preajuste de ecualizador:';

  @override
  String get bassBoost => 'Refuerzo de graves';

  @override
  String get trebleBoost => 'Refuerzo de agudos';

  @override
  String get voice => 'Voz';

  @override
  String get audioCleaning => 'Limpieza de audio';

  @override
  String get removeNoise => 'Eliminar ruido';

  @override
  String get reducesBackgroundHiss => 'Reduce el siseo de fondo';

  @override
  String get noiseThreshold => 'Umbral de ruido';

  @override
  String get reverb => 'Reverberación';

  @override
  String get activeAudioEffects => 'Efectos de audio activos:';

  @override
  String get noActiveAudioFilters => 'No hay filtros de audio activos';

  @override
  String excellentQuality(Object crf) {
    return 'Excelente (CRF: $crf)';
  }

  @override
  String greatQuality(Object crf) {
    return 'Muy bueno (CRF: $crf)';
  }

  @override
  String goodQuality(Object crf) {
    return 'Bueno (CRF: $crf)';
  }

  @override
  String averageQuality(Object crf) {
    return 'Promedio (CRF: $crf)';
  }

  @override
  String lowQualityLabel(Object crf) {
    return 'Bajo (CRF: $crf)';
  }

  @override
  String get crfScale => 'CRF: 0 (Mejor) - 51 (Peor)';

  @override
  String get bitrateScale => 'Velocidad de bits: 64 kbps - 320 kbps';

  @override
  String get audioCodec => 'Códec de audio';

  @override
  String get audioCodecDesc => 'Seleccionar códec de audio para el archivo de salida';

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
  String get error => 'Error';

  @override
  String get files => 'archivos';

  @override
  String get customResolution => 'Resolución personalizada';

  @override
  String get customWidth => 'Ancho (px)';

  @override
  String get customHeight => 'Altura (px)';

  @override
  String get originalResolution => 'Resolución de imagen';

  @override
  String get previewOriginal => 'Vista previa original';

  @override
  String get previewModified => 'Vista previa modificada';

  @override
  String get useCustomResolution => 'Usar resolución personalizada';

  @override
  String get customResolutionDesc => 'Establecer ancho y alto específicos (ej. 1920x1080)';

  @override
  String get loadingResolution => 'Cargando resolución...';

  @override
  String get resolutionNotAvailable => 'Resolución no disponible';

  @override
  String get selectImageForResolution => 'Seleccionar una imagen para ver la resolución';

  @override
  String get resolutionDescription => 'Establecer una resolución específica. Si establece solo ancho o alto, se mantiene la relación de aspecto.';

  @override
  String get previewDescription => 'Ver la imagen original o con filtros aplicados';

  @override
  String get advancedUpscalingAlgorithms => 'Double or quadruple the image resolution. Uses advanced upscaling algorithms.';

  @override
  String audioCodecSection(Object mediaType) {
    return 'Audio Codec - $mediaType';
  }

  @override
  String get ffmpegVersionCheck => 'Verificación de versión de FFmpeg';

  @override
  String get ffmpegNotInstalled => 'FFmpeg no está instalado o la versión está desactualizada';

  @override
  String get ffmpegVersionRequired => 'Versión requerida: 8.0.1';

  @override
  String ffmpegCurrentVersion(Object version) {
    return 'Versión actual: $version';
  }

  @override
  String get ffmpegNeedsUpdate => 'FFmpeg debe actualizarse a la versión 8.0.1';

  @override
  String get installFFmpeg => 'Instalar FFmpeg 8.0.1';

  @override
  String get installFFmpegDesc => 'Esto instalará FFmpeg 8.0.1 usando privilegios de administrador. La contraseña se almacenará de forma segura para uso futuro.';

  @override
  String get enterSudoPassword => 'Ingresar contraseña de administrador';

  @override
  String get passwordRequired => 'La contraseña es requerida';

  @override
  String get installingFFmpeg => 'Instalando FFmpeg...';

  @override
  String get ffmpegInstallSuccess => '¡FFmpeg 8.0.1 instalado con éxito!';

  @override
  String ffmpegInstallFailed(Object error) {
    return 'Instalación de FFmpeg fallida: $error';
  }

  @override
  String detectedDistribution(Object distro) {
    return 'Distribución detectada: $distro';
  }

  @override
  String get addingRepository => 'Añadiendo repositorio...';

  @override
  String get updatingPackages => 'Actualizando lista de paquetes...';

  @override
  String get installingPackage => 'Instalando FFmpeg...';

  @override
  String get passwordStored => 'Contraseña almacenada de forma segura para instalaciones futuras';

  @override
  String get skipInstallation => 'Omitir instalación';

  @override
  String get manualInstall => 'Instalación manual';

  @override
  String get manualInstallDesc => 'Puede instalar FFmpeg manualmente usando los comandos a continuación';

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
  String get audioPreview => 'Vista previa de audio';

  @override
  String get audioPreviewDescription => 'Escuchar el audio original o con filtros aplicados';

  @override
  String get openWithSystemPlayer => 'Abrir con reproductor del sistema';

  @override
  String get audioFileReady => 'Archivo de audio listo para reproducir';

  @override
  String get modifiedAudioGenerated => 'Audio modificado generado (primeros 10 segundos)';

  @override
  String get fileWillOpenWithDefaultPlayer => 'El archivo se abrirá con el reproductor de audio predeterminado del sistema';

  @override
  String get videoQualityMode => 'Modo de calidad de video';

  @override
  String get constantQualityLabel => 'CRF (Calidad constante)';

  @override
  String get constantBitrateLabel => 'Velocidad de bits (Tamaño de archivo)';

  @override
  String get videoBitrateLabel => 'Velocidad de bits de video';

  @override
  String get crfQualityRange => 'CRF: 0 (Mejor calidad) - 51 (Peor calidad)';

  @override
  String get bitrateQualityRange => 'Velocidad de bits: 500 kbps (Baja calidad) - 20,000 kbps (Muy alta calidad)';

  @override
  String get qualityLabel => 'Calidad:';

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
  String get audioQualityHighest => 'Calidad más alta (Sin pérdidas)';

  @override
  String get audioQualityHigh => 'Alta calidad (Transparencia)';

  @override
  String get audioQualityMedium => 'Calidad media (Buen equilibrio)';

  @override
  String get audioQualityLow => 'Baja calidad (Compatibilidad)';

  @override
  String get selectVideoForAnalysis => 'Seleccionar un video para análisis automático';

  @override
  String get analyzeVideoQuality => 'Analizar calidad de video';

  @override
  String get analyzingVideoQuality => 'Analizando calidad de video...';

  @override
  String get videoAnalyzedNoIssues => 'Video analizado - Sin problemas críticos';

  @override
  String problemsDetectedRecommendations(Object problems, Object recommendations) {
    return '$problems problemas detectados - $recommendations recomendaciones';
  }

  @override
  String get intelligentVideoAnalysis => 'Análisis inteligente de video';

  @override
  String get automaticOptimizations => 'Optimizaciones automáticas';

  @override
  String get autoOptimization => 'Optimización automática';

  @override
  String get autoOptimizationDesc => 'Aplicar mejores configuraciones basadas en análisis';

  @override
  String get lowQuality => 'Baja calidad ⭐';

  @override
  String get lowQualityDesc => 'OPTIMIZACIÓN MÁXIMA para videos de baja calidad con mucho ruido';

  @override
  String get ultraQuality => 'Calidad ultra';

  @override
  String get ultraQualityDesc => 'Mejora profesional con todos los filtros avanzados';

  @override
  String get lowLight => 'Poca iluminación';

  @override
  String get lowLightDesc => 'Mejora videos en condiciones de poca luz';

  @override
  String get detailRecovery => 'Restauración de detalles';

  @override
  String get detailRecoveryDesc => 'Recupera detalles y texturas perdidos';

  @override
  String get compressionFix => 'Corrección de compresión';

  @override
  String get compressionFixDesc => 'Elimina artefactos de compresión pesada';

  @override
  String get filmRestoration => 'Restauración de película';

  @override
  String get filmRestorationDesc => 'Optimizado para videos antiguos y películas';

  @override
  String get fundamentalFilters => 'Filtros fundamentales';

  @override
  String get qualityAndDetails => 'Calidad y detalles';

  @override
  String get noiseReductionLabel => 'Reducción de ruido';

  @override
  String get colorAndLight => 'Color y luz';

  @override
  String get redBalance => 'Balance rojo';

  @override
  String get greenBalance => 'Balance verde';

  @override
  String get blueBalance => 'Balance azul';

  @override
  String get deinterlacingLabel => 'Desentrelazado';

  @override
  String get deinterlacingDesc => 'Elimina líneas entrelazadas de videos más antiguos';

  @override
  String get stabilizationLabel => 'Estabilización';

  @override
  String get stabilizationDesc => 'Reduce el temblor de la cámara';

  @override
  String get detailEnhancement => 'Mejora de detalles';

  @override
  String get detailEnhancementDesc => 'Mejora la definición de detalles';

  @override
  String get gpuAccelerationLabel => 'Aceleración GPU';

  @override
  String get useGpuForConversion => 'Usar GPU para conversión';

  @override
  String get useGpuForConversionDesc => 'Mueve codificación de video a tarjeta gráfica (si está disponible)';

  @override
  String get gpuPreset => 'Ajuste preestablecido GPU (velocidad vs calidad)';

  @override
  String get gpuPresetFast => 'Rápido';

  @override
  String get gpuPresetFastDesc => 'Velocidad máxima, calidad ligeramente inferior';

  @override
  String get gpuPresetMedium => 'Medio';

  @override
  String get gpuPresetMediumDesc => 'Equilibrado entre velocidad y calidad (recomendado)';

  @override
  String get gpuPresetHighQuality => 'Alta calidad';

  @override
  String get gpuPresetHighQualityDesc => 'Mejor calidad posible, conversión más lenta';

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
  String get noneLabel => 'Ninguno';

  @override
  String get vividLabel => 'Vívido';

  @override
  String get cinematicLabel => 'Cinematográfico';

  @override
  String get blackWhiteLabel => 'Blanco y negro';

  @override
  String get sepiaLabel => 'Sepia';

  @override
  String get imageFiltersTitle => 'Filtros de imagen';

  @override
  String get qualityEnhancementLabel => 'Mejora de calidad';

  @override
  String get imageUpscaling => 'Upscaling de imagen';

  @override
  String get enableImageUpscaling => 'Habilitar upscaling';

  @override
  String get enableImageUpscalingDesc => 'Aumenta la resolución de la imagen';

  @override
  String get upscalingFactor => 'Factor de upscaling';

  @override
  String get upscalingDisabledWithCustom => 'El upscaling está deshabilitado cuando se usa resolución personalizada.';

  @override
  String get imageColorProfiles => 'Perfiles de color';

  @override
  String get userGuideMenu => 'Guía';

  @override
  String get userGuideTitle => 'Guía de uso';

  @override
  String get userGuideIntro => 'Resumen de FE Media Converter: elige el tipo de medio, añade archivos, formato y calidad, ajusta filtros si quieres y usa la cola para convertir. Los ajustes se guardan entre sesiones.';

  @override
  String get guideSectionQuickStartTitle => 'Inicio rápido';

  @override
  String get guideSectionQuickStartBody => '1) Elige Vídeo, Audio o Imagen a la izquierda.\n2) Examina o arrastra archivos a la ventana.\n3) Elige formato de salida y códecs.\n4) Ajusta la calidad (CRF o bitrate).\n5) Añade a la cola, abre la pestaña Cola e inicia.\n6) Ajustes: carpeta de salida, tema, idioma, hilos CPU y GPU.';

  @override
  String get guideSectionFormatsTitle => 'Formatos y códecs';

  @override
  String get guideSectionFormatsBody => 'Cada modo tiene sus ajustes. Vídeo: H.264, HEVC, VP9, AV1, etc. Audio: AAC, MP3, Opus, FLAC… Imágenes: PNG, JPEG, WebP… Puedes extraer solo audio del vídeo si la opción está activa en Ajustes.';

  @override
  String get guideSectionVideoTitle => 'Vídeo: filtros e IA';

  @override
  String get guideSectionVideoBody => 'Filtros avanzados: reducción de ruido, nitidez, color (brillo, contraste, saturación, gamma, RGB), estabilización, desentrelazado, perfiles creativos. El análisis inteligente puede sugerir optimizaciones (poca luz, compresión fuerte, aspecto de película antigua).\nDRUNet opcional descarga un modelo neuronal. Detección de escenas (PySceneDetect) analiza cortes; activa la optimización por escenas para aplicar sus sugerencias.\nLa aceleración GPU mueve la codificación a la gráfica; elige un equilibrio velocidad/calidad.';

  @override
  String get guideSectionAudioTitle => 'Filtros de audio';

  @override
  String get guideSectionAudioBody => 'Volumen, compresión y normalización. Ecualizador graves/agudos y presets (p. ej. refuerzo de graves, voz). Limpieza reduce el sisido; reverberación añade espacio. La vista previa compara original y procesado cuando está disponible.';

  @override
  String get guideSectionImageTitle => 'Imágenes: resolución y upscaling';

  @override
  String get guideSectionImageBody => 'Ajustes de calidad/color similares al vídeo. Ancho/alto personalizados o mantener proporción. La superresolución aumenta la resolución; se desactiva si choca con una resolución fija. Perfiles de color para estilos rápidos.';

  @override
  String get guideSectionQueueTitle => 'Cola y paralelismo';

  @override
  String get guideSectionQueueBody => 'La cola muestra tareas pendientes, activas, en pausa, completadas o fallidas. Puedes pausar, reanudar, detener o quitar. Las conversiones simultáneas en Ajustes controlan la carga del sistema.';

  @override
  String get guideSectionSettingsTitle => 'Ajustes';

  @override
  String get guideSectionSettingsBody => 'Carpeta de salida vacía = junto a cada origen. Hilos CPU limitan FFmpeg (0 = auto). Tema e idioma tras confirmar. Formatos y códecs por defecto se recuerdan por tipo de medio.';

  @override
  String get guideSectionModelsTitle => 'Modelos y Python';

  @override
  String get guideSectionModelsBody => 'DRUNet y los scripts de escenas usan el entorno Python de la app. En el primer arranque puede pedirse descargar pesos DRUNet (~125 MB). Puedes cambiar la carpeta de modelos; hay caché por defecto en el directorio personal.';

  @override
  String get guideSectionDepsTitle => 'FFmpeg y comprobación';

  @override
  String get guideSectionDepsBody => 'FFmpeg debe estar instalado y razonablemente actualizado. Si aparece la pantalla de dependencias, sigue la instalación guiada o manual y reintenta. Python 3 y pip/venv mejoran las funciones opcionales.';

  @override
  String get pythonSetupTitle => 'Componentes Python opcionales';

  @override
  String get pythonSetupIntro => 'DRUNet y la detección de escenas usan un entorno virtual Python local (PyTorch, etc.). La descarga puede ser grande y se hace en el primer inicio de la app, no al instalar el paquete.\n\nInstala ahora u omite y usa el resto sin estas funciones.';

  @override
  String get pythonSetupInstall => 'Descargar e instalar';

  @override
  String get pythonSetupSkip => 'Omitir por ahora';

  @override
  String get pythonSetupRunning => 'Instalando paquetes (puede tardar varios minutos)…';

  @override
  String get pythonSetupPleaseWait => 'Espere…';

  @override
  String get pythonSetupSuccess => 'Entorno Python listo. DRUNet y herramientas de escenas disponibles.';

  @override
  String pythonSetupFailed(int code) {
    return 'Error (código: $code). Reintenta o ejecuta scripts/python/setup_python_env.sh manualmente.';
  }

  @override
  String get pythonSetupRetry => 'Reintentar';
}
