import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:focus_lock/core/constants/app_colors.dart';
import 'package:focus_lock/core/constants/app_strings.dart';
import 'package:focus_lock/core/constants/app_constants.dart';
import 'package:focus_lock/core/widgets/animated_gradient_bg.dart';
import 'package:focus_lock/core/widgets/glass_card.dart';
import 'package:focus_lock/presentation/settings/settings_controller.dart';
import 'package:focus_lock/services/platform_channel_service.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _buildChallengeSection(),
                      const SizedBox(height: 20),
                      _buildBarcodeSection(),
                      const SizedBox(height: 20),
                      _buildPermissionsSection(),
                      const SizedBox(height: 20),
                      _buildPreferencesSection(),
                      const SizedBox(height: 20),
                      _buildAboutSection(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textPrimary,
            ),
            onPressed: () => Get.back(),
          ),
          const Text(
            AppStrings.settings,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeSection() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: AppStrings.challengeType,
            icon: Icons.psychology_rounded,
          ),
          const SizedBox(height: 16),
          Obx(() => Row(
                children: [
                  Expanded(
                    child: _ChallengeTypeCard(
                      title: AppStrings.typingTest,
                      icon: Icons.keyboard_rounded,
                      isSelected:
                          controller.settings.value.isTypingChallenge,
                      onTap: () => controller.setChallengeType('typing'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ChallengeTypeCard(
                      title: AppStrings.barcodeScan,
                      icon: Icons.qr_code_scanner_rounded,
                      isSelected:
                          controller.settings.value.isBarcodeChallenge,
                      onTap: () => controller.setChallengeType('barcode'),
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildBarcodeSection() {
    return Obx(() {
      final settings = controller.settings.value;
      return GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle(
              title: AppStrings.savedBarcode,
              icon: Icons.qr_code_rounded,
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    settings.hasSavedBarcode
                        ? Icons.check_circle_rounded
                        : Icons.info_outline_rounded,
                    color: settings.hasSavedBarcode
                        ? AppColors.neonGreen
                        : AppColors.textMuted,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      settings.hasSavedBarcode
                          ? 'Barcode saved: ${settings.savedBarcodeValue ?? "***"}'
                          : AppStrings.barcodeNotSet,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: settings.hasSavedBarcode
                            ? AppColors.textSecondary
                            : AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showBarcodeScanDialog(),
                icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                label: Text(
                  settings.hasSavedBarcode
                      ? AppStrings.scanNewBarcode
                      : AppStrings.scanAndSave,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showBarcodeScanDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Scan Barcode to Save',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: MobileScanner(
                    onDetect: (capture) {
                      final barcodes = capture.barcodes;
                      if (barcodes.isNotEmpty) {
                        final value = barcodes.first.rawValue;
                        if (value != null && value.isNotEmpty) {
                          controller.saveBarcodeHash(value);
                          Get.back();
                          Get.snackbar(
                            '✅ Saved',
                            AppStrings.barcodeSaved,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text(AppStrings.cancel),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionsSection() {
    final platform = Get.find<PlatformChannelService>();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: AppStrings.permissions,
            icon: Icons.security_rounded,
          ),
          const SizedBox(height: 12),
          Obx(() => _PermissionTile(
                title: AppStrings.permissionUsageStats,
                isGranted: platform.hasUsageStatsPermission.value,
                onTap: controller.requestUsageStatsPermission,
              )),
          Obx(() => _PermissionTile(
                title: AppStrings.permissionOverlay,
                isGranted: platform.hasOverlayPermission.value,
                onTap: controller.requestOverlayPermission,
              )),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Preferences',
            icon: Icons.tune_rounded,
          ),
          const SizedBox(height: 12),
          Obx(() => _ToggleTile(
                title: AppStrings.weeklyReport,
                subtitle: AppStrings.weeklyReportDesc,
                value: controller.settings.value.weeklyReportEnabled,
                onChanged: controller.toggleWeeklyReport,
              )),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: AppStrings.about,
            icon: Icons.info_outline_rounded,
          ),
          const SizedBox(height: 12),
          _InfoTile(
            title: AppStrings.appName,
            value:
                '${AppStrings.version} ${AppConstants.appVersion} (${AppConstants.appBuildNumber})',
          ),
          const SizedBox(height: 8),
          const _InfoTile(
            title: 'Developer',
            value: 'Deep Focus Team',
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.neonCyan, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ChallengeTypeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChallengeTypeCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.neonCyan.withValues(alpha: 0.1)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.neonCyan.withValues(alpha: 0.5)
                : AppColors.glassBorder,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.neonCyan : AppColors.textMuted,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? AppColors.neonCyan
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final String title;
  final bool isGranted;
  final VoidCallback onTap;

  const _PermissionTile({
    required this.title,
    required this.isGranted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isGranted ? null : onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(
              isGranted
                  ? Icons.check_circle_rounded
                  : Icons.circle_outlined,
              color: isGranted ? AppColors.neonGreen : AppColors.textMuted,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              isGranted ? AppStrings.granted : AppStrings.notGranted,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: isGranted ? AppColors.neonGreen : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;

  const _InfoTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
