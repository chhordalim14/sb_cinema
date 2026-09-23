import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

enum SoftButtonVariant { primary, secondary, outline, glass }

class SoftButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final SoftButtonVariant variant;
  final double? width;
  final double height;
  final double borderRadius;
  final bool isLoading;
  final Widget? trailing;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;

  const SoftButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.variant = SoftButtonVariant.primary,
    this.width,
    this.height = 50.0,
    this.borderRadius = 16.0,
    this.isLoading = false,
    this.trailing,
    this.textStyle,
    this.padding,
  });

  @override
  State<SoftButton> createState() => _SoftButtonState();
}

class _SoftButtonState extends State<SoftButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null && !widget.isLoading;

    Decoration decoration;
    Color textColor = Colors.white;

    switch (widget.variant) {
      case SoftButtonVariant.primary:
        decoration = BoxDecoration(
          gradient: isEnabled
              ? const LinearGradient(
                  colors: [Color(0xFFE2B755), Color(0xFFCE9B30)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isEnabled ? null : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        );
        textColor = isEnabled ? AppColors.onPrimary : AppColors.textTertiary;
        break;

      case SoftButtonVariant.secondary:
        decoration = BoxDecoration(
          gradient: isEnabled ? AppColors.secondaryGradient : null,
          color: isEnabled ? null : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.16),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        );
        textColor = isEnabled ? Colors.white : AppColors.textTertiary;
        break;

      case SoftButtonVariant.glass:
        decoration = BoxDecoration(
          color: AppColors.surfaceLighter.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(color: AppColors.glassBorderSubtle, width: 1.0),
        );
        textColor = isEnabled ? AppColors.textPrimary : AppColors.textTertiary;
        break;

      case SoftButtonVariant.outline:
        decoration = BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: isEnabled
                ? AppColors.primary.withValues(alpha: 0.65)
                : AppColors.glassBorderSubtle,
            width: 1.0,
          ),
        );
        textColor = isEnabled ? AppColors.primaryLight : AppColors.textTertiary;
        break;
    }

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.isLoading ? null : widget.onPressed,
        child: Container(
          width: widget.width,
          height: widget.height,
          padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 18),
          decoration: decoration,
          alignment: Alignment.center,
          child: widget.isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: textColor,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, size: 18, color: textColor),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        widget.text,
                        style: (widget.textStyle ?? AppTypography.labelLarge).copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.trailing != null) ...[
                      const SizedBox(width: 8),
                      widget.trailing!,
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
