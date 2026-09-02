import 'package:flutter/services.dart';

/// Centralized haptic feedback controller providing crisp tactile feedback across Invincible.
class AppHaptics {
  /// Subtle click for tab switches, segmented buttons, sliders, selection changes.
  static void selection() {
    HapticFeedback.selectionClick();
  }

  /// Light tactile tap for normal buttons, cards, pills, icon buttons.
  static void light() {
    HapticFeedback.lightImpact();
  }

  /// Medium solid bump for significant actions (Start workout, Add food, Complete set, Send message).
  static void medium() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy impact for hero milestones (Workout finished, AI check-in completed, Goal reached).
  static void heavy() {
    HapticFeedback.heavyImpact();
  }

  /// Double vibration pulse for alarms, timer zero, warning alerts.
  static void vibrate() {
    HapticFeedback.vibrate();
  }
}
