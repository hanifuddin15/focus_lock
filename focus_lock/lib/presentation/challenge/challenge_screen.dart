import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:focus_lock/core/constants/app_colors.dart';
import 'package:focus_lock/core/constants/app_strings.dart';
import 'package:focus_lock/core/widgets/neon_button.dart';
import 'package:focus_lock/presentation/challenge/challenge_controller.dart';
import 'package:focus_lock/presentation/challenge/barcode_challenge_view.dart';
import 'package:focus_lock/presentation/challenge/typing_challenge_view.dart';

class ChallengeScreen extends GetView<ChallengeController> {
  const ChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: Obx(() {
                  // Show success/failure overlay
                  if (controller.challengeStatus.value == 'success') {
                    return _buildStatusOverlay(
                      icon: Icons.check_circle_rounded,
                      color: AppColors.neonGreen,
                      text: controller.challengeType.value == 'barcode'
                          ? AppStrings.barcodeMatched
                          : AppStrings.typingSuccess,
                    );
                  }
                  if (controller.challengeStatus.value == 'failed') {
                    return _buildStatusOverlay(
                      icon: Icons.cancel_rounded,
                      color: AppColors.error,
                      text: controller.challengeType.value == 'barcode'
                          ? AppStrings.barcodeNotMatched
                          : AppStrings.typingFailed,
                    );
                  }

                  // Show challenge
                  if (controller.challengeType.value == 'barcode') {
                    return const BarcodeChallengeView();
                  }
                  return const TypingChallengeView();
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              NeonOutlineButton(
                text: AppStrings.goBack,
                onPressed: controller.goBack,
                color: AppColors.textMuted,
                icon: Icons.arrow_back_rounded,
                height: 40,
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.neonPink.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.neonPink.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.neonPink,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Break Lock',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neonPink,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            AppStrings.challengeTitle,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => Text(
                controller.challengeType.value == 'barcode'
                    ? AppStrings.barcodeChallengeDesc
                    : AppStrings.typingChallengeDesc,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              )),
        ],
      ),
    );
  }

  Widget _buildStatusOverlay({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.15),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: color, size: 64),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
