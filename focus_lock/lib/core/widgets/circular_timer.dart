import 'dart:math';
import 'package:flutter/material.dart';
import 'package:focus_lock/core/constants/app_colors.dart';

class CircularTimer extends StatelessWidget {
  final double progress;
  final String centerText;
  final String? subText;
  final double size;
  final double strokeWidth;
  final Color? progressColor;
  final Color? trackColor;
  final bool showGlow;
  final bool animated;

  const CircularTimer({
    super.key,
    required this.progress,
    required this.centerText,
    this.subText,
    this.size = 220,
    this.strokeWidth = 10,
    this.progressColor,
    this.trackColor,
    this.showGlow = true,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow effect
          if (showGlow && progress > 0)
            Container(
              width: size * 0.85,
              height: size * 0.85,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (progressColor ?? AppColors.neonCyan)
                        .withValues(alpha: 0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
          // Custom painted timer
          CustomPaint(
            size: Size(size, size),
            painter: _CircularTimerPainter(
              progress: animated ? progress : progress,
              strokeWidth: strokeWidth,
              progressColor: progressColor ?? AppColors.neonCyan,
              trackColor: trackColor ?? AppColors.surfaceLight,
              showGlow: showGlow,
            ),
          ),
          // Center content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                centerText,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: size * 0.16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 2,
                ),
              ),
              if (subText != null) ...[
                const SizedBox(height: 4),
                Text(
                  subText!,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: size * 0.06,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _CircularTimerPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color progressColor;
  final Color trackColor;
  final bool showGlow;

  _CircularTimerPainter({
    required this.progress,
    required this.strokeWidth,
    required this.progressColor,
    required this.trackColor,
    required this.showGlow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress.clamp(0.0, 1.0);

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Tick marks
    final tickPaint = Paint()
      ..color = trackColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < 60; i++) {
      final angle = startAngle + (2 * pi * i / 60);
      final isMainTick = i % 5 == 0;
      final innerRadius = radius - (isMainTick ? 15 : 8);
      final outerRadius = radius - 4;

      canvas.drawLine(
        Offset(
          center.dx + innerRadius * cos(angle),
          center.dy + innerRadius * sin(angle),
        ),
        Offset(
          center.dx + outerRadius * cos(angle),
          center.dy + outerRadius * sin(angle),
        ),
        tickPaint..strokeWidth = isMainTick ? 2 : 1,
      );
    }

    if (progress <= 0) return;

    // Progress arc with gradient
    final rect = Rect.fromCircle(center: center, radius: radius);
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: [
          progressColor.withValues(alpha: 0.6),
          progressColor,
        ],
        stops: const [0.0, 1.0],
        transform: GradientRotation(startAngle),
      ).createShader(rect);

    canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);

    // End dot
    if (progress > 0 && progress < 1) {
      final endAngle = startAngle + sweepAngle;
      final dotCenter = Offset(
        center.dx + radius * cos(endAngle),
        center.dy + radius * sin(endAngle),
      );

      // Glow
      if (showGlow) {
        final glowPaint = Paint()
          ..color = progressColor.withValues(alpha: 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(dotCenter, strokeWidth * 0.8, glowPaint);
      }

      // Dot
      final dotPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(dotCenter, strokeWidth * 0.6, dotPaint);

      // Inner dot
      final innerDotPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(dotCenter, strokeWidth * 0.25, innerDotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CircularTimerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor;
  }
}

class InteractiveTimerDial extends StatefulWidget {
  final int currentMinutes;
  final int minMinutes;
  final int maxMinutes;
  final ValueChanged<int> onChanged;
  final double size;

  const InteractiveTimerDial({
    super.key,
    required this.currentMinutes,
    this.minMinutes = 1,
    this.maxMinutes = 180,
    required this.onChanged,
    this.size = 260,
  });

  @override
  State<InteractiveTimerDial> createState() => _InteractiveTimerDialState();
}

class _InteractiveTimerDialState extends State<InteractiveTimerDial> {
  late int _currentMinutes;

  @override
  void initState() {
    super.initState();
    _currentMinutes = widget.currentMinutes;
  }

  @override
  void didUpdateWidget(InteractiveTimerDial oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentMinutes != widget.currentMinutes) {
      _currentMinutes = widget.currentMinutes;
    }
  }

  void _handlePanUpdate(DragUpdateDetails details, Offset center) {
    final angle = atan2(
      details.localPosition.dy - center.dy,
      details.localPosition.dx - center.dx,
    );

    // Convert angle to 0-1 range (starting from top)
    double normalized = (angle + pi / 2) / (2 * pi);
    if (normalized < 0) normalized += 1;

    // Map to minutes
    final minutes = (normalized * widget.maxMinutes)
        .round()
        .clamp(widget.minMinutes, widget.maxMinutes);

    if (minutes != _currentMinutes) {
      setState(() => _currentMinutes = minutes);
      widget.onChanged(minutes);
    }
  }

  String get _displayText {
    if (_currentMinutes >= 60) {
      final hours = _currentMinutes ~/ 60;
      final mins = _currentMinutes % 60;
      return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
    }
    return '${_currentMinutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _currentMinutes / widget.maxMinutes;

    return GestureDetector(
      onPanUpdate: (details) {
        _handlePanUpdate(
          details,
          Offset(widget.size / 2, widget.size / 2),
        );
      },
      child: CircularTimer(
        progress: progress,
        centerText: _displayText,
        subText: 'drag to adjust',
        size: widget.size,
        strokeWidth: 12,
      ),
    );
  }
}
