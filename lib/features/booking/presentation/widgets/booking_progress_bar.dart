import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

enum BookingStep {
  showtime(
    stepNumber: 1,
    title: 'Showtime',
    shortTitle: 'Showtime',
    icon: Icons.movie_filter_rounded,
  ),
  chooseSeat(
    stepNumber: 2,
    title: 'Choose Seat',
    shortTitle: 'Seats',
    icon: Icons.event_seat_rounded,
  ),
  orderReview(
    stepNumber: 3,
    title: 'Order Review',
    shortTitle: 'Review',
    icon: Icons.receipt_long_rounded,
  ),
  checkout(
    stepNumber: 4,
    title: 'Checkout',
    shortTitle: 'Pay',
    icon: Icons.payment_rounded,
  );

  final int stepNumber;
  final String title;
  final String shortTitle;
  final IconData icon;

  const BookingStep({
    required this.stepNumber,
    required this.title,
    required this.shortTitle,
    required this.icon,
  });
}

/// A clean, minimalist booking progress indicator.
class BookingProgressBar extends StatelessWidget {
  final BookingStep currentStep;
  final void Function(BookingStep step)? onStepTapped;
  final bool isCompact;

  const BookingProgressBar({
    super.key,
    required this.currentStep,
    this.onStepTapped,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isNarrow = isCompact || screenWidth < 520 || constraints.maxWidth < 520;
        final connectorWidth = isNarrow ? 10.0 : 22.0;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isNarrow ? 10 : 14,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF14161F),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < BookingStep.values.length; i++) ...[
                _buildStepItem(context, BookingStep.values[i], isNarrow),
                if (i < BookingStep.values.length - 1)
                  _buildConnector(
                    isCompleted: i < currentStep.index,
                    width: connectorWidth,
                    isNarrow: isNarrow,
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepItem(BuildContext context, BookingStep step, bool isNarrow) {
    final isCompleted = step.index < currentStep.index;
    final isActive = step == currentStep;
    final canTap = isCompleted && onStepTapped != null;

    final child = isActive
        ? _buildActiveStep(step, isNarrow)
        : (isCompleted
            ? _buildCompletedStep(step, isNarrow)
            : _buildUpcomingStep(step, isNarrow));

    if (canTap) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => onStepTapped!(step),
          child: child,
        ),
      );
    }

    return child;
  }

  Widget _buildCompletedStep(BookingStep step, bool isNarrow) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.check_rounded,
              size: 13,
              color: Colors.white,
            ),
          ),
        ),
        if (!isNarrow) ...[
          const SizedBox(width: 7),
          Text(
            step.title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActiveStep(BookingStep step, bool isNarrow) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${step.stepNumber}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.1,
              ),
            ),
          ),
        ),
        const SizedBox(width: 7),
        Text(
          isNarrow ? step.shortTitle : step.title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingStep(BookingStep step, bool isNarrow) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.2,
            ),
          ),
          child: Center(
            child: Text(
              '${step.stepNumber}',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.38),
                height: 1.1,
              ),
            ),
          ),
        ),
        if (!isNarrow) ...[
          const SizedBox(width: 7),
          Text(
            step.title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.38),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildConnector({
    required bool isCompleted,
    required double width,
    required bool isNarrow,
  }) {
    return Container(
      width: width,
      height: 2,
      margin: EdgeInsets.symmetric(horizontal: isNarrow ? 4 : 8),
      decoration: BoxDecoration(
        color: isCompleted ? AppColors.primary : Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
