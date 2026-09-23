import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class DesktopSkyscraperBanner extends StatefulWidget {
  final bool isLeft;
  final double width;
  final double height;
  final VoidCallback? onTap;

  const DesktopSkyscraperBanner({
    super.key,
    required this.isLeft,
    this.width = 150,
    this.height = 720,
    this.onTap,
  });

  @override
  State<DesktopSkyscraperBanner> createState() =>
      _DesktopSkyscraperBannerState();
}

class _DesktopSkyscraperBannerState extends State<DesktopSkyscraperBanner> {
  bool _isHovered = false;

  String get _assetPath => widget.isLeft
      ? 'assets/banners/banner_skyscraper_left.png'
      : 'assets/banners/banner_skyscraper_right.png';

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isLeft
        ? const Color(0xFF040A21)
        : const Color(0xFFE2E4E8);
    final glowColor = widget.isLeft
        ? const Color(0xFF0038A8).withValues(alpha: 0.35)
        : Colors.white.withValues(alpha: 0.2);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: widget.width,
          height: widget.height,
          transform: Matrix4.diagonal3Values(
            _isHovered ? 1.02 : 1.0,
            _isHovered ? 1.02 : 1.0,
            1.0,
          ),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered
                  ? (widget.isLeft ? const Color(0xFF1E88E5) : Colors.white)
                  : Colors.white.withValues(alpha: 0.12),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
              if (_isHovered)
                BoxShadow(
                  color: glowColor,
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Skyscraper Image
                Image.asset(
                  _assetPath,
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildFallback(context),
                ),

                // 2. Subtle shine/shimmer on hover
                if (_isHovered)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.08),
                          Colors.transparent,
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

  Widget _buildFallback(BuildContext context) {
    if (widget.isLeft) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF040A21),
              Color(0xFF071B5C),
              Color(0xFF020716),
            ],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
        child: Column(
          children: [
            const Text(
              'SCREENX',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            const Icon(Icons.movie_filter_rounded, size: 40, color: AppColors.accentCyan),
            const SizedBox(height: 10),
            const Text(
              'SB19\nWAKAS AT SIMULA',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const Spacer(),
            Text(
              'IN CINEMAS',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 10,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE0E5EC),
              Color(0xFFC5CDD8),
              Color(0xFFB0BAC8),
            ],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
        child: Column(
          children: [
            const Text(
              'INFINITY VISION',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                fontSize: 11,
              ),
            ),
            const Spacer(),
            const Icon(Icons.shield_rounded, size: 40, color: Color(0xFF8B1538)),
            const SizedBox(height: 10),
            const Text(
              'AVENGERS\nENDGAME ENCORE',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const Spacer(),
            const Text(
              'IN CINEMAS SEP 23',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
  }
}
