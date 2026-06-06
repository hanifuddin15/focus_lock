import 'package:get/get.dart';
import 'package:focus_lock/routes/app_routes.dart';
import 'package:focus_lock/presentation/onboarding/onboarding_screen.dart';
import 'package:focus_lock/presentation/onboarding/onboarding_controller.dart';
import 'package:focus_lock/presentation/home/home_screen.dart';
import 'package:focus_lock/presentation/home/home_controller.dart';
import 'package:focus_lock/presentation/lock/lock_screen.dart';
import 'package:focus_lock/presentation/lock/lock_controller.dart';
import 'package:focus_lock/presentation/challenge/challenge_screen.dart';
import 'package:focus_lock/presentation/challenge/challenge_controller.dart';
import 'package:focus_lock/presentation/statistics/statistics_screen.dart';
import 'package:focus_lock/presentation/statistics/statistics_controller.dart';
import 'package:focus_lock/presentation/settings/settings_screen.dart';
import 'package:focus_lock/presentation/settings/settings_controller.dart';

class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => OnboardingController());
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => HomeController());
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.lock,
      page: () => const LockScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => LockController());
      }),
      transition: Transition.fadeIn,
      fullscreenDialog: true,
    ),
    GetPage(
      name: AppRoutes.challenge,
      page: () => const ChallengeScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ChallengeController());
      }),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.statistics,
      page: () => const StatisticsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => StatisticsController());
      }),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => SettingsController());
      }),
      transition: Transition.rightToLeft,
    ),
  ];
}
