import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:flutter/material.dart';

import 'package:invincible/core/theme/app_haptics.dart';
import 'package:invincible/core/theme/app_theme.dart';
import 'package:invincible/features/dashboard/screens/dashboard_screen.dart';
import 'package:invincible/features/training/screens/training_screen.dart';
import 'package:invincible/features/nutrition/screens/nutrition_screen.dart';
import 'package:invincible/features/progress/screens/progress_screen.dart';
import 'package:invincible/features/learn/screens/learn_screen.dart';
import 'package:invincible/features/coach/widgets/coach_chat_sheet.dart';

/// App shell with full-width circular bottom navigation bar (circle_nav_bar).
/// Tabs: Home, Train, Nutrition, Progress, Learn.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    TrainingScreen(),
    NutritionScreen(),
    ProgressScreen(),
    LearnScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.black,
        elevation: 6,
        onPressed: () {
          AppHaptics.medium();
          CoachChatSheet.show(context);
        },
        child: const Icon(Icons.smart_toy_rounded),
      ),
      bottomNavigationBar: CircleNavBar(
        activeIcons: const [
          Icon(Icons.home_rounded, color: Colors.black, size: 26),
          Icon(Icons.fitness_center_rounded, color: Colors.black, size: 24),
          Icon(Icons.restaurant_rounded, color: Colors.black, size: 24),
          Icon(Icons.timeline_rounded, color: Colors.black, size: 26),
          Icon(Icons.school_rounded, color: Colors.black, size: 24),
        ],
        inactiveIcons: const [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home_outlined, color: AppColors.textTertiary, size: 20),
              SizedBox(height: 2),
              Text('Home', style: TextStyle(color: AppColors.textTertiary, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fitness_center_outlined, color: AppColors.textTertiary, size: 20),
              SizedBox(height: 2),
              Text('Train', style: TextStyle(color: AppColors.textTertiary, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.restaurant_outlined, color: AppColors.textTertiary, size: 20),
              SizedBox(height: 2),
              Text('Eats', style: TextStyle(color: AppColors.textTertiary, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timeline_outlined, color: AppColors.textTertiary, size: 20),
              SizedBox(height: 2),
              Text('Track', style: TextStyle(color: AppColors.textTertiary, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school_outlined, color: AppColors.textTertiary, size: 20),
              SizedBox(height: 2),
              Text('Learn', style: TextStyle(color: AppColors.textTertiary, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
        color: AppColors.surface,
        circleColor: AppColors.accent,
        height: 64,
        circleWidth: 54,
        activeIndex: _currentIndex,
        onTap: (index) {
          AppHaptics.selection();
          setState(() => _currentIndex = index);
        },
        padding: EdgeInsets.zero, // Occupies 100% full device width!
        cornerRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        shadowColor: AppColors.accent.withValues(alpha: 0.25),
        elevation: 10,
      ),
    );
  }
}
