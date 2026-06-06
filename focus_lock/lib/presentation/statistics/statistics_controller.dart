import 'package:get/get.dart';
import 'package:focus_lock/data/repositories/session_repository.dart';
import 'package:focus_lock/data/models/focus_session_model.dart';

class StatisticsController extends GetxController {
  final SessionRepository _sessionRepo = SessionRepository();

  final sessions = <FocusSessionModel>[].obs;
  final totalSessions = 0.obs;
  final completedSessions = 0.obs;
  final earlyBreaks = 0.obs;
  final totalFocusHours = 0.0.obs;
  final currentStreak = 0.obs;
  final weeklyData = <int, double>{}.obs;
  final selectedPeriod = 'week'.obs;

  @override
  void onInit() {
    super.onInit();
    loadStatistics();
  }

  void loadStatistics() {
    final allSessions = _sessionRepo.getAllSessions();
    sessions.assignAll(allSessions.where((s) => !s.isActive));
    totalSessions.value = sessions.length;
    completedSessions.value = _sessionRepo.getCompletedCount();
    earlyBreaks.value = _sessionRepo.getEarlyBreakCount();
    totalFocusHours.value = _sessionRepo.getTotalFocusHours();
    currentStreak.value = _sessionRepo.getCurrentStreak();
    weeklyData.value = _sessionRepo.getWeeklyFocusData();
  }

  void setPeriod(String period) {
    selectedPeriod.value = period;
    loadStatistics();
  }

  double get maxWeeklyValue {
    if (weeklyData.isEmpty) return 60;
    final max = weeklyData.values.reduce((a, b) => a > b ? a : b);
    return max < 30 ? 60 : max * 1.2;
  }
}
