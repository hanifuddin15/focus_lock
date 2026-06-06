import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:focus_lock/core/constants/app_constants.dart';
import 'package:focus_lock/services/logger_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);
    _initialized = true;
    LoggerService.info('NotificationService initialized');
  }

  static Future<void> showSessionStarted(int durationMinutes) async {
    await _showNotification(
      id: AppConstants.foregroundNotificationId,
      title: '🔒 Focus Lock Active',
      body:
          'Stay focused for $durationMinutes minutes. You\'ve got this!',
      ongoing: true,
    );
  }

  static Future<void> showSessionCompleted() async {
    await _cancelNotification(AppConstants.foregroundNotificationId);
    await _showNotification(
      id: AppConstants.sessionCompleteNotificationId,
      title: '🎉 Session Complete!',
      body: 'Great work! You stayed focused.',
    );
  }

  static Future<void> showHalfwayMark(int remainingMinutes) async {
    await _showNotification(
      id: AppConstants.sessionCompleteNotificationId + 1,
      title: '⏳ Halfway There!',
      body: '$remainingMinutes minutes remaining. Keep going!',
    );
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  static Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    bool ongoing = false,
  }) async {
    try {
      await init();

      final androidDetails = AndroidNotificationDetails(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        channelDescription: AppConstants.notificationChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
        ongoing: ongoing,
        autoCancel: !ongoing,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _plugin.show(id, title, body, details);
    } catch (e) {
      LoggerService.error('Failed to show notification: $e');
    }
  }

  static Future<void> _cancelNotification(int id) async {
    await _plugin.cancel(id);
  }
}
