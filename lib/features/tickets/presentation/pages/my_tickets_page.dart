import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_footer.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/responsive_shell.dart';
import '../../../booking/domain/entities/ticket.dart';
import '../../../booking/presentation/bloc/booking_bloc.dart';
import '../../../booking/presentation/bloc/booking_event.dart';
import '../../../booking/presentation/bloc/booking_state.dart';
import '../../../booking/presentation/widgets/ticket_boarding_pass.dart';

class MyTicketsPage extends StatefulWidget {
  const MyTicketsPage({super.key});

  @override
  State<MyTicketsPage> createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends State<MyTicketsPage> {
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<BookingBloc>().add(LoadActiveTicketsEvent());
  }

  void _showFullTicketModal(Ticket ticket) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (ctx) {
        return Material(
          color: Colors.transparent,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Clean Close Button above the pass
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10, right: 4),
                      child: GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.glassBorderSubtle),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    // Direct Cinema Pass (no duplicate card container)
                    TicketBoardingPass(
                      ticket: ticket,
                      margin: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveShell.isDesktop(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Ambient soft background glow
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.burgundy.withValues(alpha: 0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: BlocBuilder<BookingBloc, BookingState>(
              builder: (context, state) {
                final activeTickets = state.activeTickets.where((t) => !t.isUsed).toList();
                final pastTickets = state.activeTickets.where((t) => t.isUsed).toList();

                return CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: ResponsiveShell.maxContentWidth,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Page Header
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'My Tickets',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: isDesktop ? 28 : 24,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Your digital boarding passes & entry QR codes',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    // Active passes count badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 7,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceElevated,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: AppColors.glassBorderSubtle,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: activeTickets.isNotEmpty
                                                  ? AppColors.success
                                                  : AppColors.textTertiary,
                                              shape: BoxShape.circle,
                                              boxShadow: activeTickets.isNotEmpty
                                                  ? [
                                                      BoxShadow(
                                                        color: AppColors.success
                                                            .withValues(alpha: 0.6),
                                                        blurRadius: 6,
                                                      ),
                                                    ]
                                                  : null,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${activeTickets.length} Active',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Clean Tab Chips
                                Row(
                                  children: [
                                    _buildTabChip(
                                      index: 0,
                                      label: 'Active Passes',
                                      count: activeTickets.length,
                                      icon: Icons.confirmation_num_rounded,
                                    ),
                                    const SizedBox(width: 10),
                                    _buildTabChip(
                                      index: 1,
                                      label: 'History',
                                      count: pastTickets.length,
                                      icon: Icons.history_rounded,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Swipeable / Switchable Tickets List (Only this area transitions)
                      GestureDetector(
                        onHorizontalDragEnd: (details) {
                          if (details.primaryVelocity != null) {
                            if (details.primaryVelocity! < -200 && _currentTabIndex == 0) {
                              setState(() => _currentTabIndex = 1);
                            } else if (details.primaryVelocity! > 200 && _currentTabIndex == 1) {
                              setState(() => _currentTabIndex = 0);
                            }
                          }
                        },
                        behavior: HitTestBehavior.translucent,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(opacity: animation, child: child);
                          },
                          child: KeyedSubtree(
                            key: ValueKey<int>(_currentTabIndex),
                            child: _currentTabIndex == 0
                                ? _buildTicketsList(
                                    tickets: activeTickets,
                                    isDesktop: isDesktop,
                                    isEmpty: activeTickets.isEmpty,
                                    emptyTitle: 'No Active Cinema Passes',
                                    emptySubtitle:
                                        'You don\'t have any upcoming movies booked. Browse now showing films to grab your favorite seats!',
                                    showBrowseButton: true,
                                  )
                                : _buildTicketsList(
                                    tickets: pastTickets,
                                    isDesktop: isDesktop,
                                    isEmpty: pastTickets.isEmpty,
                                    emptyTitle: 'No Past Tickets',
                                    emptySubtitle:
                                        'Your completed movie screenings and past tickets will be saved here for your records.',
                                    showBrowseButton: false,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: 48),
                            AppFooter(),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabChip({
    required int index,
    required String label,
    required int count,
    required IconData icon,
  }) {
    final isSelected = _currentTabIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentTabIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.5),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.16)
              : AppColors.surfaceLighter.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.45)
                : AppColors.glassBorderSubtle,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 7),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.25)
                      : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? AppColors.primaryLight
                        : AppColors.textTertiary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTicketsList({
    required List<Ticket> tickets,
    required bool isDesktop,
    required bool isEmpty,
    required String emptyTitle,
    required String emptySubtitle,
    required bool showBrowseButton,
  }) {
    if (isEmpty) {
      return _buildModernEmptyState(
        title: emptyTitle,
        subtitle: emptySubtitle,
        showBrowseButton: showBrowseButton,
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: ResponsiveShell.maxContentWidth,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final isWide = width > 840;

              if (isWide) {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.1,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = tickets[index];
                    return _buildModernTicketCard(ticket);
                  },
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tickets.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final ticket = tickets[index];
                  return _buildModernTicketCard(ticket);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildModernTicketCard(Ticket ticket) {
    return GestureDetector(
      onTap: () => _showFullTicketModal(ticket),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.glassBorderSubtle,
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Bar: Cinema Branch & Active Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLighter.withValues(alpha: 0.5),
                  border: const Border(
                    bottom: BorderSide(
                      color: AppColors.glassBorderSubtle,
                      width: 0.8,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 15,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${ticket.cinemaName} • ${ticket.hallName}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Format Tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        ticket.format,
                        style: const TextStyle(
                          color: AppColors.primaryLight,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Main Details Row
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Movie Poster with rounded corners
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        ticket.moviePosterUrl,
                        width: 78,
                        height: 108,
                        fit: BoxFit.cover,
                        webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 78,
                          height: 108,
                          color: AppColors.surfaceLighter,
                          child: const Icon(
                            Icons.movie_rounded,
                            color: Colors.white38,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Movie Info & Showtime
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ticket.movieTitle,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),

                          // Date & Time Chip
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 13,
                                color: AppColors.accentGold,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '${Formatters.formatDate(ticket.showtime)} • ${Formatters.formatTime(ticket.showtime)}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Seats and Ref ID
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceLighter,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.glassBorderSubtle,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.chair_rounded,
                                      size: 13,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Seats: ${ticket.seatCodes.join(", ")}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Text(
                                ticket.ticketNumber,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textTertiary,
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

              // Dashed Perforation Line
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: List.generate(
                    32,
                    (index) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        height: 1.2,
                        color: index.isEven
                            ? AppColors.glassBorderSubtle
                            : Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Action Button Row
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_rounded,
                            size: 14,
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Ready to Scan at Cinema',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.qr_code_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'View Pass',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
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
      ),
    );
  }

  Widget _buildModernEmptyState({
    required String title,
    required String subtitle,
    required bool showBrowseButton,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 48, 28, 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceElevated,
                border: Border.all(color: AppColors.glassBorderSubtle, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 28,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.confirmation_num_outlined,
                  size: 44,
                  color: AppColors.primary.withValues(alpha: 0.8),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (showBrowseButton) ...[
              const SizedBox(height: 28),
              GestureDetector(
                onTap: () {
                  ResponsiveShell.navigateToTab(context, 0, null);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.movie_filter_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Discover Movies',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
