import 'package:get/get.dart';
import 'package:focus_lock/data/local/storage_service.dart';
import 'package:focus_lock/data/models/app_info_model.dart';
import 'package:focus_lock/services/platform_channel_service.dart';
import 'package:focus_lock/services/logger_service.dart';

class AppListRepository {
  final StorageService _storage = Get.find<StorageService>();
  final PlatformChannelService _platform = Get.find<PlatformChannelService>();

  List<AppInfoModel> getCachedApps() {
    return _storage.getCachedApps();
  }

  List<AppInfoModel> getBlockedApps() {
    return getCachedApps().where((a) => a.isBlocked).toList();
  }

  List<AppInfoModel> getWhitelistedApps() {
    return getCachedApps().where((a) => a.isWhitelisted).toList();
  }

  Future<List<AppInfoModel>> fetchInstalledApps() async {
    try {
      final apps = await _platform.getInstalledApps();
      final cached = getCachedApps();

      // Preserve block/whitelist state from cache
      final mergedApps = apps.map((newApp) {
        final existing = cached.firstWhereOrNull(
          (c) => c.packageName == newApp.packageName,
        );
        if (existing != null) {
          newApp.isBlocked = existing.isBlocked;
          newApp.isWhitelisted = existing.isWhitelisted;
        }
        return newApp;
      }).toList();

      await _storage.cacheApps(mergedApps);
      LoggerService.info('Fetched ${mergedApps.length} installed apps');
      return mergedApps;
    } catch (e) {
      LoggerService.error('Failed to fetch installed apps: $e');
      // Return cached data as fallback
      return getCachedApps();
    }
  }

  Future<void> toggleAppBlocked(String packageName) async {
    final apps = getCachedApps();
    final app = apps.firstWhereOrNull((a) => a.packageName == packageName);
    if (app != null) {
      app.isBlocked = !app.isBlocked;
      await _storage.updateApp(app);
    }
  }

  Future<void> setAppBlocked(String packageName, bool blocked) async {
    final apps = getCachedApps();
    final app = apps.firstWhereOrNull((a) => a.packageName == packageName);
    if (app != null) {
      app.isBlocked = blocked;
      await _storage.updateApp(app);
    }
  }

  Future<void> toggleAppWhitelisted(String packageName) async {
    final apps = getCachedApps();
    final app = apps.firstWhereOrNull((a) => a.packageName == packageName);
    if (app != null) {
      app.isWhitelisted = !app.isWhitelisted;
      if (app.isWhitelisted) {
        app.isBlocked = false; // Whitelist overrides block
      }
      await _storage.updateApp(app);
    }
  }

  Future<void> setAllBlocked(bool blocked) async {
    final apps = getCachedApps();
    for (final app in apps) {
      if (!app.isWhitelisted) {
        app.isBlocked = blocked;
        await _storage.updateApp(app);
      }
    }
  }
}
