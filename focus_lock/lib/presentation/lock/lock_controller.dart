import 'package:get/get.dart';
import 'package:focus_lock/services/lock_service.dart';
import 'package:focus_lock/services/platform_channel_service.dart';
import 'package:focus_lock/routes/app_routes.dart';
import 'package:focus_lock/core/utils/extensions.dart';

class LockController extends GetxController {
  final LockService _lockService = Get.find<LockService>();
  final PlatformChannelService _platform = Get.find<PlatformChannelService>();

  int get remainingSeconds => _lockService.remainingSeconds.value;
  bool get isLocked => _lockService.isLocked.value;

  String get timeDisplay {
    final duration = Duration(seconds: remainingSeconds);
    if (duration.inHours > 0) {
      return duration.toHHMMSS();
    }
    return duration.toMMSS();
  }

  double get progress {
    final session = _lockService.activeSession.value;
    if (session == null) return 0;
    return session.progressPercent;
  }

  @override
  void onInit() {
    super.onInit();
    _platform.enableImmersiveMode();

    // Watch for session end
    ever(_lockService.isLocked, (locked) {
      if (!locked) {
        _platform.disableImmersiveMode();
        if (Get.currentRoute == AppRoutes.lock) {
          Get.offAllNamed(AppRoutes.home);
        }
      }
    });
  }

  void requestEarlyBreak() {
    _lockService.incrementBreakAttempt();
    Get.toNamed(AppRoutes.challenge);
  }

  void onChallengeComplete() {
    _lockService.endSession(completedFully: false);
  }

  @override
  void onClose() {
    _platform.disableImmersiveMode();
    super.onClose();
  }
}
