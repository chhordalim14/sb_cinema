import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/responsive_shell.dart';
import '../../../../core/widgets/soft_button.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_state.dart';
import '../widgets/ticket_boarding_pass.dart';

class TicketPassPage extends StatelessWidget {
  const TicketPassPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveShell.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: AppColors.surfaceGlass,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: Text(
                'Booking Confirmed',
                style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GlassCard(
                    borderRadius: 14,
                    padding: const EdgeInsets.all(6),
                    onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
      body: Column(
        children: [
          if (isDesktop) ...[
            ResponsiveShell.buildDesktopHeader(
              context,
              currentIndex: 2,
            ),
            _buildDesktopSubHeader(context),
          ],
          Expanded(
            child: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          final ticket = state.confirmedTicket;

          if (ticket == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLighter.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.confirmation_number_outlined, size: 48, color: AppColors.textTertiary),
                  ),
                  const SizedBox(height: 16),
                  Text('No active ticket found', style: AppTypography.titleMedium),
                  const SizedBox(height: 16),
                  SoftButton(
                    text: 'Explore Movies',
                    borderRadius: 18,
                    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  ),
                ],
              ),
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: ResponsiveShell.maxContentWidth),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 40),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Column(
                      children: [
                        // Celebration Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.accentEmerald.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.accentEmerald.withValues(alpha: 0.4)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentEmerald.withValues(alpha: 0.2),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppColors.accentEmerald, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'E-TICKET ISSUED SUCCESSFULLY',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.accentEmerald,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Digital Boarding Pass
                TicketBoardingPass(ticket: ticket),
                const SizedBox(height: 24),

                // Actions: Save & Add to Calendar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: SoftButton(
                          text: 'Save to Wallet',
                          icon: Icons.account_balance_wallet_rounded,
                          variant: SoftButtonVariant.glass,
                          borderRadius: 18,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Saved to Apple / Google Wallet!'),
                                backgroundColor: AppColors.surfaceElevated,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SoftButton(
                          text: 'Add to Calendar',
                          icon: Icons.event_rounded,
                          variant: SoftButtonVariant.glass,
                          borderRadius: 18,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Movie showtime added to Calendar!'),
                                backgroundColor: AppColors.surfaceElevated,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Return Home Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: SoftButton(
                    text: 'Done & Return Home',
                    icon: Icons.home_rounded,
                    borderRadius: 18,
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  ],
),
);
}

Widget _buildDesktopSubHeader(BuildContext context) {
  return Container(
    height: 60,
    decoration: const BoxDecoration(
      color: AppColors.surfaceGlass,
      border: Border(
        bottom: BorderSide(color: AppColors.glassBorderSubtle, width: 1),
      ),
    ),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: ResponsiveShell.maxContentWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                'Booking Confirmed',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w800, color: Colors.white),
              ),
              const Spacer(),
              GlassCard(
                borderRadius: 14,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.close_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text('Close', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
