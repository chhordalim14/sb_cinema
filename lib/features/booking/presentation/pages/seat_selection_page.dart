import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/responsive_shell.dart';
import '../../../../core/widgets/soft_button.dart';
import '../../../movies/domain/entities/movie.dart';
import '../../../movies/domain/entities/showtime.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import '../widgets/curved_cinema_screen.dart';
import '../widgets/seat_legend_widget.dart';
import '../widgets/seat_matrix_widget.dart';
import 'booking_concessions_page.dart';

class SeatSelectionPage extends StatelessWidget {
  final Movie movie;
  final Showtime showtime;

  const SeatSelectionPage({
    super.key,
    required this.movie,
    required this.showtime,
  });

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
              centerTitle: true,
              title: Column(
                children: [
                  Text(
                    movie.title,
                    style: AppTypography.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${showtime.hallName} • ${Formatters.formatTime(showtime.startTime)}',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.primaryLight, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GlassCard(
                  borderRadius: 16,
                  padding: EdgeInsets.zero,
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
                ),
              ),
            ),
      body: Column(
        children: [
          if (isDesktop) ...[
            ResponsiveShell.buildDesktopHeader(
              context,
              currentIndex: 0,
            ),
            _buildDesktopSubHeader(context),
          ],
          Expanded(
            child: BlocBuilder<BookingBloc, BookingState>(
              builder: (context, state) {
                if (state.status == BookingStatus.loading) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                return Column(
                  children: [
                    const SizedBox(height: 18),
                    // Curved Projector Screen
                    CurvedCinemaScreen(hallFormat: showtime.experience.displayName),
                    const SizedBox(height: 20),

                    // Interactive Hall Seat Grid
                    Expanded(
                      child: InteractiveViewer(
                        maxScale: 2.5,
                        minScale: 0.8,
                        boundaryMargin: const EdgeInsets.all(20),
                        child: Center(
                          child: Transform.scale(
                            scale: isDesktop ? 1.25 : 1.0,
                            child: SeatMatrixWidget(
                              allSeats: state.allSeats,
                              selectedSeats: state.selectedSeats,
                              onSeatTapped: (seat) {
                                context.read<BookingBloc>().add(ToggleSeatEvent(seat));
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Seat Legend
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: SeatLegendWidget(),
                    ),

                    // Bottom Sheet Order Drawer
                    _buildBottomDrawer(context, state),
                  ],
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
                GlassCard(
                  borderRadius: 14,
                  padding: const EdgeInsets.all(8),
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        style: AppTypography.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${showtime.locationName} • ${showtime.hallName} • ${Formatters.formatTime(showtime.startTime)}',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.primaryLight, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.event_seat_rounded, size: 14, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Step 2: Choose Your Seats',
                        style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                      ),
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

  Widget _buildBottomDrawer(BuildContext context, BookingState state) {
    final hasSelection = state.selectedSeats.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: const Border(
          top: BorderSide(color: AppColors.glassBorder, width: 1.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 28,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: ResponsiveShell.maxContentWidth),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selected Seat Chips
                  if (hasSelection) ...[
                    Row(
                      children: [
                        Text('Selected Seats:', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: state.selectedSeats.map((s) {
                                return Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                                  ),
                                  child: Text(
                                    '${s.seatCode} (${Formatters.formatCurrency(s.price)})',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primaryLight,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Total & Checkout Button
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasSelection ? '${state.totalSeatCount} Seats Total' : 'No Seats Selected',
                              style: AppTypography.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              Formatters.formatCurrency(state.ticketSubtotal),
                              style: AppTypography.titleLarge.copyWith(
                                color: AppColors.accentGold,
                                fontWeight: FontWeight.w900,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      SoftButton(
                        text: 'Continue to Snacks',
                        icon: Icons.fastfood_rounded,
                        height: 52,
                        borderRadius: 18,
                        onPressed: hasSelection
                            ? () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => BookingConcessionsPage(
                                      movie: movie,
                                      showtime: showtime,
                                    ),
                                  ),
                                );
                              }
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
