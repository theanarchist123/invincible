import 'package:flutter/material.dart';
import 'package:invincible/core/theme/app_haptics.dart';
import 'package:invincible/core/theme/app_theme.dart';

class GrowthWindowChecker extends StatefulWidget {
  const GrowthWindowChecker({super.key});

  @override
  State<GrowthWindowChecker> createState() => _GrowthWindowCheckerState();
}

class _GrowthWindowCheckerState extends State<GrowthWindowChecker> {
  double _age = 16.0;
  String _result = 'Likely Open';
  String _description = 'At 16, growth plates are typically still open. Proper nutrition and sleep are critical right now.';

  void _calculate() {
    setState(() {
      if (_age < 15) {
        _result = 'Open';
        _description = 'Your growth plates are open. This is the prime window for natural development. Maximize sleep and eat in a surplus.';
      } else if (_age >= 15 && _age <= 18) {
        _result = 'Likely Open / Closing';
        _description = 'Growth is slowing down but likely still possible. Only a bone-age X-ray can confirm exactly how much time is left.';
      } else if (_age > 18 && _age <= 21) {
        _result = 'Likely Closed';
        _description = 'Most males finish growing between 18 and 21. While late spurts happen, focus on building muscle mass rather than height now.';
      } else {
        _result = 'Closed';
        _description = 'Your growth plates are fused. Your skeletal frame is locked in. Your focus now is 100% on adding muscle mass to your frame.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Growth Plate Estimator',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'An honest, clinical look at your growth window based on age. No false hope.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 24),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Current Age', style: TextStyle(color: AppColors.textTertiary)),
              Text('${_age.toInt()} yrs', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          Slider(
            value: _age,
            min: 12,
            max: 25,
            divisions: 13,
            activeColor: AppColors.accent,
            onChanged: (val) {
              if (val.toInt() != _age.toInt()) {
                AppHaptics.selection();
              }
              setState(() {
                _age = val;
                _calculate();
              });
            },
          ),
          
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  _result,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _result.contains('Closed') ? AppColors.textSecondary : AppColors.accent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textTertiary, fontSize: 13),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          const Center(
            child: Text(
              '*For absolute certainty, request a bone-age X-ray from a doctor.',
              style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
            ),
          ),
        ],
      ),
    );
  }
}
