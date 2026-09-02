import 'package:flutter/material.dart';
import 'package:invincible/core/theme/app_theme.dart';

class InsightCard extends StatelessWidget {
  final VoidCallback onDismiss;

  const InsightCard({super.key, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.accent, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Weekly Recalibration',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onDismiss,
                child: const Icon(Icons.close, color: AppColors.textTertiary, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Your weight trend was flat over the last 7 days. We\'ve increased your daily calorie surplus by 150 kcal to break the plateau and restart growth.',
            style: TextStyle(
              color: AppColors.textPrimary,
              height: 1.4,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatBadge(label: 'Old Target', value: '2400'),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.arrow_forward, color: AppColors.textTertiary, size: 16),
              ),
              _StatBadge(label: 'New Target', value: '2550', isHighlight: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;

  const _StatBadge({
    required this.label,
    required this.value,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isHighlight ? AppColors.accent.withValues(alpha: 0.2) : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isHighlight ? AppColors.accent : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
