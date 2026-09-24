import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

class CurvedCinemaScreen extends StatelessWidget {
  final String hallFormat;
  final double? maxWidth;

  const CurvedCinemaScreen({
    super.key,
    this.hallFormat = 'IMAX LASER SCREEN',
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? 740),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              CustomPaint(
                size: const Size(double.infinity, 52),
                painter: _ScreenPainter(),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentCyan.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accentCyan.withValues(alpha: 0.3)),
                ),
                child: Text(
                  hallFormat.toUpperCase(),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.accentCyan,
                    letterSpacing: 2.2,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
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

class _ScreenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Curved screen path
    final path = Path();
    path.moveTo(width * 0.08, height * 0.82);
    path.quadraticBezierTo(width * 0.5, height * 0.08, width * 0.92, height * 0.82);

    // Luminous Screen Glow Gradient
    final glowPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.accentCyan.withValues(alpha: 0.35),
          AppColors.accentCyan.withValues(alpha: 0.06),
          Colors.transparent,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, width, height))
      ..style = PaintingStyle.fill;

    final glowAreaPath = Path()
      ..moveTo(width * 0.08, height * 0.82)
      ..quadraticBezierTo(width * 0.5, height * 0.08, width * 0.92, height * 0.82)
      ..lineTo(width * 0.96, height)
      ..lineTo(width * 0.04, height)
      ..close();

    canvas.drawPath(glowAreaPath, glowPaint);

    // Screen curve stroke
    final strokePaint = Paint()
      ..color = AppColors.accentCyan
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Drop shadow glow behind stroke
    final shadowPaint = Paint()
      ..color = AppColors.accentCyan.withValues(alpha: 0.6)
      ..strokeWidth = 7.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
