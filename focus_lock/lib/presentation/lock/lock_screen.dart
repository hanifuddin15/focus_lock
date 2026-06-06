import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:focus_lock/core/constants/app_colors.dart';
import 'package:focus_lock/core/constants/app_strings.dart';
import 'package:focus_lock/core/widgets/circular_timer.dart';
import 'package:focus_lock/core/widgets/neon_button.dart';
import 'package:focus_lock/presentation/lock/lock_controller.dart';
import 'package:focus_lock/presentation/lock/widgets/countdown_display.dart';
import 'package:focus_lock/services/lock_service.dart';

class LockScreen extends GetView<LockController> {
  const LockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppColors.lockGradient,
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Focus Mode label
                _buildFocusModeLabel(),
                const SizedBox(height: 20),

                // Timer
                Expanded(
                  child: Center(
                    child: _buildTimerSection(),
                  ),
                ),

                // Early break button
                _buildEarlyBreakButton(),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFocusModeLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.neonCyan.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.neonCyan.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.neonCyan,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonCyan.withValues(alpha: 0.5),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            AppStrings.focusMode,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.neonCyan,
              letterSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerSection() {
    final lockService = Get.find<LockService>();

    return Obx(() {
      final remaining = lockService.remainingSeconds.value;
      final duration = Duration(seconds: remaining);
      final session = lockService.activeSession.value;
      final total = session != null ? session.durationMinutes * 60 : 1;
      final progress = 1.0 - (remaining / total).clamp(0.0, 1.0);

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated timer
          CountdownDisplay(
            progress: progress,
            timeText: controller.timeDisplay,
          ),
          const SizedBox(height: 32),

          // Motivational text
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Text(
              _getMotivationalText(remaining),
              key: ValueKey<String>(_getMotivationalText(remaining)),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildEarlyBreakButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: NeonOutlineButton(
        text: AppStrings.earlyBreakLock,
        onPressed: controller.requestEarlyBreak,
        color: AppColors.neonPink,
        icon: Icons.lock_open_rounded,
      ),
    );
  }

  String _getMotivationalText(int remainingSeconds) {
    if (remainingSeconds > 3600) return 'Deep work in progress...';
    if (remainingSeconds > 1800) return 'Stay focused, you\'re doing great!';
    if (remainingSeconds > 600) return 'More than halfway there! 💪';
    if (remainingSeconds > 120) return 'Almost done, keep going!';
    if (remainingSeconds > 0) return 'Final stretch! 🎯';
    return AppStrings.sessionComplete;
  }
}
