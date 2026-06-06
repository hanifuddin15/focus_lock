import 'package:get/get.dart';
import 'package:focus_lock/data/local/storage_service.dart';
import 'package:focus_lock/data/models/focus_session_model.dart';
import 'package:focus_lock/services/logger_service.dart';

class SessionRepository {
  final StorageService _storage = Get.find<StorageService>();

  List<FocusSessionModel> getAllSessions() {
    return _storage.getAllSessions();
  }

  FocusSessionModel? getActiveSession() {
    return _storage.getActiveSession();
  }

  Future<void> createSession(FocusSessionModel session) async {
    await _storage.addSession(session);
    LoggerService.info('Session created: ${session.id}');
  }

  Future<void> updateSession(FocusSessionModel session) async {
    await _storage.updateSession(session);
    LoggerService.info('Session updated: ${session.id}');
  }

  Future<void> completeSession(String sessionId, {bool fully = true}) async {
    final sessions = getAllSessions();
    final session = sessions.firstWhereOrNull((s) => s.id == sessionId);
    if (session != null) {
      session.endTime = DateTime.now();
      session.wasCompletedFully = fully;
      session.isActive = false;
      await _storage.updateSession(session);
      LoggerService.info(
        'Session completed: $sessionId, fully: $fully',
      );
    }
  }

  Future<void> incrementBreakAttempts(String sessionId) async {
    final sessions = getAllSessions();
    final session = sessions.firstWhereOrNull((s) => s.id == sessionId);
    if (session != null) {
      session.earlyBreakAttempts++;
      await _storage.updateSession(session);
    }
  }

  List<FocusSessionModel> getSessionsInRange(DateTime start, DateTime end) {
    return getAllSessions()
        .where(
          (s) => s.startTime.isAfter(start) && s.startTime.isBefore(end),
        )
        .toList();
  }

  int getCompletedCount() {
    return getAllSessions().where((s) => s.wasCompletedFully).length;
  }

  int getEarlyBreakCount() {
    return getAllSessions()
        .where((s) => !s.wasCompletedFully && !s.isActive)
        .length;
  }

  double getTotalFocusHours() {
    final sessions = getAllSessions().where((s) => !s.isActive);
    int totalMinutes = 0;
    for (final session in sessions) {
      if (session.endTime != null) {
        totalMinutes +=
            session.endTime!.difference(session.startTime).inMinutes;
      }
    }
    return totalMinutes / 60.0;
  }

  int getCurrentStreak() {
    final sessions = getAllSessions()
        .where((s) => s.wasCompletedFully)
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    if (sessions.isEmpty) return 0;

    int streak = 1;
    DateTime lastDate = sessions.first.startTime;

    for (int i = 1; i < sessions.length; i++) {
      final diff = lastDate.difference(sessions[i].startTime).inDays;
      if (diff <= 1) {
        streak++;
        lastDate = sessions[i].startTime;
      } else {
        break;
      }
    }
    return streak;
  }

  Map<int, double> getWeeklyFocusData() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final data = <int, double>{};

    for (int i = 0; i < 7; i++) {
      final dayStart =
          DateTime(weekStart.year, weekStart.month, weekStart.day + i);
      final dayEnd = dayStart.add(const Duration(days: 1));
      final daySessions = getSessionsInRange(dayStart, dayEnd);
      double totalMinutes = 0;
      for (final s in daySessions) {
        if (s.endTime != null) {
          totalMinutes += s.endTime!.difference(s.startTime).inMinutes;
        } else if (s.isActive) {
          totalMinutes +=
              DateTime.now().difference(s.startTime).inMinutes;
        }
      }
      data[i] = totalMinutes;
    }
    return data;
  }
}
