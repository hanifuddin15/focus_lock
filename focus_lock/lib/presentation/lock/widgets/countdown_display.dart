import 'package:flutter/material.dart';
import 'package:focus_lock/core/constants/app_colors.dart';
import 'package:focus_lock/core/widgets/circular_timer.dart';

class CountdownDisplay extends StatefulWidget {
  final double progress;
  final String timeText;

  const CountdownDisplay({
    super.key,
    required this.progress,
    required this.timeText,
  });

  @override
  State<CountdownDisplay> createState() => _CountdownDisplayState();
}

class _CountdownDisplayState extends State<CountdownDisplay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breathController;
  late final Animation<double> _breathAnimation;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    _breathAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _breathAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _breathAnimation.value,
          child: CircularTimer(
            progress: widget.progress,
            centerText: widget.timeText,
            subText: 'remaining',
            size: 280,
            strokeWidth: 12,
            progressColor: _getProgressColor(widget.progress),
          ),
        );
      },
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.5) return AppColors.neonCyan;
    if (progress < 0.75) return AppColors.neonGreen;
    if (progress < 0.9) return AppColors.neonOrange;
    return AppColors.neonPink;
  }
}
