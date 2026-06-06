import 'dart:async';
import 'package:get/get.dart';
import 'package:focus_lock/data/models/focus_session_model.dart';
import 'package:focus_lock/data/repositories/session_repository.dart';
import 'package:focus_lock/domain/usecases/start_focus_session.dart';
import 'package:focus_lock/domain/usecases/end_focus_session.dart';
import 'package:focus_lock/services/notification_service.dart';
import 'package:focus_lock/services/logger_service.dart';
import 'package:focus_lock/routes/app_routes.dart';

class LockService extends GetxService {
  final SessionRepository _sessionRepo = SessionRepository();
  final StartFocusSession _startUseCase = StartFocusSession();
  final EndFocusSession _endUseCase = EndFocusSession();

  final activeSession = Rxn<FocusSessionModel>();
  final isLocked = false.obs;
  final remainingSeconds = 0.obs;

  Timer? _countdownTimer;

  Future<LockService> init() async {
    // Check for active session on app start (survives app restarts)
    final existing = _sessionRepo.getActiveSession();
    if (existing != null) {
      final remaining = existing.remainingDuration;
      if (remaining > Duration.zero) {
        activeSession.value = existing;
        isLocked.value = true;
        _startCountdown();
        LoggerService.info('Restored active session: ${existing.id}');
      } else {
        // Session expired while app was killed
        await _endUseCase.execute(existing.id, completedFully: true);
        LoggerService.info('Expired session cleaned up: ${existing.id}');
      }
    }
    return this;
  }

  Future<bool> startSession({
    required int durationMinutes,
    required List<String> blockedAppPackages,
  }) async {
    if (isLocked.value) {
      LoggerService.warning('Cannot start: session already active');
      return false;
    }

    final session = await _startUseCase.execute(
      durationMinutes: durationMinutes,
      blockedAppPackages: blockedAppPackages,
    );

    if (session == null) return false;

    activeSession.value = session;
    isLocked.value = true;
    _startCountdown();

    // Show notification
    NotificationService.showSessionStarted(durationMinutes);

    return true;
  }

  Future<void> endSession({bool completedFully = false}) async {
    final session = activeSession.value;
    if (session == null) return;

    _countdownTimer?.cancel();
    await _endUseCase.execute(session.id, completedFully: completedFully);

    activeSession.value = null;
    isLocked.value = false;
    remainingSeconds.value = 0;

    if (completedFully) {
      NotificationService.showSessionCompleted();
    }

    LoggerService.info(
      'Session ended, completed: $completedFully',
    );
  }

  void incrementBreakAttempt() {
    final session = activeSession.value;
    if (session != null) {
      _sessionRepo.incrementBreakAttempts(session.id);
      session.earlyBreakAttempts++;
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _updateRemaining();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemaining();

      if (remainingSeconds.value <= 0) {
        _onSessionComplete();
      }
    });
  }

  void _updateRemaining() {
    final session = activeSession.value;
    if (session == null) return;
    remainingSeconds.value = session.remainingDuration.inSeconds;
  }

  void _onSessionComplete() {
    _countdownTimer?.cancel();
    endSession(completedFully: true);

    // Navigate to home
    if (Get.currentRoute == AppRoutes.lock ||
        Get.currentRoute == AppRoutes.challenge) {
      Get.offAllNamed(AppRoutes.home);
      Get.snackbar(
        'Session Complete! 🎉',
        'Great work! You stayed focused.',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
    }
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    super.onClose();
  }
}
