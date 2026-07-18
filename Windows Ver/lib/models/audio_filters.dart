class AudioFilters {
  double volume; // 0.0 - 2.0
  double bass; // -20.0 - 20.0 (deprecated, use eqBands)
  double treble; // -20.0 - 20.0 (deprecated, use eqBands)
  // Equalizzatore multi-banda: 10 bande (31Hz, 62Hz, 125Hz, 250Hz, 500Hz, 1kHz, 2kHz, 4kHz, 8kHz, 16kHz)
  List<double> eqBands; // -20.0 - 20.0 per ogni banda
  bool normalize;
  bool removeNoise;
  double noiseThreshold; // 0.0 - 1.0
  String equalizerPreset; // none, flat, bass_boost, treble_boost, voice, rock, pop, jazz, classical
  double compression; // 0.0 - 1.0
  double reverb; // 0.0 - 1.0

  AudioFilters({
    this.volume = 1.0,
    this.bass = 0.0,
    this.treble = 0.0,
    List<double>? eqBands,
    this.normalize = false,
    this.removeNoise = false,
    this.noiseThreshold = 0.1,
    this.equalizerPreset = 'none',
    this.compression = 0.0,
    this.reverb = 0.0,
  }) : eqBands = eqBands ?? List.filled(10, 0.0);

  AudioFilters copyWith({
    double? volume,
    double? bass,
    double? treble,
    List<double>? eqBands,
    bool? normalize,
    bool? removeNoise,
    double? noiseThreshold,
    String? equalizerPreset,
    double? compression,
    double? reverb,
  }) {
    return AudioFilters(
      volume: volume ?? this.volume,
      bass: bass ?? this.bass,
      treble: treble ?? this.treble,
      eqBands: eqBands ?? List.from(this.eqBands),
      normalize: normalize ?? this.normalize,
      removeNoise: removeNoise ?? this.removeNoise,
      noiseThreshold: noiseThreshold ?? this.noiseThreshold,
      equalizerPreset: equalizerPreset ?? this.equalizerPreset,
      compression: compression ?? this.compression,
      reverb: reverb ?? this.reverb,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'volume': volume,
      'bass': bass,
      'treble': treble,
      'eqBands': eqBands,
      'normalize': normalize,
      'removeNoise': removeNoise,
      'noiseThreshold': noiseThreshold,
      'equalizerPreset': equalizerPreset,
      'compression': compression,
      'reverb': reverb,
    };
  }

  static AudioFilters fromMap(Map<String, dynamic> map) {
    final eqBandsList = map['eqBands'];
    List<double> eqBands;
    if (eqBandsList != null && eqBandsList is List) {
      eqBands = eqBandsList.map((e) => (e is num ? e.toDouble() : 0.0)).toList();
      if (eqBands.length != 10) {
        eqBands = List.filled(10, 0.0);
      }
    } else {
      eqBands = List.filled(10, 0.0);
    }
    
    return AudioFilters(
      volume: map['volume'] ?? 1.0,
      bass: map['bass'] ?? 0.0,
      treble: map['treble'] ?? 0.0,
      eqBands: eqBands,
      normalize: map['normalize'] ?? false,
      removeNoise: map['removeNoise'] ?? false,
      noiseThreshold: map['noiseThreshold'] ?? 0.1,
      equalizerPreset: map['equalizerPreset'] ?? 'none',
      compression: map['compression'] ?? 0.0,
      reverb: map['reverb'] ?? 0.0,
    );
  }

  void reset() {
    volume = 1.0;
    bass = 0.0;
    treble = 0.0;
    eqBands = List.filled(10, 0.0);
    normalize = false;
    removeNoise = false;
    noiseThreshold = 0.1;
    equalizerPreset = 'none';
    compression = 0.0;
    reverb = 0.0;
  }
  
  /// Applica un preset all'equalizzatore
  void applyEqualizerPreset(String preset) {
    switch (preset) {
      case 'flat':
      case 'none':
        eqBands = List.filled(10, 0.0);
        break;
      case 'bass_boost':
        // Boost bassi (prime 3 bande: 31Hz, 62Hz, 125Hz)
        eqBands = [6.0, 5.0, 3.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
        break;
      case 'treble_boost':
        // Boost alti (ultime 3 bande: 4kHz, 8kHz, 16kHz)
        eqBands = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 4.0, 5.0, 6.0];
        break;
      case 'voice':
        // Boost frequenze vocali (250Hz - 2kHz)
        eqBands = [-2.0, -1.0, 2.0, 4.0, 3.0, 2.0, 1.0, -1.0, -2.0, -3.0];
        break;
      case 'rock':
        // Preset Rock: boost bassi e alti, taglio medi
        eqBands = [4.0, 3.0, 1.0, -1.0, -2.0, -1.0, 1.0, 3.0, 4.0, 3.0];
        break;
      case 'pop':
        // Preset Pop: boost medi e alti
        eqBands = [2.0, 1.0, 0.0, 1.0, 2.0, 3.0, 3.0, 2.0, 1.0, 0.0];
        break;
      case 'jazz':
        // Preset Jazz: boost medi, leggero boost bassi
        eqBands = [2.0, 1.0, 0.0, 1.0, 2.0, 2.0, 1.0, 0.0, -1.0, -1.0];
        break;
      case 'classical':
        // Preset Classical: boost leggero su tutte le frequenze
        eqBands = [1.0, 1.0, 0.0, 0.0, 1.0, 2.0, 2.0, 1.0, 1.0, 0.0];
        break;
      default:
        eqBands = List.filled(10, 0.0);
    }
  }

  bool get hasActiveFilters {
    final hasEqBands = eqBands.any((band) => band != 0.0);
    return volume != 1.0 ||
        bass != 0.0 ||
        treble != 0.0 ||
        hasEqBands ||
        normalize ||
        removeNoise ||
        compression > 0.0 ||
        reverb > 0.0 ||
        (equalizerPreset != 'none' && equalizerPreset != 'flat');
  }
}