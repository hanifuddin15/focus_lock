import 'package:get/get.dart';
import 'package:focus_lock/data/repositories/settings_repository.dart';
import 'package:focus_lock/domain/usecases/validate_challenge.dart';
import 'package:focus_lock/services/lock_service.dart';
import 'package:focus_lock/core/constants/app_strings.dart';
import 'package:focus_lock/core/utils/haptic_utils.dart';
import 'package:focus_lock/routes/app_routes.dart';
import 'package:focus_lock/services/logger_service.dart';

class ChallengeController extends GetxController {
  final SettingsRepository _settingsRepo = SettingsRepository();
  final ValidateChallenge _validator = ValidateChallenge();
  final LockService _lockService = Get.find<LockService>();

  // State
  final challengeType = 'typing'.obs;
  final typedText = ''.obs;
  final characterStatuses = <CharacterStatus>[].obs;
  final isScanning = false.obs;
  final scanResult = ''.obs;
  final challengeStatus = ''.obs; // 'success', 'failed', ''
  final isProcessing = false.obs;

  String get expectedText => AppStrings.typingParagraph;
  int get typedWordCount => typedText.value.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  int get expectedWordCount => expectedText.trim().split(RegExp(r'\s+')).length;

  @override
  void onInit() {
    super.onInit();
    final settings = _settingsRepo.getSettings();
    challengeType.value = settings.challengeType;

    // If barcode challenge selected but no barcode saved, fall back to typing
    if (settings.isBarcodeChallenge && !settings.hasSavedBarcode) {
      challengeType.value = 'typing';
      LoggerService.warning('No barcode saved, falling back to typing challenge');
    }
  }

  // ─── Typing Challenge ────────────────────────────────────────────

  void onTypedTextChanged(String text) {
    typedText.value = text;
    characterStatuses.value = _validator.getCharacterStatuses(text, expectedText);
  }

  void submitTypingChallenge() {
    if (isProcessing.value) return;
    isProcessing.value = true;

    final result = _validator.validateTyping(typedText.value, expectedText);

    if (result.isCorrect) {
      challengeStatus.value = 'success';
      HapticUtils.success();
      Future.delayed(const Duration(seconds: 2), () {
        _lockService.endSession(completedFully: false);
        Get.offAllNamed(AppRoutes.home);
        Get.snackbar(
          'Lock Released',
          'Challenge completed. Session ended early.',
          snackPosition: SnackPosition.TOP,
        );
      });
    } else {
      challengeStatus.value = 'failed';
      HapticUtils.error();
      Future.delayed(const Duration(seconds: 2), () {
        challengeStatus.value = '';
        isProcessing.value = false;
        typedText.value = '';
        characterStatuses.clear();
      });
    }
  }

  // ─── Barcode Challenge ───────────────────────────────────────────

  void onBarcodeScanned(String value) {
    if (isProcessing.value) return;
    isProcessing.value = true;
    scanResult.value = value;

    final matches = _validator.validateBarcode(value);

    if (matches) {
      challengeStatus.value = 'success';
      HapticUtils.success();
      Future.delayed(const Duration(seconds: 2), () {
        _lockService.endSession(completedFully: false);
        Get.offAllNamed(AppRoutes.home);
        Get.snackbar(
          'Lock Released',
          'Barcode matched! Session ended early.',
          snackPosition: SnackPosition.TOP,
        );
      });
    } else {
      challengeStatus.value = 'failed';
      HapticUtils.error();
      Future.delayed(const Duration(seconds: 3), () {
        challengeStatus.value = '';
        isProcessing.value = false;
        scanResult.value = '';
      });
    }
  }

  void goBack() {
    Get.back();
  }
}
