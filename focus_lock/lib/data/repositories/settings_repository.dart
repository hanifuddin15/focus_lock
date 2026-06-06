import 'package:get/get.dart';
import 'package:focus_lock/data/local/hive_service.dart';
import 'package:focus_lock/data/models/user_settings_model.dart';
import 'package:focus_lock/services/logger_service.dart';

class SettingsRepository {
  final HiveService _hive = Get.find<HiveService>();

  UserSettingsModel getSettings() {
    return _hive.getSettings();
  }

  Future<void> updateSettings(UserSettingsModel settings) async {
    await _hive.saveSettings(settings);
    LoggerService.info('Settings updated');
  }

  Future<void> saveBarcodeHash(String hash, String rawValue) async {
    final settings = getSettings();
    settings.savedBarcodeHash = hash;
    settings.savedBarcodeValue = rawValue;
    await updateSettings(settings);
    LoggerService.info('Barcode saved');
  }

  Future<void> setChallengeType(String type) async {
    final settings = getSettings();
    settings.challengeType = type;
    await updateSettings(settings);
  }

  Future<void> setOnboardingComplete() async {
    final settings = getSettings();
    settings.onboardingCompleted = true;
    await updateSettings(settings);
  }

  bool isOnboardingDone() {
    return getSettings().onboardingCompleted;
  }

  Future<void> toggleWeeklyReport(bool enabled) async {
    final settings = getSettings();
    settings.weeklyReportEnabled = enabled;
    await updateSettings(settings);
  }

  Future<void> updateWhitelist(List<String> apps) async {
    final settings = getSettings();
    settings.whitelistedApps = apps;
    await updateSettings(settings);
  }

  Future<void> setDefaultDuration(int minutes) async {
    final settings = getSettings();
    settings.defaultDurationMinutes = minutes;
    await updateSettings(settings);
  }

  Future<void> saveLastBlockedApps(List<String> apps) async {
    final settings = getSettings();
    settings.lastBlockedApps = apps;
    await updateSettings(settings);
  }
}
