import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:focus_lock/core/constants/app_constants.dart';
import 'package:focus_lock/data/models/focus_session_model.dart';
import 'package:focus_lock/data/models/app_info_model.dart';
import 'package:focus_lock/data/models/user_settings_model.dart';
import 'package:focus_lock/data/models/challenge_result_model.dart';
import 'package:focus_lock/services/logger_service.dart';

class HiveService extends GetxService {
  late Box<FocusSessionModel> sessionsBox;
  late Box<UserSettingsModel> settingsBox;
  late Box<AppInfoModel> appsBox;
  late Box<ChallengeResultModel> challengeBox;

  Future<HiveService> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(FocusSessionModelAdapter());
    Hive.registerAdapter(AppInfoModelAdapter());
    Hive.registerAdapter(UserSettingsModelAdapter());
    Hive.registerAdapter(ChallengeResultModelAdapter());

    // Open boxes
    sessionsBox = await Hive.openBox<FocusSessionModel>(
      AppConstants.sessionsBox,
    );
    settingsBox = await Hive.openBox<UserSettingsModel>(
      AppConstants.settingsBox,
    );
    appsBox = await Hive.openBox<AppInfoModel>(AppConstants.appsBox);
    challengeBox = await Hive.openBox<ChallengeResultModel>(
      AppConstants.challengeBox,
    );

    LoggerService.info('HiveService initialized successfully');
    return this;
  }

  // Settings helpers
  UserSettingsModel getSettings() {
    return settingsBox.get(
      AppConstants.settingsKey,
      defaultValue: UserSettingsModel(),
    )!;
  }

  Future<void> saveSettings(UserSettingsModel settings) async {
    await settingsBox.put(AppConstants.settingsKey, settings);
  }

  // Session helpers
  List<FocusSessionModel> getAllSessions() {
    return sessionsBox.values.toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  FocusSessionModel? getActiveSession() {
    try {
      return sessionsBox.values.firstWhere((s) => s.isActive);
    } catch (_) {
      return null;
    }
  }

  Future<void> addSession(FocusSessionModel session) async {
    await sessionsBox.put(session.id, session);
  }

  Future<void> updateSession(FocusSessionModel session) async {
    await session.save();
  }

  // App helpers
  List<AppInfoModel> getCachedApps() {
    return appsBox.values.toList()
      ..sort((a, b) => a.appName.compareTo(b.appName));
  }

  Future<void> cacheApps(List<AppInfoModel> apps) async {
    await appsBox.clear();
    for (final app in apps) {
      await appsBox.put(app.packageName, app);
    }
  }

  Future<void> updateApp(AppInfoModel app) async {
    await appsBox.put(app.packageName, app);
  }

  // Challenge helpers
  Future<void> addChallengeResult(ChallengeResultModel result) async {
    await challengeBox.put(result.id, result);
  }

  List<ChallengeResultModel> getChallengeResults() {
    return challengeBox.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Cleanup
  Future<void> clearAllData() async {
    await sessionsBox.clear();
    await settingsBox.clear();
    await appsBox.clear();
    await challengeBox.clear();
  }
}
