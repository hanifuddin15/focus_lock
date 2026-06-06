import 'package:get/get.dart';
import 'package:focus_lock/data/repositories/settings_repository.dart';
import 'package:focus_lock/routes/app_routes.dart';

class OnboardingController extends GetxController {
  final currentPage = 0.obs;
  final SettingsRepository _settingsRepo = SettingsRepository();

  void nextPage() {
    if (currentPage.value < 2) {
      currentPage.value++;
    } else {
      completeOnboarding();
    }
  }

  void skipOnboarding() {
    completeOnboarding();
  }

  void setPage(int page) {
    currentPage.value = page;
  }

  void completeOnboarding() {
    _settingsRepo.setOnboardingComplete();
    Get.offAllNamed(AppRoutes.home);
  }
}
