import 'package:get/get.dart';
import 'package:focus_lock/data/repositories/session_repository.dart';
import 'package:focus_lock/services/platform_channel_service.dart';
import 'package:focus_lock/services/logger_service.dart';

class EndFocusSession {
  final SessionRepository _sessionRepo = SessionRepository();
  final PlatformChannelService _platform = Get.find<PlatformChannelService>();

  Future<bool> execute(String sessionId, {bool completedFully = true}) async {
    try {
      // Complete session in storage
      await _sessionRepo.completeSession(sessionId, fully: completedFully);

      // Stop platform-level monitoring
      try {
        await _platform.stopMonitoring();
        LoggerService.info('Platform monitoring stopped');
      } catch (e) {
        LoggerService.warning('Failed to stop platform monitoring: $e');
      }

      LoggerService.info(
        'Session ended: $sessionId, completed: $completedFully',
      );
      return true;
    } catch (e) {
      LoggerService.error('Failed to end session: $e');
      return false;
    }
  }
}
