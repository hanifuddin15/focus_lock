import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:focus_lock/core/constants/app_colors.dart';
import 'package:focus_lock/core/constants/app_strings.dart';
import 'package:focus_lock/core/widgets/animated_gradient_bg.dart';
import 'package:focus_lock/core/widgets/neon_button.dart';
import 'package:focus_lock/presentation/home/home_controller.dart';
import 'package:focus_lock/presentation/home/widgets/timer_dial_widget.dart';
import 'package:focus_lock/presentation/home/widgets/app_selector_widget.dart';
import 'package:focus_lock/presentation/home/widgets/preset_buttons.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              _buildAppBar(),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      // Timer Dial
                      const TimerDialWidget(),
                      const SizedBox(height: 20),

                      // Preset Buttons
                      const PresetButtons(),
                      const SizedBox(height: 28),

                      // App Selector
                      const AppSelectorWidget(),
                      const SizedBox(height: 24),

                      // Start Button
                      _buildStartButton(),
                      const SizedBox(height: 32),
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
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.appName,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                AppStrings.appTagline,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.neonCyan,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _AppBarIcon(
                icon: Icons.bar_chart_rounded,
                onTap: controller.goToStatistics,
              ),
              _AppBarIcon(
                icon: Icons.settings_rounded,
                onTap: controller.goToSettings,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return Obx(() => NeonButton(
          text: AppStrings.startFocusLock,
          onPressed: controller.startFocusLock,
          enabled: controller.selectedAppCount > 0,
          icon: Icons.lock_rounded,
          gradient: controller.selectedAppCount > 0
              ? AppColors.primaryGradient
              : null,
        ));
  }
}

class _AppBarIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _AppBarIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            color: AppColors.textSecondary,
            size: 24,
          ),
        ),
      ),
    );
  }
}
