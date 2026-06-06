import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:focus_lock/app.dart';
import 'package:focus_lock/data/local/storage_service.dart';
import 'package:focus_lock/services/platform_channel_service.dart';
import 'package:focus_lock/services/lock_service.dart';
import 'package:focus_lock/services/notification_service.dart';
import 'package:focus_lock/services/license_manager.dart';
import 'package:focus_lock/services/logger_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));

  LoggerService.info('App starting...');

  // Initialize services
  await _initServices();

  LoggerService.info('All services initialized. Launching app.');

  runApp(const FocusLockApp());
}

Future<void> _initServices() async {
  // Storage (must be first — other services depend on it)
  await Get.putAsync(() => StorageService().init());

  // Platform channels
  await Get.putAsync(() => PlatformChannelService().init());

  // Notifications
  await NotificationService.init();

  // License manager
  await Get.putAsync(() => LicenseManager().init());

  // Lock service (must be last — depends on others)
  await Get.putAsync(() => LockService().init());
}
