import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:invincible/core/theme/app_theme.dart';
import 'package:invincible/core/models/workout_models.dart';
import 'package:invincible/features/training/training_provider.dart';

class TemplateBuilderScreen extends StatefulWidget {
  const TemplateBuilderScreen({super.key});

  @override
  State<TemplateBuilderScreen> createState() => _TemplateBuilderScreenState();
}

class _TemplateBuilderScreenState extends State<TemplateBuilderScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<Exercise> _selectedExercises = [];

  void _addExercise(Exercise exercise) {
    setState(() {
      _selectedExercises.add(exercise);
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _selectedExercises.removeAt(index);
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _selectedExercises.removeAt(oldIndex);
      _selectedExercises.insert(newIndex, item);
    });
  }

  void _saveTemplate() {
    if (_nameController.text.isEmpty || _selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name and add exercises')),
      );
      return;
    }

    final provider = context.read<TrainingProvider>();
    final template = WorkoutTemplate(
      name: _nameController.text,
      exercises: List.from(_selectedExercises),
    );
    
    // In a real app, this would save to the local DB through a repository.
    // For now we'll just add it to the provider's mock list.
    setState(() {
      provider.templates.add(template);
    });
    
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Build Template'),
        actions: [
          TextButton(
            onPressed: _saveTemplate,
            child: const Text('SAVE', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'e.g. Pull Day, Leg Day',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('EXERCISES', style: Theme.of(context).textTheme.labelSmall),
                TextButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: AppColors.background,
                      builder: (context) => _ExerciseLibrarySheet(
                        onExerciseSelected: (ex) {
                          _addExercise(ex);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, size: 16, color: AppColors.accent),
                  label: const Text('Add', style: TextStyle(color: AppColors.accent)),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: _selectedExercises.isEmpty
                ? const Center(child: Text('Tap Add to select exercises', style: TextStyle(color: AppColors.textTertiary)))
                : ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _selectedExercises.length,
                    onReorder: _onReorder,
                    itemBuilder: (context, index) {
                      final ex = _selectedExercises[index];
                      return Card(
                        key: ValueKey('${ex.id}_$index'),
                        margin: const EdgeInsets.only(bottom: 8),
                        color: AppColors.surface,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.drag_indicator, color: AppColors.textTertiary, size: 20),
                          ),
                          title: Text(ex.name, style: Theme.of(context).textTheme.bodyLarge),
                          subtitle: Text(
                            ex.primaryMuscle.name.toUpperCase(),
                            style: const TextStyle(color: AppColors.accent, fontSize: 10),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: AppColors.warning),
                            onPressed: () => _removeExercise(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseLibrarySheet extends StatelessWidget {
  final ValueChanged<Exercise> onExerciseSelected;

  const _ExerciseLibrarySheet({required this.onExerciseSelected});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TrainingProvider>();
    final exercises = provider.exerciseLibrary;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.surfaceBorder, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Text('Exercise Library', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final ex = exercises[index];
                    return ListTile(
                      title: Text(ex.name),
                      subtitle: Text(ex.primaryMuscle.name, style: const TextStyle(color: AppColors.textTertiary)),
                      trailing: const Icon(Icons.add_circle_outline, color: AppColors.accent),
                      onTap: () => onExerciseSelected(ex),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
