import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:invincible/core/models/guided_routine_models.dart';
import 'package:invincible/core/theme/app_theme.dart';

/// Live 60 FPS procedural vector animation demonstrating exercises with glowing neon aesthetic.
class ExerciseAnimationWidget extends StatefulWidget {
  final ExerciseAnimationType animationType;
  final double height;
  final double width;
  final bool isPlaying;
  final Color? accentColor;

  const ExerciseAnimationWidget({
    super.key,
    required this.animationType,
    this.height = 240,
    this.width = double.infinity,
    this.isPlaying = true,
    this.accentColor,
  });

  @override
  State<ExerciseAnimationWidget> createState() => _ExerciseAnimationWidgetState();
}

class _ExerciseAnimationWidgetState extends State<ExerciseAnimationWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _getDurationForExercise(widget.animationType),
    );

    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant ExerciseAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animationType != widget.animationType) {
      _controller.duration = _getDurationForExercise(widget.animationType);
      if (widget.isPlaying && !_controller.isAnimating) {
        _controller.repeat();
      }
    }
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  Duration _getDurationForExercise(ExerciseAnimationType type) {
    switch (type) {
      case ExerciseAnimationType.burpees:
        return const Duration(milliseconds: 2400);
      case ExerciseAnimationType.plank:
        return const Duration(milliseconds: 1800);
      case ExerciseAnimationType.crunches:
        return const Duration(milliseconds: 1600);
      case ExerciseAnimationType.pushups:
        return const Duration(milliseconds: 1800);
      case ExerciseAnimationType.squats:
        return const Duration(milliseconds: 2000);
      case ExerciseAnimationType.mountainClimbers:
        return const Duration(milliseconds: 1000);
      case ExerciseAnimationType.jumpingJacks:
        return const Duration(milliseconds: 1100);
      case ExerciseAnimationType.highKnees:
        return const Duration(milliseconds: 900);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? AppColors.accent;

    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        color: const Color(0xFF16191B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background grid lines for gym floor feeling
            CustomPaint(
              size: Size(widget.width, widget.height),
              painter: _GymFloorGridPainter(accentColor: accent),
            ),

            // Main animated exercise figure
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(widget.width == double.infinity ? 300 : widget.width, widget.height),
                  painter: _ExerciseFigurePainter(
                    type: widget.animationType,
                    progress: _controller.value,
                    accentColor: accent,
                  ),
                );
              },
            ),

            // Exercise badge
            Positioned(
              bottom: 12,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accent.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isPlaying ? accent : AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.isPlaying ? 'ANIMATED PREVIEW' : 'PAUSED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: accent,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Subtle grid on gym floor to give athletic grounding and depth
class _GymFloorGridPainter extends CustomPainter {
  final Color accentColor;

  _GymFloorGridPainter({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final floorY = size.height * 0.78;

    // Ground horizon line
    final linePaint = Paint()
      ..color = accentColor.withValues(alpha: 0.15)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(0, floorY), Offset(size.width, floorY), linePaint);

    // Floor glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          accentColor.withValues(alpha: 0.12),
          Colors.transparent,
        ],
        radius: 0.8,
      ).createShader(Rect.fromCenter(
        center: Offset(size.width / 2, floorY),
        width: size.width * 0.7,
        height: size.height * 0.3,
      ));

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, floorY),
        width: size.width * 0.7,
        height: 24,
      ),
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GymFloorGridPainter oldDelegate) => false;
}

/// Master procedural figure painter that animates joints and limbs
class _ExerciseFigurePainter extends CustomPainter {
  final ExerciseAnimationType type;
  final double progress; // 0.0 to 1.0
  final Color accentColor;

  _ExerciseFigurePainter({
    required this.type,
    required this.progress,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.52);

    final bonePaint = Paint()
      ..color = accentColor
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final glowPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.35)
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final jointPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final muscleTensionPaint = Paint()
      ..color = const Color(0xFFFF5252)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    switch (type) {
      case ExerciseAnimationType.burpees:
        _paintBurpee(canvas, center, progress, bonePaint, glowPaint, jointPaint);
        break;
      case ExerciseAnimationType.plank:
        _paintPlank(canvas, center, progress, bonePaint, glowPaint, jointPaint, muscleTensionPaint);
        break;
      case ExerciseAnimationType.crunches:
        _paintCrunches(canvas, center, progress, bonePaint, glowPaint, jointPaint, muscleTensionPaint);
        break;
      case ExerciseAnimationType.pushups:
        _paintPushup(canvas, center, progress, bonePaint, glowPaint, jointPaint, muscleTensionPaint);
        break;
      case ExerciseAnimationType.squats:
        _paintSquat(canvas, center, progress, bonePaint, glowPaint, jointPaint, muscleTensionPaint);
        break;
      case ExerciseAnimationType.mountainClimbers:
        _paintMountainClimbers(canvas, center, progress, bonePaint, glowPaint, jointPaint);
        break;
      case ExerciseAnimationType.jumpingJacks:
        _paintJumpingJacks(canvas, center, progress, bonePaint, glowPaint, jointPaint);
        break;
      case ExerciseAnimationType.highKnees:
        _paintHighKnees(canvas, center, progress, bonePaint, glowPaint, jointPaint);
        break;
    }
  }

  // ----------------------------------------------------
  // 1. BURPEES ANIMATION
  // ----------------------------------------------------
  void _paintBurpee(
    Canvas canvas,
    Offset center,
    double t,
    Paint bonePaint,
    Paint glowPaint,
    Paint jointPaint,
  ) {
    // 5 Stages of a Burpee:
    // 0.0 - 0.20: Standing tall -> Drop into crouch
    // 0.20 - 0.40: Crouch -> Kick feet back to plank
    // 0.40 - 0.55: Plank push-up dip down & press up
    // 0.55 - 0.75: Pull feet back to hands (crouch)
    // 0.75 - 0.95: Explosive vertical jump with arms overhead!
    // 0.95 - 1.00: Return to standing

    final groundY = center.dy + 45;

    Offset head, shoulders, hips, knees, feet, elbows, hands;

    if (t < 0.20) {
      // Standing to crouch
      final p = t / 0.20;
      final yDrop = p * 45;
      head = Offset(center.dx, center.dy - 60 + yDrop);
      shoulders = Offset(center.dx, center.dy - 45 + yDrop);
      hips = Offset(center.dx - 5 * p, center.dy - 10 + yDrop * 0.9);
      knees = Offset(center.dx + 15 * p, center.dy + 20 + yDrop * 0.4);
      feet = Offset(center.dx, groundY);
      elbows = Offset(center.dx - 12, center.dy - 20 + yDrop);
      hands = Offset(center.dx - 5 + 10 * p, center.dy + yDrop * 1.1);
    } else if (t < 0.40) {
      // Crouch to Plank
      final p = (t - 0.20) / 0.20;
      head = Offset(center.dx + 35, groundY - 30);
      shoulders = Offset(center.dx + 25, groundY - 25);
      hips = Offset(center.dx - 10 * (1 - p) - 20 * p, groundY - 20);
      knees = Offset(center.dx - 10 - 25 * p, groundY - 10);
      feet = Offset(center.dx - 50 * p, groundY);
      elbows = Offset(center.dx + 25, groundY - 12);
      hands = Offset(center.dx + 25, groundY);
    } else if (t < 0.55) {
      // Pushup dip
      final p = math.sin(((t - 0.40) / 0.15) * math.pi);
      final dip = p * 12;
      head = Offset(center.dx + 35, groundY - 30 + dip);
      shoulders = Offset(center.dx + 25, groundY - 25 + dip);
      hips = Offset(center.dx - 20, groundY - 20 + dip);
      knees = Offset(center.dx - 35, groundY - 10 + dip * 0.6);
      feet = Offset(center.dx - 50, groundY);
      elbows = Offset(center.dx + 32, groundY - 10 + dip * 0.3);
      hands = Offset(center.dx + 25, groundY);
    } else if (t < 0.75) {
      // Plank back to crouch
      final p = (t - 0.55) / 0.20;
      head = Offset(center.dx + 35 * (1 - p), groundY - 30);
      shoulders = Offset(center.dx + 25 * (1 - p), groundY - 25);
      hips = Offset(center.dx - 20 * (1 - p), groundY - 20);
      knees = Offset(center.dx - 35 * (1 - p) + 15 * p, groundY - 10);
      feet = Offset(center.dx - 50 * (1 - p), groundY);
      elbows = Offset(center.dx + 15 * (1 - p), groundY - 15);
      hands = Offset(center.dx + 10 * (1 - p), groundY);
    } else if (t < 0.95) {
      // Explosive Jump!
      final p = math.sin(((t - 0.75) / 0.20) * math.pi);
      final jumpHeight = p * 40;
      head = Offset(center.dx, center.dy - 60 - jumpHeight);
      shoulders = Offset(center.dx, center.dy - 45 - jumpHeight);
      hips = Offset(center.dx, center.dy - 10 - jumpHeight);
      knees = Offset(center.dx, center.dy + 20 - jumpHeight);
      feet = Offset(center.dx, groundY - jumpHeight);
      // Arms raised high in air
      elbows = Offset(center.dx + 15 * p, center.dy - 70 - jumpHeight);
      hands = Offset(center.dx + 20 * p, center.dy - 85 - jumpHeight);
    } else {
      // Landing
      head = Offset(center.dx, center.dy - 60);
      shoulders = Offset(center.dx, center.dy - 45);
      hips = Offset(center.dx, center.dy - 10);
      knees = Offset(center.dx, center.dy + 20);
      feet = Offset(center.dx, groundY);
      elbows = Offset(center.dx - 12, center.dy - 25);
      hands = Offset(center.dx - 14, center.dy);
    }

    _drawStickFigure(canvas, head, shoulders, hips, knees, feet, elbows, hands, bonePaint, glowPaint, jointPaint);
  }

  // ----------------------------------------------------
  // 2. PLANK ANIMATION
  // ----------------------------------------------------
  void _paintPlank(
    Canvas canvas,
    Offset center,
    double t,
    Paint bonePaint,
    Paint glowPaint,
    Paint jointPaint,
    Paint muscleTensionPaint,
  ) {
    // Subtle rhythmic isometric breathing pulse
    final breathe = math.sin(t * math.pi * 2) * 2.5;

    final groundY = center.dy + 35;
    final head = Offset(center.dx + 50, groundY - 28 + breathe);
    final shoulders = Offset(center.dx + 35, groundY - 24 + breathe);
    final hips = Offset(center.dx - 20, groundY - 20 + breathe * 0.5);
    final knees = Offset(center.dx - 45, groundY - 10 + breathe * 0.2);
    final feet = Offset(center.dx - 70, groundY);

    // Forearm plank: elbows on floor, hands extended forward
    final elbows = Offset(center.dx + 35, groundY);
    final hands = Offset(center.dx + 55, groundY);

    // Draw core abdominal tension indicator
    final coreCenter = Offset(center.dx + 5, groundY - 22 + breathe * 0.7);
    canvas.drawCircle(
      coreCenter,
      12 + math.sin(t * math.pi * 4).abs() * 3,
      Paint()
        ..color = accentColor.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Core muscle tension bar
    canvas.drawLine(
      Offset(center.dx - 10, groundY - 22 + breathe * 0.7),
      Offset(center.dx + 20, groundY - 22 + breathe * 0.7),
      muscleTensionPaint,
    );

    _drawStickFigure(canvas, head, shoulders, hips, knees, feet, elbows, hands, bonePaint, glowPaint, jointPaint);
  }

  // ----------------------------------------------------
  // 3. CRUNCHES ANIMATION
  // ----------------------------------------------------
  void _paintCrunches(
    Canvas canvas,
    Offset center,
    double t,
    Paint bonePaint,
    Paint glowPaint,
    Paint jointPaint,
    Paint muscleTensionPaint,
  ) {
    // Curl up and down smoothly
    final curl = (math.sin(t * math.pi * 2 - math.pi / 2) + 1) / 2; // 0 to 1

    final matY = center.dy + 30;

    // Hips stay grounded on mat
    final hips = Offset(center.dx - 15, matY);
    // Legs bent 90 degrees: knees up in air, feet grounded
    final knees = Offset(center.dx + 25, matY - 40);
    final feet = Offset(center.dx + 55, matY);

    // Upper torso curls off the mat
    final torsoAngle = curl * 0.45; // in radians
    final shoulders = Offset(
      hips.dx - 40 * math.cos(torsoAngle),
      matY - 40 * math.sin(torsoAngle),
    );
    final head = Offset(
      shoulders.dx - 18 * math.cos(torsoAngle),
      shoulders.dy - 18 * math.sin(torsoAngle),
    );

    // Hands behind ears / temple
    final elbows = Offset(shoulders.dx + 10, shoulders.dy - 18);
    final hands = Offset(head.dx + 5, head.dy);

    // Core contraction glow
    if (curl > 0.4) {
      canvas.drawCircle(
        Offset(center.dx - 15, matY - 15 * curl),
        14 * curl,
        Paint()
          ..color = Colors.redAccent.withValues(alpha: 0.3 * curl)
          ..style = PaintingStyle.fill,
      );
    }

    _drawStickFigure(canvas, head, shoulders, hips, knees, feet, elbows, hands, bonePaint, glowPaint, jointPaint);
  }

  // ----------------------------------------------------
  // 4. PUSHUPS ANIMATION
  // ----------------------------------------------------
  void _paintPushup(
    Canvas canvas,
    Offset center,
    double t,
    Paint bonePaint,
    Paint glowPaint,
    Paint jointPaint,
    Paint muscleTensionPaint,
  ) {
    // Body lowers and presses up
    final dip = (math.sin(t * math.pi * 2 - math.pi / 2) + 1) / 2; // 0 to 1
    final groundY = center.dy + 35;
    final dipAmount = dip * 22; // drops by 22 px

    final head = Offset(center.dx + 50, groundY - 32 + dipAmount);
    final shoulders = Offset(center.dx + 35, groundY - 26 + dipAmount);
    final hips = Offset(center.dx - 15, groundY - 20 + dipAmount * 0.7);
    final knees = Offset(center.dx - 42, groundY - 10 + dipAmount * 0.4);
    final feet = Offset(center.dx - 65, groundY);

    // Hands stay fixed on ground; elbows flare out/back
    final hands = Offset(center.dx + 35, groundY);
    final elbows = Offset(center.dx + 28 - dip * 8, groundY - 15 + dipAmount * 0.5);

    _drawStickFigure(canvas, head, shoulders, hips, knees, feet, elbows, hands, bonePaint, glowPaint, jointPaint);
  }

  // ----------------------------------------------------
  // 5. SQUATS ANIMATION
  // ----------------------------------------------------
  void _paintSquat(
    Canvas canvas,
    Offset center,
    double t,
    Paint bonePaint,
    Paint glowPaint,
    Paint jointPaint,
    Paint muscleTensionPaint,
  ) {
    // Deep squat descent and rise
    final squatDepth = (math.sin(t * math.pi * 2 - math.pi / 2) + 1) / 2; // 0 to 1
    final groundY = center.dy + 50;

    final drop = squatDepth * 35;

    final feet = Offset(center.dx, groundY);
    // Knees push forward and bend
    final knees = Offset(center.dx + 16 * squatDepth, groundY - 30 + drop * 0.3);
    // Hips sink down and back
    final hips = Offset(center.dx - 22 * squatDepth, groundY - 55 + drop);
    // Torso angles forward slightly
    final shoulders = Offset(center.dx - 10 * squatDepth, groundY - 90 + drop);
    final head = Offset(center.dx - 6 * squatDepth, groundY - 106 + drop);

    // Arms reach forward for balance during descent
    final elbows = Offset(center.dx + 15 * squatDepth, shoulders.dy + 12);
    final hands = Offset(center.dx + 30 * squatDepth, shoulders.dy + 5);

    _drawStickFigure(canvas, head, shoulders, hips, knees, feet, elbows, hands, bonePaint, glowPaint, jointPaint);
  }

  // ----------------------------------------------------
  // 6. MOUNTAIN CLIMBERS ANIMATION
  // ----------------------------------------------------
  void _paintMountainClimbers(
    Canvas canvas,
    Offset center,
    double t,
    Paint bonePaint,
    Paint glowPaint,
    Paint jointPaint,
  ) {
    final groundY = center.dy + 35;
    final head = Offset(center.dx + 48, groundY - 34);
    final shoulders = Offset(center.dx + 32, groundY - 26);
    final hips = Offset(center.dx - 12, groundY - 22);

    final hands = Offset(center.dx + 32, groundY);
    final elbows = Offset(center.dx + 32, groundY - 13);

    // Alternating leg drives (sine wave)
    final legCycle = math.sin(t * math.pi * 2);

    // Left leg
    final kneeL = Offset(
      center.dx + 10 + legCycle * 18,
      groundY - 18 - legCycle.abs() * 8,
    );
    final footL = Offset(
      center.dx - 20 + legCycle * 30,
      groundY - (legCycle > 0 ? 12 : 0),
    );

    // Right leg (opposite phase)
    final kneeR = Offset(
      center.dx + 10 - legCycle * 18,
      groundY - 18 - (-legCycle).abs() * 8,
    );
    final footR = Offset(
      center.dx - 20 - legCycle * 30,
      groundY - (legCycle < 0 ? 12 : 0),
    );

    // Draw torso & arms
    _drawLineWithGlow(canvas, shoulders, hips, bonePaint, glowPaint);
    _drawLineWithGlow(canvas, shoulders, elbows, bonePaint, glowPaint);
    _drawLineWithGlow(canvas, elbows, hands, bonePaint, glowPaint);

    // Draw both legs
    _drawLineWithGlow(canvas, hips, kneeL, bonePaint, glowPaint);
    _drawLineWithGlow(canvas, kneeL, footL, bonePaint, glowPaint);
    _drawLineWithGlow(canvas, hips, kneeR, bonePaint, glowPaint);
    _drawLineWithGlow(canvas, kneeR, footR, bonePaint, glowPaint);

    // Draw Head
    canvas.drawCircle(head, 10, glowPaint);
    canvas.drawCircle(head, 10, bonePaint);
    canvas.drawCircle(head, 4, jointPaint);

    // Draw Joints
    for (final pt in [shoulders, hips, kneeL, footL, kneeR, footR, elbows, hands]) {
      canvas.drawCircle(pt, 3.5, jointPaint);
    }
  }

  // ----------------------------------------------------
  // 7. JUMPING JACKS ANIMATION
  // ----------------------------------------------------
  void _paintJumpingJacks(
    Canvas canvas,
    Offset center,
    double t,
    Paint bonePaint,
    Paint glowPaint,
    Paint jointPaint,
  ) {
    // 0 = closed, 1 = open wide
    final open = (math.sin(t * math.pi * 2 - math.pi / 2) + 1) / 2;
    final jumpY = math.sin(t * math.pi * 2).abs() * 14;

    final groundY = center.dy + 45;

    final head = Offset(center.dx, center.dy - 55 - jumpY);
    final shoulders = Offset(center.dx, center.dy - 38 - jumpY);
    final hips = Offset(center.dx, center.dy - 5 - jumpY);

    // Legs spread wide
    final legSpread = open * 35;
    final kneeL = Offset(center.dx - legSpread * 0.5, center.dy + 20 - jumpY);
    final kneeR = Offset(center.dx + legSpread * 0.5, center.dy + 20 - jumpY);
    final footL = Offset(center.dx - legSpread, groundY - jumpY);
    final footR = Offset(center.dx + legSpread, groundY - jumpY);

    // Arms sweep overhead
    final armAngle = open * math.pi * 0.8; // sweeps up
    final elbowL = Offset(
      shoulders.dx - 22 * math.sin(armAngle),
      shoulders.dy - 22 * math.cos(armAngle),
    );
    final handL = Offset(
      elbowL.dx - 22 * math.sin(armAngle),
      elbowL.dy - 22 * math.cos(armAngle),
    );

    final elbowR = Offset(
      shoulders.dx + 22 * math.sin(armAngle),
      shoulders.dy - 22 * math.cos(armAngle),
    );
    final handR = Offset(
      elbowR.dx + 22 * math.sin(armAngle),
      elbowR.dy - 22 * math.cos(armAngle),
    );

    _drawStickFigure(canvas, head, shoulders, hips, kneeL, footL, elbowL, handL, bonePaint, glowPaint, jointPaint);
    // Draw other leg & arm
    _drawLineWithGlow(canvas, hips, kneeR, bonePaint, glowPaint);
    _drawLineWithGlow(canvas, kneeR, footR, bonePaint, glowPaint);
    _drawLineWithGlow(canvas, shoulders, elbowR, bonePaint, glowPaint);
    _drawLineWithGlow(canvas, elbowR, handR, bonePaint, glowPaint);
    canvas.drawCircle(kneeR, 3.5, jointPaint);
    canvas.drawCircle(footR, 3.5, jointPaint);
    canvas.drawCircle(elbowR, 3.5, jointPaint);
    canvas.drawCircle(handR, 3.5, jointPaint);
  }

  // ----------------------------------------------------
  // 8. HIGH KNEES ANIMATION
  // ----------------------------------------------------
  void _paintHighKnees(
    Canvas canvas,
    Offset center,
    double t,
    Paint bonePaint,
    Paint glowPaint,
    Paint jointPaint,
  ) {
    final groundY = center.dy + 45;
    final bounce = math.sin(t * math.pi * 4).abs() * 8;

    final head = Offset(center.dx, center.dy - 55 - bounce);
    final shoulders = Offset(center.dx, center.dy - 38 - bounce);
    final hips = Offset(center.dx, center.dy - 5 - bounce);

    final runPhase = math.sin(t * math.pi * 2);

    // Left knee drives high to waist level
    final kneeL = Offset(
      center.dx + 12,
      runPhase > 0 ? (hips.dy + 5) : (center.dy + 20),
    );
    final footL = Offset(
      center.dx + 15,
      runPhase > 0 ? (center.dy + 15) : groundY,
    );

    // Right leg opposite
    final kneeR = Offset(
      center.dx - 12,
      runPhase <= 0 ? (hips.dy + 5) : (center.dy + 20),
    );
    final footR = Offset(
      center.dx - 15,
      runPhase <= 0 ? (center.dy + 15) : groundY,
    );

    // Pumping runner arms
    final elbowL = Offset(center.dx - 18, shoulders.dy + (runPhase > 0 ? 18 : 5));
    final handL = Offset(center.dx - 18, elbowL.dy + (runPhase > 0 ? -12 : 12));

    final elbowR = Offset(center.dx + 18, shoulders.dy + (runPhase <= 0 ? 18 : 5));
    final handR = Offset(center.dx + 18, elbowR.dy + (runPhase <= 0 ? -12 : 12));

    _drawStickFigure(canvas, head, shoulders, hips, kneeL, footL, elbowL, handL, bonePaint, glowPaint, jointPaint);
    _drawLineWithGlow(canvas, hips, kneeR, bonePaint, glowPaint);
    _drawLineWithGlow(canvas, kneeR, footR, bonePaint, glowPaint);
    _drawLineWithGlow(canvas, shoulders, elbowR, bonePaint, glowPaint);
    _drawLineWithGlow(canvas, elbowR, handR, bonePaint, glowPaint);
    canvas.drawCircle(kneeR, 3.5, jointPaint);
    canvas.drawCircle(footR, 3.5, jointPaint);
    canvas.drawCircle(elbowR, 3.5, jointPaint);
    canvas.drawCircle(handR, 3.5, jointPaint);
  }

  // ----------------------------------------------------
  // HELPER DRAW FUNCTIONS
  // ----------------------------------------------------
  void _drawStickFigure(
    Canvas canvas,
    Offset head,
    Offset shoulders,
    Offset hips,
    Offset knees,
    Offset feet,
    Offset elbows,
    Offset hands,
    Paint bonePaint,
    Paint glowPaint,
    Paint jointPaint,
  ) {
    // Spine
    _drawLineWithGlow(canvas, shoulders, hips, bonePaint, glowPaint);
    // Legs
    _drawLineWithGlow(canvas, hips, knees, bonePaint, glowPaint);
    _drawLineWithGlow(canvas, knees, feet, bonePaint, glowPaint);
    // Arms
    _drawLineWithGlow(canvas, shoulders, elbows, bonePaint, glowPaint);
    _drawLineWithGlow(canvas, elbows, hands, bonePaint, glowPaint);

    // Head
    canvas.drawCircle(head, 10, glowPaint);
    canvas.drawCircle(head, 10, bonePaint);
    canvas.drawCircle(head, 4, jointPaint);

    // Joints
    for (final pt in [shoulders, hips, knees, feet, elbows, hands]) {
      canvas.drawCircle(pt, 3.5, jointPaint);
    }
  }

  void _drawLineWithGlow(Canvas canvas, Offset p1, Offset p2, Paint bonePaint, Paint glowPaint) {
    canvas.drawLine(p1, p2, glowPaint);
    canvas.drawLine(p1, p2, bonePaint);
  }

  @override
  bool shouldRepaint(covariant _ExerciseFigurePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.type != type;
  }
}
