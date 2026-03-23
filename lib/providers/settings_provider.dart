import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:video_converter_pro/models/video_filters.dart';
import 'package:video_converter_pro/models/audio_filters.dart';
import 'package:video_converter_pro/models/image_filters.dart';
import 'package:video_converter_pro/l10n/app_localizations.dart';
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
    notifyListeners();
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
      return '${_videoBitrate} kbps';
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