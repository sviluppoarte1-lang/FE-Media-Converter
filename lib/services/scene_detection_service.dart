import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:video_converter_pro/utils/app_log.dart';

class SceneDetectionService {
  /// Get app installation directory (project root or /usr/share/video-converter-pro).
  static String _getAppDirectory() {
    try {
      final executable = Platform.resolvedExecutable;
      final executableDir = path.dirname(executable);
      if (executableDir.contains('/usr/share/video-converter-pro')) {
        return '/usr/share/video-converter-pro';
      }
      var dir = executableDir;
      for (int i = 0; i < 12; i++) {
        final scriptsPath = path.join(dir, 'scripts', 'python');
        if (Directory(scriptsPath).existsSync()) return dir;
        final parent = path.dirname(dir);
        if (parent == dir) break;
        dir = parent;
      }
      return Directory.current.path;
    } catch (e) {
      return Directory.current.path;
    }
  }
  
  /// Get scripts directory
  static String _getScriptsDirectory() {
    final appDir = _getAppDirectory();
    final scriptsPath = path.join(appDir, 'scripts', 'python');
    if (Directory(scriptsPath).existsSync()) return scriptsPath;
    return path.join(Directory.current.path, 'scripts', 'python');
  }
  
  static String get _scriptPath => path.join(_getScriptsDirectory(), 'scene_detector.py');
  static String get _venvPath => path.join(_getScriptsDirectory(), 'venv');
  
  /// Get Python executable path (prefer venv if available)
  static Future<String> _getPythonExecutable() async {
    // Check for virtual environment first
    final venvPython = File(path.join(_venvPath, 'bin', 'python3'));
    if (await venvPython.exists()) {
      return venvPython.absolute.path;
    }
    
    // Fallback to system python3
    return 'python3';
  }
  
  /// Check if Python and PySceneDetect are available
  static Future<bool> checkDependencies() async {
    try {
      final pythonExe = await _getPythonExecutable();
      
      // Check Python
      final pythonCheck = await Process.run(pythonExe, ['--version']);
      if (pythonCheck.exitCode != 0) {
        return false;
      }
      
      // Check if script exists
      final scriptFile = File(_scriptPath);
      if (!await scriptFile.exists()) {
        return false;
      }
      
      // Try to import scenedetect
      final importCheck = await Process.run(pythonExe, [
        '-c',
        'import scenedetect; print("OK")'
      ]);
      
      return importCheck.exitCode == 0;
    } catch (e) {
      appLog('⚠️ [SceneDetection] Dependency check failed: $e');
      return false;
    }
  }
  
  /// Detect scenes in a video
  /// 
  /// [videoPath] - Path to input video
  /// [method] - Detection method: 'adaptive', 'content', or 'threshold'
  /// [threshold] - Threshold value for content/threshold methods
  /// [outputJson] - Optional path to save scene list as JSON
  /// [analyzeQuality] - Whether to analyze scenes and provide quality recommendations
  static Future<Map<String, dynamic>> detectScenes({
    required String videoPath,
    String method = 'adaptive',
    double threshold = 30.0,
    String? outputJson,
    bool analyzeQuality = true,
  }) async {
    try {
      final scriptFile = File(_scriptPath);
      if (!await scriptFile.exists()) {
        return {
          'success': false,
          'error': 'Scene detection script not found. Please ensure Python dependencies are installed.'
        };
      }
      
      // Make script executable
      await Process.run('chmod', ['+x', _scriptPath]);
      
      final pythonExe = await _getPythonExecutable();
      
      final args = [
        _scriptPath,
        '--input', videoPath,
        '--method', method,
        '--threshold', threshold.toString(),
      ];
      
      if (outputJson != null) {
        args.addAll(['--output-json', outputJson]);
      }
      
      if (analyzeQuality) {
        args.add('--analyze-quality');
      }
      
      appLog('🔍 [SceneDetection] Detecting scenes in: $videoPath');
      appLog('   → Python: $pythonExe');
      appLog('   → Method: $method');
      appLog('   → Threshold: $threshold');
      
      final process = await Process.run(pythonExe, args);
      
      if (process.exitCode != 0) {
        final stderr = process.stderr.toString().trim();
        final stdout = process.stdout.toString().trim();
        appLog('❌ [SceneDetection] Exit code: ${process.exitCode}');
        if (stderr.isNotEmpty) appLog('   stderr: $stderr');
        if (stdout.isNotEmpty) appLog('   stdout: $stdout');
        // Script may send JSON error on stdout (e.g. ImportError)
        String errorMsg = stderr;
        if (errorMsg.isEmpty && stdout.isNotEmpty) {
          try {
            final decoded = json.decode(stdout) as Map<String, dynamic>;
            errorMsg = decoded['error']?.toString() ?? stdout;
          } catch (_) {
            errorMsg = stdout;
          }
        }
        if (errorMsg.isEmpty) errorMsg = 'Unknown error during scene detection';
        return {
          'success': false,
          'error': errorMsg
        };
      }
      
      // Parse JSON output
      final output = process.stdout.toString().trim();
      if (output.isEmpty) {
        return {
          'success': false,
          'error': 'No output from scene detection script'
        };
      }
      
      try {
        final result = json.decode(output) as Map<String, dynamic>;
        if (result['success'] == true) {
          final totalScenes = result['total_scenes'] as int? ?? 0;
          appLog('✅ [SceneDetection] Detected $totalScenes scenes');
          
          // Log scene summary
          final scenes = result['scenes'] as List<dynamic>?;
          if (scenes != null && scenes.isNotEmpty) {
            appLog('   → First scene: ${scenes.first['start_time']}');
            appLog('   → Last scene: ${scenes.last['end_time']}');
          }
        }
        return result;
      } catch (e) {
        return {
          'success': false,
          'error': 'Failed to parse scene detection output: $e'
        };
      }
    } catch (e) {
      appLog('❌ [SceneDetection] Exception: $e');
      return {
        'success': false,
        'error': 'Exception during scene detection: $e'
      };
    }
  }
  
  /// Split video into separate scene files
  static Future<Map<String, dynamic>> splitVideoByScenes({
    required String videoPath,
    required String outputDir,
    String method = 'adaptive',
    double threshold = 30.0,
  }) async {
    try {
      final scriptFile = File(_scriptPath);
      if (!await scriptFile.exists()) {
        return {
          'success': false,
          'error': 'Scene detection script not found'
        };
      }
      
      await Process.run('chmod', ['+x', _scriptPath]);
      
      final pythonExe = await _getPythonExecutable();
      
      final args = [
        _scriptPath,
        '--input', videoPath,
        '--method', method,
        '--threshold', threshold.toString(),
        '--split',
        '--output-dir', outputDir,
      ];
      
      appLog('✂️ [SceneDetection] Splitting video into scenes...');
      appLog('   → Python: $pythonExe');
      
      final process = await Process.run(pythonExe, args);
      
      if (process.exitCode != 0) {
        final errorOutput = process.stderr.toString();
        return {
          'success': false,
          'error': errorOutput.isNotEmpty ? errorOutput : 'Unknown error during video splitting'
        };
      }
      
      final output = process.stdout.toString().trim();
      if (output.isEmpty) {
        return {
          'success': false,
          'error': 'No output from scene detection script'
        };
      }
      
      try {
        final result = json.decode(output) as Map<String, dynamic>;
        if (result['success'] == true) {
          final splitResult = result['split_result'] as Map<String, dynamic>?;
          if (splitResult != null && splitResult['success'] == true) {
            final totalFiles = splitResult['total_files'] as int? ?? 0;
            appLog('✅ [SceneDetection] Video split into $totalFiles scene files');
          }
        }
        return result;
      } catch (e) {
        return {
          'success': false,
          'error': 'Failed to parse split result: $e'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Exception during video splitting: $e'
      };
    }
  }
  
  /// Get optimal quality settings based on scene analysis
  static Map<String, dynamic> getOptimalQualitySettings(Map<String, dynamic> sceneResult) {
    try {
      final qualityAnalysis = sceneResult['quality_analysis'] as Map<String, dynamic>?;
      if (qualityAnalysis == null || qualityAnalysis['success'] != true) {
        return {
          'success': false,
          'error': 'Quality analysis not available'
        };
      }
      
      final recommendations = qualityAnalysis['recommendations'] as Map<String, dynamic>?;
      if (recommendations == null) {
        return {
          'success': false,
          'error': 'No recommendations available'
        };
      }
      
      return {
        'success': true,
        'recommendations': recommendations,
        'suggested_bitrate_mode': recommendations['suggested_bitrate_mode'] ?? 'crf',
        'suggested_crf': recommendations['suggested_crf'] ?? 23,
        'suggested_bitrate': recommendations['suggested_bitrate'] ?? 5000,
        'has_rapid_cuts': recommendations['has_rapid_cuts'] ?? false,
        'has_long_scenes': recommendations['has_long_scenes'] ?? false,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Exception parsing quality settings: $e'
      };
    }
  }
  
  /// Analyze video and provide conversion recommendations
  static Future<Map<String, dynamic>> analyzeVideoForOptimization({
    required String videoPath,
    String method = 'adaptive',
  }) async {
    try {
      // Detect scenes
      final sceneResult = await detectScenes(
        videoPath: videoPath,
        method: method,
        analyzeQuality: true,
      );
      
      if (sceneResult['success'] != true) {
        return sceneResult;
      }
      
      // Get quality recommendations
      final qualitySettings = getOptimalQualitySettings(sceneResult);
      
      return {
        'success': true,
        'scene_detection': sceneResult,
        'quality_recommendations': qualitySettings,
        'total_scenes': sceneResult['total_scenes'] ?? 0,
        'scenes': sceneResult['scenes'] ?? [],
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Exception during video analysis: $e'
      };
    }
  }
}

