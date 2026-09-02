import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:invincible/core/theme/app_theme.dart';
import 'package:invincible/features/training/training_provider.dart';

class RestTimerBottomSheet extends StatelessWidget {
  const RestTimerBottomSheet({super.key});

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TrainingProvider>();
    final remaining = provider.restSecondsRemaining;
    final total = provider.totalRestSeconds;
    
    if (!provider.isRestTimerActive) return const SizedBox.shrink();

    final progress = total > 0 ? remaining / total : 0.0;

    return Container(
      height: 80,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Progress
          SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  backgroundColor: AppColors.surfaceBorder,
                  color: remaining <= 10 ? AppColors.warning : AppColors.accent,
                ),
                Center(
                  child: Icon(
                    Icons.timer_outlined,
                    size: 20,
                    color: remaining <= 10 ? AppColors.warning : AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          
          // Time text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('REST TIME', style: TextStyle(color: AppColors.textTertiary, fontSize: 10, fontWeight: FontWeight.bold)),
              Text(
                _formatTime(remaining),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: remaining <= 10 ? AppColors.warning : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const Spacer(),
          
          // Controls
          Row(
            children: [
              _TimerAdjustButton(
                icon: Icons.remove,
                onTap: () => provider.startRestTimer(remaining - 15 > 0 ? remaining - 15 : 0),
              ),
              const SizedBox(width: 8),
              _TimerAdjustButton(
                icon: Icons.add,
                onTap: () => provider.startRestTimer(remaining + 15),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textTertiary),
                onPressed: () => provider.stopRestTimer(),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _TimerAdjustButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TimerAdjustButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surfaceBorder.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: AppColors.textPrimary),
      ),
    );
  }
}
