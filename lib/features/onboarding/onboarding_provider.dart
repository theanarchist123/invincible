import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/engine/tdee_engine.dart';
import '../../core/models/user_profile.dart';

/// Manages the onboarding state and persists the completed profile.
class OnboardingProvider extends ChangeNotifier {
  UserProfile _profile = const UserProfile();
  int _currentStep = 0;
  bool _isComplete = false;
  bool _isRevealing = false;

  static const int totalSteps = 9;
  static const String _storageKey = 'user_profile';

  UserProfile get profile => _profile;
  int get currentStep => _currentStep;
  bool get isComplete => _isComplete;
  bool get isRevealing => _isRevealing;
  double get progress => (_currentStep + 1) / totalSteps;

  /// Try to load a previously saved profile.
  Future<bool> tryLoadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_storageKey);
    if (json != null) {
      _profile = UserProfile.fromJson(jsonDecode(json));
      _isComplete = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Save profile to storage.
  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_profile.toJson()));
  }

  // ─── Step updates ─────────────────────────────────────

  void setAge(int age) {
    _profile = _profile.copyWith(age: age);
    notifyListeners();
  }

  void setSex(Sex sex) {
    _profile = _profile.copyWith(sex: sex);
    notifyListeners();
  }

  void setHeight(double heightCm) {
    _profile = _profile.copyWith(heightCm: heightCm);
    notifyListeners();
  }

  void setWeight(double weightKg) {
    _profile = _profile.copyWith(weightKg: weightKg);
    notifyListeners();
  }

  void setActivityLevel(ActivityLevel level) {
    _profile = _profile.copyWith(activityLevel: level);
    notifyListeners();
  }

  void setTrainingAge(TrainingAge trainingAge) {
    _profile = _profile.copyWith(trainingAge: trainingAge);
    notifyListeners();
  }

  void setDietType(DietType type) {
    _profile = _profile.copyWith(dietType: type);
    notifyListeners();
  }

  void setFoodBudget(FoodBudget budget) {
    _profile = _profile.copyWith(foodBudget: budget);
    notifyListeners();
  }

  void setGymAccess(GymAccess access) {
    _profile = _profile.copyWith(gymAccess: access);
    notifyListeners();
  }

  void setGoalType(GoalType goal) {
    _profile = _profile.copyWith(goalType: goal);
    notifyListeners();
  }

  void toggleInjury(String injury) {
    final injuries = List<String>.from(_profile.injuries);
    if (injuries.contains(injury)) {
      injuries.remove(injury);
    } else {
      injuries.add(injury);
    }
    _profile = _profile.copyWith(injuries: injuries);
    notifyListeners();
  }

  // ─── Navigation ───────────────────────────────────────

  bool get canGoNext {
    switch (_currentStep) {
      case 0: // sex
        return _profile.sex != null;
      case 1: // age
        return _profile.age != null;
      case 2: // height & weight
        return _profile.heightCm != null && _profile.weightKg != null;
      case 3: // activity level
        return _profile.activityLevel != null;
      case 4: // training age
        return _profile.trainingAge != null;
      case 5: // diet type
        return _profile.dietType != null;
      case 6: // food budget
        return _profile.foodBudget != null;
      case 7: // gym access
        return _profile.gymAccess != null;
      case 8: // goal type
        return _profile.goalType != null;
      default:
        return false;
    }
  }

  void nextStep() {
    if (_currentStep < totalSteps - 1) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  /// Compute the final profile and trigger reveal animation.
  Future<void> finalize() async {
    _profile = TdeeEngine.computeFullProfile(_profile);
    _isRevealing = true;
    notifyListeners();

    // Save
    await _saveProfile();

    // After reveal completes
    await Future.delayed(const Duration(milliseconds: 3500));
    _isComplete = true;
    _isRevealing = false;
    notifyListeners();
  }
}
