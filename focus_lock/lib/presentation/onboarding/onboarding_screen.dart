import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:focus_lock/core/constants/app_colors.dart';
import 'package:focus_lock/core/constants/app_strings.dart';
import 'package:focus_lock/core/widgets/animated_gradient_bg.dart';
import 'package:focus_lock/core/widgets/neon_button.dart';
import 'package:focus_lock/presentation/onboarding/onboarding_controller.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pageController = PageController();

    ever(controller.currentPage, (page) {
      pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });

    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextButton(
                    onPressed: controller.skipOnboarding,
                    child: const Text(
                      AppStrings.skip,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontFamily: 'Poppins',
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),

              // Pages
              Expanded(
                child: PageView(
                  controller: pageController,
                  onPageChanged: controller.setPage,
                  children: const [
                    _OnboardingPage(
                      icon: Icons.lock_outline_rounded,
                      iconColor: AppColors.neonCyan,
                      title: AppStrings.onboardingTitle1,
                      description: AppStrings.onboardingDesc1,
                    ),
                    _OnboardingPage(
                      icon: Icons.psychology_outlined,
                      iconColor: AppColors.neonPurple,
                      title: AppStrings.onboardingTitle2,
                      description: AppStrings.onboardingDesc2,
                    ),
                    _OnboardingPage(
                      icon: Icons.trending_up_rounded,
                      iconColor: AppColors.neonGreen,
                      title: AppStrings.onboardingTitle3,
                      description: AppStrings.onboardingDesc3,
                    ),
                  ],
                ),
              ),

              // Page indicator
              Obx(() => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: controller.currentPage.value == index
                              ? 32
                              : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: controller.currentPage.value == index
                                ? AppColors.neonCyan
                                : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  )),

              // Button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: Obx(() => NeonButton(
                      text: controller.currentPage.value < 2
                          ? AppStrings.next
                          : AppStrings.getStarted,
                      onPressed: controller.nextPage,
                      icon: controller.currentPage.value < 2
                          ? Icons.arrow_forward_rounded
                          : Icons.rocket_launch_rounded,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const _OnboardingPage({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  @override
  State<_OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<_OnboardingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon container with glow
              Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.iconColor.withValues(alpha: 0.1),
                    boxShadow: [
                      BoxShadow(
                        color: widget.iconColor.withValues(alpha: 0.3),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                    border: Border.all(
                      color: widget.iconColor.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    widget.icon,
                    size: 64,
                    color: widget.iconColor,
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Title
              Opacity(
                opacity: _fadeAnimation.value,
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 16),

              // Description
              Opacity(
                opacity: _fadeAnimation.value,
                child: Text(
                  widget.description,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
