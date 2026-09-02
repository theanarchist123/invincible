import 'package:flutter/material.dart';
import 'package:invincible/core/theme/app_theme.dart';

class ScoreRevealAnimation extends StatefulWidget {
  final Map<String, int> scores; // e.g., {'Shoulders': 7, 'Chest': 6, 'Arms': 8, 'Legs': 5, 'Back': 7}
  final int overallScore;

  const ScoreRevealAnimation({
    super.key,
    required this.scores,
    required this.overallScore,
  });

  @override
  State<ScoreRevealAnimation> createState() => _ScoreRevealAnimationState();
}

class _ScoreRevealAnimationState extends State<ScoreRevealAnimation> with TickerProviderStateMixin {
  late final AnimationController _overallController;
  late final Animation<double> _overallAnimation;
  
  final Map<String, AnimationController> _partControllers = {};
  final Map<String, Animation<double>> _partAnimations = {};

  @override
  void initState() {
    super.initState();
    
    // Overall score animation (grows from 0 to target)
    _overallController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _overallAnimation = Tween<double>(begin: 0, end: widget.overallScore.toDouble()).animate(
      CurvedAnimation(parent: _overallController, curve: Curves.easeOutCubic),
    );

    // Sequence the individual part animations
    int delayMs = 500;
    for (final entry in widget.scores.entries) {
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
      );
      final animation = Tween<double>(begin: 0, end: entry.value.toDouble()).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
      );
      
      _partControllers[entry.key] = controller;
      _partAnimations[entry.key] = animation;

      Future.delayed(Duration(milliseconds: delayMs), () {
        if (mounted) controller.forward();
      });
      delayMs += 300; // Stagger each part by 300ms
    }

    // Start overall animation immediately
    _overallController.forward();
  }

  @override
  void dispose() {
    _overallController.dispose();
    for (final controller in _partControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Overall Physique Score
        AnimatedBuilder(
          animation: _overallAnimation,
          builder: (context, child) {
            return Column(
              children: [
                const Text('PHYSIQUE SCORE', style: TextStyle(color: AppColors.textTertiary, letterSpacing: 2)),
                const SizedBox(height: 8),
                Text(
                  _overallAnimation.value.toInt().toString(),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.accent,
                    fontSize: 80,
                    shadows: [
                      Shadow(
                        color: AppColors.accent.withValues(alpha: 0.5),
                        blurRadius: 20,
                      )
                    ],
                  ),
                ),
                const Text('/100', style: TextStyle(color: AppColors.textSecondary)),
              ],
            );
          },
        ),
        
        const SizedBox(height: 48),
        
        // Breakdown
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Column(
            children: widget.scores.keys.map((part) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AnimatedBuilder(
                  animation: _partAnimations[part]!,
                  builder: (context, child) {
                    final value = _partAnimations[part]!.value;
                    return Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: Text(part.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        Expanded(
                          child: Stack(
                            children: [
                              Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              Container(
                                height: 8,
                                width: (MediaQuery.of(context).size.width - 180) * (value / 10),
                                decoration: BoxDecoration(
                                  color: value > 0 ? AppColors.accent : Colors.transparent,
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    if (value > 0)
                                      BoxShadow(
                                        color: AppColors.accent.withValues(alpha: 0.5),
                                        blurRadius: 8,
                                      )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 32,
                          child: Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
