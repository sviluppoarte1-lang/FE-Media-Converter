/// Sanitizes throughput numbers from FFmpeg stderr and frame-delta heuristics.
/// Burst-decoded lines and bogus `fps=` values otherwise produce absurd UI (e.g. 800+ "fps").
abstract final class ProcessingFpsSanitize {
  static const double minPlausible = 0.08;
  static const double maxPlausible = 180.0;

  static double? fromReported(double? v) {
    if (v == null || v.isNaN || !v.isFinite) return null;
    if (v < minPlausible || v > maxPlausible) return null;
    return v;
  }

  /// Smoothed fps from wall clock and media time (stable vs stderr bursts).
  static double? fromMediaTimeDelta({
    required double prevTimeSec,
    required double timeSec,
    required double wallDtSec,
  }) {
    if (wallDtSec < 0.2 || timeSec <= prevTimeSec) return null;
    final inst = (timeSec - prevTimeSec) / wallDtSec;
    return fromReported(inst);
  }
}
