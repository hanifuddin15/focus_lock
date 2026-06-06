import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:focus_lock/core/constants/app_colors.dart';
import 'package:focus_lock/core/constants/app_constants.dart';
import 'package:focus_lock/core/constants/app_strings.dart';
import 'package:focus_lock/core/utils/haptic_utils.dart';
import 'package:focus_lock/presentation/home/home_controller.dart';

class PresetButtons extends GetView<HomeController> {
  const PresetButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...AppConstants.presetMinutes.map(
              (minutes) => _PresetChip(
                label: _formatMinutes(minutes),
                isSelected: controller.selectedMinutes.value == minutes,
                onTap: () {
                  HapticUtils.selection();
                  controller.setPresetDuration(minutes);
                },
              ),
            ),
            _PresetChip(
              label: AppStrings.custom,
              isSelected: !AppConstants.presetMinutes
                  .contains(controller.selectedMinutes.value),
              onTap: () => _showCustomPicker(context),
              icon: Icons.tune_rounded,
            ),
          ],
        ));
  }

  String _formatMinutes(int minutes) {
    if (minutes >= 60) {
      return '${minutes ~/ 60}${AppStrings.hours}';
    }
    return '$minutes${AppStrings.minutes}';
  }

  void _showCustomPicker(BuildContext context) {
    int tempValue = controller.selectedMinutes.value;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textMuted,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Custom Duration',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _formatMinutes(tempValue),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neonCyan,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppColors.neonCyan,
                      inactiveTrackColor: AppColors.surfaceLight,
                      thumbColor: AppColors.neonCyan,
                      overlayColor: AppColors.neonCyan.withValues(alpha: 0.2),
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8,
                      ),
                    ),
                    child: Slider(
                      value: tempValue.toDouble(),
                      min: AppConstants.minTimerMinutes.toDouble(),
                      max: AppConstants.maxTimerMinutes.toDouble(),
                      divisions: AppConstants.maxTimerMinutes - 1,
                      onChanged: (v) {
                        setState(() => tempValue = v.round());
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${AppConstants.minTimerMinutes}m',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${AppConstants.maxTimerMinutes}m',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        controller.setDuration(tempValue);
                        Navigator.pop(context);
                      },
                      child: const Text('Set Duration'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const _PresetChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.neonCyan.withValues(alpha: 0.15)
                : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.neonCyan.withValues(alpha: 0.5)
                  : AppColors.glassBorder,
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.neonCyan.withValues(alpha: 0.15),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: isSelected
                      ? AppColors.neonCyan
                      : AppColors.textMuted,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppColors.neonCyan
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
