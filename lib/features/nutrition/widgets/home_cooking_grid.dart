import 'package:flutter/material.dart';
import 'package:invincible/core/theme/app_haptics.dart';
import 'package:invincible/core/theme/app_theme.dart';

class HomeCookingGrid extends StatelessWidget {
  const HomeCookingGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final commonDishes = [
      {'name': 'Dal Tadka', 'unit': 'Katori', 'cal': '150 kcal'},
      {'name': 'Paneer Tikka', 'unit': 'Pieces', 'cal': '280 kcal'},
      {'name': 'Roti', 'unit': 'Roti', 'cal': '110 kcal'},
      {'name': 'White Rice', 'unit': 'Katori', 'cal': '180 kcal'},
      {'name': 'Egg Curry', 'unit': 'Katori', 'cal': '220 kcal'},
      {'name': 'Oats', 'unit': 'Bowl', 'cal': '160 kcal'},
      {'name': 'Ghee', 'unit': 'Tbsp', 'cal': '112 kcal'},
      {'name': 'Chicken Curry', 'unit': 'Katori', 'cal': '250 kcal'},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: commonDishes.length,
      itemBuilder: (context, index) {
        final dish = commonDishes[index];
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fake image
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: const Icon(Icons.restaurant_menu, color: AppColors.textTertiary, size: 32),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dish['name']!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${dish['unit']} • ${dish['cal']}',
                      style: const TextStyle(color: AppColors.accent, fontSize: 10),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surfaceLight,
                          foregroundColor: AppColors.textPrimary,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          AppHaptics.medium();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Logged 1 ${dish['unit']} of ${dish['name']}')),
                          );
                        },
                        child: const Text('+ Add', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
