import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CurvedCinemaScreen extends StatelessWidget {
  final String hallFormat;
  final double? maxWidth;
  final Color? color;
  final bool showTitle;

  const CurvedCinemaScreen({
    super.key,
    this.hallFormat = 'IMAX LASER SCREEN',
    this.maxWidth,
    this.color,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenColor = color ?? AppColors.logoRed;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? 640),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomPaint(
                size: const Size(double.infinity, 36),
                painter: _ScreenPainter(glowColor: screenColor),
              ),
              const SizedBox(height: 6),
              if (showTitle)
                Text(
                  'SCREEN',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    letterSpacing: 4.0,
                    fontWeight: FontWeight.w800,
                    fontSize: 11.5,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScreenPainter extends CustomPainter {
  final Color glowColor;

  _ScreenPainter({required this.glowColor});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Curved screen path
    final path = Path();
    path.moveTo(width * 0.06, height * 0.85);
    path.quadraticBezierTo(width * 0.5, height * 0.12, width * 0.94, height * 0.85);

    // Luminous Screen Glow Gradient
    final glowPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          glowColor.withValues(alpha: 0.35),
          glowColor.withValues(alpha: 0.05),
          Colors.transparent,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, width, height))
      ..style = PaintingStyle.fill;

    final glowAreaPath = Path()
      ..moveTo(width * 0.06, height * 0.85)
      ..quadraticBezierTo(width * 0.5, height * 0.12, width * 0.94, height * 0.85)
      ..lineTo(width * 0.96, height)
      ..lineTo(width * 0.04, height)
      ..close();

    canvas.drawPath(glowAreaPath, glowPaint);

    // Screen curve stroke
    final strokePaint = Paint()
      ..color = glowColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Drop shadow glow behind stroke
    final shadowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.6)
      ..strokeWidth = 7.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _ScreenPainter oldDelegate) =>
      oldDelegate.glowColor != glowColor;
}
