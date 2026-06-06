import 'package:get/get.dart';
import 'package:focus_lock/core/constants/app_constants.dart';
import 'package:focus_lock/data/models/app_info_model.dart';
import 'package:focus_lock/data/repositories/app_list_repository.dart';
import 'package:focus_lock/data/repositories/settings_repository.dart';
import 'package:focus_lock/services/lock_service.dart';
import 'package:focus_lock/services/logger_service.dart';
import 'package:focus_lock/routes/app_routes.dart';

class HomeController extends GetxController {
  final AppListRepository _appListRepo = AppListRepository();
  final SettingsRepository _settingsRepo = SettingsRepository();
  final LockService _lockService = Get.find<LockService>();

  final selectedMinutes = AppConstants.defaultTimerMinutes.obs;
  final apps = <AppInfoModel>[].obs;
  final filteredApps = <AppInfoModel>[].obs;
  final isLoading = true.obs;
  final searchQuery = ''.obs;

  int get selectedAppCount => apps.where((a) => a.isBlocked).length;
  List<String> get blockedPackages =>
      apps.where((a) => a.isBlocked).map((a) => a.packageName).toList();

  @override
  void onInit() {
    super.onInit();
    _loadApps();
    _loadLastSettings();

    // React to search query changes
    ever(searchQuery, (_) => _filterApps());
  }

  Future<void> _loadApps() async {
    isLoading.value = true;
    try {
      final installedApps = await _appListRepo.fetchInstalledApps();
      apps.assignAll(installedApps);
      _filterApps();

      // Restore last blocked apps
      final settings = _settingsRepo.getSettings();
      if (settings.lastBlockedApps.isNotEmpty) {
        for (final app in apps) {
          if (settings.lastBlockedApps.contains(app.packageName)) {
            app.isBlocked = true;
          }
        }
        apps.refresh();
        _filterApps();
      }
    } catch (e) {
      LoggerService.error('Failed to load apps: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _loadLastSettings() {
    final settings = _settingsRepo.getSettings();
    selectedMinutes.value = settings.defaultDurationMinutes;
  }

  void _filterApps() {
    if (searchQuery.value.isEmpty) {
      filteredApps.assignAll(apps);
    } else {
      filteredApps.assignAll(
        apps.where(
          (a) => a.appName
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase()),
        ),
      );
    }
  }

  void setDuration(int minutes) {
    selectedMinutes.value =
        minutes.clamp(AppConstants.minTimerMinutes, AppConstants.maxTimerMinutes);
  }

  void setPresetDuration(int minutes) {
    selectedMinutes.value = minutes;
  }

  void toggleApp(String packageName) {
    final app = apps.firstWhereOrNull((a) => a.packageName == packageName);
    if (app != null) {
      app.isBlocked = !app.isBlocked;
      apps.refresh();
      filteredApps.refresh();
      _appListRepo.setAppBlocked(packageName, app.isBlocked);
    }
  }

  void selectAll() {
    for (final app in apps) {
      if (!app.isWhitelisted) {
        app.isBlocked = true;
      }
    }
    apps.refresh();
    filteredApps.refresh();
  }

  void deselectAll() {
    for (final app in apps) {
      app.isBlocked = false;
    }
    apps.refresh();
    filteredApps.refresh();
  }

  Future<void> startFocusLock() async {
    if (selectedAppCount == 0) {
      Get.snackbar(
        'No Apps Selected',
        'Please select at least one app to block.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final success = await _lockService.startSession(
      durationMinutes: selectedMinutes.value,
      blockedAppPackages: blockedPackages,
    );

    if (success) {
      Get.toNamed(AppRoutes.lock);
    } else {
      Get.snackbar(
        'Error',
        'Failed to start focus session. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void goToStatistics() {
    Get.toNamed(AppRoutes.statistics);
  }

  void goToSettings() {
    Get.toNamed(AppRoutes.settings);
  }
}
