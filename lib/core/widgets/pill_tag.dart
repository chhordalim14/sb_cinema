import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

class PillTag extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final bool isSelected;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double fontSize;

  const PillTag({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.textColor,
    this.isSelected = false,
    this.onTap,
    this.padding,
    this.fontSize = 11.0,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? AppColors.primary;
    final effectiveTextColor = textColor ??
        (isSelected
            ? (baseColor == AppColors.primary ? AppColors.primaryLight : Colors.white)
            : AppColors.textSecondary);

    Widget child = Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? baseColor.withValues(alpha: 0.16)
            : (color != null ? color!.withValues(alpha: 0.08) : AppColors.glassFill),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? baseColor.withValues(alpha: 0.45)
              : (color != null ? color!.withValues(alpha: 0.20) : AppColors.glassBorderSubtle),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: effectiveTextColor),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelSmall.copyWith(
                color: effectiveTextColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: fontSize,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: child,
      );
    }

    return child;
  }
}
