import 'package:flutter/material.dart';
import 'package:invincible/core/theme/app_haptics.dart';
import 'package:invincible/core/theme/app_theme.dart';

/// Scroll-wheel picker for numeric values (height, weight, age).
/// Tactile, fast — no keyboard friction as per the plan.
class ScrollWheelPicker extends StatefulWidget {
  final int minValue;
  final int maxValue;
  final int initialValue;
  final String unit;
  final String? label;
  final ValueChanged<int> onChanged;
  final double itemExtent;

  const ScrollWheelPicker({
    super.key,
    required this.minValue,
    required this.maxValue,
    required this.initialValue,
    required this.unit,
    this.label,
    required this.onChanged,
    this.itemExtent = 56,
  });

  @override
  State<ScrollWheelPicker> createState() => _ScrollWheelPickerState();
}

class _ScrollWheelPickerState extends State<ScrollWheelPicker> {
  late FixedExtentScrollController _controller;
  late int _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
    _controller = FixedExtentScrollController(
      initialItem: widget.initialValue - widget.minValue,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
        ],
        SizedBox(
          height: widget.itemExtent * 3, // show 3 items
          child: Stack(
            children: [
              // Selection highlight
              Center(
                child: Container(
                  height: widget.itemExtent,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
              // Wheel
              ListWheelScrollView.useDelegate(
                controller: _controller,
                itemExtent: widget.itemExtent,
                perspective: 0.003,
                diameterRatio: 2.0,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (index) {
                  AppHaptics.selection();
                  setState(() {
                    _selectedValue = widget.minValue + index;
                  });
                  widget.onChanged(_selectedValue);
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: widget.maxValue - widget.minValue + 1,
                  builder: (context, index) {
                    final value = widget.minValue + index;
                    final isSelected = value == _selectedValue;
                    return Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: isSelected ? 32 : 20,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w400,
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.textTertiary.withValues(alpha: 0.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text('$value'),
                            if (isSelected) ...[
                              const SizedBox(width: 4),
                              Text(
                                widget.unit,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.accent.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
