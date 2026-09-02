import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:invincible/core/theme/app_theme.dart';
import 'package:invincible/core/theme/app_haptics.dart';
import 'package:invincible/features/onboarding/onboarding_provider.dart';
import 'package:invincible/features/onboarding/screens/onboarding_screen.dart';
import 'package:invincible/features/shell/app_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _animationController.repeat(reverse: true);
    
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final provider = context.read<OnboardingProvider>();
    
    // We want the splash screen to be visible for at least 3 seconds 
    // so the user can admire the stunning UI.
    final startTime = DateTime.now();
    await provider.tryLoadProfile();
    final elapsed = DateTime.now().difference(startTime);
    final minDuration = const Duration(milliseconds: 3500);
    
    if (elapsed < minDuration) {
      await Future.delayed(minDuration - elapsed);
    }
    
    if (!mounted) return;

    AppHaptics.heavy();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1200),
        pageBuilder: (context, animation, secondaryAnimation) {
          if (provider.isComplete) {
            return const AppShell();
          }
          return OnboardingScreen(
            onComplete: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const AppShell()),
              );
            },
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Stunning dark aesthetic gym photo from Unsplash
    const bgUrl = 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&w=1470&q=80';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.network(
            bgUrl,
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.5),
            colorBlendMode: BlendMode.darken,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const ColoredBox(color: AppColors.background);
            },
          ),
          
          // Blur & Gradient overlay for depth
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.background.withOpacity(0.3),
                    AppColors.background.withOpacity(0.8),
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ),
          
          // Center Animated Logo
          Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Use the user's provided logo
                  Image.asset(
                    'assets/images/logo.png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'INVINCIBLE',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 8.0,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'EMBRACE THE STRUGGLE',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 4.0,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Loader
          Positioned(
            bottom: 60,
            left: 40,
            right: 40,
            child: Column(
              children: [
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    color: AppColors.accent,
                    strokeWidth: 2,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'LOADING ASSETS...',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2.0,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
