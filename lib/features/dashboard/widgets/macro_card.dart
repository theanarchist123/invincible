import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:invincible/core/theme/app_theme.dart';
import 'package:invincible/core/models/user_profile.dart';

/// Calorie/macro card with sparkline showing the last 2 weeks of
/// weight trend behind the big number.
class MacroCard extends StatelessWidget {
  final MacroSplit macros;
  final int consumedCalories;
  final int consumedProtein;
  final int consumedCarbs;
  final int consumedFat;

  const MacroCard({
    super.key,
    required this.macros,
    this.consumedCalories = 0,
    this.consumedProtein = 0,
    this.consumedCarbs = 0,
    this.consumedFat = 0,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = macros.calories - consumedCalories;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'Today\'s Nutrition',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: remaining > 0
                      ? AppColors.warm.withValues(alpha: 0.1)
                      : AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  remaining > 0
                      ? '$remaining kcal remaining'
                      : 'Target hit! 🎯',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: remaining > 0
                        ? AppColors.warm
                        : AppColors.success,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Big calorie number with sparkline background
          Stack(
            children: [
              // Faux sparkline (placeholder for actual trend data)
              Positioned.fill(
                child: CustomPaint(
                  painter: _SparklinePainter(),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$consumedCalories',
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -2,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '/ ${macros.calories}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'kcal',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Macro bars
          _MacroBar(
            label: 'Protein',
            current: consumedProtein,
            target: macros.proteinG,
            color: const Color(0xFF57B8FF),
            unit: 'g',
          ),
          const SizedBox(height: 10),
          _MacroBar(
            label: 'Carbs',
            current: consumedCarbs,
            target: macros.carbsG,
            color: AppColors.accent,
            unit: 'g',
          ),
          const SizedBox(height: 10),
          _MacroBar(
            label: 'Fat',
            current: consumedFat,
            target: macros.fatG,
            color: AppColors.warm,
            unit: 'g',
          ),
        ],
      ),
    );
  }
}

class _MacroBar extends StatelessWidget {
  final String label;
  final int current;
  final int target;
  final Color color;
  final String unit;

  const _MacroBar({
    required this.label,
    required this.current,
    required this.target,
    required this.color,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            Text(
              '$current / $target$unit',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.surfaceBorder,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class _SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Gentle upward trend sparkline (placeholder data)
    final paint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    final path = Path();
    final rng = math.Random(42); // deterministic

    path.moveTo(0, size.height);
    for (int i = 0; i <= 14; i++) {
      final x = (i / 14) * size.width;
      final baseY = size.height * 0.7 - (i / 14) * size.height * 0.2;
      final y = baseY + rng.nextDouble() * size.height * 0.1;
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
