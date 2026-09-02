import 'package:flutter/material.dart';
import 'package:invincible/core/theme/app_haptics.dart';
import 'package:invincible/core/theme/app_theme.dart';
import 'package:invincible/features/nutrition/widgets/home_cooking_grid.dart';
import 'package:invincible/features/nutrition/widgets/calorie_floor_alert.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  // Mock data for alert
  bool _showFloorAlert = true;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nutrition'),
          bottom: TabBar(
            onTap: (_) => AppHaptics.selection(),
            indicatorColor: AppColors.accent,
            labelColor: AppColors.accent,
            unselectedLabelColor: AppColors.textTertiary,
            tabs: const [
              Tab(text: 'Home Cooking'),
              Tab(text: 'Barcode'),
              Tab(text: 'Search'),
            ],
          ),
        ),
        body: Column(
          children: [
            if (_showFloorAlert)
              CalorieFloorAlert(
                deficit: 450,
                onLog: () {
                  setState(() => _showFloorAlert = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logged! Surplus gap closed.')),
                  );
                },
              ),
            
            const Expanded(
              child: TabBarView(
                children: [
                  HomeCookingGrid(),
                  _BarcodeScannerTab(),
                  _SearchTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarcodeScannerTab extends StatelessWidget {
  const _BarcodeScannerTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_scanner, size: 80, color: AppColors.textTertiary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text('Scan a barcode to log instantly', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceLight,
              foregroundColor: AppColors.textPrimary,
            ),
            onPressed: () {},
            child: const Text('Open Camera'),
          ),
        ],
      ),
    );
  }
}

class _SearchTab extends StatelessWidget {
  const _SearchTab();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search foods...',
              prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Icon(Icons.search, size: 64, color: AppColors.surfaceLight),
          const SizedBox(height: 16),
          const Text('Search over 1M+ foods', style: TextStyle(color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}
