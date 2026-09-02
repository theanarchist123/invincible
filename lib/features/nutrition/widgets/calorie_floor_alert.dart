import 'package:flutter/material.dart';
import 'package:invincible/core/theme/app_haptics.dart';
import 'package:invincible/core/theme/app_theme.dart';

class CalorieFloorAlert extends StatelessWidget {
  final int deficit;
  final VoidCallback onLog;

  const CalorieFloorAlert({
    super.key,
    required this.deficit,
    required this.onLog,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
              const SizedBox(width: 8),
              Text(
                'Low Calorie Floor',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.warning),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'You are $deficit kcal behind your bulk target today. To keep your surplus on track, here are some quick ways to close the gap:',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
          
          // Quick log suggestions
          _SuggestionRow(
            icon: Icons.bakery_dining,
            title: 'Peanut Butter',
            subtitle: '2 Tbsp (190 kcal)',
            onTap: onLog,
          ),
          const SizedBox(height: 8),
          _SuggestionRow(
            icon: Icons.local_drink,
            title: 'Banana Milkshake',
            subtitle: '1 Glass (250 kcal)',
            onTap: onLog,
          ),
        ],
      ),
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SuggestionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textTertiary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(subtitle, style: const TextStyle(color: AppColors.textTertiary, fontSize: 11)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.black,
              minimumSize: const Size(64, 32),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              AppHaptics.medium();
              onTap();
            },
            child: const Text('+ Add', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
