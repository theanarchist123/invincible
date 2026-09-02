import 'package:flutter/material.dart';
import 'package:invincible/core/models/guided_routine_models.dart';
import 'package:invincible/core/theme/app_haptics.dart';
import 'package:invincible/core/theme/app_theme.dart';
import 'package:invincible/features/training/screens/guided_workout_player_screen.dart';
import 'package:invincible/features/training/widgets/exercise_video_player.dart';

class ExercisePreviewSheet extends StatelessWidget {
  final RoutineExercise exercise;

  const ExercisePreviewSheet({super.key, required this.exercise});

  static void show(BuildContext context, RoutineExercise exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExercisePreviewSheet(exercise: exercise),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exercise.targetMuscles,
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // 16:9 MuscleWiki Video / 3D Animation Player
                ExerciseVideoPlayer(
                  exercise: exercise,
                  autoPlay: true,
                ),

                const SizedBox(height: 16),

                // Quick stats pill row
                Row(
                  children: [
                    _PillBadge(
                      icon: Icons.timer,
                      text: '${exercise.durationSeconds}s Duration',
                    ),
                    const SizedBox(width: 8),
                    _PillBadge(
                      icon: Icons.local_fire_department,
                      text: '~${exercise.calories} kcal',
                    ),
                    const SizedBox(width: 8),
                    _PillBadge(
                      icon: Icons.restore,
                      text: '${exercise.restSeconds}s Rest',
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // How to perform
                const Text(
                  'HOW TO PERFORM',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: Text(
                    exercise.instructions,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      height: 1.6,
                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Form Tips
                const Text(
                  'PRO FORM TIP',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.tips_and_updates, color: AppColors.accent, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          exercise.tips,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            height: 1.4,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),

          // Bottom Action Button: Play Single Exercise
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                AppHaptics.medium();
                Navigator.pop(context); // close sheet
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GuidedWorkoutPlayerScreen(
                      exercises: [exercise],
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow_rounded, size: 28),
              label: Text(
                'PLAY THIS EXERCISE (${exercise.durationSeconds}s)',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PillBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _PillBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.accent),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
