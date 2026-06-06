import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:focus_lock/core/constants/app_colors.dart';
import 'package:focus_lock/core/constants/app_strings.dart';
import 'package:focus_lock/core/widgets/neon_button.dart';
import 'package:focus_lock/domain/usecases/validate_challenge.dart';
import 'package:focus_lock/presentation/challenge/challenge_controller.dart';

class TypingChallengeView extends GetView<ChallengeController> {
  const TypingChallengeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Stats row
          _buildStatsRow(),
          const SizedBox(height: 12),

          // Expected text with highlighting
          Expanded(
            flex: 3,
            child: _buildExpectedText(),
          ),
          const SizedBox(height: 12),

          // Text input
          Expanded(
            flex: 2,
            child: _buildTextInput(),
          ),
          const SizedBox(height: 12),

          // Submit button
          Obx(() => NeonButton(
                text: AppStrings.submit,
                onPressed: controller.submitTypingChallenge,
                enabled: controller.typedText.value.length >=
                    controller.expectedText.length,
                isLoading: controller.isProcessing.value,
                gradient: AppColors.successGradient,
                icon: Icons.check_rounded,
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Obx(() {
      final statuses = controller.characterStatuses;
      final correct =
          statuses.where((s) => s == CharacterStatus.correct).length;
      final total = controller.expectedText.length;
      final accuracy =
          total > 0 && correct > 0 ? (correct / total * 100).toStringAsFixed(0) : '0';

      return Row(
        children: [
          _StatChip(
            icon: Icons.text_fields_rounded,
            label:
                '${controller.typedWordCount}/${controller.expectedWordCount} words',
          ),
          const SizedBox(width: 8),
          _StatChip(
            icon: Icons.check_circle_outline_rounded,
            label: '$accuracy% ${AppStrings.accuracy}',
            color: _getAccuracyColor(double.tryParse(accuracy) ?? 0),
          ),
        ],
      );
    });
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 95) return AppColors.neonGreen;
    if (accuracy >= 80) return AppColors.neonCyan;
    if (accuracy >= 50) return AppColors.neonOrange;
    return AppColors.error;
  }

  Widget _buildExpectedText() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Obx(() {
        final text = controller.expectedText;
        final statuses = controller.characterStatuses;

        return SingleChildScrollView(
          child: RichText(
            text: TextSpan(
              children: List.generate(text.length, (i) {
                Color color;
                Color? bgColor;

                if (i >= statuses.length) {
                  color = AppColors.textMuted;
                  bgColor = null;
                } else {
                  switch (statuses[i]) {
                    case CharacterStatus.correct:
                      color = AppColors.neonGreen;
                      bgColor = null;
                      break;
                    case CharacterStatus.incorrect:
                      color = Colors.white;
                      bgColor = AppColors.error.withValues(alpha: 0.6);
                      break;
                    case CharacterStatus.pending:
                      color = AppColors.textMuted;
                      bgColor = null;
                      break;
                  }
                }

                return TextSpan(
                  text: text[i],
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: color,
                    backgroundColor: bgColor,
                    height: 1.8,
                    letterSpacing: 0.3,
                  ),
                );
              }),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTextInput() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.3)),
      ),
      child: TextField(
        onChanged: controller.onTypedTextChanged,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        // Disable paste
        contextMenuBuilder: (context, editableTextState) {
          // Return empty to disable context menu (copy/paste)
          return const SizedBox.shrink();
        },
        enableInteractiveSelection: false,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: AppColors.textPrimary,
          height: 1.8,
        ),
        decoration: const InputDecoration(
          hintText: 'Start typing the paragraph above...',
          hintStyle: TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.textMuted,
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(12),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    this.color = AppColors.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
