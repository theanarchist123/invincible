import 'package:flutter_test/flutter_test.dart';
import 'package:invincible/core/engine/tdee_engine.dart';
import 'package:invincible/core/models/user_profile.dart';

void main() {
  test('TDEE engine calculates correct BMR for male', () {
    final bmr = TdeeEngine.calculateBMR(
      weightKg: 60,
      heightCm: 175,
      age: 20,
      sex: Sex.male,
    );
    // Mifflin-St Jeor: (10 * 60) + (6.25 * 175) - (5 * 20) + 5 = 1598.75
    expect(bmr, closeTo(1598.75, 0.01));
  });

  test('Full profile computation produces valid macros', () {
    const profile = UserProfile(
      age: 20,
      sex: Sex.male,
      heightCm: 175,
      weightKg: 60,
      activityLevel: ActivityLevel.moderatelyActive,
      trainingAge: TrainingAge.beginner,
      dietType: DietType.nonVeg,
      foodBudget: FoodBudget.moderate,
      gymAccess: GymAccess.fullGym,
      goalType: GoalType.bulkLean,
    );

    final computed = TdeeEngine.computeFullProfile(profile);

    expect(computed.bmr, isNotNull);
    expect(computed.tdee, isNotNull);
    expect(computed.targetCalories, greaterThan(0));
    expect(computed.macros, isNotNull);
    expect(computed.macros!.proteinG, greaterThan(100));
    expect(computed.macros!.carbsG, greaterThan(200));
    expect(computed.trainingSplit, TrainingSplit.fullBody);
  });
}
