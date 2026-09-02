import 'package:flutter/material.dart';
import 'package:invincible/core/theme/app_haptics.dart';
import 'package:invincible/core/theme/app_theme.dart';

class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  bool _isProcessing = false;

  void _simulateCapture() {
    AppHaptics.heavy();
    setState(() {
      _isProcessing = true;
    });
    
    // Simulate API delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context, true); // Return success
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Simulated Camera Preview
          Container(color: Colors.grey[900]),
          
          // Silhouette Guide Overlay
          CustomPaint(
            painter: _SilhouettePainter(),
          ),
          
          // Instructions
          const Positioned(
            top: 64,
            left: 0,
            right: 0,
            child: Text(
              'Line up with the guide',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: Colors.black, blurRadius: 4)],
              ),
            ),
          ),
          
          // Back Button
          Positioned(
            top: 54,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          
          // Capture Controls
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
                  onPressed: () {},
                ),
                GestureDetector(
                  onTap: _isProcessing ? null : _simulateCapture,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Center(
                      child: _isProcessing
                          ? const CircularProgressIndicator(color: AppColors.accent)
                          : Container(
                              width: 56,
                              height: 56,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.flash_off, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.accent),
                  SizedBox(height: 24),
                  Text('Analyzing Physique...', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    paint.style = PaintingStyle.stroke;
    
    // Draw a stylized generic male torso outline
    final path = Path();
    final centerX = size.width / 2;
    final topY = size.height * 0.15;
    final headRadius = size.width * 0.12;
    
    // Head
    path.addOval(Rect.fromCircle(center: Offset(centerX, topY + headRadius), radius: headRadius));
    
    // Shoulders & Torso
    path.moveTo(centerX - headRadius, topY + headRadius * 2);
    path.quadraticBezierTo(centerX - size.width * 0.3, topY + headRadius * 2.2, centerX - size.width * 0.35, topY + size.height * 0.25); // Left shoulder
    path.lineTo(centerX - size.width * 0.25, topY + size.height * 0.45); // Left hip
    path.lineTo(centerX + size.width * 0.25, topY + size.height * 0.45); // Right hip
    path.lineTo(centerX + size.width * 0.35, topY + size.height * 0.25); // Right shoulder
    path.quadraticBezierTo(centerX + size.width * 0.3, topY + headRadius * 2.2, centerX + headRadius, topY + headRadius * 2); // To neck
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
