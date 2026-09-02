import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:invincible/core/models/guided_routine_models.dart';
import 'package:invincible/core/theme/app_haptics.dart';
import 'package:invincible/core/theme/app_theme.dart';
import 'package:invincible/features/training/training_provider.dart';
import 'package:invincible/features/training/screens/workout_logger_screen.dart';
import 'package:invincible/features/training/screens/template_builder_screen.dart';
import 'package:invincible/features/training/screens/routine_detail_screen.dart';
import 'package:invincible/features/training/screens/guided_workout_player_screen.dart';
import 'package:invincible/features/training/widgets/exercise_animation_widget.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  int _selectedTabIndex = 0; // 0: Guided Daily Plans, 1: Gym Barbell Logger

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TrainingProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Train'),
        actions: [
          if (_selectedTabIndex == 1)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'New Template',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TemplateBuilderScreen()),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Segmented Tab Switcher (Guided Plans vs Gym Logger)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _TabPill(
                      title: 'DAILY GUIDED PLANS',
                      icon: Icons.play_circle_fill_rounded,
                      isSelected: _selectedTabIndex == 0,
                      onTap: () {
                        AppHaptics.selection();
                        setState(() => _selectedTabIndex = 0);
                      },
                    ),
                  ),
                  Expanded(
                    child: _TabPill(
                      title: 'GYM FREE WEIGHTS',
                      icon: Icons.fitness_center_rounded,
                      isSelected: _selectedTabIndex == 1,
                      onTap: () {
                        AppHaptics.selection();
                        setState(() => _selectedTabIndex = 1);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Tab Content
          Expanded(
            child: _selectedTabIndex == 0
                ? _buildGuidedPlansView(context)
                : _buildGymLoggerView(context, provider),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // GUIDED PLANS TAB (Day 1, Day 2 with Burpees, Plank, Crunches)
  // ----------------------------------------------------
  Widget _buildGuidedPlansView(BuildContext context) {
    final routines = GuidedRoutinesData.routines;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Motivating Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.timer, color: Colors.black, size: 20),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Follow-Along Guided Workouts',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Live animated exercises • Timed sets • Audio & haptic cues',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Text('SCHEDULED ROUTINES', style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 12),

        ...routines.map((routine) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.surfaceBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                AppHaptics.light();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RoutineDetailScreen(routine: routine)),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge & Difficulty
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: routine.badgeColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: routine.badgeColor.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            'DAY ${routine.dayNumber}',
                            style: TextStyle(
                              color: routine.badgeColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        Text(
                          '${routine.estimatedMinutes} MIN • ~${routine.estimatedCalories} KCAL',
                          style: const TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Routine Title
                    Text(
                      routine.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      routine.subtitle,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),

                    const SizedBox(height: 16),

                    // Mini animated preview of lead exercise + exercise chips
                    Row(
                      children: [
                        // Animated square preview
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 64,
                            height: 64,
                            child: ExerciseAnimationWidget(
                              animationType: routine.exercises.first.animationType,
                              height: 64,
                              width: 64,
                              isPlaying: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // List of exercises in chips
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: routine.exercises.take(4).map((ex) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceLight,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${ex.name} (${ex.durationSeconds}s)',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              if (routine.exercises.length > 4) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '+${routine.exercises.length - 4} more exercises',
                                  style: const TextStyle(color: AppColors.accent, fontSize: 11),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: AppColors.surfaceBorder),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              AppHaptics.light();
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => RoutineDetailScreen(routine: routine)),
                              );
                            },
                            child: const Text('VIEW EXERCISES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            AppHaptics.heavy();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GuidedWorkoutPlayerScreen(
                                  routine: routine,
                                  exercises: routine.exercises,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.play_arrow_rounded, size: 20),
                          label: const Text('START', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ----------------------------------------------------
  // GYM LOGGER TAB (Free weights & custom templates)
  // ----------------------------------------------------
  Widget _buildGymLoggerView(BuildContext context, TrainingProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (provider.activeSession != null)
          _ActiveWorkoutCard(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WorkoutLoggerScreen()),
              );
            },
          ),
        if (provider.activeSession != null) const SizedBox(height: 24),

        Text('CUSTOM STRENGTH TEMPLATES', style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 12),

        ...provider.templates.map((template) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              onTap: () {
                AppHaptics.medium();
                if (provider.activeSession != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Finish your active workout first!')),
                  );
                  return;
                }
                provider.startWorkout(template);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WorkoutLoggerScreen()),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(template.name, style: Theme.of(context).textTheme.titleLarge),
                        const Icon(Icons.play_circle_fill, color: AppColors.accent),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${template.exercises.length} exercises • ~${template.estimatedDurationMinutes} min',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: template.exercises.take(3).map((ex) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            ex.name,
                            style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _TabPill extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabPill({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.black : AppColors.textTertiary,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: isSelected ? Colors.black : AppColors.textTertiary,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveWorkoutCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ActiveWorkoutCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.1),
          border: Border.all(color: AppColors.accent, width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.fitness_center, color: AppColors.accent),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Workout in progress', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Tap to return to session', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppColors.accent),
          ],
        ),
      ),
    );
  }
}
