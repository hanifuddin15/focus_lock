import 'package:hive/hive.dart';

part 'challenge_result_model.g.dart';

@HiveType(typeId: 3)
class ChallengeResultModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String type; // 'barcode' or 'typing'

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  final bool success;

  @HiveField(4)
  final int attemptDurationSeconds;

  @HiveField(5)
  final String sessionId;

  ChallengeResultModel({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.success,
    required this.attemptDurationSeconds,
    required this.sessionId,
  });
}
