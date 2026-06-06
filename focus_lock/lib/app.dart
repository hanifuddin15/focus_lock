import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:focus_lock/core/theme/app_theme.dart';
import 'package:focus_lock/core/constants/app_strings.dart';
import 'package:focus_lock/routes/app_routes.dart';
import 'package:focus_lock/routes/app_pages.dart';
import 'package:focus_lock/data/repositories/settings_repository.dart';

class FocusLockApp extends StatelessWidget {
  const FocusLockApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsRepo = SettingsRepository();
    final isOnboarded = settingsRepo.isOnboardingDone();

    return GetMaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: isOnboarded ? AppRoutes.home : AppRoutes.onboarding,
      getPages: AppPages.pages,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
