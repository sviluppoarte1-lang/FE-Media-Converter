// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FE Media Converter 🎬🎵🖼️';

  @override
  String get conversion => 'Conversion';

  @override
  String get queue => 'Queue';

  @override
  String get settings => 'Settings';

  @override
  String get about => 'About';

  @override
  String get close => 'Close';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get remove => 'Remove';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get stop => 'Stop';

  @override
  String get clear => 'Clear';

  @override
  String get clearAll => 'Clear All';

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
  String get browse => 'Browse';

  @override
  String get addToQueue => 'Add to Queue';

  @override
  String get clearSelection => 'Clear Selection';

  @override
  String get videoCodec => 'Video Codec';

  @override
  String get videoBitrate => 'Video Bitrate';

  @override
  String get qualityMode => 'Quality Mode';

  @override
  String get constantQuality => 'Constant Quality';

  @override
  String get constantBitrate => 'Constant Bitrate';

  @override
  String get crfDescription => 'Maintains constant quality, variable file size';

  @override
  String get bitrateDescription => 'Maintains constant file size, variable quality';

  @override
  String get videoSettings => 'Video Settings';

  @override
  String get advancedVideoSettings => 'Advanced Video Settings';

  @override
  String get codecDescription => 'Select video compression format';

  @override
  String get bitrateMode => 'Bitrate Mode';

  @override
  String get mediaType => 'Media Type';

  @override
  String selectMedia(Object mediaType) {
    return 'Select $mediaType';
  }

  @override
  String get noFilesSelected => 'No files selected';

  @override
  String clickToBrowse(Object mediaType) {
    return 'Click on \"Browse $mediaType\" to select files';
  }

  @override
  String filesSelected(Object count) {
    return '$count files selected';
  }

  @override
  String get selectionCleared => 'Selection cleared';

  @override
  String filesAddedToQueue(Object count) {
    return '$count files added to queue';
  }

  @override
  String get dropFilesHere => 'Drop files here to add them';

  @override
  String get dragAndDropSupported => 'Drag and drop files here';

  @override
  String outputFormat(Object mediaType) {
    return 'Output Format - $mediaType';
  }

  @override
  String get qualitySettings => 'Quality Settings';

  @override
  String get videoQuality => 'Video Quality:';

  @override
  String get audioQuality => 'Audio Quality:';

  @override
  String get videoFilters => 'Advanced Video Filters';

  @override
  String get audioFilters => 'Professional Audio Filters';

  @override
  String get conversionQueue => 'Conversion Queue';

  @override
  String completedCount(Object completed, Object total) {
    return '$completed/$total completed';
  }

  @override
  String get converting => 'Converting...';

  @override
  String get noFilesInQueue => 'No files in queue';

  @override
  String get addFilesFromConversion => 'Add files from the Conversion page\nto start converting';

  @override
  String get removeFromQueue => 'Remove from queue';

  @override
  String get pauseConversion => 'Pause conversion';

  @override
  String get stopConversion => 'Stop conversion';

  @override
  String fileRemoved(Object fileName) {
    return '\"$fileName\" removed from queue';
  }

  @override
  String filePaused(Object fileName) {
    return '\"$fileName\" paused';
  }

  @override
  String fileStopped(Object fileName) {
    return '\"$fileName\" stopped';
  }

  @override
  String get pending => 'Pending';

  @override
  String get processing => 'Processing';

  @override
  String get paused => 'Paused';

  @override
  String get completed => 'Completed';

  @override
  String get failed => 'Failed';

  @override
  String get calculating => 'Calculating...';

  @override
  String get waiting => 'Waiting';

  @override
  String get conversionInProgress => 'Conversion in progress';

  @override
  String pausedAt(Object time) {
    return 'Paused at $time';
  }

  @override
  String completedAt(Object time) {
    return 'Completed $time';
  }

  @override
  String failedAt(Object time) {
    return 'Failed $time';
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
  String get theme => 'Theme';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get outputFolder => 'Output Folder';

  @override
  String get sameAsInput => 'Same as input folder';

  @override
  String get cpuThreads => 'CPU Threads';

  @override
  String get autoDetect => 'Auto-detect';

  @override
  String get concurrentConversions => 'Concurrent Conversions';

  @override
  String get concurrentConversionsDesc => 'Number of files to convert concurrently';

  @override
  String get gpuAcceleration => 'GPU Acceleration';

  @override
  String get useGpu => 'Use GPU for conversion';

  @override
  String get gpuCompatibility => 'Better performance but limited compatibility';

  @override
  String get requiresCompatibleHardware => 'Requires compatible hardware and drivers';

  @override
  String get gpuType => 'GPU Type';

  @override
  String get autoDetection => 'Auto-detection';

  @override
  String get selectGpuType => 'Select the type of graphics card installed';

  @override
  String get information => 'Information';

  @override
  String get version => 'Version';

  @override
  String get professionalMediaConversion => 'Professional media conversion application';

  @override
  String get usesFfmpeg => 'Uses FFmpeg for conversions. Make sure FFmpeg is installed on your system.';

  @override
  String get extractAudioOnly => 'Extract Audio Only';

  @override
  String get extractAudioFromVideo => 'Extract audio from video files (e.g., MP4 to MP3, MOV to WAV)';

  @override
  String get video => 'Video';

  @override
  String get audio => 'Audio';

  @override
  String get image => 'Image';

  @override
  String get videos => 'Videos';

  @override
  String get audios => 'Audios';

  @override
  String get images => 'Images';

  @override
  String get formats => 'formats';

  @override
  String get filtersActive => 'Active filters';

  @override
  String get resetAll => 'Reset All';

  @override
  String get noiseReduction => 'Noise Reduction';

  @override
  String get noiseReductionStrength => 'Noise Reduction Strength';

  @override
  String get reducesDigitalNoise => 'Reduces digital noise and grain. High values may soften the image.';

  @override
  String get qualityEnhancement => 'Quality Enhancement';

  @override
  String get sharpness => 'Sharpness';

  @override
  String get brightness => 'Brightness';

  @override
  String get contrast => 'Contrast';

  @override
  String get saturation => 'Saturation';

  @override
  String get gamma => 'Gamma';

  @override
  String get advancedCorrections => 'Advanced Corrections';

  @override
  String get videoStabilization => 'Video Stabilization';

  @override
  String get reducesCameraShake => 'Reduces camera shake';

  @override
  String get deinterlacing => 'Deinterlacing';

  @override
  String get removesInterlacedLines => 'Removes lines from interlaced videos';

  @override
  String get colorProfiles => 'Color Profiles';

  @override
  String get none => 'None';

  @override
  String get vivid => 'Vivid';

  @override
  String get cinematic => 'Cinematic';

  @override
  String get blackWhite => 'Black & White';

  @override
  String get sepia => 'Sepia';

  @override
  String get activeEffectsPreview => 'Active Effects Preview:';

  @override
  String get noActiveFilters => 'No active filters';

  @override
  String get volumeDynamics => 'Volume and Dynamics';

  @override
  String get volume => 'Volume';

  @override
  String get compression => 'Compression';

  @override
  String get normalization => 'Normalization';

  @override
  String get levelsVolumeAutomatically => 'Levels volume automatically';

  @override
  String get equalizer => 'Equalizer';

  @override
  String get bass => 'Bass';

  @override
  String get treble => 'Treble';

  @override
  String get equalizerPreset => 'Equalizer Preset:';

  @override
  String get bassBoost => 'Bass Boost';

  @override
  String get trebleBoost => 'Treble Boost';

  @override
  String get voice => 'Voice';

  @override
  String get audioCleaning => 'Audio Cleaning';

  @override
  String get removeNoise => 'Remove Noise';

  @override
  String get reducesBackgroundHiss => 'Reduces background hiss';

  @override
  String get noiseThreshold => 'Noise Threshold';

  @override
  String get reverb => 'Reverb';

  @override
  String get activeAudioEffects => 'Active Audio Effects:';

  @override
  String get noActiveAudioFilters => 'No active audio filters';

  @override
  String excellentQuality(Object crf) {
    return 'Excellent (CRF: $crf)';
  }

  @override
  String greatQuality(Object crf) {
    return 'Great (CRF: $crf)';
  }

  @override
  String goodQuality(Object crf) {
    return 'Good (CRF: $crf)';
  }

  @override
  String averageQuality(Object crf) {
    return 'Average (CRF: $crf)';
  }

  @override
  String lowQualityLabel(Object crf) {
    return 'Low (CRF: $crf)';
  }

  @override
  String get crfScale => 'CRF: 0 (Best) - 51 (Worst)';

  @override
  String get bitrateScale => 'Bitrate: 64 kbps - 320 kbps';

  @override
  String get audioCodec => 'Audio Codec';

  @override
  String get audioCodecDesc => 'Select audio codec for the output file';

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
  String get files => 'files';

  @override
  String get customResolution => 'Custom Resolution';

  @override
  String get customWidth => 'Width (px)';

  @override
  String get customHeight => 'Height (px)';

  @override
  String get originalResolution => 'Image Resolution';

  @override
  String get previewOriginal => 'Original Preview';

  @override
  String get previewModified => 'Modified Preview';

  @override
  String get useCustomResolution => 'Use Custom Resolution';

  @override
  String get customResolutionDesc => 'Set specific width and height (e.g. 1920x1080)';

  @override
  String get loadingResolution => 'Loading resolution...';

  @override
  String get resolutionNotAvailable => 'Resolution not available';

  @override
  String get selectImageForResolution => 'Select an image to see the resolution';

  @override
  String get resolutionDescription => 'Set a specific resolution. If you set only width or height, the aspect ratio is maintained.';

  @override
  String get previewDescription => 'View the original image or with filters applied';

  @override
  String get advancedUpscalingAlgorithms => 'Double or quadruple the image resolution. Uses advanced upscaling algorithms.';

  @override
  String audioCodecSection(Object mediaType) {
    return 'Audio Codec - $mediaType';
  }

  @override
  String get ffmpegVersionCheck => 'FFmpeg Version Check';

  @override
  String get ffmpegNotInstalled => 'FFmpeg is not installed or version is outdated';

  @override
  String get ffmpegVersionRequired => 'Required version: 8.0.1';

  @override
  String ffmpegCurrentVersion(Object version) {
    return 'Current version: $version';
  }

  @override
  String get ffmpegNeedsUpdate => 'FFmpeg needs to be updated to version 8.0.1';

  @override
  String get installFFmpeg => 'Install FFmpeg 8.0.1';

  @override
  String get installFFmpegDesc => 'This will install FFmpeg 8.0.1 using administrator privileges. The password will be stored securely for future use.';

  @override
  String get enterSudoPassword => 'Enter administrator password';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get installingFFmpeg => 'Installing FFmpeg...';

  @override
  String get ffmpegInstallSuccess => 'FFmpeg 8.0.1 installed successfully!';

  @override
  String ffmpegInstallFailed(Object error) {
    return 'FFmpeg installation failed: $error';
  }

  @override
  String detectedDistribution(Object distro) {
    return 'Detected distribution: $distro';
  }

  @override
  String get addingRepository => 'Adding repository...';

  @override
  String get updatingPackages => 'Updating package list...';

  @override
  String get installingPackage => 'Installing FFmpeg...';

  @override
  String get passwordStored => 'Password stored securely for future installations';

  @override
  String get skipInstallation => 'Skip Installation';

  @override
  String get manualInstall => 'Manual Installation';

  @override
  String get manualInstallDesc => 'You can install FFmpeg manually using the commands below';

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
  String get audioPreview => 'Audio Preview';

  @override
  String get audioPreviewDescription => 'Listen to the original audio or with filters applied';

  @override
  String get openWithSystemPlayer => 'Open with system player';

  @override
  String get audioFileReady => 'Audio file ready for playback';

  @override
  String get modifiedAudioGenerated => 'Modified audio generated (first 10 seconds)';

  @override
  String get fileWillOpenWithDefaultPlayer => 'The file will open with the system\'s default audio player';

  @override
  String get videoQualityMode => 'Video Quality Mode';

  @override
  String get constantQualityLabel => 'CRF (Constant Quality)';

  @override
  String get constantBitrateLabel => 'Bitrate (File Size)';

  @override
  String get videoBitrateLabel => 'Video Bitrate';

  @override
  String get crfQualityRange => 'CRF: 0 (Best Quality) - 51 (Worst Quality)';

  @override
  String get bitrateQualityRange => 'Bitrate: 500 kbps (Low Quality) - 20,000 kbps (Very High Quality)';

  @override
  String get qualityLabel => 'Quality:';

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
  String get audioQualityHighest => 'Highest Quality (Lossless-like)';

  @override
  String get audioQualityHigh => 'High Quality (Transparency)';

  @override
  String get audioQualityMedium => 'Medium Quality (Good balance)';

  @override
  String get audioQualityLow => 'Low Quality (Compatibility)';

  @override
  String get selectVideoForAnalysis => 'Select a video for automatic analysis';

  @override
  String get analyzeVideoQuality => 'Analyze Video Quality';

  @override
  String get analyzingVideoQuality => 'Analyzing video quality...';

  @override
  String get videoAnalyzedNoIssues => 'Video analyzed - No critical issues';

  @override
  String problemsDetectedRecommendations(Object problems, Object recommendations) {
    return '$problems problems detected - $recommendations recommendations';
  }

  @override
  String get intelligentVideoAnalysis => 'Intelligent Video Analysis';

  @override
  String get automaticOptimizations => 'Automatic Optimizations';

  @override
  String get autoOptimization => 'Auto Optimization';

  @override
  String get autoOptimizationDesc => 'Apply best settings based on analysis';

  @override
  String get lowQuality => 'Low Quality ⭐';

  @override
  String get lowQualityDesc => 'MAXIMUM OPTIMIZATION for low quality videos with heavy noise';

  @override
  String get ultraQuality => 'Ultra Quality';

  @override
  String get ultraQualityDesc => 'Professional enhancement with all advanced filters';

  @override
  String get lowLight => 'Low Light';

  @override
  String get lowLightDesc => 'Improve videos in low light conditions';

  @override
  String get detailRecovery => 'Restore Details';

  @override
  String get detailRecoveryDesc => 'Recover lost details and textures';

  @override
  String get compressionFix => 'Fix Compression';

  @override
  String get compressionFixDesc => 'Remove artifacts from heavy compression';

  @override
  String get filmRestoration => 'Film Restoration';

  @override
  String get filmRestorationDesc => 'Optimized for old videos and films';

  @override
  String get fundamentalFilters => 'Fundamental Filters';

  @override
  String get qualityAndDetails => 'Quality and Details';

  @override
  String get noiseReductionLabel => 'Noise Reduction';

  @override
  String get colorAndLight => 'Color and Light';

  @override
  String get redBalance => 'Red Balance';

  @override
  String get greenBalance => 'Green Balance';

  @override
  String get blueBalance => 'Blue Balance';

  @override
  String get deinterlacingLabel => 'Deinterlacing';

  @override
  String get deinterlacingDesc => 'Remove interlaced lines from older videos';

  @override
  String get stabilizationLabel => 'Stabilization';

  @override
  String get stabilizationDesc => 'Reduce camera shake';

  @override
  String get detailEnhancement => 'Detail Enhancement';

  @override
  String get detailEnhancementDesc => 'Improve detail definition';

  @override
  String get gpuAccelerationLabel => 'GPU Acceleration';

  @override
  String get useGpuForConversion => 'Use GPU for conversion';

  @override
  String get useGpuForConversionDesc => 'Move video encoding to graphics card (if available)';

  @override
  String get gpuPreset => 'GPU Preset (speed vs quality)';

  @override
  String get gpuPresetFast => 'Fast';

  @override
  String get gpuPresetFastDesc => 'Maximum speed, slightly lower quality';

  @override
  String get gpuPresetMedium => 'Medium';

  @override
  String get gpuPresetMediumDesc => 'Balanced between speed and quality (recommended)';

  @override
  String get gpuPresetHighQuality => 'High Quality';

  @override
  String get gpuPresetHighQualityDesc => 'Best possible quality, slower conversion';

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
  String get noneLabel => 'None';

  @override
  String get vividLabel => 'Vivid';

  @override
  String get cinematicLabel => 'Cinematic';

  @override
  String get blackWhiteLabel => 'Black & White';

  @override
  String get sepiaLabel => 'Sepia';

  @override
  String get imageFiltersTitle => 'Image Filters';

  @override
  String get qualityEnhancementLabel => 'Quality Enhancement';

  @override
  String get imageUpscaling => 'Image Upscaling';

  @override
  String get enableImageUpscaling => 'Enable Upscaling';

  @override
  String get enableImageUpscalingDesc => 'Increase image resolution';

  @override
  String get upscalingFactor => 'Upscaling Factor';

  @override
  String get upscalingDisabledWithCustom => 'Upscaling is disabled when using custom resolution.';

  @override
  String get imageColorProfiles => 'Color Profiles';

  @override
  String get userGuideMenu => 'User guide';

  @override
  String get userGuideTitle => 'User guide';

  @override
  String get userGuideIntro => 'This guide summarizes how FE Media Converter works: pick a media type, add files, choose format and quality, optionally tune filters, then use the queue to run jobs. Settings persist between sessions.';

  @override
  String get guideSectionQuickStartTitle => 'Quick start';

  @override
  String get guideSectionQuickStartBody => '1) Choose Video, Audio, or Image on the left.\n2) Tap Browse or drop files onto the window.\n3) Pick output format and codecs.\n4) Adjust quality (CRF or bitrate) if needed.\n5) Tap Add to queue, open the Queue tab, and start conversion.\n6) Use Settings for output folder, theme, language, threads, and GPU options.';

  @override
  String get guideSectionFormatsTitle => 'Formats and codecs';

  @override
  String get guideSectionFormatsBody => 'Each media mode has its own presets. Video supports common codecs (for example H.264, HEVC, VP9, AV1). Audio includes AAC, MP3, Opus, FLAC, and more. Images support PNG, JPEG, WebP, and others. You can extract audio only from video files when that option is enabled in Settings.';

  @override
  String get guideSectionVideoTitle => 'Video: filters and AI';

  @override
  String get guideSectionVideoBody => 'Advanced video filters cover noise reduction, sharpness, color (brightness, contrast, saturation, gamma, RGB balance), stabilization, deinterlacing, and creative color profiles. Intelligent analysis can suggest optimizations for low light, heavy compression, or old film look.\nOptional DRUNet denoising uses a downloaded neural model. Scene detection (PySceneDetect) can analyze cuts to tune encoding; enable scene-based optimization to apply its hints.\nGPU acceleration (when supported) moves encoding to the graphics card—pick a GPU preset that balances speed and quality.';

  @override
  String get guideSectionAudioTitle => 'Audio filters';

  @override
  String get guideSectionAudioBody => 'Adjust volume, compression, and normalization. Use the equalizer with bass/treble controls and presets (for example bass boost or voice). Cleaning tools reduce background hiss; reverb adds space. Preview helps compare original and processed audio where available.';

  @override
  String get guideSectionImageTitle => 'Images: resolution and upscaling';

  @override
  String get guideSectionImageBody => 'Apply quality and color adjustments similar to video. Set a custom width/height or keep aspect ratio by filling only one dimension. Super-resolution / upscaling increases resolution; it is disabled when a fixed custom resolution conflicts with scaling. Color profiles give quick stylistic looks.';

  @override
  String get guideSectionQueueTitle => 'Queue and concurrency';

  @override
  String get guideSectionQueueBody => 'The queue lists pending, active, paused, completed, and failed jobs. You can pause, resume, stop, or remove tasks. Concurrent conversions in Settings controls how many files run at once—raise it on powerful CPUs, lower it to reduce load.';

  @override
  String get guideSectionSettingsTitle => 'Settings';

  @override
  String get guideSectionSettingsBody => 'Output folder: leave empty to write next to each source file. CPU threads limits FFmpeg thread usage (0 = auto). Theme and UI language apply immediately after confirmation. Default formats and codecs are remembered per media type.';

  @override
  String get guideSectionModelsTitle => 'Models and Python tools';

  @override
  String get guideSectionModelsBody => 'DRUNet and scene scripts live under the app’s Python environment. On first launch you may be prompted to download the DRUNet weights (~125 MB). You can change the models directory in Settings; the app also uses a default folder under your home for caches.';

  @override
  String get guideSectionDepsTitle => 'FFmpeg and startup check';

  @override
  String get guideSectionDepsBody => 'FFmpeg must be installed and reasonably up to date. If the dependency screen appears, follow the guided install or manual instructions, then retry. The app also benefits from Python 3 and pip/venv for optional features.';

  @override
  String get pythonSetupTitle => 'Optional Python components';

  @override
  String get pythonSetupIntro => 'DRUNet AI denoising and scene detection use a local Python virtual environment with PyTorch and other libraries. This download can be large and is prepared on first launch (not during package install).\n\nInstall now, or skip and use the rest of the app without these features.';

  @override
  String get pythonSetupInstall => 'Download and install';

  @override
  String get pythonSetupSkip => 'Skip for now';

  @override
  String get pythonSetupRunning => 'Installing packages (this may take several minutes)…';

  @override
  String get pythonSetupPleaseWait => 'Please wait…';

  @override
  String get pythonSetupSuccess => 'Python environment is ready. You can use DRUNet and scene tools.';

  @override
  String pythonSetupFailed(int code) {
    return 'Setup failed (exit code: $code). You can retry or run scripts/python/setup_python_env.sh manually.';
  }

  @override
  String get pythonSetupRetry => 'Retry';
}
