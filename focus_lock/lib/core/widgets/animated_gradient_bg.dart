import 'dart:math';
import 'package:flutter/material.dart';
import 'package:focus_lock/core/constants/app_colors.dart';

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  final List<Color>? colors;

  const AnimatedGradientBackground({
    super.key,
    required this.child,
    this.colors,
  });

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
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
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(
                    sin(_controller.value * 2 * pi),
                    cos(_controller.value * 2 * pi),
                  ),
                  end: Alignment(
                    cos(_controller.value * 2 * pi + 1),
                    sin(_controller.value * 2 * pi + 1),
                  ),
                  colors: widget.colors ??
                      const [
                        AppColors.background,
                        Color(0xFF0F1429),
                        Color(0xFF130A2E),
                        AppColors.background,
                      ],
                ),
              ),
            ),
            // Floating orbs
            ..._buildOrbs(),
            child!,
          ],
        );
      },
      child: widget.child,
    );
  }

  List<Widget> _buildOrbs() {
    return [
      _AnimatedOrb(
        controller: _controller,
        color: AppColors.neonCyan.withValues(alpha: 0.06),
        size: 300,
        offsetMultiplier: 1.0,
        top: -50,
        right: -80,
      ),
      _AnimatedOrb(
        controller: _controller,
        color: AppColors.neonPurple.withValues(alpha: 0.05),
        size: 250,
        offsetMultiplier: 1.5,
        bottom: 100,
        left: -60,
      ),
      _AnimatedOrb(
        controller: _controller,
        color: AppColors.neonPink.withValues(alpha: 0.04),
        size: 200,
        offsetMultiplier: 0.8,
        top: 300,
        right: -40,
      ),
    ];
  }
}

class _AnimatedOrb extends StatelessWidget {
  final AnimationController controller;
  final Color color;
  final double size;
  final double offsetMultiplier;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  const _AnimatedOrb({
    required this.controller,
    required this.color,
    required this.size,
    required this.offsetMultiplier,
    this.top,
    this.bottom,
    this.left,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final offset = sin(controller.value * 2 * pi * offsetMultiplier) * 20;
        return Positioned(
          top: top != null ? top! + offset : null,
          bottom: bottom != null ? bottom! - offset : null,
          left: left != null ? left! + offset * 0.5 : null,
          right: right != null ? right! - offset * 0.5 : null,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color,
                  color.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
