import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

class SeatLegendWidget extends StatelessWidget {
  const SeatLegendWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildItem(
              'Available',
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.seatAvailable,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: AppColors.seatAvailableBorder, width: 1.2),
                ),
              ),
            ),
            const SizedBox(width: 14),
            _buildItem(
              'Selected',
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(7),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.45),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            _buildItem(
              'Reserved',
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.seatReserved,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(Icons.close_rounded, size: 12, color: AppColors.textTertiary),
              ),
            ),
            const SizedBox(width: 14),
            _buildItem(
              'VIP Recliner',
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  gradient: AppColors.vipGradient,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(Icons.star_rounded, size: 12, color: Colors.white),
              ),
            ),
            const SizedBox(width: 14),
            _buildItem(
              'Twin Bed',
              Container(
                width: 28,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.seatTwin.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: AppColors.seatTwin, width: 1.2),
                ),
                child: const Icon(Icons.favorite_rounded, size: 11, color: AppColors.seatTwin),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(String label, Widget icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
