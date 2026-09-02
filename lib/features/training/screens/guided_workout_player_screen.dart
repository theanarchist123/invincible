import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invincible/core/models/guided_routine_models.dart';
import 'package:invincible/core/theme/app_theme.dart';
import 'package:invincible/features/training/widgets/exercise_animation_widget.dart';
import 'package:invincible/features/training/widgets/exercise_video_player.dart';

enum PlayerState {
  getReady,
  active,
  resting,
  completed,
}

class GuidedWorkoutPlayerScreen extends StatefulWidget {
  final GuidedWorkoutRoutine? routine;
  final List<RoutineExercise> exercises;
  final int initialExerciseIndex;

  const GuidedWorkoutPlayerScreen({
    super.key,
    this.routine,
    required this.exercises,
    this.initialExerciseIndex = 0,
  });

  @override
  State<GuidedWorkoutPlayerScreen> createState() => _GuidedWorkoutPlayerScreenState();
}

class _GuidedWorkoutPlayerScreenState extends State<GuidedWorkoutPlayerScreen> with TickerProviderStateMixin {
  late int _currentIndex;
  late PlayerState _state;
  late int _secondsRemaining;
  late int _totalDurationForCurrent;
  Timer? _timer;
  bool _isPaused = false;
  bool _soundEnabled = true;

  // Stats accumulator
  int _totalSecondsElapsed = 0;
  int _totalCaloriesBurned = 0;

  // Get ready countdown state
  int _getReadySeconds = 3;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialExerciseIndex;
    _startGetReadyCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startGetReadyCountdown() {
    setState(() {
      _state = PlayerState.getReady;
      _getReadySeconds = 3;
    });

    HapticFeedback.mediumImpact();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_getReadySeconds > 1) {
        setState(() {
          _getReadySeconds--;
        });
        HapticFeedback.selectionClick();
      } else {
        timer.cancel();
        _startExercise();
      }
    });
  }

  void _startExercise() {
    final currentExercise = widget.exercises[_currentIndex];
    setState(() {
      _state = PlayerState.active;
      _isPaused = false;
      _secondsRemaining = currentExercise.durationSeconds;
      _totalDurationForCurrent = currentExercise.durationSeconds;
    });

    HapticFeedback.heavyImpact();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused) return;

      _totalSecondsElapsed++;

      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });

        // 3-2-1 countdown cue
        if (_secondsRemaining <= 3) {
          HapticFeedback.mediumImpact();
        }
      } else {
        timer.cancel();
        _onExerciseFinished();
      }
    });
  }

  void _onExerciseFinished() {
    final currentExercise = widget.exercises[_currentIndex];
    _totalCaloriesBurned += currentExercise.calories;
    HapticFeedback.vibrate();

    final hasMore = _currentIndex < widget.exercises.length - 1;

    if (hasMore) {
      _startRestInterval(currentExercise.restSeconds);
    } else {
      _finishWorkout();
    }
  }

  void _startRestInterval(int restDuration) {
    setState(() {
      _state = PlayerState.resting;
      _isPaused = false;
      _secondsRemaining = restDuration;
      _totalDurationForCurrent = restDuration;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused) return;

      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
        if (_secondsRemaining <= 3) {
          HapticFeedback.selectionClick();
        }
      } else {
        timer.cancel();
        setState(() {
          _currentIndex++;
        });
        _startExercise();
      }
    });
  }

  void _skipRest() {
    _timer?.cancel();
    setState(() {
      _currentIndex++;
    });
    _startExercise();
  }

  void _addRestSeconds(int seconds) {
    setState(() {
      _secondsRemaining += seconds;
      _totalDurationForCurrent += seconds;
    });
    HapticFeedback.lightImpact();
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
    HapticFeedback.selectionClick();
  }

  void _skipNextExercise() {
    _timer?.cancel();
    if (_currentIndex < widget.exercises.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _startExercise();
    } else {
      _finishWorkout();
    }
  }

  void _previousExercise() {
    if (_currentIndex > 0) {
      _timer?.cancel();
      setState(() {
        _currentIndex--;
      });
      _startExercise();
    }
  }

  void _restartCurrentExercise() {
    _timer?.cancel();
    _startExercise();
  }

  void _finishWorkout() {
    _timer?.cancel();
    setState(() {
      _state = PlayerState.completed;
    });
    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: switch (_state) {
          PlayerState.getReady => _buildGetReadyView(),
          PlayerState.active => _buildActiveExerciseView(),
          PlayerState.resting => _buildRestingView(),
          PlayerState.completed => _buildCompletedView(),
        },
      ),
    );
  }

  // ----------------------------------------------------
  // GET READY VIEW (3... 2... 1...)
  // ----------------------------------------------------
  Widget _buildGetReadyView() {
    final currentExercise = widget.exercises[_currentIndex];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'GET READY!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            currentExercise.name.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${currentExercise.durationSeconds} SECONDS',
            style: const TextStyle(color: AppColors.textTertiary, letterSpacing: 1.5),
          ),
          const SizedBox(height: 48),
          // Big pulsing countdown number
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(color: AppColors.accent, width: 4),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.4),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$_getReadySeconds',
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w900,
                  color: AppColors.accent,
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              currentExercise.tips,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // ACTIVE EXERCISE VIEW
  // ----------------------------------------------------
  Widget _buildActiveExerciseView() {
    final currentExercise = widget.exercises[_currentIndex];
    final progress = _totalDurationForCurrent > 0 ? (_secondsRemaining / _totalDurationForCurrent) : 0.0;

    return Column(
      children: [
        // Top App Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () => _showExitDialog(),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Text(
                  widget.routine != null
                      ? 'EXERCISE ${_currentIndex + 1} OF ${widget.exercises.length}'
                      : 'DRILL',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  _soundEnabled ? Icons.volume_up : Icons.volume_off,
                  color: _soundEnabled ? AppColors.accent : AppColors.textTertiary,
                ),
                onPressed: () {
                  setState(() => _soundEnabled = !_soundEnabled);
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Exercise Title & Target Muscles
        Text(
          currentExercise.name,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          currentExercise.targetMuscles,
          style: const TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 16),

        // Live 16:9 Video & 3D Demonstration
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ExerciseVideoPlayer(
            exercise: currentExercise,
            autoPlay: !_isPaused,
          ),
        ),

        const Spacer(),

        // Circular Timer Countdown Display
        SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 8,
                backgroundColor: AppColors.surfaceLight,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _secondsRemaining <= 5 ? AppColors.error : AppColors.accent,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$_secondsRemaining',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: _secondsRemaining <= 5 ? AppColors.error : Colors.white,
                    ),
                  ),
                  const Text(
                    'SEC',
                    style: TextStyle(color: AppColors.textTertiary, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),

        const Spacer(),

        // Controls (Prev, Play/Pause, Restart, Next)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Previous
              IconButton(
                iconSize: 32,
                icon: const Icon(Icons.skip_previous_rounded, color: Colors.white70),
                onPressed: _currentIndex > 0 ? _previousExercise : null,
              ),

              // Restart
              IconButton(
                iconSize: 28,
                icon: const Icon(Icons.replay_rounded, color: Colors.white70),
                onPressed: _restartCurrentExercise,
              ),

              // Play / Pause FAB
              GestureDetector(
                onTap: _togglePause,
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.4),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                    color: Colors.black,
                    size: 38,
                  ),
                ),
              ),

              // Next / Skip
              IconButton(
                iconSize: 32,
                icon: const Icon(Icons.skip_next_rounded, color: Colors.white70),
                onPressed: _skipNextExercise,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------
  // REST INTERVAL VIEW
  // ----------------------------------------------------
  Widget _buildRestingView() {
    final nextExercise = widget.exercises[_currentIndex + 1];
    final progress = _totalDurationForCurrent > 0 ? (_secondsRemaining / _totalDurationForCurrent) : 0.0;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () => _showExitDialog(),
              ),
              const Text(
                'REST & RECOVER',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 48), // balance
            ],
          ),

          const SizedBox(height: 12),

          // Big Rest Timer Ring
          SizedBox(
            width: 130,
            height: 130,
            child: Stack(
              alignment: Alignment.center,
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: AppColors.surfaceLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$_secondsRemaining',
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const Text('REST', style: TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Rest Controls (+10s and Skip)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.surfaceBorder),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _addRestSeconds(10),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('+10 SEC'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _skipRest,
                icon: const Icon(Icons.fast_forward_rounded, size: 18),
                label: const Text('SKIP REST', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Next Up Preview Card
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.arrow_forward_rounded, color: AppColors.accent, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'NEXT UP: ${nextExercise.name.toUpperCase()}',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 1,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${nextExercise.durationSeconds}s',
                        style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ExerciseAnimationWidget(
                      animationType: nextExercise.animationType,
                      height: 160,
                      isPlaying: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // COMPLETED SUMMARY VIEW
  // ----------------------------------------------------
  Widget _buildCompletedView() {
    final minutes = _totalSecondsElapsed ~/ 60;
    final seconds = _totalSecondsElapsed % 60;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.15),
                border: Border.all(color: AppColors.accent, width: 2),
              ),
              child: const Icon(Icons.emoji_events_rounded, color: AppColors.accent, size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              'WORKOUT COMPLETE!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.routine?.title ?? 'Single Drill Completed',
              style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Frame built. Consistency unlocked.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 36),

            // Stat Cards Grid
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.timer,
                    label: 'TOTAL TIME',
                    value: '${minutes}m ${seconds}s',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.local_fire_department,
                    label: 'CALORIES',
                    value: '$_totalCaloriesBurned kcal',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.fitness_center,
                    label: 'EXERCISES',
                    value: '${widget.exercises.length}',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 48),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'FINISH & RECORD',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitDialog() {
    _timer?.cancel();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Quit Workout?'),
        content: const Text('Your current progress in this workout will be lost.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              if (_state == PlayerState.active) {
                _startExercise();
              } else if (_state == PlayerState.resting) {
                _startRestInterval(_secondsRemaining);
              }
            },
            child: const Text('RESUME', style: TextStyle(color: AppColors.accent)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // exit player
            },
            child: const Text('QUIT', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.accent, size: 22),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.textTertiary, letterSpacing: 1),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
