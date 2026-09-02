import 'package:flutter/material.dart';

enum ExerciseAnimationType {
  burpees,
  plank,
  crunches,
  pushups,
  squats,
  mountainClimbers,
  jumpingJacks,
  highKnees,
}

class RoutineExercise {
  final String id;
  final String name;
  final ExerciseAnimationType animationType;
  final int durationSeconds;
  final int restSeconds;
  final String targetMuscles;
  final String instructions;
  final String tips;
  final int calories;

  const RoutineExercise({
    required this.id,
    required this.name,
    required this.animationType,
    required this.durationSeconds,
    this.restSeconds = 15,
    required this.targetMuscles,
    required this.instructions,
    required this.tips,
    required this.calories,
  });
}

class GuidedWorkoutRoutine {
  final String id;
  final int dayNumber;
  final String title;
  final String subtitle;
  final String difficulty;
  final int estimatedMinutes;
  final int estimatedCalories;
  final List<RoutineExercise> exercises;
  final Color badgeColor;

  const GuidedWorkoutRoutine({
    required this.id,
    required this.dayNumber,
    required this.title,
    required this.subtitle,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.estimatedCalories,
    required this.exercises,
    this.badgeColor = const Color(0xFFB8FF57),
  });

  int get totalExerciseCount => exercises.length;
}

/// Pre-populated library of daily guided routines for ectomorph mass building & conditioning.
class GuidedRoutinesData {
  static const RoutineExercise burpees = RoutineExercise(
    id: 'ex_burpees',
    name: 'Burpees',
    animationType: ExerciseAnimationType.burpees,
    durationSeconds: 30,
    restSeconds: 15,
    targetMuscles: 'Full Body • Chest • Quads • Core',
    instructions: '1. Stand tall with feet shoulder-width apart.\n2. Drop into a squat and place hands on the floor.\n3. Kick feet back into a full plank position.\n4. Lower into a push-up and press back up.\n5. Jump feet back to hands and explode straight up into the air with arms overhead.',
    tips: 'Pace your breathing. Land softly on the balls of your feet.',
    calories: 25,
  );

  static const RoutineExercise plank = RoutineExercise(
    id: 'ex_plank',
    name: 'Plank Hold',
    animationType: ExerciseAnimationType.plank,
    durationSeconds: 45,
    restSeconds: 15,
    targetMuscles: 'Core • Abs • Lower Back • Shoulders',
    instructions: '1. Place elbows on the floor directly beneath your shoulders.\n2. Extend legs back onto toes, creating a rigid straight line from head to heels.\n3. Squeeze glutes and brace your core like preparing for a punch.\n4. Hold steady without letting hips sag or pike upward.',
    tips: 'Keep your gaze on the floor just past your hands to keep your neck neutral.',
    calories: 18,
  );

  static const RoutineExercise crunches = RoutineExercise(
    id: 'ex_crunches',
    name: 'Abdominal Crunches',
    animationType: ExerciseAnimationType.crunches,
    durationSeconds: 30,
    restSeconds: 15,
    targetMuscles: 'Rectus Abdominis • Core',
    instructions: '1. Lie on your back with knees bent and feet flat on the floor.\n2. Place fingertips lightly behind ears (don\'t pull on your neck).\n3. Contract your abs to curl your shoulder blades 3-4 inches off the floor.\n4. Pause at the peak for 1 second, then lower with control.',
    tips: 'Exhale forcefully at the top of each crunch to maximize contraction.',
    calories: 15,
  );

  static const RoutineExercise pushups = RoutineExercise(
    id: 'ex_pushups',
    name: 'Push-Ups',
    animationType: ExerciseAnimationType.pushups,
    durationSeconds: 35,
    restSeconds: 15,
    targetMuscles: 'Chest • Triceps • Anterior Delts • Core',
    instructions: '1. Hands slightly wider than shoulder-width, body in a rigid plank.\n2. Lower your chest until it is an inch above the floor, elbows at 45 degrees.\n3. Drive through your palms to return to the top position.',
    tips: 'Keep your core tight and do not let your lower back arch.',
    calories: 22,
  );

  static const RoutineExercise squats = RoutineExercise(
    id: 'ex_squats',
    name: 'Bodyweight Squats',
    animationType: ExerciseAnimationType.squats,
    durationSeconds: 40,
    restSeconds: 15,
    targetMuscles: 'Quadriceps • Glutes • Hamstrings',
    instructions: '1. Stand with feet slightly wider than shoulder-width, toes slightly flared.\n2. Send hips back and bend knees, sitting down to parallel.\n3. Keep chest proud and knees tracking in line with toes.\n4. Drive through the mid-foot and heels to stand tall.',
    tips: 'Reach arms forward as you descend to maintain an upright torso.',
    calories: 28,
  );

  static const RoutineExercise mountainClimbers = RoutineExercise(
    id: 'ex_mountain_climbers',
    name: 'Mountain Climbers',
    animationType: ExerciseAnimationType.mountainClimbers,
    durationSeconds: 30,
    restSeconds: 15,
    targetMuscles: 'Core • Hip Flexors • Shoulders • Cardio',
    instructions: '1. Begin in a push-up plank with shoulders over wrists.\n2. Drive one knee rapidly towards your chest without raising hips.\n3. Quickly switch legs in a running motion.\n4. Maintain a fast, continuous cadence.',
    tips: 'Keep your hips level with your shoulders; avoid bouncing high.',
    calories: 24,
  );

  static const RoutineExercise jumpingJacks = RoutineExercise(
    id: 'ex_jumping_jacks',
    name: 'Jumping Jacks',
    animationType: ExerciseAnimationType.jumpingJacks,
    durationSeconds: 30,
    restSeconds: 15,
    targetMuscles: 'Full Body • Calves • Shoulders • Cardio',
    instructions: '1. Start standing with arms at sides and feet together.\n2. Jump feet out wide while swinging arms overhead in an arc.\n3. Immediately jump back to the starting position.',
    tips: 'Stay light on your feet and maintain a continuous steady rhythm.',
    calories: 20,
  );

  static const RoutineExercise highKnees = RoutineExercise(
    id: 'ex_high_knees',
    name: 'High Knees',
    animationType: ExerciseAnimationType.highKnees,
    durationSeconds: 30,
    restSeconds: 15,
    targetMuscles: 'Quads • Calves • Core • Cardio',
    instructions: '1. Run in place, driving knees up towards chest level at a rapid pace.\n2. Pump arms rhythmically opposite to legs.\n3. Land softly on the balls of your feet.',
    tips: 'Keep your torso tall; do not lean backward as knees rise.',
    calories: 26,
  );

  static final List<GuidedWorkoutRoutine> routines = [
    const GuidedWorkoutRoutine(
      id: 'routine_day_1',
      dayNumber: 1,
      title: 'Day 1: Full-Body Mass & Core',
      subtitle: 'Burpees, Plank, Crunches & Calisthenics',
      difficulty: 'Beginner / Intermediate',
      estimatedMinutes: 8,
      estimatedCalories: 130,
      exercises: [
        burpees,
        pushups,
        plank,
        crunches,
        squats,
        mountainClimbers,
      ],
      badgeColor: Color(0xFFB8FF57),
    ),
    const GuidedWorkoutRoutine(
      id: 'routine_day_2',
      dayNumber: 2,
      title: 'Day 2: Core & Abs Iron Shred',
      subtitle: 'Targeted midsection and isometric resilience',
      difficulty: 'Intermediate',
      estimatedMinutes: 7,
      estimatedCalories: 110,
      exercises: [
        crunches,
        plank,
        mountainClimbers,
        burpees,
        plank,
      ],
      badgeColor: Color(0xFF64FFDA),
    ),
    const GuidedWorkoutRoutine(
      id: 'routine_day_3',
      dayNumber: 3,
      title: 'Day 3: Explosive Upper & Cardio',
      subtitle: 'High-cadence push-ups, burpees and agility',
      difficulty: 'Intermediate / Advanced',
      estimatedMinutes: 9,
      estimatedCalories: 145,
      exercises: [
        jumpingJacks,
        pushups,
        burpees,
        mountainClimbers,
        plank,
        crunches,
      ],
      badgeColor: Color(0xFFFFD54F),
    ),
    const GuidedWorkoutRoutine(
      id: 'routine_day_4',
      dayNumber: 4,
      title: 'Day 4: Lower Body & Explosive Legs',
      subtitle: 'Squat endurance, high knees and core stamina',
      difficulty: 'All Levels',
      estimatedMinutes: 8,
      estimatedCalories: 135,
      exercises: [
        jumpingJacks,
        squats,
        highKnees,
        burpees,
        squats,
        plank,
      ],
      badgeColor: Color(0xFFFF6D00),
    ),
  ];
}
