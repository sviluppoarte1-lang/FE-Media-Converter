class ImageFilters {
  double denoiseStrength;
  double sharpness;
  double brightness;
  double contrast;
  double saturation;
  double gamma;
  String colorProfile;
  bool enableUpscaling;
  double upscaleFactor;
  bool useCustomResolution;
  int customWidth;
  int customHeight;

  bool enableDRUNet;
  String drunetMode;
  int drunetNoiseLevel;
  double drunetUpscaleFactor;
  double drunetDeblurStrength;

  ImageFilters({
    this.denoiseStrength = 0.0,
    this.sharpness = 1.0,
    this.brightness = 0.0,
    this.contrast = 1.0,
    this.saturation = 1.0,
    this.gamma = 1.0,
    this.colorProfile = 'none',
    this.enableUpscaling = false,
    this.upscaleFactor = 2.0,
    this.useCustomResolution = false,
    this.customWidth = 0,
    this.customHeight = 0,
    this.enableDRUNet = false,
    this.drunetMode = 'denoise',
    this.drunetNoiseLevel = 7,
    this.drunetUpscaleFactor = 2.0,
    this.drunetDeblurStrength = 0.5,
  });

  ImageFilters copyWith({
    double? denoiseStrength,
    double? sharpness,
    double? brightness,
    double? contrast,
    double? saturation,
    double? gamma,
    String? colorProfile,
    bool? enableUpscaling,
    double? upscaleFactor,
    bool? useCustomResolution,
    int? customWidth,
    int? customHeight,
    bool? enableDRUNet,
    String? drunetMode,
    int? drunetNoiseLevel,
    double? drunetUpscaleFactor,
    double? drunetDeblurStrength,
  }) {
    return ImageFilters(
      denoiseStrength: denoiseStrength ?? this.denoiseStrength,
      sharpness: sharpness ?? this.sharpness,
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      saturation: saturation ?? this.saturation,
      gamma: gamma ?? this.gamma,
      colorProfile: colorProfile ?? this.colorProfile,
      enableUpscaling: enableUpscaling ?? this.enableUpscaling,
      upscaleFactor: upscaleFactor ?? this.upscaleFactor,
      useCustomResolution: useCustomResolution ?? this.useCustomResolution,
      customWidth: customWidth ?? this.customWidth,
      customHeight: customHeight ?? this.customHeight,
      enableDRUNet: enableDRUNet ?? this.enableDRUNet,
      drunetMode: drunetMode ?? this.drunetMode,
      drunetNoiseLevel: drunetNoiseLevel ?? this.drunetNoiseLevel,
      drunetUpscaleFactor: drunetUpscaleFactor ?? this.drunetUpscaleFactor,
      drunetDeblurStrength: drunetDeblurStrength ?? this.drunetDeblurStrength,
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
      'colorProfile': colorProfile,
      'enableUpscaling': enableUpscaling,
      'upscaleFactor': upscaleFactor,
      'useCustomResolution': useCustomResolution,
      'customWidth': customWidth,
      'customHeight': customHeight,
      'enableDRUNet': enableDRUNet,
      'drunetMode': drunetMode,
      'drunetNoiseLevel': drunetNoiseLevel,
      'drunetUpscaleFactor': drunetUpscaleFactor,
      'drunetDeblurStrength': drunetDeblurStrength,
    };
  }

  static ImageFilters fromMap(Map<String, dynamic> map) {
    return ImageFilters(
      denoiseStrength: map['denoiseStrength'] ?? 0.0,
      sharpness: map['sharpness'] ?? 1.0,
      brightness: map['brightness'] ?? 0.0,
      contrast: map['contrast'] ?? 1.0,
      saturation: map['saturation'] ?? 1.0,
      gamma: map['gamma'] ?? 1.0,
      colorProfile: map['colorProfile'] ?? 'none',
      enableUpscaling: map['enableUpscaling'] ?? false,
      upscaleFactor: map['upscaleFactor'] ?? 2.0,
      useCustomResolution: map['useCustomResolution'] ?? false,
      customWidth: map['customWidth'] ?? 0,
      customHeight: map['customHeight'] ?? 0,
      enableDRUNet: map['enableDRUNet'] ?? false,
      drunetMode: map['drunetMode'] as String? ?? 'denoise',
      drunetNoiseLevel: map['drunetNoiseLevel'] is int
          ? map['drunetNoiseLevel'] as int
          : (map['drunetNoiseLevel'] as num?)?.toInt() ?? 7,
      drunetUpscaleFactor: _mapDouble(map['drunetUpscaleFactor'], 2.0),
      drunetDeblurStrength: _mapDouble(map['drunetDeblurStrength'], 0.5),
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
    denoiseStrength = 0.0;
    sharpness = 1.0;
    brightness = 0.0;
    contrast = 1.0;
    saturation = 1.0;
    gamma = 1.0;
    colorProfile = 'none';
    enableUpscaling = false;
    upscaleFactor = 2.0;
    useCustomResolution = false;
    customWidth = 0;
    customHeight = 0;
    enableDRUNet = false;
    drunetMode = 'denoise';
    drunetNoiseLevel = 7;
    drunetUpscaleFactor = 2.0;
    drunetDeblurStrength = 0.5;
  }

  bool get hasActiveFilters {
    return denoiseStrength > 0.0 ||
        sharpness != 1.0 ||
        brightness != 0.0 ||
        contrast != 1.0 ||
        saturation != 1.0 ||
        gamma != 1.0 ||
        colorProfile != 'none' ||
        enableUpscaling ||
        (useCustomResolution && (customWidth > 0 || customHeight > 0)) ||
        enableDRUNet;
  }
}
