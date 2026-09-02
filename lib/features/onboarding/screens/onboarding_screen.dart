import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:invincible/core/theme/app_haptics.dart';
import 'package:invincible/core/theme/app_theme.dart';
import 'package:invincible/core/models/user_profile.dart';
import 'package:invincible/features/onboarding/onboarding_provider.dart';
import 'package:invincible/features/onboarding/widgets/progress_ring.dart';
import 'package:invincible/features/onboarding/widgets/selection_card.dart';
import 'package:invincible/features/onboarding/widgets/scroll_wheel_picker.dart';
import 'package:invincible/features/onboarding/screens/reveal_screen.dart';

/// The main onboarding flow — one question at a time, full-screen,
/// with reasoning text underneath each question.
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.08, 0),
      end: Offset.zero,
    ).animate(_fadeAnimation);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _animateToNext(OnboardingProvider provider) async {
    AppHaptics.medium();
    await _fadeController.reverse();
    provider.nextStep();
    _fadeController.forward();
  }

  void _animateToPrev(OnboardingProvider provider) async {
    AppHaptics.light();
    await _fadeController.reverse();
    provider.previousStep();
    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, _) {
        // Show reveal screen when finalizing
        if (provider.isRevealing || provider.isComplete) {
          return RevealScreen(
            profile: provider.profile,
            onContinue: widget.onComplete,
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Top bar: back + progress ring
                  Row(
                    children: [
                      if (provider.currentStep > 0)
                        GestureDetector(
                          onTap: () => _animateToPrev(provider),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.surfaceBorder),
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 40),
                      const Spacer(),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: ProgressRing(
                          key: ValueKey(provider.currentStep),
                          progress: provider.progress,
                          size: 48,
                          strokeWidth: 3,
                          child: Text(
                            '${provider.currentStep + 1}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Step content
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildStep(provider),
                      ),
                    ),
                  ),

                  // Next button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: provider.canGoNext ? 1.0 : 0.4,
                        child: ElevatedButton(
                          onPressed: provider.canGoNext
                              ? () {
                                  if (provider.currentStep ==
                                      OnboardingProvider.totalSteps - 1) {
                                    provider.finalize();
                                  } else {
                                    _animateToNext(provider);
                                  }
                                }
                              : null,
                          child: Text(
                            provider.currentStep ==
                                    OnboardingProvider.totalSteps - 1
                                ? 'CALCULATE MY PLAN'
                                : 'NEXT',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStep(OnboardingProvider provider) {
    switch (provider.currentStep) {
      case 0:
        return _SexStep(provider: provider);
      case 1:
        return _AgeStep(provider: provider);
      case 2:
        return _BodyMeasurementsStep(provider: provider);
      case 3:
        return _ActivityLevelStep(provider: provider);
      case 4:
        return _TrainingAgeStep(provider: provider);
      case 5:
        return _DietTypeStep(provider: provider);
      case 6:
        return _FoodBudgetStep(provider: provider);
      case 7:
        return _GymAccessStep(provider: provider);
      case 8:
        return _GoalTypeStep(provider: provider);
      default:
        return const SizedBox.shrink();
    }
  }
}

/// Step base layout — question + reasoning + content
class _StepLayout extends StatelessWidget {
  final String question;
  final String reasoning;
  final Widget child;

  const _StepLayout({
    required this.question,
    required this.reasoning,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            reasoning,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textTertiary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          child,
        ],
      ),
    );
  }
}

// ─── Step 0: Sex ───────────────────────────────────────

class _SexStep extends StatelessWidget {
  final OnboardingProvider provider;
  const _SexStep({required this.provider});

  @override
  Widget build(BuildContext context) {
    return _StepLayout(
      question: 'What\'s your\nbiological sex?',
      reasoning:
          'Hormonal differences directly affect BMR calculation and how your body responds to training stimulus.',
      child: Column(
        children: Sex.values.map((sex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SelectionCard(
              label: sex.label,
              emoji: sex == Sex.male ? '♂️' : '♀️',
              isSelected: provider.profile.sex == sex,
              onTap: () => provider.setSex(sex),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Step 1: Age ───────────────────────────────────────

class _AgeStep extends StatelessWidget {
  final OnboardingProvider provider;
  const _AgeStep({required this.provider});

  @override
  Widget build(BuildContext context) {
    return _StepLayout(
      question: 'How old\nare you?',
      reasoning:
          'Your age affects metabolic rate and recovery capacity — both change how we calibrate your surplus.',
      child: Center(
        child: ScrollWheelPicker(
          minValue: 14,
          maxValue: 60,
          initialValue: provider.profile.age ?? 20,
          unit: 'yrs',
          onChanged: (value) => provider.setAge(value),
        ),
      ),
    );
  }
}

// ─── Step 2: Height & Weight ───────────────────────────

class _BodyMeasurementsStep extends StatelessWidget {
  final OnboardingProvider provider;
  const _BodyMeasurementsStep({required this.provider});

  @override
  Widget build(BuildContext context) {
    return _StepLayout(
      question: 'Your body\nmeasurements',
      reasoning:
          'Height and weight are the foundation of your BMR — every other calculation builds on these numbers.',
      child: Row(
        children: [
          Expanded(
            child: ScrollWheelPicker(
              minValue: 140,
              maxValue: 210,
              initialValue: provider.profile.heightCm?.round() ?? 170,
              unit: 'cm',
              label: 'HEIGHT',
              onChanged: (value) =>
                  provider.setHeight(value.toDouble()),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: ScrollWheelPicker(
              minValue: 35,
              maxValue: 150,
              initialValue: provider.profile.weightKg?.round() ?? 60,
              unit: 'kg',
              label: 'WEIGHT',
              onChanged: (value) =>
                  provider.setWeight(value.toDouble()),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 3: Activity Level ────────────────────────────

class _ActivityLevelStep extends StatelessWidget {
  final OnboardingProvider provider;
  const _ActivityLevelStep({required this.provider});

  @override
  Widget build(BuildContext context) {
    return _StepLayout(
      question: 'Your daily\nactivity level',
      reasoning:
          'This multiplier scales your BMR into a real TDEE — a desk job and an active job need very different surplus sizes.',
      child: Column(
        children: ActivityLevel.values.map((level) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SelectionCard(
              label: level.label,
              description: level.description,
              icon: _activityIcon(level),
              isSelected: provider.profile.activityLevel == level,
              onTap: () => provider.setActivityLevel(level),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _activityIcon(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.sedentary:
        return Icons.chair_rounded;
      case ActivityLevel.lightlyActive:
        return Icons.directions_walk_rounded;
      case ActivityLevel.moderatelyActive:
        return Icons.directions_run_rounded;
      case ActivityLevel.veryActive:
        return Icons.fitness_center_rounded;
      case ActivityLevel.extremelyActive:
        return Icons.sports_martial_arts_rounded;
    }
  }
}

// ─── Step 4: Training Age ──────────────────────────────

class _TrainingAgeStep extends StatelessWidget {
  final OnboardingProvider provider;
  const _TrainingAgeStep({required this.provider});

  @override
  Widget build(BuildContext context) {
    return _StepLayout(
      question: 'How long have\nyou been training?',
      reasoning:
          'Your training age changes how much volume you can recover from — beginners need less to grow, advanced lifters need more.',
      child: Column(
        children: TrainingAge.values.map((age) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SelectionCard(
              label: age.label,
              description: age.description,
              icon: Icons.trending_up_rounded,
              isSelected: provider.profile.trainingAge == age,
              onTap: () => provider.setTrainingAge(age),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Step 5: Diet Type ─────────────────────────────────

class _DietTypeStep extends StatelessWidget {
  final OnboardingProvider provider;
  const _DietTypeStep({required this.provider});

  @override
  Widget build(BuildContext context) {
    return _StepLayout(
      question: 'What\'s your\ndiet type?',
      reasoning:
          'Protein sources and bioavailability differ — plant-based diets need slightly higher protein targets to match amino acid profiles.',
      child: Column(
        children: DietType.values.map((diet) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SelectionCard(
              label: diet.label,
              emoji: diet.emoji,
              isSelected: provider.profile.dietType == diet,
              onTap: () => provider.setDietType(diet),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Step 6: Food Budget ───────────────────────────────

class _FoodBudgetStep extends StatelessWidget {
  final OnboardingProvider provider;
  const _FoodBudgetStep({required this.provider});

  @override
  Widget build(BuildContext context) {
    return _StepLayout(
      question: 'Your monthly\nfood budget',
      reasoning:
          'We\'ll recommend affordable, protein-dense foods that fit your budget — eating to grow shouldn\'t break the bank.',
      child: Column(
        children: FoodBudget.values.map((budget) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SelectionCard(
              label: budget.label,
              description: budget.description,
              icon: Icons.currency_rupee_rounded,
              isSelected: provider.profile.foodBudget == budget,
              onTap: () => provider.setFoodBudget(budget),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Step 7: Gym Access ────────────────────────────────

class _GymAccessStep extends StatelessWidget {
  final OnboardingProvider provider;
  const _GymAccessStep({required this.provider});

  @override
  Widget build(BuildContext context) {
    return _StepLayout(
      question: 'What equipment\ndo you have access to?',
      reasoning:
          'Your available equipment determines which exercises and training split will be most effective for you.',
      child: Column(
        children: GymAccess.values.map((access) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SelectionCard(
              label: access.label,
              description: access.description,
              icon: _gymIcon(access),
              isSelected: provider.profile.gymAccess == access,
              onTap: () => provider.setGymAccess(access),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _gymIcon(GymAccess access) {
    switch (access) {
      case GymAccess.fullGym:
        return Icons.fitness_center_rounded;
      case GymAccess.basicGym:
        return Icons.sports_gymnastics_rounded;
      case GymAccess.homeSetup:
        return Icons.home_rounded;
    }
  }
}

// ─── Step 8: Goal Type ─────────────────────────────────

class _GoalTypeStep extends StatelessWidget {
  final OnboardingProvider provider;
  const _GoalTypeStep({required this.provider});

  @override
  Widget build(BuildContext context) {
    return _StepLayout(
      question: 'What\'s your\nprimary goal?',
      reasoning:
          'This decides your caloric surplus size — the single biggest lever for whether you gain weight or stay stuck.',
      child: Column(
        children: GoalType.values.map((goal) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SelectionCard(
              label: goal.label,
              description: goal.description,
              icon: _goalIcon(goal),
              isSelected: provider.profile.goalType == goal,
              onTap: () => provider.setGoalType(goal),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _goalIcon(GoalType goal) {
    switch (goal) {
      case GoalType.bulkAggressive:
        return Icons.rocket_launch_rounded;
      case GoalType.bulkLean:
        return Icons.trending_up_rounded;
      case GoalType.maintain:
        return Icons.balance_rounded;
      case GoalType.recomp:
        return Icons.autorenew_rounded;
    }
  }
}
