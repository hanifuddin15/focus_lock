import 'package:get/get.dart';
import 'package:focus_lock/data/repositories/settings_repository.dart';
import 'package:focus_lock/data/repositories/app_list_repository.dart';
import 'package:focus_lock/data/models/user_settings_model.dart';
import 'package:focus_lock/data/models/app_info_model.dart';
import 'package:focus_lock/domain/usecases/validate_challenge.dart';
import 'package:focus_lock/services/platform_channel_service.dart';

class SettingsController extends GetxController {
  final SettingsRepository _settingsRepo = SettingsRepository();
  final AppListRepository _appListRepo = AppListRepository();
  final PlatformChannelService _platform = Get.find<PlatformChannelService>();

  final settings = UserSettingsModel().obs;
  final whitelistedApps = <AppInfoModel>[].obs;
  final isScanningBarcode = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
    loadWhitelistedApps();
  }

  void loadSettings() {
    settings.value = _settingsRepo.getSettings();
  }

  void loadWhitelistedApps() {
    whitelistedApps.assignAll(_appListRepo.getWhitelistedApps());
  }

  Future<void> setChallengeType(String type) async {
    await _settingsRepo.setChallengeType(type);
    loadSettings();
  }

  Future<void> toggleWeeklyReport(bool enabled) async {
    await _settingsRepo.toggleWeeklyReport(enabled);
    loadSettings();
  }

  Future<void> saveBarcodeHash(String rawValue) async {
    final hash = ValidateChallenge.hashBarcode(rawValue);
    await _settingsRepo.saveBarcodeHash(hash, rawValue);
    loadSettings();
  }

  Future<void> toggleWhitelist(String packageName) async {
    await _appListRepo.toggleAppWhitelisted(packageName);
    loadWhitelistedApps();
  }

  Future<void> requestUsageStatsPermission() async {
    await _platform.requestUsageStatsPermission();
  }

  Future<void> requestOverlayPermission() async {
    await _platform.requestOverlayPermission();
  }

  Future<void> checkPermissions() async {
    await _platform.checkPermissions();
  }
}
