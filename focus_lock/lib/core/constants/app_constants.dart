class AppConstants {
  AppConstants._();

  // Timer
  static const int minTimerMinutes = 1;
  static const int maxTimerMinutes = 180;
  static const int defaultTimerMinutes = 30;
  static const List<int> presetMinutes = [30, 60, 120];

  // Challenge
  static const int typingTestMinWords = 200;
  static const int pollingIntervalMs = 500;

  // Platform Channel
  static const String channelName = 'com.deepfocus.focus_lock/device_lock';
  static const String eventChannelName = 'com.deepfocus.focus_lock/lock_events';
  static const int channelTimeoutSeconds = 5;
  static const int channelRetryCount = 3;

  // Hive Boxes
  static const String sessionsBox = 'focus_sessions';
  static const String settingsBox = 'user_settings';
  static const String appsBox = 'app_info_cache';
  static const String challengeBox = 'challenge_results';

  // Hive Type IDs
  static const int focusSessionTypeId = 0;
  static const int appInfoTypeId = 1;
  static const int userSettingsTypeId = 2;
  static const int challengeResultTypeId = 3;
  static const int challengeTypeEnumId = 4;

  // Settings Keys
  static const String settingsKey = 'user_settings';
  static const String onboardingKey = 'onboarding_complete';

  // Notification
  static const String notificationChannelId = 'focus_lock_channel';
  static const String notificationChannelName = 'Focus Lock';
  static const String notificationChannelDesc = 'Focus session notifications';
  static const int foregroundNotificationId = 888;
  static const int sessionCompleteNotificationId = 889;

  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 350);
  static const Duration slowAnimation = Duration(milliseconds: 600);
  static const Duration pageTransition = Duration(milliseconds: 400);

  // App Info
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
}
