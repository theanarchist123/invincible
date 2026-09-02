import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:invincible/core/theme/app_theme.dart';

/// 7-segment weekly consistency ring.
/// Each day is a segment. Filled = session logged. Never resets mid-week.
class ConsistencyRing extends StatelessWidget {
  final int filledDays; // 0–7
  final double size;

  const ConsistencyRing({
    super.key,
    required this.filledDays,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _ConsistencyRingPainter(
              filledDays: filledDays,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$filledDays/7',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'days',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConsistencyRingPainter extends CustomPainter {
  final int filledDays;
  static const int totalSegments = 7;
  static const double gapDegrees = 8;

  _ConsistencyRingPainter({required this.filledDays});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 8) / 2;

    final totalGap = gapDegrees * totalSegments;
    final segmentDegrees = (360 - totalGap) / totalSegments;

    for (int i = 0; i < totalSegments; i++) {
      final startAngle =
          (-90 + i * (segmentDegrees + gapDegrees)) * math.pi / 180;
      final sweepAngle = segmentDegrees * math.pi / 180;

      final isFilled = i < filledDays;

      final paint = Paint()
        ..color = isFilled ? AppColors.accent : AppColors.surfaceBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round;

      if (isFilled) {
        // Glow for filled segments
        final glowPaint = Paint()
          ..color = AppColors.accent.withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
          glowPaint,
        );
      }

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ConsistencyRingPainter old) =>
      old.filledDays != filledDays;
}
