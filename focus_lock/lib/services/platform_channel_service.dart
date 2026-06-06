import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:focus_lock/core/constants/app_constants.dart';
import 'package:focus_lock/data/models/app_info_model.dart';
import 'package:focus_lock/services/logger_service.dart';

class PlatformChannelService extends GetxService {
  static const _channel = MethodChannel(AppConstants.channelName);
  static const _eventChannel = EventChannel(AppConstants.eventChannelName);

  final isMonitoring = false.obs;
  final hasUsageStatsPermission = false.obs;
  final hasOverlayPermission = false.obs;
  final hasCameraPermission = false.obs;

  StreamSubscription? _eventSubscription;

  Future<PlatformChannelService> init() async {
    await checkPermissions();
    LoggerService.info('PlatformChannelService initialized');
    return this;
  }

  // ─── Permission Checks ───────────────────────────────────────────

  Future<void> checkPermissions() async {
    try {
      final result = await _invokeMethod<Map>('checkPermissions');
      if (result != null) {
        hasUsageStatsPermission.value =
            result['usageStats'] as bool? ?? false;
        hasOverlayPermission.value =
            result['overlay'] as bool? ?? false;
        hasCameraPermission.value =
            result['camera'] as bool? ?? false;
      }
    } catch (e) {
      LoggerService.warning('Permission check failed: $e');
    }
  }

  Future<bool> requestUsageStatsPermission() async {
    try {
      final result =
          await _invokeMethod<bool>('requestUsageStatsPermission');
      hasUsageStatsPermission.value = result ?? false;
      return result ?? false;
    } catch (e) {
      LoggerService.error('Usage stats permission request failed: $e');
      return false;
    }
  }

  Future<bool> requestOverlayPermission() async {
    try {
      final result =
          await _invokeMethod<bool>('requestOverlayPermission');
      hasOverlayPermission.value = result ?? false;
      return result ?? false;
    } catch (e) {
      LoggerService.error('Overlay permission request failed: $e');
      return false;
    }
  }

  // ─── App Monitoring ──────────────────────────────────────────────

  Future<void> startMonitoring(
    List<String> blockedPackages,
    int durationMinutes,
  ) async {
    try {
      await _invokeMethod<bool>('startMonitoring', {
        'blockedPackages': blockedPackages,
        'durationMinutes': durationMinutes,
      });
      isMonitoring.value = true;
      _listenToEvents();
      LoggerService.info('Monitoring started');
    } catch (e) {
      LoggerService.error('Start monitoring failed: $e');
      rethrow;
    }
  }

  Future<void> stopMonitoring() async {
    try {
      await _invokeMethod<bool>('stopMonitoring');
      isMonitoring.value = false;
      _eventSubscription?.cancel();
      LoggerService.info('Monitoring stopped');
    } catch (e) {
      LoggerService.error('Stop monitoring failed: $e');
      rethrow;
    }
  }

  // ─── Installed Apps ──────────────────────────────────────────────

  Future<List<AppInfoModel>> getInstalledApps() async {
    try {
      final result =
          await _invokeMethod<List>('getInstalledApps');
      if (result == null) return _getDefaultApps();

      return result.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return AppInfoModel.fromMap(map);
      }).toList();
    } catch (e) {
      LoggerService.warning('Get installed apps failed: $e');
      return _getDefaultApps();
    }
  }

  // ─── Immersive Mode ──────────────────────────────────────────────

  Future<void> enableImmersiveMode() async {
    try {
      await _invokeMethod<bool>('enableImmersiveMode');
    } catch (e) {
      // Fallback: use Flutter's SystemChrome
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  Future<void> disableImmersiveMode() async {
    try {
      await _invokeMethod<bool>('disableImmersiveMode');
    } catch (e) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  // ─── Event Listening ─────────────────────────────────────────────

  void _listenToEvents() {
    _eventSubscription?.cancel();
    _eventSubscription = _eventChannel.receiveBroadcastStream().listen(
      (event) {
        final data = Map<String, dynamic>.from(event as Map);
        final type = data['type'] as String?;

        switch (type) {
          case 'blocked_app_detected':
            final packageName = data['packageName'] as String?;
            LoggerService.info('Blocked app detected: $packageName');
            _onBlockedAppDetected(packageName);
            break;
          case 'session_expired':
            LoggerService.info('Session expired event received');
            break;
        }
      },
      onError: (error) {
        LoggerService.error('Event channel error: $error');
      },
    );
  }

  void _onBlockedAppDetected(String? packageName) {
    // The lock screen controller will handle this via GetX reactive state
    // This is a notification that the app should be brought to front
  }

  // ─── Private Helpers ─────────────────────────────────────────────

  Future<T?> _invokeMethod<T>(String method, [Map<String, dynamic>? args]) async {
    int retries = 0;
    while (retries < AppConstants.channelRetryCount) {
      try {
        final result = await _channel
            .invokeMethod<T>(method, args)
            .timeout(
              Duration(seconds: AppConstants.channelTimeoutSeconds),
            );
        return result;
      } on TimeoutException {
        retries++;
        LoggerService.warning(
          'Channel call "$method" timeout (attempt $retries)',
        );
        if (retries >= AppConstants.channelRetryCount) rethrow;
      } on MissingPluginException {
        LoggerService.warning(
          'Channel method "$method" not implemented on ${Platform.operatingSystem}',
        );
        return null;
      } on PlatformException catch (e) {
        LoggerService.error('Platform error in "$method": ${e.message}');
        return null;
      } catch (e) {
        retries++;
        if (retries >= AppConstants.channelRetryCount) rethrow;
        await Future.delayed(Duration(milliseconds: 500 * retries));
      }
    }
    return null;
  }

  /// Default apps list for platforms where we can't fetch installed apps
  List<AppInfoModel> _getDefaultApps() {
    final defaults = [
      ('Instagram', 'com.instagram.android', 'Social'),
      ('TikTok', 'com.zhiliaoapp.musically', 'Social'),
      ('Facebook', 'com.facebook.katana', 'Social'),
      ('Twitter / X', 'com.twitter.android', 'Social'),
      ('Snapchat', 'com.snapchat.android', 'Social'),
      ('YouTube', 'com.google.android.youtube', 'Entertainment'),
      ('Reddit', 'com.reddit.frontpage', 'Social'),
      ('WhatsApp', 'com.whatsapp', 'Communication'),
      ('Telegram', 'org.telegram.messenger', 'Communication'),
      ('Discord', 'com.discord', 'Communication'),
      ('Netflix', 'com.netflix.mediaclient', 'Entertainment'),
      ('Twitch', 'tv.twitch.android.app', 'Entertainment'),
      ('Spotify', 'com.spotify.music', 'Music'),
      ('Pinterest', 'com.pinterest', 'Social'),
      ('LinkedIn', 'com.linkedin.android', 'Social'),
      ('Messenger', 'com.facebook.orca', 'Communication'),
      ('Chrome', 'com.android.chrome', 'Browser'),
      ('Safari', 'com.apple.mobilesafari', 'Browser'),
      ('Games', 'com.games.generic', 'Games'),
    ];

    return defaults
        .map(
          (d) => AppInfoModel(
            appName: d.$1,
            packageName: d.$2,
            category: d.$3,
          ),
        )
        .toList();
  }

  @override
  void onClose() {
    _eventSubscription?.cancel();
    super.onClose();
  }
}
