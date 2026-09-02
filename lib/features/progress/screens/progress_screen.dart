import 'package:flutter/material.dart';
import 'package:invincible/core/theme/app_haptics.dart';
import 'package:invincible/core/theme/app_theme.dart';
import 'package:invincible/features/progress/screens/camera_capture_screen.dart';
import 'package:invincible/features/progress/widgets/score_reveal_animation.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  bool _hasNewScore = false;

  void _openCamera() async {
    AppHaptics.medium();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CameraCaptureScreen()),
    );
    
    if (result == true) {
      AppHaptics.heavy();
      setState(() {
        _hasNewScore = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: _openCamera,
          ),
        ],
      ),
      body: _hasNewScore ? _buildScoreReveal() : _buildHistoricalView(),
    );
  }

  Widget _buildScoreReveal() {
    return Center(
      child: ScoreRevealAnimation(
        overallScore: 68,
        scores: const {
          'Shoulders': 7,
          'Chest': 6,
          'Arms': 8,
          'Legs': 5,
          'Back': 7,
        },
      ),
    );
  }

  Widget _buildHistoricalView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              const Text('CURRENT PHYSIQUE', style: TextStyle(color: AppColors.textTertiary, letterSpacing: 1)),
              const SizedBox(height: 16),
              const Text(
                '68',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _openCamera,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('AI CHECK-IN', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        Text('TIMELINE', style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 16),
        
        // Historical Filmstrip
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            itemBuilder: (context, index) {
              final dates = ['Today', 'Last Week', '2 Weeks Ago', 'Last Month'];
              final scores = [68, 65, 62, 58];
              
              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Fake photo background
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.grey[800]!,
                              Colors.grey[900]!,
                            ],
                          ),
                        ),
                        child: const Icon(Icons.person, size: 64, color: Colors.white24),
                      ),
                    ),
                    // Score Overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.black87, Colors.transparent],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dates[index],
                              style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
                            ),
                            Text(
                              scores[index].toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
