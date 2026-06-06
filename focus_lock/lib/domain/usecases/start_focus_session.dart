import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:focus_lock/data/models/focus_session_model.dart';
import 'package:focus_lock/data/repositories/session_repository.dart';
import 'package:focus_lock/data/repositories/settings_repository.dart';
import 'package:focus_lock/services/platform_channel_service.dart';
import 'package:focus_lock/services/logger_service.dart';

class StartFocusSession {
  final SessionRepository _sessionRepo = SessionRepository();
  final SettingsRepository _settingsRepo = SettingsRepository();
  final PlatformChannelService _platform = Get.find<PlatformChannelService>();

  Future<FocusSessionModel?> execute({
    required int durationMinutes,
    required List<String> blockedAppPackages,
  }) async {
    try {
      // Check for existing active session
      final existing = _sessionRepo.getActiveSession();
      if (existing != null) {
        LoggerService.warning('Active session already exists: ${existing.id}');
        return existing;
      }

      // Get current settings
      final settings = _settingsRepo.getSettings();

      // Create session
      final session = FocusSessionModel(
        id: const Uuid().v4(),
        startTime: DateTime.now(),
        durationMinutes: durationMinutes,
        blockedApps: blockedAppPackages,
        challengeType: settings.challengeType,
      );

      // Save session
      await _sessionRepo.createSession(session);

      // Save last blocked apps for quick re-selection
      await _settingsRepo.saveLastBlockedApps(blockedAppPackages);

      // Start platform-level monitoring
      try {
        await _platform.startMonitoring(blockedAppPackages, durationMinutes);
        LoggerService.info(
          'Platform monitoring started for ${blockedAppPackages.length} apps',
        );
      } catch (e) {
        LoggerService.warning(
          'Platform monitoring failed (app-level lock still active): $e',
        );
      }

      return session;
    } catch (e) {
      LoggerService.error('Failed to start focus session: $e');
      return null;
    }
  }
}
