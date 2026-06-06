import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:focus_lock/core/constants/app_constants.dart';
import 'package:focus_lock/data/models/focus_session_model.dart';
import 'package:focus_lock/data/models/app_info_model.dart';
import 'package:focus_lock/data/models/user_settings_model.dart';
import 'package:focus_lock/data/models/challenge_result_model.dart';
import 'package:focus_lock/services/logger_service.dart';

class StorageService extends GetxService {
  late SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    LoggerService.info('StorageService initialized successfully');
    return this;
  }

  // Settings helpers
  UserSettingsModel getSettings() {
    final data = _prefs.getString(AppConstants.settingsKey);
    if (data != null) {
      return UserSettingsModel.fromMap(jsonDecode(data));
    }
    return UserSettingsModel();
  }

  Future<void> saveSettings(UserSettingsModel settings) async {
    await _prefs.setString(AppConstants.settingsKey, jsonEncode(settings.toMap()));
  }

  // Session helpers
  List<FocusSessionModel> getAllSessions() {
    final dataList = _prefs.getStringList(AppConstants.sessionsBox) ?? [];
    return dataList
        .map((e) => FocusSessionModel.fromMap(jsonDecode(e)))
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  FocusSessionModel? getActiveSession() {
    try {
      return getAllSessions().firstWhere((s) => s.isActive);
    } catch (_) {
      return null;
    }
  }

  Future<void> addSession(FocusSessionModel session) async {
    final sessions = getAllSessions();
    sessions.add(session);
    await _saveSessions(sessions);
  }

  Future<void> updateSession(FocusSessionModel session) async {
    final sessions = getAllSessions();
    final index = sessions.indexWhere((s) => s.id == session.id);
    if (index != -1) {
      sessions[index] = session;
      await _saveSessions(sessions);
    }
  }

  Future<void> _saveSessions(List<FocusSessionModel> sessions) async {
    final dataList = sessions.map((e) => jsonEncode(e.toMap())).toList();
    await _prefs.setStringList(AppConstants.sessionsBox, dataList);
  }

  // App helpers
  List<AppInfoModel> getCachedApps() {
    final dataList = _prefs.getStringList(AppConstants.appsBox) ?? [];
    return dataList
        .map((e) => AppInfoModel.fromMap(jsonDecode(e)))
        .toList()
      ..sort((a, b) => a.appName.compareTo(b.appName));
  }

  Future<void> cacheApps(List<AppInfoModel> apps) async {
    final dataList = apps.map((e) => jsonEncode(e.toMap())).toList();
    await _prefs.setStringList(AppConstants.appsBox, dataList);
  }

  Future<void> updateApp(AppInfoModel app) async {
    final apps = getCachedApps();
    final index = apps.indexWhere((a) => a.packageName == app.packageName);
    if (index != -1) {
      apps[index] = app;
      await cacheApps(apps);
    } else {
      apps.add(app);
      await cacheApps(apps);
    }
  }

  // Challenge helpers
  Future<void> addChallengeResult(ChallengeResultModel result) async {
    final results = getChallengeResults();
    results.add(result);
    final dataList = results.map((e) => jsonEncode(e.toMap())).toList();
    await _prefs.setStringList(AppConstants.challengeBox, dataList);
  }

  List<ChallengeResultModel> getChallengeResults() {
    final dataList = _prefs.getStringList(AppConstants.challengeBox) ?? [];
    return dataList
        .map((e) => ChallengeResultModel.fromMap(jsonDecode(e)))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Cleanup
  Future<void> clearAllData() async {
    await _prefs.remove(AppConstants.sessionsBox);
    await _prefs.remove(AppConstants.settingsKey);
    await _prefs.remove(AppConstants.appsBox);
    await _prefs.remove(AppConstants.challengeBox);
  }
}
