class FocusSessionModel {
  final String id;
  final DateTime startTime;
  DateTime? endTime;
  final int durationMinutes;
  final List<String> blockedApps;
  bool wasCompletedFully;
  int earlyBreakAttempts;
  final String challengeType;
  bool isActive;

  FocusSessionModel({
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

  int get elapsedMinutes {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime).inMinutes;
  }

  double get progressPercent {
    if (durationMinutes <= 0) return 0;
    final elapsed = DateTime.now().difference(startTime).inSeconds;
    final total = durationMinutes * 60;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  Duration get remainingDuration {
    final total = Duration(minutes: durationMinutes);
    final elapsed = DateTime.now().difference(startTime);
    final remaining = total - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationMinutes': durationMinutes,
      'blockedApps': blockedApps,
      'wasCompletedFully': wasCompletedFully,
      'earlyBreakAttempts': earlyBreakAttempts,
      'challengeType': challengeType,
      'isActive': isActive,
    };
  }

  factory FocusSessionModel.fromMap(Map<String, dynamic> map) {
    return FocusSessionModel(
      id: map['id'] as String,
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime'] as String) : null,
      durationMinutes: map['durationMinutes'] as int,
      blockedApps: List<String>.from(map['blockedApps'] as List),
      wasCompletedFully: map['wasCompletedFully'] as bool? ?? false,
      earlyBreakAttempts: map['earlyBreakAttempts'] as int? ?? 0,
      challengeType: map['challengeType'] as String,
      isActive: map['isActive'] as bool? ?? true,
    );
  }
}
