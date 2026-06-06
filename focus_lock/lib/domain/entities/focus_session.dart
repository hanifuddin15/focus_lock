class FocusSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationMinutes;
  final List<String> blockedApps;
  final bool wasCompletedFully;
  final int earlyBreakAttempts;
  final String challengeType;
  final bool isActive;

  const FocusSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.durationMinutes,
    required this.blockedApps,
    this.wasCompletedFully = false,
    this.earlyBreakAttempts = 0,
    required this.challengeType,
    this.isActive = true,
  });

  Duration get totalDuration => Duration(minutes: durationMinutes);

  Duration get elapsed {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  Duration get remaining {
    final r = totalDuration - elapsed;
    return r.isNegative ? Duration.zero : r;
  }

  double get progress {
    if (durationMinutes <= 0) return 0;
    return (elapsed.inSeconds / totalDuration.inSeconds).clamp(0.0, 1.0);
  }

  bool get isExpired => remaining == Duration.zero;
}
