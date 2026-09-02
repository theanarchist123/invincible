import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/models/workout_models.dart';
import '../../core/theme/app_haptics.dart';

class TrainingProvider extends ChangeNotifier {
  // Hardcoded mock library for Phase 2 UI building
  final List<Exercise> exerciseLibrary = [
    const Exercise(id: 'ex1', name: 'Barbell Bench Press', primaryMuscle: MuscleGroup.chest),
    const Exercise(id: 'ex2', name: 'Incline Dumbbell Press', primaryMuscle: MuscleGroup.chest),
    const Exercise(id: 'ex3', name: 'Squat', primaryMuscle: MuscleGroup.legs),
    const Exercise(id: 'ex4', name: 'Romanian Deadlift', primaryMuscle: MuscleGroup.legs),
    const Exercise(id: 'ex5', name: 'Pull-up', primaryMuscle: MuscleGroup.back),
    const Exercise(id: 'ex6', name: 'Barbell Row', primaryMuscle: MuscleGroup.back),
    const Exercise(id: 'ex7', name: 'Overhead Press', primaryMuscle: MuscleGroup.shoulders),
    const Exercise(id: 'ex8', name: 'Lateral Raise', primaryMuscle: MuscleGroup.shoulders),
  ];

  late List<WorkoutTemplate> templates;
  
  WorkoutSession? activeSession;

  // Rest Timer State
  Timer? _restTimer;
  int _restSecondsRemaining = 0;
  int _totalRestSeconds = 90;
  bool get isRestTimerActive => _restTimer != null && _restTimer!.isActive;
  int get restSecondsRemaining => _restSecondsRemaining;
  int get totalRestSeconds => _totalRestSeconds;

  TrainingProvider() {
    _loadMockTemplates();
  }

  void _loadMockTemplates() {
    templates = [
      WorkoutTemplate(
        id: 'tpl1',
        name: 'Upper Body Power',
        exercises: [exerciseLibrary[0], exerciseLibrary[4], exerciseLibrary[6]],
        estimatedDurationMinutes: 60,
      ),
      WorkoutTemplate(
        id: 'tpl2',
        name: 'Lower Body Hypertrophy',
        exercises: [exerciseLibrary[2], exerciseLibrary[3]],
        estimatedDurationMinutes: 45,
      ),
    ];
  }

  void startWorkout(WorkoutTemplate template) {
    activeSession = WorkoutSession(
      name: template.name,
      exercises: template.exercises.map((ex) {
        return WorkoutExercise(
          exercise: ex,
          sets: [
            WorkoutSet(targetWeight: 60, targetReps: 8), // Ghost data
            WorkoutSet(targetWeight: 60, targetReps: 8),
            WorkoutSet(targetWeight: 60, targetReps: 8),
          ],
        );
      }).toList(),
    );
    notifyListeners();
  }

  void completeSet(WorkoutExercise exercise, int setIndex) {
    if (activeSession == null) return;
    
    final set = exercise.sets[setIndex];
    set.isCompleted = true;
    AppHaptics.heavy();
    
    // Auto-start rest timer
    startRestTimer(90);
    
    notifyListeners();
  }

  void addSet(WorkoutExercise exercise) {
    AppHaptics.light();
    exercise.sets.add(WorkoutSet());
    notifyListeners();
  }

  void updateSetWeight(WorkoutSet set, double weight) {
    set.weight = weight;
    notifyListeners();
  }

  void updateSetReps(WorkoutSet set, int reps) {
    set.reps = reps;
    notifyListeners();
  }

  void finishWorkout() {
    AppHaptics.vibrate();
    activeSession?.endTime = DateTime.now();
    // In a real app, save to local DB here
    activeSession = null;
    stopRestTimer();
    notifyListeners();
  }

  // --- Rest Timer ---

  void startRestTimer(int seconds) {
    stopRestTimer();
    _totalRestSeconds = seconds;
    _restSecondsRemaining = seconds;
    
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSecondsRemaining > 0) {
        _restSecondsRemaining--;
        
        // Haptic feedback at 10s remaining
        if (_restSecondsRemaining == 10) {
          HapticFeedback.heavyImpact();
        }
        
        notifyListeners();
      } else {
        stopRestTimer();
        HapticFeedback.vibrate();
      }
    });
    notifyListeners();
  }

  void stopRestTimer() {
    _restTimer?.cancel();
    _restTimer = null;
    _restSecondsRemaining = 0;
    notifyListeners();
  }
}
