import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:video_converter_pro/models/video_filters.dart';
import 'package:video_converter_pro/models/audio_filters.dart';
import 'package:video_converter_pro/models/image_filters.dart';
import 'package:video_converter_pro/l10n/app_localizations.dart';
import 'package:video_converter_pro/services/benchmark_service.dart';
import 'package:video_converter_pro/utils/app_log.dart';

class SettingsProvider with ChangeNotifier {
  final SharedPreferences prefs;
  
  SettingsProvider(this.prefs) {
    _loadSettings();
  }

  // Chiavi per SharedPreferences
  static const String _outputFolderKey = 'output_folder';
  static const String _themeModeKey = 'theme_mode';
  static const String _videoQualityKey = 'video_quality';
  static const String _audioQualityKey = 'audio_quality';
  static const String _defaultVideoFormatKey = 'default_video_format';
  static const String _defaultAudioFormatKey = 'default_audio_format';
  static const String _defaultImageFormatKey = 'default_image_format';
  static const String _audioBitrateKey = 'audio_bitrate';
  static const String _cpuThreadsKey = 'cpu_threads';
  static const String _concurrentConversionsKey = 'concurrent_conversions';
  static const String _useGpuKey = 'use_gpu';
  static const String _gpuTypeKey = 'gpu_type';
  static const String _languageKey = 'app_language';
  static const String _defaultAudioCodecKey = 'default_audio_codec';
  
  // NUOVE CHIAVI
  static const String _defaultVideoCodecKey = 'default_video_codec';
  static const String _videoBitrateKey = 'video_bitrate';
  static const String _videoBitrateModeKey = 'video_bitrate_mode';
  static const String _extractAudioFromVideoKey = 'extract_audio_from_video';
  static const String _videoFiltersKey = 'video_filters';
  static const String _audioFiltersKey = 'audio_filters';
  static const String _imageFiltersKey = 'image_filters';
  static const String _modelsDirectoryKey = 'models_directory';
  static const String _autoBenchmarkPresetKey = 'auto_benchmark_preset';
  static const String _benchmarkHistoryKey = 'benchmark_history';
  static const String _benchmarkSignatureKey = 'benchmark_signature';

  String _outputFolder = '';
  String _modelsDirectory = ''; // Directory per i modelli (VRT, DRUNet, ecc.)
  String _defaultVideoFormat = 'mp4';
  String _defaultAudioFormat = 'mp3';
  String _defaultImageFormat = 'jpg';
  String _defaultAudioCodec = 'aac';
  String _defaultVideoCodec = 'libx264'; // NUOVO
  int _audioBitrate = 192;
  int _videoBitrate = 4000; // NUOVO: bitrate in kbps
  String _videoBitrateMode = 'crf'; // NUOVO: 'crf' o 'bitrate'
  ThemeMode _themeMode = ThemeMode.system;
  int _videoQuality = 23;
  int _audioQuality = 128;
  int _cpuThreads = 0;
  int _concurrentConversions = 1;
  bool _useGpu = false;
  String _gpuType = 'auto';
  String _language = 'en';
  bool _extractAudioFromVideo = false;
  String _autoBenchmarkPreset = 'medium';
  bool _isBenchmarkRunning = false;
  double _benchmarkProgress = 0.0;
  String _benchmarkPhase = '';
  String _lastBenchmarkSignature = '';
  List<Map<String, dynamic>> _benchmarkHistory = <Map<String, dynamic>>[];

  // Getters
  String get outputFolder => _outputFolder;
  ThemeMode get themeMode => _themeMode;
  String get defaultVideoFormat => _defaultVideoFormat;
  String get defaultAudioFormat => _defaultAudioFormat;
  String get defaultImageFormat => _defaultImageFormat;
  String get defaultAudioCodec => _defaultAudioCodec;
  String get defaultVideoCodec => _defaultVideoCodec; // NUOVO
  int get audioBitrate => _audioBitrate;
  int get videoBitrate => _videoBitrate; // NUOVO
  String get videoBitrateMode => _videoBitrateMode; // NUOVO
  int get videoQuality => _videoQuality;
  int get audioQuality => _audioQuality;
  int get cpuThreads => _cpuThreads;
  int get concurrentConversions => _concurrentConversions;
  bool get useGpu => _useGpu;
  String get gpuType => _gpuType;
  String get language => _language;
  bool get extractAudioFromVideo => _extractAudioFromVideo;
  String get modelsDirectory => _modelsDirectory;
  String get autoBenchmarkPreset => _autoBenchmarkPreset;
  bool get isBenchmarkRunning => _isBenchmarkRunning;
  double get benchmarkProgress => _benchmarkProgress;
  String get benchmarkPhase => _benchmarkPhase;
  List<Map<String, dynamic>> get benchmarkHistory =>
      List<Map<String, dynamic>>.unmodifiable(_benchmarkHistory);

  String get currentLanguageName {
    return getLanguageName(_language);
  }
  
  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'it':
        return 'Italiano';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'es':
        return 'Español';
      case 'pt':
        return 'Português';
      case 'en':
      default:
        return 'English';
    }
  }

  void _loadSettings() {
    _outputFolder = prefs.getString(_outputFolderKey) ?? '';
    _defaultVideoFormat = prefs.getString(_defaultVideoFormatKey) ?? 'mp4';
    _defaultAudioFormat = prefs.getString(_defaultAudioFormatKey) ?? 'mp3';
    _defaultImageFormat = prefs.getString(_defaultImageFormatKey) ?? 'jpg';
    _defaultAudioCodec = prefs.getString(_defaultAudioCodecKey) ?? 'aac';
    _defaultVideoCodec = prefs.getString(_defaultVideoCodecKey) ?? 'libx264'; // NUOVO
    _audioBitrate = prefs.getInt(_audioBitrateKey) ?? 192;
    _videoBitrate = prefs.getInt(_videoBitrateKey) ?? 4000; // NUOVO
    _videoBitrateMode = prefs.getString(_videoBitrateModeKey) ?? 'crf'; // NUOVO
    _themeMode = ThemeMode.values[prefs.getInt(_themeModeKey) ?? ThemeMode.system.index];
    _videoQuality = prefs.getInt(_videoQualityKey) ?? 23;
    _audioQuality = prefs.getInt(_audioQualityKey) ?? 128;
    _cpuThreads = prefs.getInt(_cpuThreadsKey) ?? 0;
    _concurrentConversions = prefs.getInt(_concurrentConversionsKey) ?? 1;
    _useGpu = prefs.getBool(_useGpuKey) ?? false;
    _gpuType = prefs.getString(_gpuTypeKey) ?? 'auto';
    _language = prefs.getString(_languageKey) ?? 'en';
    _extractAudioFromVideo = prefs.getBool(_extractAudioFromVideoKey) ?? false;
    _modelsDirectory = prefs.getString(_modelsDirectoryKey) ?? '';
    _autoBenchmarkPreset = prefs.getString(_autoBenchmarkPresetKey) ?? 'medium';
    _lastBenchmarkSignature = prefs.getString(_benchmarkSignatureKey) ?? '';
    final historyRaw = prefs.getString(_benchmarkHistoryKey);
    if (historyRaw != null && historyRaw.isNotEmpty) {
      try {
        final decoded = json.decode(historyRaw);
        if (decoded is List) {
          _benchmarkHistory = decoded
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      } catch (e) {
        appLog('⚠️ Failed to parse benchmark history: $e');
      }
    }
    notifyListeners();
    _maybeAutoRerunBenchmark();
  }

  // Metodi esistenti...
  Future<void> setOutputFolder(String folder) async {
    _outputFolder = folder;
    await prefs.setString(_outputFolderKey, folder);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await prefs.setInt(_themeModeKey, mode.index);
    notifyListeners();
  }

  Future<void> setVideoQuality(int quality) async {
    _videoQuality = quality;
    await prefs.setInt(_videoQualityKey, quality);
    notifyListeners();
  }

  Future<void> setAudioQuality(int quality) async {
    _audioQuality = quality;
    await prefs.setInt(_audioQualityKey, quality);
    notifyListeners();
  }

  Future<void> setDefaultVideoFormat(String format) async {
    _defaultVideoFormat = format;
    await prefs.setString(_defaultVideoFormatKey, format);
    notifyListeners();
  }

  Future<void> setDefaultAudioFormat(String format) async {
    _defaultAudioFormat = format;
    await prefs.setString(_defaultAudioFormatKey, format);
    notifyListeners();
  }

  Future<void> setDefaultImageFormat(String format) async {
    _defaultImageFormat = format;
    await prefs.setString(_defaultImageFormatKey, format);
    notifyListeners();
  }

  Future<void> setDefaultAudioCodec(String codec) async {
    _defaultAudioCodec = codec;
    await prefs.setString(_defaultAudioCodecKey, codec);
    notifyListeners();
  }

  // NUOVI METODI PER CODEC VIDEO E BITRATE
  Future<void> setDefaultVideoCodec(String codec) async {
    _defaultVideoCodec = codec;
    await prefs.setString(_defaultVideoCodecKey, codec);
    notifyListeners();
  }

  Future<void> setVideoBitrate(int bitrate) async {
    _videoBitrate = bitrate;
    await prefs.setInt(_videoBitrateKey, bitrate);
    notifyListeners();
  }

  Future<void> setVideoBitrateMode(String mode) async {
    _videoBitrateMode = mode;
    await prefs.setString(_videoBitrateModeKey, mode);
    notifyListeners();
  }

  Future<void> setAudioBitrate(int bitrate) async {
    _audioBitrate = bitrate;
    await prefs.setInt(_audioBitrateKey, bitrate);
    notifyListeners();
  }

  Future<void> setCpuThreads(int threads) async {
    _cpuThreads = threads;
    await prefs.setInt(_cpuThreadsKey, threads);
    notifyListeners();
  }

  Future<void> setConcurrentConversions(int count) async {
    _concurrentConversions = count;
    await prefs.setInt(_concurrentConversionsKey, count);
    notifyListeners();
  }

  Future<void> setUseGpu(bool useGpu) async {
    _useGpu = useGpu;
    await prefs.setBool(_useGpuKey, useGpu);
    notifyListeners();
  }

  Future<void> setExtractAudioFromVideo(bool extract) async {
    _extractAudioFromVideo = extract;
    await prefs.setBool(_extractAudioFromVideoKey, extract);
    notifyListeners();
  }
  
  Future<void> setModelsDirectory(String directory) async {
    _modelsDirectory = directory;
    await prefs.setString(_modelsDirectoryKey, directory);
    notifyListeners();
  }

  Future<void> setGpuType(String gpuType) async {
    _gpuType = gpuType;
    await prefs.setString(_gpuTypeKey, gpuType);
    notifyListeners();
  }

  Future<void> setAutoBenchmarkPreset(String preset) async {
    var effectivePreset = preset;
    final smoke = await BenchmarkService.validatePresetCompatibility(
      useGpu: _useGpu,
      gpuType: _gpuType,
      preferredCodec: _defaultVideoCodec,
      preset: effectivePreset,
    );
    if (smoke['success'] != true) {
      appLog('⚠️ Benchmark preset "$preset" not compatible, fallback to medium');
      effectivePreset = 'medium';
      final mediumSmoke = await BenchmarkService.validatePresetCompatibility(
        useGpu: _useGpu,
        gpuType: _gpuType,
        preferredCodec: _defaultVideoCodec,
        preset: effectivePreset,
      );
      if (mediumSmoke['success'] != true) {
        appLog('⚠️ Medium preset failed smoke-test, fallback to fast');
        effectivePreset = 'fast';
      }
    }

    _autoBenchmarkPreset = effectivePreset;
    await prefs.setString(_autoBenchmarkPresetKey, effectivePreset);
    final current = loadVideoFilters() ?? VideoFilters.maximumQualityDefaults();
    await saveVideoFilters(current.copyWith(gpuEncodingPreset: effectivePreset));
    notifyListeners();
  }

  Future<Map<String, dynamic>> runUniversalBenchmark() async {
    if (_isBenchmarkRunning) {
      return {
        'success': false,
        'error': 'Benchmark already running',
      };
    }
    _isBenchmarkRunning = true;
    _benchmarkProgress = 0.0;
    _benchmarkPhase = 'phase.starting';
    notifyListeners();
    try {
      final result = await BenchmarkService.runUniversalBenchmark(
        useGpu: _useGpu,
        gpuType: _gpuType,
        preferredCodec: _defaultVideoCodec,
        onProgress: (progress, phase) {
          _benchmarkProgress = progress.clamp(0.0, 1.0);
          _benchmarkPhase = phase;
          notifyListeners();
        },
      );
      if (result['success'] == true) {
        final bestPreset = (result['bestPreset'] as String?) ?? 'medium';
        await setAutoBenchmarkPreset(bestPreset);
        final signature = result['signature'] is Map
            ? Map<String, String>.from(result['signature'] as Map)
            : <String, String>{};
        _lastBenchmarkSignature = BenchmarkService.flattenSignature(signature);
        await prefs.setString(_benchmarkSignatureKey, _lastBenchmarkSignature);
        final historyEntry = <String, dynamic>{
          'timestamp': result['timestamp'] ?? DateTime.now().toIso8601String(),
          'bestPreset': bestPreset,
          'codec': result['codec'] ?? _defaultVideoCodec,
          'scoresFps': result['scoresFps'] ?? <String, double>{},
          'signature': signature,
        };
        _benchmarkHistory = <Map<String, dynamic>>[historyEntry, ..._benchmarkHistory];
        if (_benchmarkHistory.length > 20) {
          _benchmarkHistory = _benchmarkHistory.sublist(0, 20);
        }
        await prefs.setString(_benchmarkHistoryKey, json.encode(_benchmarkHistory));
        appLog('🏁 Benchmark complete: best preset = $bestPreset, codec=${result['codec']}');
      } else {
        appLog('⚠️ Benchmark failed: ${result['error']}');
      }
      return result;
    } finally {
      _isBenchmarkRunning = false;
      _benchmarkProgress = 1.0;
      _benchmarkPhase = '';
      notifyListeners();
    }
  }

  Future<void> _maybeAutoRerunBenchmark() async {
    if (_isBenchmarkRunning) return;
    if (_benchmarkHistory.isEmpty) return;
    try {
      final currentSigMap = await BenchmarkService.getSystemSignature(
        useGpu: _useGpu,
        gpuType: _gpuType,
        preferredCodec: _defaultVideoCodec,
      );
      final currentSignature = BenchmarkService.flattenSignature(currentSigMap);
      if (_lastBenchmarkSignature.isEmpty) {
        _lastBenchmarkSignature = currentSignature;
        await prefs.setString(_benchmarkSignatureKey, currentSignature);
        return;
      }
      if (currentSignature != _lastBenchmarkSignature) {
        appLog('🔁 Benchmark auto-rerun: ffmpeg/GPU signature changed');
        await runUniversalBenchmark();
      }
    } catch (e) {
      appLog('⚠️ Auto benchmark check failed: $e');
    }
  }

  Future<void> setLanguage(String language) async {
    _language = language;
    await prefs.setString(_languageKey, language);
    notifyListeners();
  }

  // Metodi helper per bitrate
  String getVideoBitrateLabel() {
    if (_videoBitrateMode == 'crf') {
      return 'CRF: $_videoQuality';
    } else {
      return '$_videoBitrate kbps';
    }
  }

  String getVideoQualityDescription(AppLocalizations l10n) {
    if (_videoBitrateMode == 'crf') {
      if (_videoQuality <= 18) return l10n.excellentQuality(_videoQuality);
      if (_videoQuality <= 23) return l10n.greatQuality(_videoQuality);
      if (_videoQuality <= 28) return l10n.goodQuality(_videoQuality);
      if (_videoQuality <= 35) return l10n.averageQuality(_videoQuality);
      return l10n.lowQualityLabel(_videoQuality);
    } else {
      if (_videoBitrate >= 8000) return l10n.excellentQuality(18);
      if (_videoBitrate >= 4000) return l10n.greatQuality(23);
      if (_videoBitrate >= 2000) return l10n.goodQuality(28);
      if (_videoBitrate >= 1000) return l10n.averageQuality(35);
      return l10n.lowQualityLabel(51);
    }
  }

  // Salvataggio e caricamento filtri
  Future<void> saveVideoFilters(VideoFilters filters) async {
    final filtersJson = json.encode(filters.toMap());
    await prefs.setString(_videoFiltersKey, filtersJson);
    notifyListeners();
  }

  VideoFilters? loadVideoFilters() {
    final filtersJson = prefs.getString(_videoFiltersKey);
    if (filtersJson != null) {
      try {
        final filtersMap = json.decode(filtersJson) as Map<String, dynamic>;
        return VideoFilters.fromMap(filtersMap);
      } catch (e) {
        appLog('Errore nel caricamento filtri video: $e');
        return null;
      }
    }
    return null;
  }

  Future<void> saveAudioFilters(AudioFilters filters) async {
    final filtersJson = json.encode(filters.toMap());
    await prefs.setString(_audioFiltersKey, filtersJson);
    notifyListeners();
  }

  AudioFilters? loadAudioFilters() {
    final filtersJson = prefs.getString(_audioFiltersKey);
    if (filtersJson != null) {
      try {
        final filtersMap = json.decode(filtersJson) as Map<String, dynamic>;
        return AudioFilters.fromMap(filtersMap);
      } catch (e) {
        appLog('Errore nel caricamento filtri audio: $e');
        return null;
      }
    }
    return null;
  }

  Future<void> saveImageFilters(ImageFilters filters) async {
    final filtersJson = json.encode(filters.toMap());
    await prefs.setString(_imageFiltersKey, filtersJson);
    notifyListeners();
  }

  ImageFilters? loadImageFilters() {
    final filtersJson = prefs.getString(_imageFiltersKey);
    if (filtersJson != null) {
      try {
        final filtersMap = json.decode(filtersJson) as Map<String, dynamic>;
        return ImageFilters.fromMap(filtersMap);
      } catch (e) {
        appLog('Errore nel caricamento filtri immagine: $e');
        return null;
      }
    }
    return null;
  }
}