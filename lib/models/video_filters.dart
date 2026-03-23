class VideoFilters {
  double denoiseStrength;
  double sharpness;
  double brightness;
  double contrast;
  double saturation;
  double gamma;
  bool enableStabilization;
  bool enableDeinterlace;
  String colorProfile;
  String noiseReductionMethod;
  bool enableDetailEnhancement;
  double unsharpMask;

  String superResolutionMethod;
  String advancedDenoiseMethod;
  double detailEnhanceStrength;
  bool enableEdgeSharpening;
  double colorBalanceR;
  double colorBalanceG;
  double colorBalanceB;
  String curvesPreset;
  double hue;
  double saturationAdvanced;
  double value;
  double filmGrain;
  bool enableHdrToneMapping;

  String advancedDebandingMethod;
  double temporalDenoise;
  bool enableAdaptiveSharpening;
  String chromaUpsampling;
  bool enableColorVibrance;
  double textureBoost;
  bool enableArtifactRemoval;
  double compressionCleanup;

  bool enableGpuAcceleration;
  String gpuVendor;
  bool enableGpuFilters;
  String gpuEncodingPreset;

  bool enableDRUNetDenoising;
  int drunetNoiseLevel;
  String drunetDevice;

  bool enableSceneDetection;
  String sceneDetectionMethod;
  bool useSceneBasedOptimization;

  /// Costruttore neutro (usato dai preset che passano solo alcuni campi).
  VideoFilters({
    this.denoiseStrength = 0.0,
    this.sharpness = 1.0,
    this.brightness = 0.0,
    this.contrast = 1.0,
    this.saturation = 1.0,
    this.gamma = 1.0,
    this.enableStabilization = false,
    this.enableDeinterlace = false,
    this.colorProfile = 'none',
    this.noiseReductionMethod = 'none',
    this.enableDetailEnhancement = false,
    this.unsharpMask = 0.0,
    this.superResolutionMethod = 'none',
    this.advancedDenoiseMethod = 'none',
    this.detailEnhanceStrength = 0.0,
    this.enableEdgeSharpening = false,
    this.colorBalanceR = 0.0,
    this.colorBalanceG = 0.0,
    this.colorBalanceB = 0.0,
    this.curvesPreset = 'none',
    this.hue = 0.0,
    this.saturationAdvanced = 1.0,
    this.value = 1.0,
    this.filmGrain = 0.0,
    this.enableHdrToneMapping = false,
    this.advancedDebandingMethod = 'none',
    this.temporalDenoise = 0.0,
    this.enableAdaptiveSharpening = false,
    this.chromaUpsampling = 'lanczos',
    this.enableColorVibrance = false,
    this.textureBoost = 0.0,
    this.enableArtifactRemoval = false,
    this.compressionCleanup = 0.0,
    this.enableGpuAcceleration = true,
    this.gpuVendor = 'auto',
    this.enableGpuFilters = true,
    this.gpuEncodingPreset = 'medium',
    this.enableDRUNetDenoising = false,
    this.drunetNoiseLevel = 7,
    this.drunetDevice = 'auto',
    this.enableSceneDetection = false,
    this.sceneDetectionMethod = 'adaptive',
    this.useSceneBasedOptimization = false,
  });

  /// Predefinito app: catena FFmpeg completa (denoise, scale 2×, dettaglio, deband, color, ecc.),
  /// DRUNet + PySceneDetect attivi. Usare all'avvio e per «Ripristina».
  static VideoFilters maximumQualityDefaults() {
    return VideoFilters(
      denoiseStrength: 0.35,
      sharpness: 1.2,
      brightness: 0.05,
      contrast: 1.12,
      saturation: 1.08,
      gamma: 1.0,
      enableStabilization: false,
      enableDeinterlace: false,
      colorProfile: 'cinematic',
      noiseReductionMethod: 'medium',
      enableDetailEnhancement: true,
      unsharpMask: 0.2,
      superResolutionMethod: 'nnedi3',
      advancedDenoiseMethod: 'nlmeans',
      detailEnhanceStrength: 0.7,
      enableEdgeSharpening: true,
      colorBalanceR: 0.0,
      colorBalanceG: 0.0,
      colorBalanceB: 0.0,
      curvesPreset: 'contrast',
      hue: 0.0,
      saturationAdvanced: 1.0,
      value: 1.0,
      filmGrain: 0.01,
      enableHdrToneMapping: true,
      advancedDebandingMethod: 'gradfun',
      temporalDenoise: 0.4,
      enableAdaptiveSharpening: true,
      chromaUpsampling: 'lanczos',
      enableColorVibrance: true,
      textureBoost: 0.3,
      enableArtifactRemoval: true,
      compressionCleanup: 0.8,
      enableGpuAcceleration: true,
      gpuVendor: 'auto',
      enableGpuFilters: true,
      gpuEncodingPreset: 'high_quality',
      enableDRUNetDenoising: true,
      drunetNoiseLevel: 7,
      drunetDevice: 'auto',
      enableSceneDetection: true,
      sceneDetectionMethod: 'adaptive',
      useSceneBasedOptimization: true,
    );
  }

  VideoFilters copyWith({
    double? denoiseStrength,
    double? sharpness,
    double? brightness,
    double? contrast,
    double? saturation,
    double? gamma,
    bool? enableStabilization,
    bool? enableDeinterlace,
    String? colorProfile,
    String? noiseReductionMethod,
    bool? enableDetailEnhancement,
    double? unsharpMask,
    String? superResolutionMethod,
    String? advancedDenoiseMethod,
    double? detailEnhanceStrength,
    bool? enableEdgeSharpening,
    double? colorBalanceR,
    double? colorBalanceG,
    double? colorBalanceB,
    String? curvesPreset,
    double? hue,
    double? saturationAdvanced,
    double? value,
    double? filmGrain,
    bool? enableHdrToneMapping,
    String? advancedDebandingMethod,
    double? temporalDenoise,
    bool? enableAdaptiveSharpening,
    String? chromaUpsampling,
    bool? enableColorVibrance,
    double? textureBoost,
    bool? enableArtifactRemoval,
    double? compressionCleanup,
    bool? enableGpuAcceleration,
    String? gpuVendor,
    bool? enableGpuFilters,
    String? gpuEncodingPreset,
    bool? enableDRUNetDenoising,
    int? drunetNoiseLevel,
    String? drunetDevice,
    bool? enableSceneDetection,
    String? sceneDetectionMethod,
    bool? useSceneBasedOptimization,
  }) {
    return VideoFilters(
      denoiseStrength: denoiseStrength ?? this.denoiseStrength,
      sharpness: sharpness ?? this.sharpness,
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      saturation: saturation ?? this.saturation,
      gamma: gamma ?? this.gamma,
      enableStabilization: enableStabilization ?? this.enableStabilization,
      enableDeinterlace: enableDeinterlace ?? this.enableDeinterlace,
      colorProfile: colorProfile ?? this.colorProfile,
      noiseReductionMethod: noiseReductionMethod ?? this.noiseReductionMethod,
      enableDetailEnhancement: enableDetailEnhancement ?? this.enableDetailEnhancement,
      unsharpMask: unsharpMask ?? this.unsharpMask,
      superResolutionMethod: superResolutionMethod ?? this.superResolutionMethod,
      advancedDenoiseMethod: advancedDenoiseMethod ?? this.advancedDenoiseMethod,
      detailEnhanceStrength: detailEnhanceStrength ?? this.detailEnhanceStrength,
      enableEdgeSharpening: enableEdgeSharpening ?? this.enableEdgeSharpening,
      colorBalanceR: colorBalanceR ?? this.colorBalanceR,
      colorBalanceG: colorBalanceG ?? this.colorBalanceG,
      colorBalanceB: colorBalanceB ?? this.colorBalanceB,
      curvesPreset: curvesPreset ?? this.curvesPreset,
      hue: hue ?? this.hue,
      saturationAdvanced: saturationAdvanced ?? this.saturationAdvanced,
      value: value ?? this.value,
      filmGrain: filmGrain ?? this.filmGrain,
      enableHdrToneMapping: enableHdrToneMapping ?? this.enableHdrToneMapping,
      advancedDebandingMethod: advancedDebandingMethod ?? this.advancedDebandingMethod,
      temporalDenoise: temporalDenoise ?? this.temporalDenoise,
      enableAdaptiveSharpening: enableAdaptiveSharpening ?? this.enableAdaptiveSharpening,
      chromaUpsampling: chromaUpsampling ?? this.chromaUpsampling,
      enableColorVibrance: enableColorVibrance ?? this.enableColorVibrance,
      textureBoost: textureBoost ?? this.textureBoost,
      enableArtifactRemoval: enableArtifactRemoval ?? this.enableArtifactRemoval,
      compressionCleanup: compressionCleanup ?? this.compressionCleanup,
      enableGpuAcceleration: enableGpuAcceleration ?? this.enableGpuAcceleration,
      gpuVendor: gpuVendor ?? this.gpuVendor,
      enableGpuFilters: enableGpuFilters ?? this.enableGpuFilters,
      gpuEncodingPreset: gpuEncodingPreset ?? this.gpuEncodingPreset,
      enableDRUNetDenoising: enableDRUNetDenoising ?? this.enableDRUNetDenoising,
      drunetNoiseLevel: drunetNoiseLevel ?? this.drunetNoiseLevel,
      drunetDevice: drunetDevice ?? this.drunetDevice,
      enableSceneDetection: enableSceneDetection ?? this.enableSceneDetection,
      sceneDetectionMethod: sceneDetectionMethod ?? this.sceneDetectionMethod,
      useSceneBasedOptimization: useSceneBasedOptimization ?? this.useSceneBasedOptimization,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'denoiseStrength': denoiseStrength,
      'sharpness': sharpness,
      'brightness': brightness,
      'contrast': contrast,
      'saturation': saturation,
      'gamma': gamma,
      'enableStabilization': enableStabilization,
      'enableDeinterlace': enableDeinterlace,
      'colorProfile': colorProfile,
      'noiseReductionMethod': noiseReductionMethod,
      'enableDetailEnhancement': enableDetailEnhancement,
      'unsharpMask': unsharpMask,
      'superResolutionMethod': superResolutionMethod,
      'advancedDenoiseMethod': advancedDenoiseMethod,
      'detailEnhanceStrength': detailEnhanceStrength,
      'enableEdgeSharpening': enableEdgeSharpening,
      'colorBalanceR': colorBalanceR,
      'colorBalanceG': colorBalanceG,
      'colorBalanceB': colorBalanceB,
      'curvesPreset': curvesPreset,
      'hue': hue,
      'saturationAdvanced': saturationAdvanced,
      'value': value,
      'filmGrain': filmGrain,
      'enableHdrToneMapping': enableHdrToneMapping,
      'advancedDebandingMethod': advancedDebandingMethod,
      'temporalDenoise': temporalDenoise,
      'enableAdaptiveSharpening': enableAdaptiveSharpening,
      'chromaUpsampling': chromaUpsampling,
      'enableColorVibrance': enableColorVibrance,
      'textureBoost': textureBoost,
      'enableArtifactRemoval': enableArtifactRemoval,
      'compressionCleanup': compressionCleanup,
      'enableGpuAcceleration': enableGpuAcceleration,
      'gpuVendor': gpuVendor,
      'enableGpuFilters': enableGpuFilters,
      'gpuEncodingPreset': gpuEncodingPreset,
      'enableDRUNetDenoising': enableDRUNetDenoising,
      'drunetNoiseLevel': drunetNoiseLevel,
      'drunetDevice': drunetDevice,
      'enableSceneDetection': enableSceneDetection,
      'sceneDetectionMethod': sceneDetectionMethod,
      'useSceneBasedOptimization': useSceneBasedOptimization,
    };
  }

  static VideoFilters fromMap(Map<String, dynamic> map) {
    final d = VideoFilters.maximumQualityDefaults();
    return VideoFilters(
      denoiseStrength: _mapDouble(map['denoiseStrength'], d.denoiseStrength),
      sharpness: _mapDouble(map['sharpness'], d.sharpness),
      brightness: _mapDouble(map['brightness'], d.brightness),
      contrast: _mapDouble(map['contrast'], d.contrast),
      saturation: _mapDouble(map['saturation'], d.saturation),
      gamma: _mapDouble(map['gamma'], d.gamma),
      enableStabilization: map['enableStabilization'] ?? d.enableStabilization,
      enableDeinterlace: map['enableDeinterlace'] ?? d.enableDeinterlace,
      colorProfile: map['colorProfile'] as String? ?? d.colorProfile,
      noiseReductionMethod: map['noiseReductionMethod'] as String? ?? d.noiseReductionMethod,
      enableDetailEnhancement: map['enableDetailEnhancement'] ?? d.enableDetailEnhancement,
      unsharpMask: _mapDouble(map['unsharpMask'], d.unsharpMask),
      superResolutionMethod: map['superResolutionMethod'] as String? ?? d.superResolutionMethod,
      advancedDenoiseMethod: map['advancedDenoiseMethod'] as String? ?? d.advancedDenoiseMethod,
      detailEnhanceStrength: _mapDouble(map['detailEnhanceStrength'], d.detailEnhanceStrength),
      enableEdgeSharpening: map['enableEdgeSharpening'] ?? d.enableEdgeSharpening,
      colorBalanceR: _mapDouble(map['colorBalanceR'], d.colorBalanceR),
      colorBalanceG: _mapDouble(map['colorBalanceG'], d.colorBalanceG),
      colorBalanceB: _mapDouble(map['colorBalanceB'], d.colorBalanceB),
      curvesPreset: map['curvesPreset'] as String? ?? d.curvesPreset,
      hue: _mapDouble(map['hue'], d.hue),
      saturationAdvanced: _mapDouble(map['saturationAdvanced'], d.saturationAdvanced),
      value: _mapDouble(map['value'], d.value),
      filmGrain: _mapDouble(map['filmGrain'], d.filmGrain),
      enableHdrToneMapping: map['enableHdrToneMapping'] ?? d.enableHdrToneMapping,
      advancedDebandingMethod: map['advancedDebandingMethod'] as String? ?? d.advancedDebandingMethod,
      temporalDenoise: _mapDouble(map['temporalDenoise'], d.temporalDenoise),
      enableAdaptiveSharpening: map['enableAdaptiveSharpening'] ?? d.enableAdaptiveSharpening,
      chromaUpsampling: map['chromaUpsampling'] as String? ?? d.chromaUpsampling,
      enableColorVibrance: map['enableColorVibrance'] ?? d.enableColorVibrance,
      textureBoost: _mapDouble(map['textureBoost'], d.textureBoost),
      enableArtifactRemoval: map['enableArtifactRemoval'] ?? d.enableArtifactRemoval,
      compressionCleanup: _mapDouble(map['compressionCleanup'], d.compressionCleanup),
      enableGpuAcceleration: map['enableGpuAcceleration'] ?? d.enableGpuAcceleration,
      gpuVendor: map['gpuVendor'] as String? ?? d.gpuVendor,
      enableGpuFilters: map['enableGpuFilters'] ?? d.enableGpuFilters,
      gpuEncodingPreset: map['gpuEncodingPreset'] as String? ?? d.gpuEncodingPreset,
      enableDRUNetDenoising: map['enableDRUNetDenoising'] ?? d.enableDRUNetDenoising,
      drunetNoiseLevel: map['drunetNoiseLevel'] is int
          ? map['drunetNoiseLevel'] as int
          : (map['drunetNoiseLevel'] as num?)?.toInt() ?? d.drunetNoiseLevel,
      drunetDevice: map['drunetDevice'] as String? ?? d.drunetDevice,
      enableSceneDetection: map['enableSceneDetection'] ?? d.enableSceneDetection,
      sceneDetectionMethod: map['sceneDetectionMethod'] as String? ?? d.sceneDetectionMethod,
      useSceneBasedOptimization: map['useSceneBasedOptimization'] ?? d.useSceneBasedOptimization,
    );
  }

  static double _mapDouble(dynamic v, double fallback) {
    if (v == null) return fallback;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is num) return v.toDouble();
    return fallback;
  }

  void reset() {
    final d = VideoFilters.maximumQualityDefaults();
    denoiseStrength = d.denoiseStrength;
    sharpness = d.sharpness;
    brightness = d.brightness;
    contrast = d.contrast;
    saturation = d.saturation;
    gamma = d.gamma;
    enableStabilization = d.enableStabilization;
    enableDeinterlace = d.enableDeinterlace;
    colorProfile = d.colorProfile;
    noiseReductionMethod = d.noiseReductionMethod;
    enableDetailEnhancement = d.enableDetailEnhancement;
    unsharpMask = d.unsharpMask;
    superResolutionMethod = d.superResolutionMethod;
    advancedDenoiseMethod = d.advancedDenoiseMethod;
    detailEnhanceStrength = d.detailEnhanceStrength;
    enableEdgeSharpening = d.enableEdgeSharpening;
    colorBalanceR = d.colorBalanceR;
    colorBalanceG = d.colorBalanceG;
    colorBalanceB = d.colorBalanceB;
    curvesPreset = d.curvesPreset;
    hue = d.hue;
    saturationAdvanced = d.saturationAdvanced;
    value = d.value;
    filmGrain = d.filmGrain;
    enableHdrToneMapping = d.enableHdrToneMapping;
    advancedDebandingMethod = d.advancedDebandingMethod;
    temporalDenoise = d.temporalDenoise;
    enableAdaptiveSharpening = d.enableAdaptiveSharpening;
    chromaUpsampling = d.chromaUpsampling;
    enableColorVibrance = d.enableColorVibrance;
    textureBoost = d.textureBoost;
    enableArtifactRemoval = d.enableArtifactRemoval;
    compressionCleanup = d.compressionCleanup;
    enableGpuAcceleration = d.enableGpuAcceleration;
    gpuVendor = d.gpuVendor;
    enableGpuFilters = d.enableGpuFilters;
    gpuEncodingPreset = d.gpuEncodingPreset;
    enableDRUNetDenoising = d.enableDRUNetDenoising;
    drunetNoiseLevel = d.drunetNoiseLevel;
    drunetDevice = d.drunetDevice;
    enableSceneDetection = d.enableSceneDetection;
    sceneDetectionMethod = d.sceneDetectionMethod;
    useSceneBasedOptimization = d.useSceneBasedOptimization;
  }

  bool get hasActiveFilters {
    return denoiseStrength > 0.0 ||
        sharpness != 1.0 ||
        brightness != 0.0 ||
        contrast != 1.0 ||
        saturation != 1.0 ||
        gamma != 1.0 ||
        enableStabilization ||
        enableDeinterlace ||
        colorProfile != 'none' ||
        noiseReductionMethod != 'none' ||
        enableDetailEnhancement ||
        unsharpMask > 0.0 ||
        superResolutionMethod != 'none' ||
        advancedDenoiseMethod != 'none' ||
        detailEnhanceStrength > 0.0 ||
        enableEdgeSharpening ||
        colorBalanceR != 0.0 ||
        colorBalanceG != 0.0 ||
        colorBalanceB != 0.0 ||
        curvesPreset != 'none' ||
        hue != 0.0 ||
        saturationAdvanced != 1.0 ||
        value != 1.0 ||
        filmGrain > 0.0 ||
        enableHdrToneMapping ||
        advancedDebandingMethod != 'none' ||
        temporalDenoise > 0.0 ||
        enableAdaptiveSharpening ||
        chromaUpsampling != 'lanczos' ||
        enableColorVibrance ||
        textureBoost > 0.0 ||
        enableArtifactRemoval ||
        compressionCleanup > 0.0 ||
        enableDRUNetDenoising ||
        enableSceneDetection ||
        useSceneBasedOptimization;
  }

  /// Preset per enhancement professionale con filtri avanzati ma sicuri.
  static VideoFilters getProfessionalEnhancement() {
    return VideoFilters(
      superResolutionMethod: 'nnedi3',
      advancedDenoiseMethod: 'nlmeans',
      detailEnhanceStrength: 0.5,
      enableEdgeSharpening: true,
      noiseReductionMethod: 'medium',
      enableDetailEnhancement: true,
      unsharpMask: 0.25,
      sharpness: 1.1,
      contrast: 1.08,
      saturation: 1.06,
      brightness: 0.03,
      colorProfile: 'cinematic',
      curvesPreset: 'contrast',
      enableGpuAcceleration: true,
      gpuEncodingPreset: 'medium',
      enableArtifactRemoval: true,
      compressionCleanup: 0.6,
      textureBoost: 0.2,
      enableAdaptiveSharpening: true,
    );
  }

  /// Preset super-risoluzione / dettaglio (filtri FFmpeg)
  static VideoFilters getSuperResolution() {
    return VideoFilters(
      superResolutionMethod: 'nnedi3',
      advancedDenoiseMethod: 'fftdnoiz',
      detailEnhanceStrength: 0.6,
      enableEdgeSharpening: true,
      enableDetailEnhancement: true,
      enableAdaptiveSharpening: true,
      unsharpMask: 0.2,
      sharpness: 1.15,
      contrast: 1.08,
      saturation: 1.05,
      brightness: 0.02,
      textureBoost: 0.3,
      enableArtifactRemoval: true,
      compressionCleanup: 0.6,
      enableGpuAcceleration: true,
      gpuEncodingPreset: 'medium',
    );
  }

  /// Preset per video di bassa qualità (massima ottimizzazione).
  static VideoFilters getLowQualityOptimization() {
    return VideoFilters(
      enableGpuAcceleration: true,
      advancedDenoiseMethod: 'nlmeans',
      denoiseStrength: 0.8,
      temporalDenoise: 0.6,
      noiseReductionMethod: 'strong',
      detailEnhanceStrength: 0.9,
      enableDetailEnhancement: true,
      enableEdgeSharpening: true,
      enableAdaptiveSharpening: true,
      textureBoost: 0.5,
      unsharpMask: 0.3,
      sharpness: 1.2,
      enableArtifactRemoval: true,
      compressionCleanup: 1.0,
      advancedDebandingMethod: 'gradfun',
      superResolutionMethod: 'nnedi3',
      contrast: 1.12,
      saturation: 1.08,
      brightness: 0.05,
      gamma: 1.05,
      enableHdrToneMapping: true,
      gpuEncodingPreset: 'high_quality',
    );
  }

  /// Preset per restauro di film e video vecchi
  static VideoFilters getFilmRestoration() {
    return VideoFilters(
      enableDeinterlace: true,
      advancedDenoiseMethod: 'vaguedenoiser',
      filmGrain: 0.02,
      colorBalanceR: 0.02,
      colorBalanceG: 0.0,
      colorBalanceB: -0.02,
      curvesPreset: 'cinematic',
      enableHdrToneMapping: true,
      enableDetailEnhancement: true,
      detailEnhanceStrength: 0.3,
      enableGpuAcceleration: true,
    );
  }

  /// Preset per miglioramento video in condizioni di scarsa illuminazione
  static VideoFilters getLowLightEnhancement() {
    return VideoFilters(
      advancedDenoiseMethod: 'hqdn3d',
      brightness: 0.15,
      contrast: 1.08,
      saturation: 1.03,
      gamma: 1.08,
      enableDetailEnhancement: true,
      unsharpMask: 0.15,
      enableHdrToneMapping: true,
      curvesPreset: 'vivid',
      enableGpuAcceleration: true,
    );
  }

  /// Preset per color grading professionale
  static VideoFilters getColorGradingPro() {
    return VideoFilters(
      colorBalanceR: 0.03,
      colorBalanceG: -0.01,
      colorBalanceB: -0.005,
      curvesPreset: 'vivid',
      saturationAdvanced: 1.08,
      value: 1.03,
      enableHdrToneMapping: true,
      enableDetailEnhancement: true,
      detailEnhanceStrength: 0.2,
      enableGpuAcceleration: true,
    );
  }

  /// Preset per rimozione artefatti da compressione
  static VideoFilters getCompressionArtifactRemoval() {
    return VideoFilters(
      advancedDenoiseMethod: 'nlmeans',
      enableDetailEnhancement: true,
      detailEnhanceStrength: 0.3,
      enableEdgeSharpening: true,
      unsharpMask: 0.08,
      sharpness: 1.03,
      noiseReductionMethod: 'medium',
      enableGpuAcceleration: true,
    );
  }

  /// Preset per restauro video vintage/vecchi
  static VideoFilters getVintageRestoration() {
    return VideoFilters(
      enableDeinterlace: true,
      advancedDenoiseMethod: 'vaguedenoiser',
      colorBalanceR: 0.04,
      colorBalanceG: 0.02,
      colorBalanceB: -0.03,
      hue: 3.0,
      saturationAdvanced: 0.8,
      filmGrain: 0.015,
      curvesPreset: 'cinematic',
      enableGpuAcceleration: true,
    );
  }

  /// Preset per GPU NVIDIA
  static VideoFilters getNvidiaOptimized() {
    return VideoFilters(
      enableGpuAcceleration: true,
      gpuVendor: 'nvidia',
      gpuEncodingPreset: 'medium',
      enableGpuFilters: true,
      superResolutionMethod: 'nnedi3',
      advancedDenoiseMethod: 'nlmeans',
      enableDetailEnhancement: true,
      enableEdgeSharpening: true,
    );
  }

  /// Preset per GPU AMD
  static VideoFilters getAmdOptimized() {
    return VideoFilters(
      enableGpuAcceleration: true,
      gpuVendor: 'amd',
      gpuEncodingPreset: 'fast',
      enableGpuFilters: true,
      superResolutionMethod: 'super2xsai',
      advancedDenoiseMethod: 'fftdnoiz',
    );
  }

  /// Preset per GPU Intel
  static VideoFilters getIntelOptimized() {
    return VideoFilters(
      enableGpuAcceleration: true,
      gpuVendor: 'intel',
      gpuEncodingPreset: 'medium',
      enableGpuFilters: true,
      advancedDenoiseMethod: 'hqdn3d',
      enableDetailEnhancement: true,
    );
  }

  /// Preset ultra-safe per massima compatibilità (nessun filtro avanzato)
  static VideoFilters getUltraSafe() {
    return VideoFilters(
      enableGpuAcceleration: false,
      advancedDenoiseMethod: 'none',
      superResolutionMethod: 'none',
      noiseReductionMethod: 'light',
      enableDetailEnhancement: false,
      enableEdgeSharpening: false,
      sharpness: 1.0,
      contrast: 1.0,
      brightness: 0.0,
      saturation: 1.0,
      gamma: 1.0,
    );
  }

  /// Preset per miglioramenti base sicuri e veloci
  static VideoFilters getBasicEnhancement() {
    return VideoFilters(
      enableGpuAcceleration: false,
      advancedDenoiseMethod: 'none',
      superResolutionMethod: 'none',
      noiseReductionMethod: 'light',
      enableDetailEnhancement: true,
      enableEdgeSharpening: false,
      sharpness: 1.1,
      contrast: 1.1,
      brightness: 0.05,
      saturation: 1.05,
      gamma: 1.0,
      colorProfile: 'vivid',
    );
  }

  /// Preset per video animazione/cartoni animati
  static VideoFilters getAnimationOptimized() {
    return VideoFilters(
      enableGpuAcceleration: true,
      advancedDenoiseMethod: 'hqdn3d',
      superResolutionMethod: 'super2xsai',
      noiseReductionMethod: 'light',
      enableDetailEnhancement: true,
      enableEdgeSharpening: true,
      sharpness: 1.15,
      contrast: 1.1,
      saturation: 1.2,
      colorProfile: 'vivid',
      unsharpMask: 0.1,
    );
  }

  /// Preset per video documentari/natura
  static VideoFilters getDocumentaryOptimized() {
    return VideoFilters(
      enableGpuAcceleration: true,
      advancedDenoiseMethod: 'nlmeans',
      noiseReductionMethod: 'medium',
      enableDetailEnhancement: true,
      enableEdgeSharpening: false,
      sharpness: 1.08,
      contrast: 1.12,
      saturation: 1.1,
      colorProfile: 'cinematic',
      curvesPreset: 'contrast',
      enableHdrToneMapping: true,
    );
  }

  /// Preset per video sportivi/azione
  static VideoFilters getSportsOptimized() {
    return VideoFilters(
      enableGpuAcceleration: true,
      advancedDenoiseMethod: 'hqdn3d',
      noiseReductionMethod: 'light',
      enableDetailEnhancement: true,
      enableEdgeSharpening: true,
      sharpness: 1.2,
      contrast: 1.15,
      saturation: 1.05,
      enableStabilization: true,
      unsharpMask: 0.25,
    );
  }

  /// Preset per video musicali/clip
  static VideoFilters getMusicVideoOptimized() {
    return VideoFilters(
      enableGpuAcceleration: true,
      advancedDenoiseMethod: 'fftdnoiz',
      noiseReductionMethod: 'medium',
      enableDetailEnhancement: true,
      enableEdgeSharpening: true,
      sharpness: 1.1,
      contrast: 1.2,
      saturation: 1.3,
      colorProfile: 'vivid',
      curvesPreset: 'vivid',
      filmGrain: 0.01,
    );
  }

  /// Preset per video conferenze/streaming
  static VideoFilters getStreamingOptimized() {
    return VideoFilters(
      enableGpuAcceleration: true,
      advancedDenoiseMethod: 'hqdn3d',
      noiseReductionMethod: 'medium',
      enableDetailEnhancement: true,
      enableEdgeSharpening: false,
      sharpness: 1.05,
      contrast: 1.08,
      brightness: 0.1,
      saturation: 1.05,
      enableStabilization: true,
    );
  }

  /// Preset per video notturni/low-light
  static VideoFilters getNightVisionOptimized() {
    return VideoFilters(
      enableGpuAcceleration: true,
      advancedDenoiseMethod: 'nlmeans',
      noiseReductionMethod: 'strong',
      enableDetailEnhancement: true,
      enableEdgeSharpening: true,
      brightness: 0.25,
      contrast: 1.2,
      gamma: 1.3,
      saturation: 0.9,
      enableHdrToneMapping: true,
      unsharpMask: 0.15,
    );
  }

  /// Preset per video sott'acqua
  static VideoFilters getUnderwaterOptimized() {
    return VideoFilters(
      enableGpuAcceleration: true,
      advancedDenoiseMethod: 'vaguedenoiser',
      noiseReductionMethod: 'medium',
      enableDetailEnhancement: true,
      enableEdgeSharpening: true,
      colorBalanceR: -0.1,
      colorBalanceG: 0.05,
      colorBalanceB: 0.15,
      saturation: 1.3,
      contrast: 1.1,
      sharpness: 1.15,
    );
  }

  /// Preset per video drone/aerei
  static VideoFilters getDroneOptimized() {
    return VideoFilters(
      enableGpuAcceleration: true,
      advancedDenoiseMethod: 'hqdn3d',
      noiseReductionMethod: 'light',
      enableDetailEnhancement: true,
      enableEdgeSharpening: true,
      enableStabilization: true,
      sharpness: 1.25,
      contrast: 1.15,
      saturation: 1.2,
      enableHdrToneMapping: true,
      unsharpMask: 0.2,
    );
  }

  /// Preset per video macro/dettagli
  static VideoFilters getMacroOptimized() {
    return VideoFilters(
      enableGpuAcceleration: true,
      advancedDenoiseMethod: 'nlmeans',
      noiseReductionMethod: 'medium',
      enableDetailEnhancement: true,
      enableEdgeSharpening: true,
      sharpness: 1.3,
      contrast: 1.1,
      saturation: 1.1,
      detailEnhanceStrength: 0.5,
      unsharpMask: 0.3,
    );
  }

  /// Preset per video time-lapse
  static VideoFilters getTimelapseOptimized() {
    return VideoFilters(
      enableGpuAcceleration: true,
      advancedDenoiseMethod: 'fftdnoiz',
      noiseReductionMethod: 'light',
      enableDetailEnhancement: true,
      enableEdgeSharpening: false,
      sharpness: 1.15,
      contrast: 1.2,
      saturation: 1.1,
      enableHdrToneMapping: true,
      colorProfile: 'cinematic',
    );
  }

  /// Preset per video bianco e nero artistico
  static VideoFilters getBlackWhiteArtistic() {
    return VideoFilters(
      enableGpuAcceleration: true,
      advancedDenoiseMethod: 'nlmeans',
      noiseReductionMethod: 'medium',
      enableDetailEnhancement: true,
      enableEdgeSharpening: true,
      colorProfile: 'bw',
      contrast: 1.3,
      brightness: 0.05,
      sharpness: 1.2,
      filmGrain: 0.02,
      curvesPreset: 'contrast',
    );
  }

  /// Preset per video HDR estremo
  static VideoFilters getHdrExtreme() {
    return VideoFilters(
      enableGpuAcceleration: true,
      advancedDenoiseMethod: 'hqdn3d',
      noiseReductionMethod: 'light',
      enableDetailEnhancement: true,
      enableEdgeSharpening: true,
      enableHdrToneMapping: true,
      contrast: 1.25,
      saturation: 1.4,
      brightness: 0.1,
      sharpness: 1.15,
      colorProfile: 'vivid',
      curvesPreset: 'vivid',
    );
  }

  /// Preset per video retro/vintage anni '80
  static VideoFilters getRetro80s() {
    return VideoFilters(
      enableGpuAcceleration: true,
      advancedDenoiseMethod: 'vaguedenoiser',
      noiseReductionMethod: 'light',
      enableDetailEnhancement: false,
      enableEdgeSharpening: false,
      colorBalanceR: 0.15,
      colorBalanceG: 0.05,
      colorBalanceB: -0.1,
      saturation: 1.4,
      contrast: 1.1,
      hue: 10.0,
      filmGrain: 0.03,
      colorProfile: 'vivid',
    );
  }

  /// Preset per video cinema professionale
  static VideoFilters getCinemaProfessional() {
    return VideoFilters(
      enableGpuAcceleration: true,
      advancedDenoiseMethod: 'nlmeans',
      noiseReductionMethod: 'medium',
      enableDetailEnhancement: true,
      enableEdgeSharpening: true,
      colorProfile: 'cinematic',
      curvesPreset: 'cinematic',
      contrast: 1.15,
      saturation: 0.95,
      brightness: -0.03,
      sharpness: 1.08,
      filmGrain: 0.01,
      enableHdrToneMapping: true,
      detailEnhanceStrength: 0.4,
    );
  }

  /// Preset per video social media
  static VideoFilters getSocialMediaOptimized() {
    return VideoFilters(
      enableGpuAcceleration: true,
      advancedDenoiseMethod: 'hqdn3d',
      noiseReductionMethod: 'light',
      enableDetailEnhancement: true,
      enableEdgeSharpening: true,
      sharpness: 1.25,
      contrast: 1.2,
      saturation: 1.3,
      brightness: 0.08,
      colorProfile: 'vivid',
      unsharpMask: 0.15,
      enableStabilization: true,
    );
  }

  /// Preset per qualità ultra (video a bassa qualità in ingresso).
  static VideoFilters getUltraQualityPreset() {
    return VideoFilters(
      enableGpuAcceleration: true,
      superResolutionMethod: 'nnedi3',
      advancedDenoiseMethod: 'nlmeans',
      detailEnhanceStrength: 0.7,
      enableEdgeSharpening: true,
      sharpness: 1.2,
      contrast: 1.12,
      saturation: 1.08,
      brightness: 0.05,
      colorProfile: 'cinematic',
      enableHdrToneMapping: true,
      filmGrain: 0.01,
      temporalDenoise: 0.4,
      enableAdaptiveSharpening: true,
      textureBoost: 0.3,
      enableArtifactRemoval: true,
      compressionCleanup: 0.8,
      advancedDebandingMethod: 'gradfun',
      enableDetailEnhancement: true,
      unsharpMask: 0.2,
      gpuEncodingPreset: 'high_quality',
    );
  }

  /// Preset per pulizia avanzata e riduzione rumore.
  static VideoFilters getAICleanupPreset() {
    return VideoFilters(
      enableGpuAcceleration: true,
      advancedDenoiseMethod: 'fftdnoiz',
      temporalDenoise: 0.6,
      detailEnhanceStrength: 0.8,
      enableEdgeSharpening: true,
      sharpness: 1.15,
      contrast: 1.12,
      saturation: 1.05,
      brightness: 0.03,
      enableHdrToneMapping: true,
      colorBalanceR: 0.01,
      colorBalanceG: 0.0,
      colorBalanceB: -0.01,
      enableArtifactRemoval: true,
      compressionCleanup: 0.9,
      textureBoost: 0.4,
      advancedDebandingMethod: 'gradfun',
      enableDetailEnhancement: true,
      unsharpMask: 0.25,
      enableAdaptiveSharpening: true,
    );
  }

  /// Preset per rimozione artefatti da compressione pesante.
  static VideoFilters getHeavyCompressionCleanup() {
    return VideoFilters(
      enableGpuAcceleration: true,
      advancedDenoiseMethod: 'nlmeans',
      temporalDenoise: 0.5,
      detailEnhanceStrength: 0.6,
      enableEdgeSharpening: true,
      sharpness: 1.1,
      contrast: 1.08,
      saturation: 1.03,
      brightness: 0.02,
      enableArtifactRemoval: true,
      compressionCleanup: 1.0,
      advancedDebandingMethod: 'gradfun',
      enableDetailEnhancement: true,
      unsharpMask: 0.15,
      enableAdaptiveSharpening: true,
      textureBoost: 0.25,
      noiseReductionMethod: 'medium',
    );
  }

  /// Preset per recupero dettagli e texture.
  static VideoFilters getDetailRecoveryPreset() {
    return VideoFilters(
      enableGpuAcceleration: true,
      detailEnhanceStrength: 0.9,
      textureBoost: 0.7,
      enableEdgeSharpening: true,
      enableAdaptiveSharpening: true,
      sharpness: 1.25,
      contrast: 1.12,
      saturation: 1.05,
      brightness: 0.03,
      enableDetailEnhancement: true,
      unsharpMask: 0.3,
      advancedDenoiseMethod: 'hqdn3d',
      noiseReductionMethod: 'light',
      enableArtifactRemoval: true,
      compressionCleanup: 0.5,
    );
  }

  /// Preset per video security/sorveglianza
  static VideoFilters getSecurityEnhancement() {
    return VideoFilters(
      enableGpuAcceleration: true,
      advancedDenoiseMethod: 'nlmeans',
      temporalDenoise: 0.6,
      detailEnhanceStrength: 0.9,
      enableEdgeSharpening: true,
      sharpness: 1.3,
      contrast: 1.2,
      brightness: 0.15,
      enableDetailEnhancement: true,
      enableStabilization: true,
      enableArtifactRemoval: true,
      compressionCleanup: 0.7,
    );
  }
}