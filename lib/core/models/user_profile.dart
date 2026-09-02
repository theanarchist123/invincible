/// User profile model holding all onboarding data + computed TDEE/macros.
class UserProfile {
  final String? id;
  final int? age;
  final Sex? sex;
  final double? heightCm;
  final double? weightKg;
  final ActivityLevel? activityLevel;
  final TrainingAge? trainingAge;
  final DietType? dietType;
  final FoodBudget? foodBudget;
  final GymAccess? gymAccess;
  final List<String> injuries;
  final GoalType? goalType;

  // Computed
  final double? bmr;
  final double? tdee;
  final int? surplusCalories;
  final int? targetCalories;
  final MacroSplit? macros;
  final TrainingSplit? trainingSplit;

  const UserProfile({
    this.id,
    this.age,
    this.sex,
    this.heightCm,
    this.weightKg,
    this.activityLevel,
    this.trainingAge,
    this.dietType,
    this.foodBudget,
    this.gymAccess,
    this.injuries = const [],
    this.goalType,
    this.bmr,
    this.tdee,
    this.surplusCalories,
    this.targetCalories,
    this.macros,
    this.trainingSplit,
  });

  UserProfile copyWith({
    String? id,
    int? age,
    Sex? sex,
    double? heightCm,
    double? weightKg,
    ActivityLevel? activityLevel,
    TrainingAge? trainingAge,
    DietType? dietType,
    FoodBudget? foodBudget,
    GymAccess? gymAccess,
    List<String>? injuries,
    GoalType? goalType,
    double? bmr,
    double? tdee,
    int? surplusCalories,
    int? targetCalories,
    MacroSplit? macros,
    TrainingSplit? trainingSplit,
  }) {
    return UserProfile(
      id: id ?? this.id,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      trainingAge: trainingAge ?? this.trainingAge,
      dietType: dietType ?? this.dietType,
      foodBudget: foodBudget ?? this.foodBudget,
      gymAccess: gymAccess ?? this.gymAccess,
      injuries: injuries ?? this.injuries,
      goalType: goalType ?? this.goalType,
      bmr: bmr ?? this.bmr,
      tdee: tdee ?? this.tdee,
      surplusCalories: surplusCalories ?? this.surplusCalories,
      targetCalories: targetCalories ?? this.targetCalories,
      macros: macros ?? this.macros,
      trainingSplit: trainingSplit ?? this.trainingSplit,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'age': age,
        'sex': sex?.name,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'activityLevel': activityLevel?.name,
        'trainingAge': trainingAge?.name,
        'dietType': dietType?.name,
        'foodBudget': foodBudget?.name,
        'gymAccess': gymAccess?.name,
        'injuries': injuries,
        'goalType': goalType?.name,
        'bmr': bmr,
        'tdee': tdee,
        'surplusCalories': surplusCalories,
        'targetCalories': targetCalories,
        'macros': macros?.toJson(),
        'trainingSplit': trainingSplit?.name,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String?,
      age: json['age'] as int?,
      sex: json['sex'] != null
          ? Sex.values.firstWhere((e) => e.name == json['sex'])
          : null,
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      activityLevel: json['activityLevel'] != null
          ? ActivityLevel.values
              .firstWhere((e) => e.name == json['activityLevel'])
          : null,
      trainingAge: json['trainingAge'] != null
          ? TrainingAge.values.firstWhere((e) => e.name == json['trainingAge'])
          : null,
      dietType: json['dietType'] != null
          ? DietType.values.firstWhere((e) => e.name == json['dietType'])
          : null,
      foodBudget: json['foodBudget'] != null
          ? FoodBudget.values.firstWhere((e) => e.name == json['foodBudget'])
          : null,
      gymAccess: json['gymAccess'] != null
          ? GymAccess.values.firstWhere((e) => e.name == json['gymAccess'])
          : null,
      injuries: (json['injuries'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      goalType: json['goalType'] != null
          ? GoalType.values.firstWhere((e) => e.name == json['goalType'])
          : null,
      bmr: (json['bmr'] as num?)?.toDouble(),
      tdee: (json['tdee'] as num?)?.toDouble(),
      surplusCalories: json['surplusCalories'] as int?,
      targetCalories: json['targetCalories'] as int?,
      macros: json['macros'] != null
          ? MacroSplit.fromJson(json['macros'] as Map<String, dynamic>)
          : null,
      trainingSplit: json['trainingSplit'] != null
          ? TrainingSplit.values
              .firstWhere((e) => e.name == json['trainingSplit'])
          : null,
    );
  }
}

enum Sex {
  male('Male'),
  female('Female');

  final String label;
  const Sex(this.label);
}

enum ActivityLevel {
  sedentary('Sedentary', 'Desk job, little movement', 1.2),
  lightlyActive('Lightly Active', 'Light exercise 1-3 days/week', 1.375),
  moderatelyActive('Moderately Active', '3-5 days/week exercise', 1.55),
  veryActive('Very Active', 'Hard exercise 6-7 days/week', 1.725),
  extremelyActive('Extremely Active', 'Athlete / very physical job', 1.9);

  final String label;
  final String description;
  final double multiplier;
  const ActivityLevel(this.label, this.description, this.multiplier);
}

enum TrainingAge {
  beginner('Beginner', '< 6 months of training', 0.5),
  novice('Novice', '6 months – 1 year', 1.0),
  intermediate('Intermediate', '1–3 years', 2.0),
  advanced('Advanced', '3+ years', 3.5);

  final String label;
  final String description;
  final double years;
  const TrainingAge(this.label, this.description, this.years);
}

enum DietType {
  veg('Vegetarian', '🥦'),
  nonVeg('Non-Vegetarian', '🍗'),
  vegan('Vegan', '🌱'),
  eggetarian('Eggetarian', '🥚');

  final String label;
  final String emoji;
  const DietType(this.label, this.emoji);
}

enum FoodBudget {
  tight('Budget', '₹3,000–5,000/mo'),
  moderate('Moderate', '₹5,000–10,000/mo'),
  comfortable('Comfortable', '₹10,000+/mo');

  final String label;
  final String description;
  const FoodBudget(this.label, this.description);
}

enum GymAccess {
  fullGym('Full Gym', 'Barbell, dumbbells, machines, cables'),
  basicGym('Basic Gym', 'Dumbbells, bench, pull-up bar'),
  homeSetup('Home Setup', 'Minimal equipment / bodyweight');

  final String label;
  final String description;
  const GymAccess(this.label, this.description);
}

enum GoalType {
  bulkAggressive('Aggressive Bulk', '+500 kcal surplus', 500),
  bulkLean('Lean Bulk', '+300 kcal surplus', 300),
  maintain('Maintain', 'Stay at maintenance', 0),
  recomp('Body Recomp', 'Maintenance + high protein', 0);

  final String label;
  final String description;
  final int surplusKcal;
  const GoalType(this.label, this.description, this.surplusKcal);
}

enum TrainingSplit {
  ppl('Push/Pull/Legs', 6),
  upperLower('Upper/Lower', 4),
  fullBody('Full Body', 3),
  bro('Bro Split', 5);

  final String label;
  final int daysPerWeek;
  const TrainingSplit(this.label, this.daysPerWeek);
}

class MacroSplit {
  final int proteinG;
  final int carbsG;
  final int fatG;
  final int calories;

  const MacroSplit({
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.calories,
  });

  double get proteinPct => (proteinG * 4 / calories) * 100;
  double get carbsPct => (carbsG * 4 / calories) * 100;
  double get fatPct => (fatG * 9 / calories) * 100;

  Map<String, dynamic> toJson() => {
        'proteinG': proteinG,
        'carbsG': carbsG,
        'fatG': fatG,
        'calories': calories,
      };

  factory MacroSplit.fromJson(Map<String, dynamic> json) {
    return MacroSplit(
      proteinG: json['proteinG'] as int,
      carbsG: json['carbsG'] as int,
      fatG: json['fatG'] as int,
      calories: json['calories'] as int,
    );
  }
}
