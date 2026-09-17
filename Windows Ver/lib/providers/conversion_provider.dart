import 'dart:async';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:video_converter_pro/models/conversion_task.dart';
import 'package:video_converter_pro/services/ffmpeg_service.dart';
import 'package:video_converter_pro/models/conversion_status.dart';
import 'package:video_converter_pro/providers/settings_provider.dart';
import 'package:video_converter_pro/l10n/app_localizations.dart';
import 'package:video_converter_pro/utils/app_log.dart';

String _queueLabel(String key, [String? localeTag]) {
  final locale = (localeTag ?? Platform.localeName).toLowerCase();
  final lang = locale.split(RegExp(r'[_-]')).first;
  final l10n = lookupAppLocalizations(Locale(lang));
  switch (key) {
    case 'calculating':
      return l10n.calculating;
    case 'completed':
      return l10n.completed;
    case 'file_exists':
      return l10n.fileExistsStatus;
    case 'error':
      return l10n.error;
    case 'pending':
      return l10n.waiting;
    case 'stopped':
      return l10n.stoppedStatus;
    case 'remaining':
      return l10n.remainingLabel;
    case 'preparing':
      return l10n.preparing;
    default:
      return key;
  }
}

String _normalizeProgressMessage(String value, [String? localeTag]) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return value;
  if (trimmed.startsWith('phase.')) {
    final locale = (localeTag ?? Platform.localeName).toLowerCase();
    final lang = locale.split(RegExp(r'[_-]')).first;
    final l10n = lookupAppLocalizations(Locale(lang));
    switch (trimmed) {
      case 'phase.preparing':
        return l10n.preparing;
      case 'phase.analyzing':
        return l10n.analyzingVideo;
      case 'phase.checking_acceleration':
        return l10n.checkingAcceleration;
      case 'phase.drunet.checking':
        return l10n.drunetChecking;
      case 'phase.drunet.extract':
        return l10n.drunetExtractFrames;
      case 'phase.drunet.denoise':
        return l10n.drunetDenoisingFrames;
      case 'phase.drunet.installing':
        return l10n.drunetInstallingDeps;
      case 'phase.drunet.install_done':
        return l10n.drunetDepsInstalled;
      case 'phase.drunet.not_available':
        return '${l10n.drunetChecking} (${l10n.error})';
      case 'phase.drunet.remux':
        return l10n.drunetRebuildVideo;
      case 'phase.drunet.done':
        return l10n.drunetPrepassDone;
      case 'phase.encoding_start':
        return l10n.encodingStarting;
      default:
        if (trimmed.startsWith('phase.drunet_eta:')) {
          final eta = trimmed.substring('phase.drunet_eta:'.length).trim();
          return '${l10n.drunetDenoisingFrames} (${l10n.estimatedTimeLabel} ~ $eta)';
        }
        return l10n.preparing;
    }
  }
  final lower = trimmed.toLowerCase();
  if (lower.startsWith('remaining') ||
      lower.startsWith('restante') ||
      lower.startsWith('restant') ||
      lower.startsWith('verbleibend')) {
    final i = trimmed.indexOf('~');
    if (i >= 0) {
      final eta = trimmed.substring(i + 1).trim();
      return '${_queueLabel('remaining', localeTag)} ~ $eta';
    }
    return _queueLabel('remaining', localeTag);
  }
  if (lower.startsWith('preparing') ||
      lower.startsWith('preparazione') ||
      lower.startsWith('preparando') ||
      lower.startsWith('préparation') ||
      lower.startsWith('vorbereitung')) {
    return _queueLabel('preparing', localeTag);
  }
  return value;
}

bool _rawProgressMayShowFps(String raw) {
  final t = raw.trim();
  if (t.startsWith('phase.drunet.extract')) return true;
  if (t.startsWith('phase.drunet.denoise')) return true;
  if (t.startsWith('phase.drunet.remux')) return true;
  if (t.startsWith('phase.drunet_eta:')) return true;
  final lower = t.toLowerCase();
  if (!lower.contains('~')) return false;
  return lower.startsWith('remaining') ||
      lower.startsWith('restante') ||
      lower.startsWith('restant') ||
      lower.startsWith('verbleibend');
}

void _applyProcessingFps(ConversionTask task, String rawMsg, double? fps) {
  if (!_rawProgressMayShowFps(rawMsg)) {
    task.processingFps = null;
  } else if (fps != null && fps > 0) {
    task.processingFps = fps;
  }
}

class ConversionProvider with ChangeNotifier {
  final FFmpegService _ffmpegService = FFmpegService();
  final List<ConversionTask> _conversionQueue = [];
  bool _isConverting = false;
  final Map<String, Timer> _progressTimers = {};
  final Map<String, bool> _pausedTasks = {};
  final Map<String, Future<Map<String, dynamic>>> _activeConversions = {};
  
  // Riferimento al SettingsProvider (verrà impostato quando necessario)
  SettingsProvider? _settingsProvider;
  
  void setSettingsProvider(SettingsProvider provider) {
    _settingsProvider = provider;
  }

  List<ConversionTask> get conversionQueue => _conversionQueue;
  bool get isConverting => _isConverting;
  int get queueLength => _conversionQueue.length;
  
  int get completedCount {
    return _conversionQueue.where((task) => task.status == ConversionStatus.completed).length;
  }

  int get activeCount {
    return _conversionQueue.where((task) => task.status == ConversionStatus.processing).length;
  }

  void addToQueue(ConversionTask task) {
    _conversionQueue.add(task);
    notifyListeners();
    
    if (!_isConverting) {
      _processQueue();
    }
  }

  void removeFromQueue(String taskId) {
    _stopTask(taskId);
    _conversionQueue.removeWhere((task) => task.id == taskId);
    _pausedTasks.remove(taskId);
    notifyListeners();
  }

  void pauseTask(String taskId) {
    final taskIndex = _conversionQueue.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      final task = _conversionQueue[taskIndex];
      if (task.canPause) {
        task.pause();
        _pausedTasks[taskId] = true;
        _stopTask(taskId, pause: true);
        notifyListeners();
        
        appLog('Task ${task.fileName} messo in pausa');
      }
    }
  }

  void resumeTask(String taskId) {
    final taskIndex = _conversionQueue.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      final task = _conversionQueue[taskIndex];
      if (task.canResume) {
        task.resume();
        _pausedTasks.remove(taskId);
        notifyListeners();
        
        // Riavvia l'elaborazione della coda
        if (!_isConverting) {
          _processQueue();
        }
        
        appLog('Task ${task.fileName} ripreso');
      }
    }
  }

  void stopTask(String taskId) {
    final taskIndex = _conversionQueue.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      final task = _conversionQueue[taskIndex];
      if (task.canStop) {
        task.stop();
        _stopTask(taskId);
        notifyListeners();
        
        appLog('Task ${task.fileName} fermato');
      }
    }
  }

  void _stopTask(String taskId, {bool pause = false}) {
    _progressTimers[taskId]?.cancel();
    _progressTimers.remove(taskId);
    
    // Uccide il processo FFmpeg
    _ffmpegService.killProcess(taskId);
    _activeConversions.remove(taskId);
    
    // Se non ci sono più conversioni attive, consideriamo il ciclo terminato
    // sia in caso di stop che di pausa, così _processQueue potrà ripartire.
    if (_activeConversions.isEmpty) {
      _isConverting = false;
    }
  }

  // Metodo per fermare tutte le conversioni (utile quando l'app viene chiusa)
  void stopAllConversions() {
    appLog('Fermando tutte le conversioni attive');

    for (final task in _conversionQueue.where((t) => t.canStop)) {
      task.stop();
    }
    
    _ffmpegService.killAllProcesses();
    _activeConversions.clear();
    _progressTimers.clear();
    _pausedTasks.clear();
    _isConverting = false;
    
    notifyListeners();
  }

  void clearCompleted() {
    for (final task in _conversionQueue.where((t) => t.status == ConversionStatus.completed)) {
      _progressTimers[task.id]?.cancel();
      _progressTimers.remove(task.id);
      _pausedTasks.remove(task.id);
      _activeConversions.remove(task.id);
    }
    
    _conversionQueue.removeWhere((task) => task.status == ConversionStatus.completed);
    notifyListeners();
  }

  void clearQueue() {
    // Ferma tutte le conversioni attive prima di pulire
    stopAllConversions();
    
    _conversionQueue.clear();
    notifyListeners();
  }

  Future<void> _processQueue() async {
    if (_conversionQueue.isEmpty || _isConverting) return;

    _isConverting = true;
    notifyListeners();

    while (_conversionQueue.any((task) => 
        task.status == ConversionStatus.pending || 
        (task.status == ConversionStatus.paused && !_pausedTasks.containsKey(task.id)))) {
      
      final availableTasks = _conversionQueue
          .where((task) => 
              task.status == ConversionStatus.pending || 
              (task.status == ConversionStatus.paused && !_pausedTasks.containsKey(task.id)))
          .take(_getMaxConcurrentConversions())
          .toList();

      if (availableTasks.isEmpty) break;

      final conversionFutures = availableTasks.map((task) => _convertSingleTask(task)).toList();
      
      try {
        await Future.wait(conversionFutures);
      } catch (e) {
        appLog('Errore durante conversione: $e');
      }

      await Future.delayed(const Duration(milliseconds: 500));
    }

    _isConverting = false;
    notifyListeners();
  }

  Future<void> _convertSingleTask(ConversionTask task) async {
    // Controlla se il task è stato messo in pausa prima di iniziare
    if (_pausedTasks.containsKey(task.id)) {
      task.status = ConversionStatus.paused;
      return;
    }

    try {
      task.status = ConversionStatus.processing;
      task.progress = 0.0;
      task.processingFps = null;
      task.timeRemaining = _queueLabel('calculating');
      notifyListeners();

      final settings = _getSettings();

      // CHIAMATA CORRETTA CON TUTTI I PARAMETRI
      // Se il task ha un flag di sovrascrittura, usa il metodo con sovrascrittura
      final conversionFuture = _ffmpegService.convertMediaWithOverwrite(
        taskId: task.id,
        inputPath: task.inputPath,
        outputPath: task.outputPath,
        mediaType: task.mediaType,
        videoQuality: task.videoQuality,
        // Usa audioBitrate come valore effettivo passato a FFmpeg
        // per rispettare il bitrate scelto dall'utente.
        audioQuality: task.audioBitrate,
        audioCodec: task.audioCodec,
        // PARAMETRI AGGIUNTI
        videoCodec: task.videoCodec,
        videoBitrate: task.videoBitrate,
        videoBitrateMode: task.videoBitrateMode,
        videoFilters: task.videoFilters,
        audioFilters: task.audioFilters,
        imageFilters: task.imageFilters,
        cpuThreads: settings.cpuThreads,
        useGpu: settings.useGpu,
        gpuType: settings.gpuType,
        overwriteExisting: true, // Permetti sovrascrittura quando il task viene riprocessato
        extractAudioFromVideo: task.extractAudioFromVideo,
        onProgress: (progress, timeRemaining, {processingFps}) {
          // Controlla se il task è stato messo in pausa durante la conversione
          try {
            if (!_pausedTasks.containsKey(task.id)) {
              task.progress = progress;
              _applyProcessingFps(task, timeRemaining, processingFps);
              final uiLocale = _settingsProvider?.language ?? Platform.localeName;
              task.timeRemaining = _normalizeProgressMessage(timeRemaining, uiLocale);
              notifyListeners();
            }
          } catch (e) {
            // Ignora errori durante aggiornamento progresso
            appLog('⚠️ [ConversionProvider] Errore aggiornamento progresso: $e');
          }
        },
      );

      _activeConversions[task.id] = conversionFuture;

      Map<String, dynamic> result;
      try {
        result = await conversionFuture;
      } catch (e, stackTrace) {
        // Gestione errori robusta per prevenire crash
        appLog('❌ [ConversionProvider] Errore durante conversione: $e');
        appLog('📚 [ConversionProvider] Stack trace: $stackTrace');
        result = {
          'success': false,
          'error': 'Errore durante la conversione: $e'
        };
      } finally {
        _activeConversions.remove(task.id);
      }

      // Controlla se il task è stato messo in pausa durante la conversione
      if (!_pausedTasks.containsKey(task.id)) {
        if (result['success'] == true) {
          task.status = ConversionStatus.completed;
          task.progress = 1.0;
          task.processingFps = null;
          task.timeRemaining = _queueLabel('completed');
        } else if (result['error'] == 'file_exists') {
          // File esiste già - imposta uno stato speciale per gestire la sovrascrittura
          task.status = ConversionStatus.pending; // Rimetti in pending
          task.error = result['message'] ?? 'File già esistente';
          task.processingFps = null;
          task.timeRemaining = _queueLabel('file_exists');
          // L'UI dovrà gestire questo caso mostrando un dialog
          appLog('File esistente rilevato: ${result['file_path']}');
        } else {
          task.status = ConversionStatus.failed;
          task.error = result['error'] ?? 'Conversione fallita';
          task.processingFps = null;
          task.timeRemaining = _queueLabel('error');
        }
      }
      
      _progressTimers[task.id]?.cancel();
      _progressTimers.remove(task.id);
      
    } catch (e) {
      // Controlla se il task è stato messo in pausa durante la conversione
      if (!_pausedTasks.containsKey(task.id)) {
        task.status = ConversionStatus.failed;
        task.error = e.toString();
        task.processingFps = null;
        task.timeRemaining = _queueLabel('error');
      }
      
      _progressTimers[task.id]?.cancel();
      _progressTimers.remove(task.id);
      _activeConversions.remove(task.id);
      
      appLog('Errore conversione task ${task.id}: $e');
    } finally {
      notifyListeners();
    }
  }

  _ConversionSettings _getSettings() {
    try {
      // Legge le impostazioni reali dal SettingsProvider
      if (_settingsProvider != null) {
        return _ConversionSettings(
          cpuThreads: _settingsProvider!.cpuThreads,
          useGpu: _settingsProvider!.useGpu,
          gpuType: _settingsProvider!.gpuType,
          concurrentConversions: _settingsProvider!.concurrentConversions,
        );
      }
      
      // Fallback se SettingsProvider non è disponibile
      return _ConversionSettings(
        cpuThreads: 0,
        useGpu: false,
        gpuType: 'auto',
        concurrentConversions: 1,
      );
    } catch (e) {
      appLog('Errore lettura settings: $e');
      return _ConversionSettings(
        cpuThreads: 0,
        useGpu: false,
        gpuType: 'auto',
        concurrentConversions: 1,
      );
    }
  }

  int _getMaxConcurrentConversions() {
    final settings = _getSettings();
    return settings.concurrentConversions;
  }

  void reorderQueue(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final ConversionTask item = _conversionQueue.removeAt(oldIndex);
    _conversionQueue.insert(newIndex, item);
    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }
  
  /// Metodo per gestire la sovrascrittura di un file esistente
  Future<void> overwriteExistingFile(String taskId, bool overwrite) async {
    final taskIndex = _conversionQueue.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;
    
    final task = _conversionQueue[taskIndex];
    
    if (overwrite) {
      // Riprova la conversione con sovrascrittura
      task.status = ConversionStatus.pending;
      task.error = null;
      task.timeRemaining = _queueLabel('pending');
      notifyListeners();
      
      // Riavvia la coda se non è già in esecuzione
      if (!_isConverting) {
        _processQueue();
      }
    } else {
      // Rimuovi il task dalla coda
      removeFromQueue(taskId);
    }
  }

  // Metodo chiamato quando l'app viene chiusa
  @override
  void dispose() {
    stopAllConversions();
    super.dispose();
  }
}

class _ConversionSettings {
  final int cpuThreads;
  final bool useGpu;
  final String gpuType;
  final int concurrentConversions;

  const _ConversionSettings({
    this.cpuThreads = 0,
    this.useGpu = false,
    this.gpuType = 'auto',
    this.concurrentConversions = 1,
  });
}