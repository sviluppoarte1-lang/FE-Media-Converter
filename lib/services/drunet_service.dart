import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:video_converter_pro/utils/app_log.dart';

class DRUNetService {
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
  
  static String get _scriptPath => path.join(_getScriptsDirectory(), 'drunet_denoiser.py');
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
  
  /// Check if Python and required dependencies are available
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
      
      // Try to import required modules (basic check)
      final importCheck = await Process.run(pythonExe, [
        '-c',
        'import torch, torchvision, numpy, cv2, PIL; print("OK")'
      ]);
      
      return importCheck.exitCode == 0;
    } catch (e) {
      appLog('⚠️ [DRUNet] Dependency check failed: $e');
      return false;
    }
  }
  
  /// Denoise a single video frame using DRUNet
  /// 
  /// [framePath] - Path to input frame image
  /// [outputPath] - Path to save denoised frame
  /// [noiseLevel] - Noise level (0-255), default 7
  /// [modelPath] - Optional path to DRUNet model file
  static Future<Map<String, dynamic>> denoiseFrame({
    required String framePath,
    required String outputPath,
    int noiseLevel = 7,
    String? modelPath,
    String device = 'auto',
  }) async {
    try {
      final scriptFile = File(_scriptPath);
      if (!await scriptFile.exists()) {
        return {
          'success': false,
          'error': 'DRUNet script not found. Please ensure Python dependencies are installed.'
        };
      }
      
      // Make script executable
      await Process.run('chmod', ['+x', _scriptPath]);
      
      final pythonExe = await _getPythonExecutable();
      
      final args = [
        _scriptPath,
        '--input', framePath,
        '--output', outputPath,
        '--noise-level', noiseLevel.toString(),
        '--device', device,
      ];
      
      if (modelPath != null) {
        args.addAll(['--model-path', modelPath]);
      }
      
      appLog('🔧 [DRUNet] Denoising frame: $framePath');
      appLog('   → Python: $pythonExe');
      appLog('   → Noise level: $noiseLevel');
      appLog('   → Device: $device');
      
      final n = Platform.numberOfProcessors.clamp(1, 32).toString();
      final env = Map<String, String>.from(Platform.environment);
      env['OMP_NUM_THREADS'] = n;
      env['MKL_NUM_THREADS'] = n;
      env['OPENBLAS_NUM_THREADS'] = n;
      final process = await Process.run(
        pythonExe,
        args,
        environment: env,
      );
      
      if (process.exitCode != 0) {
        final errorOutput = process.stderr.toString();
        appLog('❌ [DRUNet] Error: $errorOutput');
        return {
          'success': false,
          'error': errorOutput.isNotEmpty ? errorOutput : 'Unknown error during denoising'
        };
      }
      
      // Parse JSON output
      final output = process.stdout.toString().trim();
      if (output.isEmpty) {
        return {
          'success': false,
          'error': 'No output from DRUNet script'
        };
      }
      
      try {
        final result = json.decode(output) as Map<String, dynamic>;
        if (result['success'] == true) {
          appLog('✅ [DRUNet] Frame denoised successfully: $outputPath');
        }
        return result;
      } catch (e) {
        return {
          'success': false,
          'error': 'Failed to parse DRUNet output: $e'
        };
      }
    } catch (e) {
      appLog('❌ [DRUNet] Exception: $e');
      return {
        'success': false,
        'error': 'Exception during denoising: $e'
      };
    }
  }
  
  /// Denoise multiple frames (batch processing)
  static Future<Map<String, dynamic>> denoiseFrames({
    required List<String> framePaths,
    required String outputDir,
    int noiseLevel = 7,
    String? modelPath,
    String device = 'auto',
    void Function(int current, int total)? onProgress,
  }) async {
    try {
      final outputDirectory = Directory(outputDir);
      if (!await outputDirectory.exists()) {
        await outputDirectory.create(recursive: true);
      }
      
      final results = <Map<String, dynamic>>[];
      int successCount = 0;
      int failCount = 0;
      
      for (int i = 0; i < framePaths.length; i++) {
        final framePath = framePaths[i];
        final frameName = path.basenameWithoutExtension(framePath);
        final outputPath = path.join(outputDir, '${frameName}_denoised.png');
        
        if (onProgress != null) {
          onProgress(i + 1, framePaths.length);
        }
        
        final result = await denoiseFrame(
          framePath: framePath,
          outputPath: outputPath,
          noiseLevel: noiseLevel,
          modelPath: modelPath,
          device: device,
        );
        
        results.add(result);
        if (result['success'] == true) {
          successCount++;
        } else {
          failCount++;
        }
      }
      
      return {
        'success': successCount > 0,
        'total_frames': framePaths.length,
        'success_count': successCount,
        'fail_count': failCount,
        'results': results,
        'output_dir': outputDir,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Exception during batch denoising: $e'
      };
    }
  }
  
  /// Extract frames from video, denoise them, and reconstruct video
  /// This is a helper method that integrates with FFmpeg
  static Future<Map<String, dynamic>> denoiseVideo({
    required String inputVideo,
    required String outputVideo,
    int noiseLevel = 7,
    String? modelPath,
    String device = 'auto',
    void Function(double progress)? onProgress,
  }) async {
    try {
      // This would require extracting frames, denoising, and reconstructing
      // For now, return a placeholder that indicates this needs FFmpeg integration
      return {
        'success': false,
        'error': 'Video denoising requires frame extraction/reconstruction. Use FFmpeg filter integration instead.',
        'suggestion': 'Consider using DRUNet as a post-processing step after frame extraction'
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Exception during video denoising: $e'
      };
    }
  }
  
  /// Get recommended noise level based on video analysis
  static int getRecommendedNoiseLevel({
    double? noisePercentage,
    bool hasHighNoise = false,
  }) {
    if (noisePercentage != null) {
      if (noisePercentage > 20.0) return 15;
      if (noisePercentage > 15.0) return 12;
      if (noisePercentage > 10.0) return 8;
      if (noisePercentage > 5.0) return 5;
      return 3;
    }
    
    if (hasHighNoise) return 10;
    return 7; // Default moderate noise level
  }
}

