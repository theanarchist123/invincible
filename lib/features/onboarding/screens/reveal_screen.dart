import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:invincible/core/theme/app_theme.dart';
import 'package:invincible/core/models/user_profile.dart';

/// The "hero moment" reveal screen — animated number count-up for TDEE,
/// macro split, and training split shown as a character build summary.
class RevealScreen extends StatefulWidget {
  final UserProfile profile;
  final VoidCallback onContinue;

  const RevealScreen({
    super.key,
    required this.profile,
    required this.onContinue,
  });

  @override
  State<RevealScreen> createState() => _RevealScreenState();
}

class _RevealScreenState extends State<RevealScreen>
    with TickerProviderStateMixin {
  late AnimationController _ringController;
  late AnimationController _numberController;
  late AnimationController _detailsController;
  late AnimationController _buttonController;

  late Animation<double> _ringAnimation;
  late Animation<int> _calorieAnimation;
  late Animation<double> _detailsAnimation;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Ring fills up (0-1s)
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _ringAnimation = CurvedAnimation(
      parent: _ringController,
      curve: Curves.easeOutCubic,
    );

    // 2. Number counts up (0.5s-2s)
    _numberController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _calorieAnimation = IntTween(
      begin: 0,
      end: widget.profile.targetCalories ?? 0,
    ).animate(CurvedAnimation(
      parent: _numberController,
      curve: Curves.easeOutCubic,
    ));

    // 3. Details slide in (1.5s-2.5s)
    _detailsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _detailsAnimation = CurvedAnimation(
      parent: _detailsController,
      curve: Curves.easeOutCubic,
    );

    // 4. Button fades in (2.5s-3s)
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _buttonAnimation = CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeOut,
    );

    _startSequence();
  }

  void _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _ringController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _numberController.forward();
    await Future.delayed(const Duration(milliseconds: 1000));
    _detailsController.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    _buttonController.forward();
  }

  @override
  void dispose() {
    _ringController.dispose();
    _numberController.dispose();
    _detailsController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final macros = profile.macros;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Title
              FadeTransition(
                opacity: _ringAnimation,
                child: Text(
                  'YOUR STARTING STATS',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent.withValues(alpha: 0.8),
                    letterSpacing: 3,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Big calorie ring + number
              AnimatedBuilder(
                animation: Listenable.merge([_ringAnimation, _calorieAnimation]),
                builder: (context, _) {
                  return SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(200, 200),
                          painter: _RevealRingPainter(
                            progress: _ringAnimation.value,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${_calorieAnimation.value}',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -2,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'kcal / day',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Surplus badge
              FadeTransition(
                opacity: _ringAnimation,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '+${profile.surplusCalories} kcal surplus',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Macro split cards
              FadeTransition(
                opacity: _detailsAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(_detailsController),
                  child: macros != null
                      ? Row(
                          children: [
                            _MacroCard(
                              label: 'Protein',
                              value: '${macros.proteinG}g',
                              color: const Color(0xFF57B8FF),
                            ),
                            const SizedBox(width: 12),
                            _MacroCard(
                              label: 'Carbs',
                              value: '${macros.carbsG}g',
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 12),
                            _MacroCard(
                              label: 'Fat',
                              value: '${macros.fatG}g',
                              color: AppColors.warm,
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ),

              const SizedBox(height: 20),

              // Training split
              FadeTransition(
                opacity: _detailsAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(_detailsController),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.fitness_center_rounded,
                            color: AppColors.accent,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Training Split',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textTertiary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                profile.trainingSplit?.label ?? '',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${profile.trainingSplit?.daysPerWeek ?? 0} days/wk',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // CTA Button
              FadeTransition(
                opacity: _buttonAnimation,
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: widget.onContinue,
                    child: const Text('LET\'S BUILD'),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RevealRingPainter extends CustomPainter {
  final double progress;

  _RevealRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 6) / 2;

    // Track
    final trackPaint = Paint()
      ..color = AppColors.surfaceBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      // Glow
      final glowPaint = Paint()
        ..color = AppColors.accent.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      // Main arc
      final arcPaint = Paint()
        ..color = AppColors.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round;

      final rect = Rect.fromCircle(center: center, radius: radius);
      final sweep = 2 * math.pi * progress;

      canvas.drawArc(rect, -math.pi / 2, sweep, false, glowPaint);
      canvas.drawArc(rect, -math.pi / 2, sweep, false, arcPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RevealRingPainter old) =>
      old.progress != progress;
}
