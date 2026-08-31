import 'dart:io';

class SnapEnvironment {
  static bool? _cached;

  /// Returns true if the app is running inside a snap package.
  static bool get isRunningInSnap {
    if (_cached != null) return _cached!;

    // Method 1: Check SNAPPING环境变量
    if (Platform.environment.containsKey('SNAP')) {
      _cached = true;
      return true;
    }

    // Method 2: Check SNAP_NAME
    if (Platform.environment.containsKey('SNAP_NAME')) {
      _cached = true;
      return true;
    }

    // Method 3: Check resolved executable path
    try {
      final exe = Platform.resolvedExecutable;
      if (exe.contains('/snap/')) {
        _cached = true;
        return true;
      }
    } catch (_) {}

    // Method 4: Check if /snap directory exists and our executable is there
    try {
      final exe = Platform.resolvedExecutable;
      if (exe.startsWith('/snap/') || exe.startsWith('/snap_v2/')) {
        _cached = true;
        return true;
      }
    } catch (_) {}

    _cached = false;
    return false;
  }

  /// Returns the user's home directory inside the snap.
  /// In strict confinement, $HOME points to the real home.
  static String get homeDirectory => Platform.environment['HOME'] ?? '/root';

  /// Returns a safe default output directory for snap.
  /// Uses $HOME which is always writable with the `home` plug.
  static String get safeOutputDirectory => homeDirectory;
}
