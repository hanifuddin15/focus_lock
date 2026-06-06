import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:focus_lock/core/constants/app_colors.dart';
import 'package:focus_lock/core/constants/app_strings.dart';
import 'package:focus_lock/presentation/challenge/challenge_controller.dart';

class BarcodeChallengeView extends GetView<ChallengeController> {
  const BarcodeChallengeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Camera preview
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  MobileScanner(
                    onDetect: (capture) {
                      final barcodes = capture.barcodes;
                      if (barcodes.isNotEmpty) {
                        final value = barcodes.first.rawValue;
                        if (value != null && value.isNotEmpty) {
                          controller.onBarcodeScanned(value);
                        }
                      }
                    },
                  ),

                  // Scan overlay
                  _buildScanOverlay(),

                  // Scan hint
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          AppStrings.scanBarcode,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Status
          Obx(() {
            if (controller.scanResult.value.isNotEmpty) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.qr_code_scanner_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Scanned: ${controller.scanResult.value}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildScanOverlay() {
    return CustomPaint(
      painter: _ScanOverlayPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scanAreaSize = size.width * 0.7;
    final left = (size.width - scanAreaSize) / 2;
    final top = (size.height - scanAreaSize) / 2;
    final scanRect = Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize);

    // Dim overlay outside scan area
    final bgPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final scanPath = Path()..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(20)));
    final overlayPath = Path.combine(PathOperation.difference, bgPath, scanPath);

    canvas.drawPath(
      overlayPath,
      Paint()..color = const Color(0x88000000),
    );

    // Corner markers
    final cornerLength = 30.0;
    final cornerPaint = Paint()
      ..color = AppColors.neonCyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Top-left
    canvas.drawLine(
      Offset(left, top + 20), Offset(left, top + 20 + cornerLength), cornerPaint..color = AppColors.neonCyan,
    );
    canvas.drawLine(
      Offset(left, top + 20), Offset(left + cornerLength, top + 20), cornerPaint,
    );

    // Top-right
    canvas.drawLine(
      Offset(left + scanAreaSize, top + 20),
      Offset(left + scanAreaSize, top + 20 + cornerLength),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaSize, top + 20),
      Offset(left + scanAreaSize - cornerLength, top + 20),
      cornerPaint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(left, top + scanAreaSize - 20),
      Offset(left, top + scanAreaSize - 20 - cornerLength),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, top + scanAreaSize - 20),
      Offset(left + cornerLength, top + scanAreaSize - 20),
      cornerPaint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(left + scanAreaSize, top + scanAreaSize - 20),
      Offset(left + scanAreaSize, top + scanAreaSize - 20 - cornerLength),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaSize, top + scanAreaSize - 20),
      Offset(left + scanAreaSize - cornerLength, top + scanAreaSize - 20),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
