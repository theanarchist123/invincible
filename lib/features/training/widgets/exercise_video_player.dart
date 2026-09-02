import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:invincible/core/models/guided_routine_models.dart';
import 'package:invincible/core/services/musclewiki_service.dart';
import 'package:invincible/core/theme/app_haptics.dart';
import 'package:invincible/core/theme/app_theme.dart';
import 'package:invincible/features/training/widgets/exercise_animation_widget.dart';

/// 16:9 Exercise Demonstration Player supporting real HD video streaming,
/// looping exercise demonstrations, 60fps 3D vector animation, YouTube-style auto-hiding controls, and Fullscreen mode.
class ExerciseVideoPlayer extends StatefulWidget {
  final RoutineExercise exercise;
  final bool autoPlay;
  final bool showControls;
  final double? width;

  const ExerciseVideoPlayer({
    super.key,
    required this.exercise,
    this.autoPlay = true,
    this.showControls = true,
    this.width,
  });

  @override
  State<ExerciseVideoPlayer> createState() => _ExerciseVideoPlayerState();
}

class _ExerciseVideoPlayerState extends State<ExerciseVideoPlayer> {
  VideoPlayerController? _videoController;
  String? _activeGifUrl;
  bool _isVideoInitialized = false;
  bool _hasVideoError = false;

  // Mode: Procedural 3D vs Real HD Video / Demonstration
  bool _showProceduralAnimation = false;

  // Auto-hiding controls (YouTube style)
  bool _controlsVisible = true;
  Timer? _autoHideTimer;

  // Multi-angle and model toggles
  bool _isMaleModel = true;
  bool _isFrontAngle = true;

  @override
  void initState() {
    super.initState();
    _checkAndInitMedia();
  }

  @override
  void didUpdateWidget(covariant ExerciseVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercise.id != widget.exercise.id) {
      _checkAndInitMedia();
    }
  }

  void _checkAndInitMedia() {
    final media = MuscleWikiService.getMediaForExercise(widget.exercise.name);
    if (media == null) {
      _videoController?.dispose();
      _videoController = null;
      setState(() {
        _activeGifUrl = null;
        _showProceduralAnimation = true;
        _isVideoInitialized = false;
        _hasVideoError = false;
      });
      _startAutoHideTimer();
    } else {
      _initializeMedia(media);
    }
  }

  Future<void> _initializeMedia(MuscleWikiExerciseMedia media) async {
    final videoUrl = media.getVideoUrl(isMale: _isMaleModel, isFront: _isFrontAngle);

    if (videoUrl == null) {
      setState(() {
        _showProceduralAnimation = true;
      });
      return;
    }

    final isGif = videoUrl.toLowerCase().endsWith('.gif');
    if (isGif) {
      _videoController?.dispose();
      _videoController = null;
      setState(() {
        _activeGifUrl = videoUrl;
        _showProceduralAnimation = false;
        _isVideoInitialized = true;
        _hasVideoError = false;
      });
      _startAutoHideTimer();
      return;
    }

    // MP4 Video Stream
    setState(() {
      _activeGifUrl = null;
      _isVideoInitialized = false;
      _hasVideoError = false;
    });

    _videoController?.dispose();
    _videoController = null;

    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      _videoController = controller;

      controller.addListener(() {
        if (controller.value.hasError && mounted) {
          setState(() {
            _hasVideoError = true;
            _showProceduralAnimation = true;
          });
        }
      });

      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0.0); // Muted by default for workout loops

      if (widget.autoPlay && mounted) {
        await controller.play();
      }

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
          _hasVideoError = false;
          _showProceduralAnimation = false;
        });
        _startAutoHideTimer();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasVideoError = true;
          _showProceduralAnimation = true;
        });
      }
    }
  }

  // --- AUTO-HIDE CONTROLS (YOUTUBE STYLE) ---
  void _startAutoHideTimer() {
    _autoHideTimer?.cancel();
    _autoHideTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _controlsVisible = false;
        });
      }
    });
  }

  void _onPlayerTapped() {
    AppHaptics.light();
    setState(() {
      _controlsVisible = !_controlsVisible;
    });

    if (_controlsVisible) {
      _startAutoHideTimer();
    } else {
      _autoHideTimer?.cancel();
    }
  }

  void _togglePlayPause() {
    if (_videoController == null || !_isVideoInitialized) return;
    AppHaptics.selection();
    setState(() {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
        _controlsVisible = true; // Keep controls visible while paused
        _autoHideTimer?.cancel();
      } else {
        _videoController!.play();
        _startAutoHideTimer();
      }
    });
  }

  void _toggleAngle() {
    AppHaptics.selection();
    _startAutoHideTimer();
    setState(() {
      _isFrontAngle = !_isFrontAngle;
    });
    final media = MuscleWikiService.getMediaForExercise(widget.exercise.name);
    if (media != null && !_showProceduralAnimation) {
      _initializeMedia(media);
    }
  }

  void _toggleGender() {
    AppHaptics.selection();
    _startAutoHideTimer();
    setState(() {
      _isMaleModel = !_isMaleModel;
    });
    final media = MuscleWikiService.getMediaForExercise(widget.exercise.name);
    if (media != null && !_showProceduralAnimation) {
      _initializeMedia(media);
    }
  }

  void _togglePlayerMode() {
    AppHaptics.medium();
    _startAutoHideTimer();

    if (_showProceduralAnimation) {
      // User wants to switch to visual demonstration
      final media = MuscleWikiService.getMediaForExercise(widget.exercise.name);
      if (media == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.surface,
            duration: const Duration(seconds: 3),
            content: Text(
              'Showing 100% accurate 3D animation for ${widget.exercise.name}.',
              style: const TextStyle(color: AppColors.accent, fontSize: 12),
            ),
          ),
        );
        return;
      }
      setState(() {
        _showProceduralAnimation = false;
      });
      _initializeMedia(media);
    } else {
      // Switch to 3D Cyber animation
      setState(() {
        _showProceduralAnimation = true;
      });
      _videoController?.pause();
    }
  }

  void _openFullscreen() {
    AppHaptics.heavy();
    _autoHideTimer?.cancel();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullscreenExercisePlayerScreen(
          exercise: widget.exercise,
          videoController: _videoController,
          activeGifUrl: _activeGifUrl,
          showProceduralAnimation: _showProceduralAnimation,
          isMaleModel: _isMaleModel,
          isFrontAngle: _isFrontAngle,
          onAngleToggle: _toggleAngle,
          onGenderToggle: _toggleGender,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _autoHideTimer?.cancel();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double aspectRatio = 16 / 9;

    return Container(
      width: widget.width ?? double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF16191B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _onPlayerTapped,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Procedural 3D Cyber Animation
                if (_showProceduralAnimation || _hasVideoError)
                  ExerciseAnimationWidget(
                    animationType: widget.exercise.animationType,
                    isPlaying: true,
                  )
                // 2. Real GIF Exercise Demonstration
                else if (_activeGifUrl != null)
                  Container(
                    color: const Color(0xFF16191B),
                    alignment: Alignment.center,
                    child: Image.network(
                      _activeGifUrl!,
                      fit: BoxFit.contain,
                      loadingBuilder: (ctx, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.accent),
                          ),
                        );
                      },
                      errorBuilder: (ctx, err, stack) {
                        return ExerciseAnimationWidget(
                          animationType: widget.exercise.animationType,
                          isPlaying: true,
                        );
                      },
                    ),
                  )
                // 3. Real HD MP4 Video Stream
                else if (_isVideoInitialized && _videoController != null)
                  FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoController!.value.size.width,
                      height: _videoController!.value.size.height,
                      child: VideoPlayer(_videoController!),
                    ),
                  )
                // 4. Loading Buffer Spinner
                else
                  Container(
                    color: const Color(0xFF141618),
                    child: const Center(
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.accent),
                      ),
                    ),
                  ),

                // 5. Center Play / Pause indicator (visible when tapped while in video mode)
                if (!_showProceduralAnimation && _activeGifUrl == null && _isVideoInitialized && _videoController != null)
                  AnimatedOpacity(
                    opacity: _controlsVisible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: Center(
                      child: GestureDetector(
                        onTap: _togglePlayPause,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.65),
                            border: Border.all(color: AppColors.accent, width: 2),
                          ),
                          child: Icon(
                            _videoController!.value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: AppColors.accent,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),

                // 6. AUTO-HIDING OVERLAYS (YouTube Style):
                AnimatedOpacity(
                  opacity: _controlsVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: IgnorePointer(
                    ignoring: !_controlsVisible,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Gradient bottom scrim for readability
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 48,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.8),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Top Left Badge: Format Tag
                        Positioned(
                          top: 10,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.surfaceBorder),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.accent,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _showProceduralAnimation
                                      ? '3D CYBER LOOP'
                                      : (_activeGifUrl != null ? 'EXERCISE DEMO' : '16:9 HD VIDEO'),
                                  style: const TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Top Right: Mode Switcher Button
                        Positioned(
                          top: 8,
                          right: 10,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: _togglePlayerMode,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.surface.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.6)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _showProceduralAnimation ? Icons.videocam : Icons.auto_awesome,
                                      size: 14,
                                      color: AppColors.accent,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _showProceduralAnimation ? 'SWITCH TO DEMO' : 'SWITCH TO 3D',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Bottom Bar: Controls & Fullscreen Button
                        if (widget.showControls)
                          Positioned(
                            bottom: 8,
                            left: 12,
                            right: 10,
                            child: Row(
                              children: [
                                if (!_showProceduralAnimation && _activeGifUrl == null) ...[
                                  _ControlPill(
                                    label: _isFrontAngle ? 'FRONT VIEW' : 'SIDE VIEW',
                                    icon: Icons.threed_rotation_rounded,
                                    onTap: _toggleAngle,
                                  ),
                                  const SizedBox(width: 6),
                                  _ControlPill(
                                    label: _isMaleModel ? 'MALE' : 'FEMALE',
                                    icon: Icons.person_outline,
                                    onTap: _toggleGender,
                                  ),
                                ],
                                const Spacer(),
                                // Fullscreen expand button
                                GestureDetector(
                                  onTap: _openFullscreen,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.75),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.white24),
                                    ),
                                    child: const Icon(
                                      Icons.fullscreen_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ControlPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ControlPill({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.accent, size: 12),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dedicated Fullscreen Exercise Player Screen (with auto-hiding controls & clean viewing)
class FullscreenExercisePlayerScreen extends StatefulWidget {
  final RoutineExercise exercise;
  final VideoPlayerController? videoController;
  final String? activeGifUrl;
  final bool showProceduralAnimation;
  final bool isMaleModel;
  final bool isFrontAngle;
  final VoidCallback onAngleToggle;
  final VoidCallback onGenderToggle;

  const FullscreenExercisePlayerScreen({
    super.key,
    required this.exercise,
    required this.videoController,
    this.activeGifUrl,
    required this.showProceduralAnimation,
    required this.isMaleModel,
    required this.isFrontAngle,
    required this.onAngleToggle,
    required this.onGenderToggle,
  });

  @override
  State<FullscreenExercisePlayerScreen> createState() => _FullscreenExercisePlayerScreenState();
}

class _FullscreenExercisePlayerScreenState extends State<FullscreenExercisePlayerScreen> {
  bool _controlsVisible = true;
  Timer? _autoHideTimer;

  @override
  void initState() {
    super.initState();
    _startAutoHide();
  }

  void _startAutoHide() {
    _autoHideTimer?.cancel();
    _autoHideTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _controlsVisible = false;
        });
      }
    });
  }

  void _onScreenTap() {
    AppHaptics.light();
    setState(() {
      _controlsVisible = !_controlsVisible;
    });
    if (_controlsVisible) {
      _startAutoHide();
    } else {
      _autoHideTimer?.cancel();
    }
  }

  @override
  void dispose() {
    _autoHideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _onScreenTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Main Media Display
              Center(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: widget.showProceduralAnimation
                      ? ExerciseAnimationWidget(
                          animationType: widget.exercise.animationType,
                          isPlaying: true,
                        )
                      : widget.activeGifUrl != null
                          ? Container(
                              color: Colors.black,
                              alignment: Alignment.center,
                              child: Image.network(
                                widget.activeGifUrl!,
                                fit: BoxFit.contain,
                              ),
                            )
                          : widget.videoController != null
                              ? FittedBox(
                                  fit: BoxFit.contain,
                                  child: SizedBox(
                                    width: widget.videoController!.value.size.width,
                                    height: widget.videoController!.value.size.height,
                                    child: VideoPlayer(widget.videoController!),
                                  ),
                                )
                              : ExerciseAnimationWidget(
                                  animationType: widget.exercise.animationType,
                                  isPlaying: true,
                                ),
                ),
              ),

              // Auto-hiding Overlays (YouTube style)
              AnimatedOpacity(
                opacity: _controlsVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: IgnorePointer(
                  ignoring: !_controlsVisible,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Bar: Exit button & Exercise Name
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.85),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.fullscreen_exit_rounded, color: Colors.white, size: 28),
                              onPressed: () {
                                AppHaptics.selection();
                                Navigator.of(context).pop();
                              },
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.exercise.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  widget.exercise.targetMuscles,
                                  style: const TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.surfaceBorder),
                              ),
                              child: Text(
                                widget.showProceduralAnimation
                                    ? '3D LOOP'
                                    : (widget.activeGifUrl != null ? 'DEMO' : '16:9 HD'),
                                style: const TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Bottom Bar: Instructions
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.9),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Text(
                          widget.exercise.instructions,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
