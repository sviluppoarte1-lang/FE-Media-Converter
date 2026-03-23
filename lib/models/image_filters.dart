class ImageFilters {
  double denoiseStrength; // 0-1.0
  double sharpness; // 0-2.0
  double brightness; // -1.0 to 1.0
  double contrast; // -2.0 to 2.0
  double saturation; // 0-3.0
  double gamma; // 0.1-10.0
  String colorProfile; // none, vivid, cinematic, bw, sepia
  bool enableUpscaling; // Abilita upscaling
  double upscaleFactor; // Fattore di upscaling (1.0 = originale, 2.0 = 2x, etc.)
  bool useCustomResolution; // Usa risoluzione personalizzata invece del fattore
  int customWidth; // Larghezza personalizzata (0 = mantiene aspect ratio)
  int customHeight; // Altezza personalizzata (0 = mantiene aspect ratio)

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
    );
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
        (useCustomResolution && (customWidth > 0 || customHeight > 0));
  }
}