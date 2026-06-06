import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:focus_lock/core/constants/app_colors.dart';
import 'package:focus_lock/core/constants/app_strings.dart';
import 'package:focus_lock/core/widgets/glass_card.dart';
import 'package:focus_lock/data/models/app_info_model.dart';
import 'package:focus_lock/presentation/home/home_controller.dart';

class AppSelectorWidget extends GetView<HomeController> {
  const AppSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(() => Text(
                  '${AppStrings.selectApps} (${controller.selectedAppCount})',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                )),
            Row(
              children: [
                _ActionChip(
                  label: AppStrings.selectAll,
                  onTap: controller.selectAll,
                ),
                const SizedBox(width: 8),
                _ActionChip(
                  label: AppStrings.deselectAll,
                  onTap: controller.deselectAll,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Search
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: TextField(
            onChanged: (v) => controller.searchQuery.value = v,
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
            decoration: const InputDecoration(
              hintText: AppStrings.searchApps,
              prefixIcon: Icon(
                Icons.search_rounded,
                color: AppColors.textMuted,
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // App Grid
        Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(
                  color: AppColors.neonCyan,
                  strokeWidth: 2,
                ),
              ),
            );
          }

          if (controller.filteredApps.isEmpty) {
            return GlassCard(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  controller.searchQuery.isEmpty
                      ? AppStrings.noAppsFound
                      : 'No apps match "${controller.searchQuery.value}"',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: AppColors.textMuted,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return GlassCard(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.85,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: controller.filteredApps.length,
              itemBuilder: (context, index) {
                return _AppTile(app: controller.filteredApps[index]);
              },
            ),
          );
        }),
      ],
    );
  }
}

class _AppTile extends GetView<HomeController> {
  final AppInfoModel app;

  const _AppTile({required this.app});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.toggleApp(app.packageName),
      child: Obx(() {
        // Force rebuild when apps list changes
        controller.apps.length;
        final isSelected = app.isBlocked;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.neonCyan.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.neonCyan.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App icon placeholder
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getCategoryColor(app.category)
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getCategoryIcon(app.category),
                  color: _getCategoryColor(app.category),
                  size: 22,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                app.appName,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }),
    );
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'Social':
        return AppColors.neonPink;
      case 'Entertainment':
        return AppColors.neonPurple;
      case 'Communication':
        return AppColors.neonBlue;
      case 'Games':
        return AppColors.neonOrange;
      case 'Browser':
        return AppColors.neonGreen;
      case 'Music':
        return AppColors.neonCyan;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'Social':
        return Icons.people_rounded;
      case 'Entertainment':
        return Icons.movie_rounded;
      case 'Communication':
        return Icons.chat_bubble_rounded;
      case 'Games':
        return Icons.sports_esports_rounded;
      case 'Browser':
        return Icons.language_rounded;
      case 'Music':
        return Icons.music_note_rounded;
      default:
        return Icons.apps_rounded;
    }
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ActionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.glassBorder,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
