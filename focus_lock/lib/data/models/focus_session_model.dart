import 'package:hive/hive.dart';

part 'focus_session_model.g.dart';

@HiveType(typeId: 0)
class FocusSessionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime startTime;

  @HiveField(2)
  DateTime? endTime;

  @HiveField(3)
  final int durationMinutes;

  @HiveField(4)
  final List<String> blockedApps;

  @HiveField(5)
  bool wasCompletedFully;

  @HiveField(6)
  int earlyBreakAttempts;

  @HiveField(7)
  final String challengeType;

  @HiveField(8)
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
}
