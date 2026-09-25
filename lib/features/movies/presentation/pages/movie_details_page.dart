import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/pill_tag.dart';
import '../../../../core/widgets/responsive_shell.dart';
import '../../../../core/widgets/app_footer.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/widgets/sign_in_dialog.dart';
import '../../../booking/presentation/bloc/booking_bloc.dart';
import '../../../booking/presentation/bloc/booking_event.dart';
import '../../../booking/presentation/pages/seat_selection_page.dart';
import '../../../locations/domain/entities/cinema_location.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/showtime.dart';
import '../../domain/usecases/get_showtimes.dart';
import '../bloc/movie_bloc.dart';
import '../bloc/movie_event.dart';
import '../widgets/sabay_showtimes_view.dart';
import '../widgets/trailer_modal.dart';

class MovieDetailsPage extends StatefulWidget {
  final Movie movie;
  final String? initialLocationId;
  final DateTime? initialDate;

  const MovieDetailsPage({
    super.key,
    required this.movie,
    this.initialLocationId,
    this.initialDate,
  });

  @override
  State<MovieDetailsPage> createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  int _selectedSegment = 0; // 0: Showtime, 1: Detail
  late DateTime _selectedDate;
  String? _selectedLocationId; // null or 'all' for All Locations
  HallExperience? _selectedExperienceFilter;
  List<CinemaLocation> _locations = [];
  List<Showtime> _showtimes = [];
  Showtime? _selectedShowtime;
  bool _isLoadingShowtimes = true;

  final List<DateTime> _dates = List.generate(
    14,
    (index) => DateTime.now().add(Duration(days: index)),
  );

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    final blocLocId = context.read<MovieBloc>().state.selectedLocationId;
    final effectiveLocId = widget.initialLocationId ?? blocLocId;
    if (effectiveLocId.isNotEmpty && effectiveLocId != 'all') {
      _selectedLocationId = effectiveLocId;
    } else {
      _selectedLocationId = null;
    }
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final locs = await ServiceLocator.locationsDataSource.getLocations();
    if (mounted) {
      setState(() => _locations = locs);
    }
    await _fetchShowtimes();
  }

  Future<void> _fetchShowtimes() async {
    setState(() => _isLoadingShowtimes = true);
    final list = await ServiceLocator.getShowtimes(
      GetShowtimesParams(
        movieId: widget.movie.id,
        locationId: _selectedLocationId,
        date: _selectedDate,
      ),
    );
    if (mounted) {
      setState(() {
        _showtimes = list;
        // Keep currently selected showtime if still present, otherwise leave null (never auto-select for user)
        if (_selectedShowtime != null &&
            list.any((s) => s.id == _selectedShowtime!.id)) {
          _selectedShowtime = list.firstWhere(
            (s) => s.id == _selectedShowtime!.id,
          );
        } else {
          _selectedShowtime = null;
        }
        _isLoadingShowtimes = false;
      });
    }
  }

  void _onProceedToSeats([Showtime? showtime]) {
    final targetShowtime = showtime ?? _selectedShowtime;
    if (targetShowtime == null) {
      setState(() => _selectedSegment = 0);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a showtime first!'),
          backgroundColor: AppColors.surfaceElevated,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // Check if user is authenticated; if not, show Sign In alert dialog with Phone/Email OTP
    final authState = context.read<AuthCubit>().state;
    if (!authState.isAuthenticated) {
      SignInDialog.show(
        context,
        onSignedIn: () {
          _navigateToSeats(targetShowtime);
        },
      );
      return;
    }

    _navigateToSeats(targetShowtime);
  }

  void _navigateToSeats(Showtime targetShowtime) {
    context.read<BookingBloc>().add(
      InitBookingSessionEvent(
        movie: widget.movie,
        showtime: targetShowtime,
      ),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SeatSelectionPage(
          movie: widget.movie,
          showtime: targetShowtime,
        ),
      ),
    );
  }

  void _onAddToWatchlist(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.movie.title} added to Watchlist!'),
        backgroundColor: AppColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    final isDesktop = ResponsiveShell.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background ambient soft glow orbs (Sabay logo flame red, ribbon violet and warm amber atmospheric depth)
          Positioned(
            top: -140,
            left: -120,
            child: Container(
              width: 420,
              height: 420,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.logoRed.withValues(alpha: 0.28),
                    AppColors.logoMagenta.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 220,
            right: -140,
            child: Container(
              width: 460,
              height: 460,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.logoPurple.withValues(alpha: 0.22),
                    AppColors.logoPurpleDeep.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 40,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.logoAmber.withValues(alpha: 0.12),
                    AppColors.logoOrange.withValues(alpha: 0.03),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Constrained Content (Center with maxWidth: 1200 matching HomePage ~70% screen width on desktop)
          Positioned.fill(
            child: Column(
              children: [
                if (isDesktop) ...[
                  ResponsiveShell.buildDesktopHeader(context, currentIndex: 0),
                  _buildDesktopSubHeader(context),
                ],
                Expanded(
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      if (!isDesktop)
                        SliverAppBar(
                          expandedHeight: 380,
                          pinned: true,
                          backgroundColor: AppColors.headerBackground,
                          leading: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GlassCard(
                              borderRadius: 16,
                              padding: EdgeInsets.zero,
                              onTap: () => Navigator.of(context).pop(),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          actions: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GlassCard(
                                borderRadius: 16,
                                padding: const EdgeInsets.all(8),
                                onTap: () => _onAddToWatchlist(context),
                                child: const Icon(
                                  Icons.bookmark_border_rounded,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                          flexibleSpace: FlexibleSpaceBar(
                            background: _buildBackdropHero(
                              context,
                              isDesktop: false,
                            ),
                          ),
                        )
                      else
                        SliverToBoxAdapter(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: ResponsiveShell.maxContentWidth,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  18,
                                  20,
                                  0,
                                ),
                                child: _buildBackdropHero(
                                  context,
                                  isDesktop: true,
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Content Body
                      SliverToBoxAdapter(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: ResponsiveShell.maxContentWidth,
                            ),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                20,
                                24,
                                20,
                                _selectedSegment == 0 ? 120 : 40,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ==================== SHOWTIME | DETAIL TABS ====================
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        _buildNavTab(0, 'Showtime'),
                                        _buildTabDivider(),
                                        _buildNavTab(1, 'Detail'),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 28),

                                  // Tab Content View
                                  if (_selectedSegment == 0) ...[
                                    // ==================== SHOWTIME TAB ====================
                                    SabayShowtimesView(
                                      showtimes: _showtimes,
                                      locations: _locations,
                                      selectedShowtime: _selectedShowtime,
                                      selectedDate: _selectedDate,
                                      availableDates: _dates,
                                      selectedLocationId: _selectedLocationId,
                                      selectedExperienceFilter:
                                          _selectedExperienceFilter,
                                      isLoading: _isLoadingShowtimes,
                                      onDateSelected: (date) {
                                        setState(() {
                                          _selectedDate = date;
                                          _selectedShowtime = null;
                                        });
                                        _fetchShowtimes();
                                      },
                                      onLocationChanged: (locId) {
                                        setState(() {
                                          _selectedLocationId = locId;
                                          _selectedShowtime = null;
                                        });
                                        final locName =
                                            (locId == null || locId == 'all')
                                            ? 'All Cinemas'
                                            : _locations
                                                      .where(
                                                        (l) => l.id == locId,
                                                      )
                                                      .firstOrNull
                                                      ?.name ??
                                                  'Selected Cinema';
                                        context.read<MovieBloc>().add(
                                          SelectLocationBranchEvent(
                                            locationId: locId ?? 'all',
                                            locationName: locName,
                                          ),
                                        );
                                        _fetchShowtimes();
                                      },
                                      onExperienceFilterChanged: (exp) {
                                        setState(
                                          () => _selectedExperienceFilter = exp,
                                        );
                                      },
                                      onShowtimeSelected: (st) {
                                        _selectedShowtime = st;
                                        _onProceedToSeats(st);
                                      },
                                      onProceedToSeats: _onProceedToSeats,
                                    ),
                                  ] else ...[
                                    // ==================== DETAIL TAB ====================
                                    // Formats and Age Rating
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        PillTag(
                                          label: movie.ageRating,
                                          color: AppColors.secondary,
                                          textColor: Colors.white,
                                        ),
                                        PillTag(
                                          label: movie.language,
                                          color: AppColors.surfaceElevated,
                                          icon: Icons.translate_rounded,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),

                                    // Movie Title
                                    Text(
                                      movie.title,
                                      style: AppTypography.displayMedium.copyWith(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.4,
                                      ),
                                    ),
                                    if (movie.originalTitle.isNotEmpty &&
                                        movie.originalTitle != movie.title) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        movie.originalTitle,
                                        style: AppTypography.bodyMedium.copyWith(
                                          color: AppColors.primaryLight,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 16),

                                    // Genres
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: movie.genres.map((genre) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.surfaceLighter
                                                .withValues(alpha: 0.8),
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            border: Border.all(
                                              color: AppColors.glassBorderSubtle,
                                            ),
                                          ),
                                          child: Text(
                                            genre,
                                            style: AppTypography.labelSmall
                                                .copyWith(
                                                  color: AppColors.textSecondary,
                                                  fontSize: 12,
                                                ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(height: 28),

                                    // Rating & Stats Matrix
                                    Row(
                                      children: [
                                        _buildStatCard(
                                          'Sabay Score',
                                          '${movie.rating} / 10',
                                          Icons.star_rounded,
                                          AppColors.accentGold,
                                        ),
                                        const SizedBox(width: 14),
                                        _buildStatCard(
                                          'Reviews',
                                          '${(movie.voteCount / 1000).toStringAsFixed(1)}k+',
                                          Icons.people_alt_rounded,
                                          AppColors.accentCyan,
                                        ),
                                        const SizedBox(width: 14),
                                        _buildStatCard(
                                          'Director',
                                          movie.director,
                                          Icons.movie_filter_rounded,
                                          AppColors.secondary,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 34),

                                    // Synopsis Section
                                    Text(
                                      'Storyline',
                                      style: AppTypography.titleMedium.copyWith(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      movie.synopsis,
                                      style: AppTypography.bodyLarge.copyWith(
                                        color: AppColors.textSecondary,
                                        height: 1.68,
                                        fontSize: 15.5,
                                      ),
                                    ),
                                    const SizedBox(height: 36),

                                    // Cast Carousel
                                    if (movie.cast.isNotEmpty) ...[
                                      Text(
                                        'Cast & Crew',
                                        style: AppTypography.titleMedium.copyWith(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        height: 118,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: movie.cast.length,
                                          itemBuilder: (context, index) {
                                            final cast = movie.cast[index];
                                            return Container(
                                              width: 90,
                                              margin: const EdgeInsets.only(
                                                right: 16,
                                              ),
                                              child: Column(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 32,
                                                    backgroundImage:
                                                        NetworkImage(
                                                          cast.avatarUrl,
                                                        ),
                                                    onBackgroundImageError:
                                                        (_, _) {},
                                                    backgroundColor: AppColors
                                                        .surfaceElevated,
                                                    child: const Icon(
                                                      Icons.person_rounded,
                                                      size: 24,
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    cast.name,
                                                    style: AppTypography
                                                        .labelSmall
                                                        .copyWith(
                                                          fontSize: 11.5,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.white,
                                                        ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    cast.role,
                                                    style: AppTypography
                                                        .bodySmall
                                                        .copyWith(
                                                          fontSize: 10.5,
                                                          color: AppColors
                                                              .textTertiary,
                                                        ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 36),
                                    ],

                                    // User Reviews Section
                                    if (movie.reviews.isNotEmpty) ...[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Audience Reviews',
                                              style: AppTypography.titleMedium
                                                  .copyWith(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'See all (${movie.reviews.length})',
                                            style: AppTypography.bodySmall
                                                .copyWith(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      ...movie.reviews.map(
                                        (rev) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 14,
                                          ),
                                          child: GlassCard(
                                            borderRadius: 18,
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 14,
                                                      backgroundImage:
                                                          NetworkImage(
                                                            rev.avatarUrl,
                                                          ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: Text(
                                                        rev.author,
                                                        style: AppTypography
                                                            .labelSmall
                                                            .copyWith(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.star_rounded,
                                                          size: 14,
                                                          color: AppColors
                                                              .accentGold,
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          rev.rating
                                                              .toStringAsFixed(
                                                                1,
                                                              ),
                                                          style: AppTypography
                                                              .labelSmall
                                                              .copyWith(
                                                                color: AppColors
                                                                    .accentGold,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  rev.comment,
                                                  style: AppTypography.bodySmall
                                                      .copyWith(
                                                        color: AppColors
                                                            .textSecondary,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (isDesktop)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: AppFooter(),
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
    );
  }

  Widget _buildNavTab(int index, String label) {
    final isSelected = _selectedSegment == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedSegment = index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          style: GoogleFonts.plusJakartaSans(
            fontSize: isSelected ? 21 : 19,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
            letterSpacing: -0.2,
          ),
          child: Text(label),
        ),
      ),
    );
  }

  Widget _buildTabDivider() {
    return Container(
      width: 1.5,
      height: 20,
      margin: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: GlassCard(
        borderRadius: 18,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTypography.labelLarge.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopSubHeader(BuildContext context) {
    final movie = widget.movie;
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: AppColors.headerBackground,
        border: Border(
          bottom: BorderSide(color: AppColors.headerBorder, width: 1),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: ResponsiveShell.maxContentWidth,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: AppTypography.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${movie.durationMinutes} min • ${movie.ageRating} • ${movie.language}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const Spacer(),
                GlassCard(
                  borderRadius: 14,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  onTap: () => _onAddToWatchlist(context),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bookmark_border_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Watchlist',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
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

  Widget _buildBackdropHero(BuildContext context, {required bool isDesktop}) {
    final movie = widget.movie;
    return ClipRRect(
      borderRadius: isDesktop ? BorderRadius.circular(24) : BorderRadius.zero,
      child: Container(
        height: isDesktop ? 380 : null,
        decoration: BoxDecoration(
          borderRadius: isDesktop ? BorderRadius.circular(24) : null,
          boxShadow: isDesktop
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Stack(
          fit: isDesktop ? StackFit.loose : StackFit.expand,
          children: [
            SizedBox(
              width: double.infinity,
              height: isDesktop ? 380 : double.infinity,
              child: Image.network(
                movie.backdropUrl,
                fit: BoxFit.cover,
                webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: AppColors.surfaceLighter),
              ),
            ),
            // Gradient Shading
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.background.withValues(alpha: 0.35),
                      AppColors.background,
                    ],
                    stops: const [0.2, 0.65, 1.0],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            // Center Play Trailer Button
            Center(
              child: GestureDetector(
                onTap: () => TrailerModal.show(context, movie),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        blurRadius: 28,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
