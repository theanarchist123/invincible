import 'package:flutter/material.dart';
import 'package:invincible/core/theme/app_theme.dart';

class PlateCalculator extends StatefulWidget {
  final double initialWeight;
  final ValueChanged<double> onWeightSelected;

  const PlateCalculator({
    super.key,
    required this.initialWeight,
    required this.onWeightSelected,
  });

  @override
  State<PlateCalculator> createState() => _PlateCalculatorState();
}

class _PlateCalculatorState extends State<PlateCalculator> {
  late double _currentWeight;
  final double _barbellWeight = 20.0;
  
  final List<double> _availablePlates = [25, 20, 15, 10, 5, 2.5, 1.25];

  @override
  void initState() {
    super.initState();
    _currentWeight = widget.initialWeight;
  }

  void _addWeight(double amount) {
    setState(() {
      _currentWeight += amount;
    });
  }
  
  void _subtractWeight(double amount) {
    setState(() {
      if (_currentWeight - amount >= _barbellWeight) {
        _currentWeight -= amount;
      } else {
        _currentWeight = _barbellWeight;
      }
    });
  }

  Map<double, int> _calculatePlates() {
    double weightToFill = (_currentWeight - _barbellWeight) / 2;
    Map<double, int> platesNeeded = {};

    for (var plate in _availablePlates) {
      if (weightToFill >= plate) {
        int count = (weightToFill / plate).floor();
        platesNeeded[plate] = count;
        weightToFill -= (plate * count);
      }
    }
    return platesNeeded;
  }

  @override
  Widget build(BuildContext context) {
    final plates = _calculatePlates();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Weight (kg)', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: AppColors.accent),
                iconSize: 32,
                onPressed: () => _subtractWeight(2.5), // Smallest jump is 2.5kg (1.25 each side)
              ),
              const SizedBox(width: 16),
              Text(
                _currentWeight.toStringAsFixed(1).replaceAll('.0', ''),
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: AppColors.accent),
                iconSize: 32,
                onPressed: () => _addWeight(2.5),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Visual Barbell
          Container(
            height: 100,
            width: double.infinity,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Left plates
                ..._availablePlates.where((p) => plates.containsKey(p)).map((p) {
                  return Row(
                    children: List.generate(plates[p]!, (_) => _PlateView(weight: p)),
                  );
                }),
                
                // Barbell Sleeve
                Container(width: 20, height: 16, color: Colors.grey[700]),
                // Barbell Center
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    border: Border.all(color: Colors.grey[600]!, width: 1),
                  ),
                  alignment: Alignment.center,
                  child: const Text('20kg', style: TextStyle(fontSize: 8, color: Colors.white54)),
                ),
                // Barbell Sleeve
                Container(width: 20, height: 16, color: Colors.grey[700]),
                
                // Right plates
                ..._availablePlates.where((p) => plates.containsKey(p)).map((p) {
                  return Row(
                    children: List.generate(plates[p]!, (_) => _PlateView(weight: p)),
                  );
                }).toList().reversed,
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => widget.onWeightSelected(_currentWeight),
              child: const Text('CONFIRM WEIGHT', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlateView extends StatelessWidget {
  final double weight;
  
  const _PlateView({required this.weight});

  @override
  Widget build(BuildContext context) {
    // Determine plate size and color based on standard Olympic colors (approximate)
    double height = 80;
    Color color = Colors.black87;
    
    if (weight >= 20) { height = 90; color = Colors.blue[900]!; }
    else if (weight == 15) { height = 75; color = Colors.yellow[800]!; }
    else if (weight == 10) { height = 60; color = Colors.green[800]!; }
    else if (weight == 5) { height = 45; color = Colors.white; }
    else { height = 30; color = Colors.grey[400]!; }

    return Container(
      width: 12,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.white24, width: 0.5),
        borderRadius: BorderRadius.circular(2),
      ),
      alignment: Alignment.center,
      child: RotatedBox(
        quarterTurns: 1,
        child: Text(
          weight.toString().replaceAll('.0', ''),
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: weight == 5 || weight < 5 ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
}
