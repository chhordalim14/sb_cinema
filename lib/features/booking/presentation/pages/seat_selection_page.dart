import 'dart:async';
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
import '../../domain/entities/seat.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import '../widgets/booking_progress_bar.dart';
import '../widgets/curved_cinema_screen.dart';
import '../widgets/seat_legend_widget.dart';
import '../widgets/seat_matrix_widget.dart';
import 'booking_concessions_page.dart';

class SeatSelectionPage extends StatefulWidget {
  final Movie movie;
  final Showtime showtime;

  const SeatSelectionPage({
    super.key,
    required this.movie,
    required this.showtime,
  });

  @override
  State<SeatSelectionPage> createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends State<SeatSelectionPage> {
  final TransformationController _transformController = TransformationController();
  Timer? _sessionTimer;
  int _remainingSeconds = 600; // 10 minutes session lock

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        if (mounted) setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _transformController.dispose();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _zoomIn() {
    final matrix = _transformController.value.clone();
    matrix.scale(1.2);
    _transformController.value = matrix;
  }

  void _zoomOut() {
    final matrix = _transformController.value.clone();
    matrix.scale(0.833);
    _transformController.value = matrix;
  }

  void _resetZoom() {
    _transformController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveShell.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: AppColors.headerBackground,
              elevation: 0,
              centerTitle: true,
              title: Column(
                children: [
                  Text(
                    widget.movie.title,
                    style: AppTypography.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${widget.showtime.hallName} • ${Formatters.formatTime(widget.showtime.startTime)}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.w600,
                    ),
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
          ] else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: BookingProgressBar(
                currentStep: BookingStep.chooseSeat,
                onStepTapped: (step) {
                  if (step == BookingStep.showtime) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ],
          Expanded(
            child: BlocBuilder<BookingBloc, BookingState>(
              builder: (context, state) {
                if (state.status == BookingStatus.loading) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                if (isDesktop) {
                  return _buildDesktopSplitLayout(context, state);
                } else {
                  return _buildMobileLayout(context, state);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // DESKTOP TWO-COLUMN LAYOUT (CLEAN & CLEAR)
  // ===========================================================================
  Widget _buildDesktopSplitLayout(BuildContext context, BookingState state) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: ResponsiveShell.maxContentWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Choose Seat Panel (~63%)
              Expanded(
                flex: 63,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose Seat',
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontSize: 22,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _buildSeatSelectionCard(context, state),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // Right Column: Order Details Panel (~37%)
              Expanded(
                flex: 37,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Details',
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontSize: 22,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _buildOrderDetailsCard(context, state),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // SEAT SELECTION CARD (LEFT)
  // ===========================================================================
  Widget _buildSeatSelectionCard(BuildContext context, BookingState state) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorderSubtle, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // Top Controls Bar: Timer on Left, Zoom on Right
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Session Countdown Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF221317),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.logoRed.withValues(alpha: 0.45),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: AppColors.logoRed,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formattedTime,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12.5,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Zoom Controls Pill (- | +)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildZoomBtn(Icons.remove_rounded, _zoomOut, 'Zoom Out'),
                        Container(width: 1, height: 16, color: Colors.white.withValues(alpha: 0.12)),
                        _buildZoomBtn(Icons.restart_alt_rounded, _resetZoom, 'Reset Zoom'),
                        Container(width: 1, height: 16, color: Colors.white.withValues(alpha: 0.12)),
                        _buildZoomBtn(Icons.add_rounded, _zoomIn, 'Zoom In'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Curved Red Screen
            const SizedBox(height: 8),
            CurvedCinemaScreen(
              hallFormat: widget.showtime.experience.displayName,
              color: AppColors.logoRed,
              showTitle: true,
            ),
            const SizedBox(height: 12),

            // Interactive Hall Seat Matrix
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return InteractiveViewer(
                    transformationController: _transformController,
                    constrained: false,
                    maxScale: 2.5,
                    minScale: 0.75,
                    boundaryMargin: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                    clipBehavior: Clip.none,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
                  );
                },
              ),
            ),

            // Bottom Tier Legend
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                border: const Border(
                  top: BorderSide(color: AppColors.glassBorderSubtle, width: 1.0),
                ),
              ),
              child: const SeatLegendWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoomBtn(IconData icon, VoidCallback onTap, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Icon(icon, size: 15, color: Colors.white.withValues(alpha: 0.85)),
        ),
      ),
    );
  }

  // ===========================================================================
  // ORDER DETAILS CARD (RIGHT)
  // ===========================================================================
  Widget _buildOrderDetailsCard(BuildContext context, BookingState state) {
    final hasSelection = state.selectedSeats.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorderSubtle, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Movie Cover Header
                    _buildMovieCoverHeader(),
                    const SizedBox(height: 20),

                    // Section Title: Selected Seats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Selected Seats',
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        if (hasSelection)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.4),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              '${state.selectedSeats.length} seats',
                              style: const TextStyle(
                                color: AppColors.primaryLight,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Empty or Populated Seats View
                    if (!hasSelection)
                      _buildEmptySeatsView()
                    else
                      _buildSelectedSeatsListView(context, state),

                    const SizedBox(height: 18),
                    Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
                    const SizedBox(height: 18),

                    // Showtime & Cinema Metadata Table
                    _buildMetadataRow('Time:', Formatters.formatTime(widget.showtime.startTime)),
                    _buildMetadataRow('Date:', Formatters.formatDate(widget.showtime.startTime)),
                    _buildMetadataRow(
                      'Format:',
                      widget.showtime.experience.displayName,
                      isBadge: true,
                    ),
                    _buildMetadataRow('Hall:', widget.showtime.hallName),
                    _buildMetadataRow('Cinema:', widget.showtime.locationName),
                  ],
                ),
              ),
            ),

            // Bottom Total & Continue Action Bar
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                border: const Border(
                  top: BorderSide(color: AppColors.glassBorderSubtle, width: 1.0),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total:',
                        style: AppTypography.titleMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        hasSelection
                            ? Formatters.formatCurrency(state.ticketSubtotal)
                            : '--',
                        style: AppTypography.headlineSmall.copyWith(
                          color: AppColors.accentGold,
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: SoftButton(
                      text: 'Continue to Snacks',
                      icon: Icons.fastfood_rounded,
                      height: 50,
                      borderRadius: 16,
                      onPressed: hasSelection
                          ? () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => BookingConcessionsPage(
                                    movie: widget.movie,
                                    showtime: widget.showtime,
                                  ),
                                ),
                              );
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieCoverHeader() {
    final movie = widget.movie;
    final coverImage = movie.backdropUrl.isNotEmpty ? movie.backdropUrl : movie.posterUrl;

    return Container(
      height: 125,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Movie Cover / Backdrop Image
            Image.network(
              coverImage,
              fit: BoxFit.cover,
              webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.surfaceElevated,
                child: const Center(
                  child: Icon(Icons.movie_rounded, color: Colors.white24, size: 36),
                ),
              ),
            ),
            // Gradient Overlay for Readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.25),
                    Colors.black.withValues(alpha: 0.88),
                  ],
                ),
              ),
            ),
            // Movie Info & Poster Overlay
            Positioned(
              left: 14,
              right: 14,
              bottom: 12,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Poster Thumbnail
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        movie.posterUrl,
                        width: 44,
                        height: 64,
                        fit: BoxFit.cover,
                        webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                        errorBuilder: (_, __, ___) => Container(
                          width: 44,
                          height: 64,
                          color: AppColors.surfaceElevated,
                          child: const Icon(Icons.movie_rounded, size: 20, color: Colors.white38),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          movie.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 4),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                movie.ageRating,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${movie.genres.take(2).join(', ')} • ${movie.durationMinutes}m',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  shadows: const [
                                    Shadow(color: Colors.black, blurRadius: 3),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySeatsView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1.2,
              ),
            ),
            child: const Icon(
              Icons.chair_outlined,
              size: 34,
              color: Colors.white38,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Your seat is empty',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Select your preferred seats on the map',
            style: TextStyle(
              color: AppColors.textTertiary.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedSeatsListView(BuildContext context, BookingState state) {
    return Column(
      children: state.selectedSeats.map((s) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              // Seat Code Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  s.seatCode,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Seat Type
              Expanded(
                child: Text(
                  s.type.displayName,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
              ),

              // Price
              Text(
                Formatters.formatCurrency(s.price),
                style: const TextStyle(
                  color: AppColors.accentGold,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),

              // Remove Tap Target
              InkWell(
                onTap: () {
                  context.read<BookingBloc>().add(ToggleSeatEvent(s));
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMetadataRow(String key, String value, {bool isBadge = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              key,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: isBadge
                ? Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.accentCyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.accentCyan.withValues(alpha: 0.4),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        value,
                        style: const TextStyle(
                          color: AppColors.accentCyan,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  )
                : Text(
                    value,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // MOBILE LAYOUT
  // ===========================================================================
  Widget _buildMobileLayout(BuildContext context, BookingState state) {
    return Column(
      children: [
        // Mobile Controls Bar: Timer on Left, Zoom on Right
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF221317),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.logoRed.withValues(alpha: 0.45),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_outlined, size: 13, color: AppColors.logoRed),
                    const SizedBox(width: 5),
                    Text(
                      _formattedTime,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildZoomBtn(Icons.remove_rounded, _zoomOut, 'Zoom Out'),
                    Container(width: 1, height: 14, color: Colors.white.withValues(alpha: 0.12)),
                    _buildZoomBtn(Icons.restart_alt_rounded, _resetZoom, 'Reset Zoom'),
                    Container(width: 1, height: 14, color: Colors.white.withValues(alpha: 0.12)),
                    _buildZoomBtn(Icons.add_rounded, _zoomIn, 'Zoom In'),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Curved Red Screen
        CurvedCinemaScreen(
          hallFormat: widget.showtime.experience.displayName,
          color: AppColors.logoRed,
          showTitle: true,
        ),
        const SizedBox(height: 8),

        // Interactive Hall Seat Grid
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return InteractiveViewer(
                transformationController: _transformController,
                constrained: false,
                maxScale: 2.5,
                minScale: 0.75,
                boundaryMargin: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                clipBehavior: Clip.none,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth,
                    minHeight: constraints.maxHeight,
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
              );
            },
          ),
        ),

        // Seat Legend
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: SeatLegendWidget(),
        ),

        // Bottom Sheet Order Drawer
        _buildBottomDrawer(context, state),
      ],
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
                Text(
                  'Select Seats',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                BookingProgressBar(
                  currentStep: BookingStep.chooseSeat,
                  onStepTapped: (step) {
                    if (step == BookingStep.showtime) {
                      Navigator.of(context).pop();
                    }
                  },
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selected Seat Chips (fixed height row to avoid layout jump)
                  SizedBox(
                    height: 32,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: hasSelection
                          ? Row(
                              key: const ValueKey('selected_seats_active'),
                              children: [
                                Text(
                                  'Seats (${state.selectedSeats.length}):',
                                  style: AppTypography.bodySmall.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: state.selectedSeats.length,
                                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                                    itemBuilder: (context, index) {
                                      final s = state.selectedSeats[index];
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(alpha: 0.18),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '${s.seatCode} (${Formatters.formatCurrency(s.price)})',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primaryLight,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              key: const ValueKey('selected_seats_empty'),
                              children: [
                                const Icon(
                                  Icons.touch_app_rounded,
                                  size: 16,
                                  color: AppColors.textTertiary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Tap seats to select (up to 8 seats per booking)',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Total & Checkout Button
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.movie.posterUrl,
                          width: 36,
                          height: 48,
                          fit: BoxFit.cover,
                          webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                      const SizedBox(width: 10),
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
                        height: 50,
                        borderRadius: 16,
                        onPressed: hasSelection
                            ? () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => BookingConcessionsPage(
                                      movie: widget.movie,
                                      showtime: widget.showtime,
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
