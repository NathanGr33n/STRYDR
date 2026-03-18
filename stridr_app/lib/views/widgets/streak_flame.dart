import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class StreakFlame extends StatelessWidget {
  final int streakCount;
  final double size;

  const StreakFlame({
    super.key,
    required this.streakCount,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    // Scale factor based on streak (min 1.0, grows up to 1.5)
    final scale = 1.0 + (streakCount.clamp(0, 30) / 30) * 0.5;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutBack,
          width: size * scale,
          height: size * scale,
          child: CustomPaint(
            painter: _FlamePainter(
              intensity: streakCount.clamp(0, 30) / 30,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          streakCount > 0 ? '$streakCount' : '0',
          style: TextStyle(
            color: streakCount > 0
                ? AppColors.neonPurpleLight
                : AppColors.textMuted,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          streakCount == 1 ? 'day' : 'days',
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _FlamePainter extends CustomPainter {
  final double intensity; // 0.0 to 1.0

  _FlamePainter({required this.intensity});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final baseY = size.height;

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          AppColors.neonPurple.withValues(alpha: 0.3 + intensity * 0.7),
          AppColors.neonPurpleLight.withValues(alpha: 0.5 + intensity * 0.5),
          AppColors.neonPurpleLight,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Geometric flame shape using a path
    final path = Path();
    final flameHeight = size.height * (0.6 + intensity * 0.4);

    path.moveTo(centerX, baseY - flameHeight);
    path.quadraticBezierTo(
      centerX + size.width * 0.35,
      baseY - flameHeight * 0.5,
      centerX + size.width * 0.2,
      baseY,
    );
    path.lineTo(centerX - size.width * 0.2, baseY);
    path.quadraticBezierTo(
      centerX - size.width * 0.35,
      baseY - flameHeight * 0.5,
      centerX,
      baseY - flameHeight,
    );
    path.close();

    // Glow
    if (intensity > 0) {
      final glowPaint = Paint()
        ..color = AppColors.neonPurpleGlow
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 + intensity * 8);
      canvas.drawPath(path, glowPaint);
    }

    canvas.drawPath(path, paint);

    // Inner flame
    if (intensity > 0.3) {
      final innerPath = Path();
      final innerHeight = flameHeight * 0.5;
      innerPath.moveTo(centerX, baseY - innerHeight);
      innerPath.quadraticBezierTo(
        centerX + size.width * 0.15,
        baseY - innerHeight * 0.4,
        centerX + size.width * 0.08,
        baseY,
      );
      innerPath.lineTo(centerX - size.width * 0.08, baseY);
      innerPath.quadraticBezierTo(
        centerX - size.width * 0.15,
        baseY - innerHeight * 0.4,
        centerX,
        baseY - innerHeight,
      );
      innerPath.close();

      final innerPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.2 + intensity * 0.3)
        ..style = PaintingStyle.fill;
      canvas.drawPath(innerPath, innerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FlamePainter oldDelegate) {
    return oldDelegate.intensity != intensity;
  }
}
