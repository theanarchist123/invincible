import 'package:uuid/uuid.dart';

final Uuid _uuid = const Uuid();

enum MuscleGroup {
  chest,
  back,
  shoulders,
  legs,
  arms,
  core,
  fullBody
}

class Exercise {
  final String id;
  final String name;
  final MuscleGroup primaryMuscle;

  const Exercise({
    required this.id,
    required this.name,
    required this.primaryMuscle,
  });
}

class WorkoutSet {
  String id;
  double weight;
  int reps;
  bool isCompleted;
  
  // Ghost data from previous session
  final double? targetWeight;
  final int? targetReps;

  WorkoutSet({
    String? id,
    this.weight = 0.0,
    this.reps = 0,
    this.isCompleted = false,
    this.targetWeight,
    this.targetReps,
  }) : id = id ?? _uuid.v4();
}

class WorkoutExercise {
  String id;
  final Exercise exercise;
  List<WorkoutSet> sets;

  WorkoutExercise({
    String? id,
    required this.exercise,
    List<WorkoutSet>? sets,
  })  : id = id ?? _uuid.v4(),
        sets = sets ?? [];
}

class WorkoutSession {
  String id;
  String name;
  DateTime startTime;
  DateTime? endTime;
  List<WorkoutExercise> exercises;
  
  WorkoutSession({
    String? id,
    required this.name,
    DateTime? startTime,
    this.endTime,
    List<WorkoutExercise>? exercises,
  })  : id = id ?? _uuid.v4(),
        startTime = startTime ?? DateTime.now(),
        exercises = exercises ?? [];

  bool get isOngoing => endTime == null;
}

class WorkoutTemplate {
  final String id;
  final String name;
  final List<Exercise> exercises;
  final int estimatedDurationMinutes;

  WorkoutTemplate({
    String? id,
    required this.name,
    required this.exercises,
    this.estimatedDurationMinutes = 45,
  }) : id = id ?? _uuid.v4();
}
