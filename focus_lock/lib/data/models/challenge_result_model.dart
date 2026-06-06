class ChallengeResultModel {
  final String id;
  final String type; // 'barcode' or 'typing'
  final DateTime timestamp;
  final bool success;
  final int attemptDurationSeconds;
  final String sessionId;

  ChallengeResultModel({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.success,
    required this.attemptDurationSeconds,
    required this.sessionId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'success': success,
      'attemptDurationSeconds': attemptDurationSeconds,
      'sessionId': sessionId,
    };
  }

  factory ChallengeResultModel.fromMap(Map<String, dynamic> map) {
    return ChallengeResultModel(
      id: map['id'] as String,
      type: map['type'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      success: map['success'] as bool,
      attemptDurationSeconds: map['attemptDurationSeconds'] as int,
      sessionId: map['sessionId'] as String,
    );
  }
}
