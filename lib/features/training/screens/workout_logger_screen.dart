import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:invincible/core/theme/app_theme.dart';
import 'package:invincible/core/models/workout_models.dart';
import 'package:invincible/features/training/training_provider.dart';
import 'package:invincible/features/training/widgets/rest_timer_bottom_sheet.dart';
import 'package:invincible/features/training/widgets/plate_calculator.dart';

class WorkoutLoggerScreen extends StatefulWidget {
  const WorkoutLoggerScreen({super.key});

  @override
  State<WorkoutLoggerScreen> createState() => _WorkoutLoggerScreenState();
}

class _WorkoutLoggerScreenState extends State<WorkoutLoggerScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TrainingProvider>();
    final session = provider.activeSession;

    if (session == null) {
      return const Scaffold(body: Center(child: Text('No active session')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(session.name),
        actions: [
          TextButton(
            onPressed: () {
              provider.finishWorkout();
              Navigator.pop(context);
            },
            child: const Text('FINISH', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.only(bottom: 120), // space for rest timer
            itemCount: session.exercises.length,
            itemBuilder: (context, index) {
              return _ExerciseCard(
                exerciseIndex: index,
                workoutExercise: session.exercises[index],
              );
            },
          ),
          
          if (provider.isRestTimerActive)
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: RestTimerBottomSheet(),
            ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final int exerciseIndex;
  final WorkoutExercise workoutExercise;

  const _ExerciseCard({
    required this.exerciseIndex,
    required this.workoutExercise,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TrainingProvider>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              workoutExercise.exercise.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Header Row
            Row(
              children: [
                const SizedBox(width: 32, child: Text('SET', style: TextStyle(color: AppColors.textTertiary, fontSize: 12))),
                const Expanded(child: Text('PREVIOUS', style: TextStyle(color: AppColors.textTertiary, fontSize: 12))),
                const Expanded(child: Text('KG', style: TextStyle(color: AppColors.textTertiary, fontSize: 12))),
                const Expanded(child: Text('REPS', style: TextStyle(color: AppColors.textTertiary, fontSize: 12))),
                const SizedBox(width: 48), // Checkbox space
              ],
            ),
            const SizedBox(height: 8),

            // Sets
            ...List.generate(workoutExercise.sets.length, (setIndex) {
              final set = workoutExercise.sets[setIndex];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 32,
                      child: Text('${setIndex + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: Text(
                        set.targetWeight != null ? '${set.targetWeight} kg x ${set.targetReps}' : '-',
                        style: const TextStyle(color: AppColors.textTertiary),
                      ),
                    ),
                    Expanded(
                      child: _NumberInput(
                        initialValue: set.targetWeight, // Pre-fill with ghost data
                        onTap: () {
                          // Show inline plate calculator
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: AppColors.surfaceLight,
                            builder: (context) => PlateCalculator(
                              initialWeight: set.weight == 0 ? (set.targetWeight ?? 20) : set.weight,
                              onWeightSelected: (w) {
                                provider.updateSetWeight(set, w);
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                        displayValue: set.weight > 0 ? set.weight.toString() : (set.targetWeight?.toString() ?? ''),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _NumberInput(
                        initialValue: set.targetReps?.toDouble(),
                        onTap: () {
                          // Simple rep input dialog (in real app, inline keyboard)
                        },
                        displayValue: set.reps > 0 ? set.reps.toString() : (set.targetReps?.toString() ?? ''),
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    // Checkbox
                    GestureDetector(
                      onTap: () {
                        if (!set.isCompleted) {
                          // If tapping check and values are empty, auto-fill from ghost
                          if (set.weight == 0 && set.targetWeight != null) {
                            provider.updateSetWeight(set, set.targetWeight!);
                          }
                          if (set.reps == 0 && set.targetReps != null) {
                            provider.updateSetReps(set, set.targetReps!);
                          }
                          provider.completeSet(workoutExercise, setIndex);
                        }
                      },
                      child: Container(
                        width: 40,
                        height: 32,
                        decoration: BoxDecoration(
                          color: set.isCompleted ? AppColors.accent : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.check,
                          color: set.isCompleted ? Colors.black : AppColors.textTertiary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            
            TextButton.icon(
              onPressed: () => provider.addSet(workoutExercise),
              icon: const Icon(Icons.add, size: 16, color: AppColors.textSecondary),
              label: const Text('Add Set', style: TextStyle(color: AppColors.textSecondary)),
            )
          ],
        ),
      ),
    );
  }
}

class _NumberInput extends StatelessWidget {
  final VoidCallback onTap;
  final String displayValue;
  final double? initialValue;

  const _NumberInput({
    required this.onTap,
    required this.displayValue,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = displayValue.isNotEmpty;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          hasValue ? displayValue : '-',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: hasValue ? AppColors.textPrimary : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}
