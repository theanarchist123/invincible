import 'package:flutter/material.dart';
import 'package:invincible/core/theme/app_theme.dart';
import 'package:invincible/features/learn/widgets/growth_window_checker.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn & Build'),
      ),
      body: PageView(
        scrollDirection: Axis.vertical,
        children: const [
          _MythCard(
            title: '"Lifting weights stunts your growth"',
            truth: 'FALSE. Resistance training increases bone mineral density. What stunts growth is poor nutrition and sleep deprivation during puberty, not lifting heavy things.',
            icon: Icons.fitness_center,
          ),
          _MythCard(
            title: '"You need to eat big to get big"',
            truth: 'PARTIALLY TRUE. You need a surplus, but a "dirty bulk" just adds fat. As a natural lifter, your body can only build a finite amount of muscle per week. A 200-300 kcal surplus is all you need.',
            icon: Icons.fastfood,
          ),
          GrowthWindowChecker(),
          _MythCard(
            title: '"I have a fast metabolism, I can\'t gain weight"',
            truth: 'FALSE. Your metabolism might run hot, but thermodynamics always wins. You simply aren\'t eating as much as you think you are. Track everything for 3 days and prove it.',
            icon: Icons.local_fire_department,
          ),
        ],
      ),
    );
  }
}

class _MythCard extends StatelessWidget {
  final String title;
  final String truth;
  final IconData icon;

  const _MythCard({
    required this.title,
    required this.truth,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: AppColors.accent.withValues(alpha: 0.5)),
          const SizedBox(height: 32),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: AppColors.surfaceLight),
          const SizedBox(height: 24),
          Text(
            truth,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
