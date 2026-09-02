import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:invincible/core/theme/app_theme.dart';
import 'package:invincible/core/models/user_profile.dart';
import 'package:invincible/features/onboarding/onboarding_provider.dart';
import 'package:invincible/features/dashboard/widgets/consistency_ring.dart';
import 'package:invincible/features/dashboard/widgets/macro_card.dart';
import 'package:invincible/features/dashboard/widgets/insight_card.dart';

/// Main dashboard screen — the daily-use home screen.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _showInsight = true;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();
    final profile = provider.profile;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App bar
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textTertiary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Invincible',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // AI Coach button
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: AppColors.accent,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_showInsight)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: InsightCard(
                    onDismiss: () => setState(() => _showInsight = false),
                  ),
                ),
              ),

            // Hero stats row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    // Consistency ring
                    const ConsistencyRing(
                      filledDays: 3, // Placeholder
                      size: 90,
                    ),
                    const SizedBox(width: 16),
                    // Quick stats
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _QuickStat(
                            label: 'Target',
                            value:
                                '${profile.targetCalories ?? 0} kcal',
                            icon: Icons.local_fire_department_rounded,
                            color: AppColors.warm,
                          ),
                          const SizedBox(height: 8),
                          _QuickStat(
                            label: 'Surplus',
                            value:
                                '+${profile.surplusCalories ?? 0} kcal',
                            icon: Icons.trending_up_rounded,
                            color: AppColors.accent,
                          ),
                          const SizedBox(height: 8),
                          _QuickStat(
                            label: 'Split',
                            value:
                                profile.trainingSplit?.label ?? '—',
                            icon: Icons.fitness_center_rounded,
                            color: const Color(0xFF57B8FF),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Macro card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: profile.macros != null
                    ? MacroCard(macros: profile.macros!)
                    : const SizedBox.shrink(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Quick start workout card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _WorkoutCard(profile: profile),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

class _QuickStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _QuickStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textTertiary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final UserProfile profile;

  const _WorkoutCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withValues(alpha: 0.08),
            AppColors.accent.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TODAY\'S SESSION',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textTertiary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _todaySession(profile),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '~60 min • ${_exerciseCount(profile)} exercises',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: AppColors.background,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  String _todaySession(UserProfile profile) {
    final day = DateTime.now().weekday; // 1=Mon, 7=Sun
    switch (profile.trainingSplit) {
      case TrainingSplit.ppl:
        final sessions = ['Push', 'Pull', 'Legs', 'Push', 'Pull', 'Legs', 'Rest'];
        return sessions[day - 1];
      case TrainingSplit.upperLower:
        final sessions = ['Upper', 'Lower', 'Rest', 'Upper', 'Lower', 'Rest', 'Rest'];
        return sessions[day - 1];
      case TrainingSplit.fullBody:
        final sessions = ['Full Body', 'Rest', 'Full Body', 'Rest', 'Full Body', 'Rest', 'Rest'];
        return sessions[day - 1];
      case TrainingSplit.bro:
        final sessions = ['Chest', 'Back', 'Shoulders', 'Arms', 'Legs', 'Rest', 'Rest'];
        return sessions[day - 1];
      case null:
        return 'Rest Day';
    }
  }

  int _exerciseCount(UserProfile profile) {
    switch (profile.trainingSplit) {
      case TrainingSplit.ppl:
        return 6;
      case TrainingSplit.upperLower:
        return 7;
      case TrainingSplit.fullBody:
        return 8;
      case TrainingSplit.bro:
        return 5;
      case null:
        return 0;
    }
  }
}
