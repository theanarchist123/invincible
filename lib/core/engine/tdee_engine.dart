import '../models/user_profile.dart';

/// TDEE & Macro calculation engine.
///
/// Uses the Mifflin-St Jeor equation for BMR, adjusted by activity level,
/// with surplus and macro splits tuned for ectomorph mass-gaining.
class TdeeEngine {
  TdeeEngine._();

  /// Calculate BMR using Mifflin-St Jeor.
  static double calculateBMR({
    required double weightKg,
    required double heightCm,
    required int age,
    required Sex sex,
  }) {
    if (sex == Sex.male) {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
    } else {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
    }
  }

  /// Calculate TDEE from BMR and activity level.
  static double calculateTDEE({
    required double bmr,
    required ActivityLevel activityLevel,
  }) {
    return bmr * activityLevel.multiplier;
  }

  /// Determine appropriate surplus based on goal and training age.
  /// Beginners can handle more aggressive surpluses; advanced trainees
  /// need smaller ones to avoid excessive fat gain.
  static int calculateSurplus({
    required GoalType goalType,
    required TrainingAge trainingAge,
  }) {
    double baseSurplus = goalType.surplusKcal.toDouble();

    // Adjust based on training age
    switch (trainingAge) {
      case TrainingAge.beginner:
        baseSurplus *= 1.0; // Beginners can gain muscle faster
      case TrainingAge.novice:
        baseSurplus *= 0.9;
      case TrainingAge.intermediate:
        baseSurplus *= 0.8;
      case TrainingAge.advanced:
        baseSurplus *= 0.65; // Advanced lifters need smaller surplus
    }

    return baseSurplus.round();
  }

  /// Calculate macro split optimized for ectomorph mass gain.
  ///
  /// Protein: 2.0g/kg bodyweight (slightly higher for ectomorphs to ensure
  /// sufficient amino acids for muscle protein synthesis).
  ///
  /// Fat: 25% of total calories (sufficient for hormones/health).
  ///
  /// Carbs: Remaining calories (ectomorphs need high carbs to fuel growth).
  static MacroSplit calculateMacros({
    required double weightKg,
    required int targetCalories,
    required DietType dietType,
  }) {
    // Protein: 2.0g/kg for most, 2.2g/kg for vegan (less bioavailable)
    double proteinPerKg = dietType == DietType.vegan ? 2.2 : 2.0;
    int proteinG = (weightKg * proteinPerKg).round();
    int proteinCal = proteinG * 4;

    // Fat: 25% of total calories
    int fatCal = (targetCalories * 0.25).round();
    int fatG = (fatCal / 9).round();

    // Carbs: everything remaining
    int carbsCal = targetCalories - proteinCal - fatCal;
    int carbsG = (carbsCal / 4).round();

    // Sanity: ensure minimum carbs
    if (carbsG < 150) {
      carbsG = 150;
      carbsCal = carbsG * 4;
      // Readjust fat
      fatCal = targetCalories - proteinCal - carbsCal;
      fatG = (fatCal / 9).round();
    }

    return MacroSplit(
      proteinG: proteinG,
      carbsG: carbsG,
      fatG: fatG,
      calories: targetCalories,
    );
  }

  /// Determine training split based on gym access and training age.
  static TrainingSplit recommendSplit({
    required GymAccess gymAccess,
    required TrainingAge trainingAge,
  }) {
    if (gymAccess == GymAccess.homeSetup) {
      return TrainingSplit.fullBody;
    }

    switch (trainingAge) {
      case TrainingAge.beginner:
        return TrainingSplit.fullBody;
      case TrainingAge.novice:
        return TrainingSplit.upperLower;
      case TrainingAge.intermediate:
      case TrainingAge.advanced:
        return TrainingSplit.ppl;
    }
  }

  /// Full computation from a user profile — returns an updated profile
  /// with all computed fields populated.
  static UserProfile computeFullProfile(UserProfile profile) {
    if (profile.weightKg == null ||
        profile.heightCm == null ||
        profile.age == null ||
        profile.sex == null ||
        profile.activityLevel == null ||
        profile.trainingAge == null ||
        profile.dietType == null ||
        profile.gymAccess == null ||
        profile.goalType == null) {
      return profile;
    }

    final bmr = calculateBMR(
      weightKg: profile.weightKg!,
      heightCm: profile.heightCm!,
      age: profile.age!,
      sex: profile.sex!,
    );

    final tdee = calculateTDEE(
      bmr: bmr,
      activityLevel: profile.activityLevel!,
    );

    final surplus = calculateSurplus(
      goalType: profile.goalType!,
      trainingAge: profile.trainingAge!,
    );

    final targetCalories = tdee.round() + surplus;

    final macros = calculateMacros(
      weightKg: profile.weightKg!,
      targetCalories: targetCalories,
      dietType: profile.dietType!,
    );

    final split = recommendSplit(
      gymAccess: profile.gymAccess!,
      trainingAge: profile.trainingAge!,
    );

    return profile.copyWith(
      bmr: bmr,
      tdee: tdee,
      surplusCalories: surplus,
      targetCalories: targetCalories,
      macros: macros,
      trainingSplit: split,
    );
  }
}
