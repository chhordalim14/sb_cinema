import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/responsive_shell.dart';
import '../../domain/entities/banner_slide.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/showtime.dart';
import '../bloc/movie_bloc.dart';
import '../bloc/movie_event.dart';
import '../bloc/movie_state.dart';
import '../widgets/branch_selector_modal.dart';
import '../widgets/hero_movie_carousel.dart';
import '../widgets/movie_poster_card.dart';
import '../widgets/trailer_modal.dart';
import '../widgets/promotion_slide_carousel.dart';
import '../widgets/desktop_skyscraper_banner.dart';
import '../../../../core/widgets/app_footer.dart';
import 'movie_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 0: NOW SHOWING, 1: COMING SOON
  int _selectedTabIndex = 0;
  int _selectedDateIndex = 0;
  int _selectedMonthIndex = 0;

  final List<DateTime> _dates = List.generate(
    7,
    (index) => DateTime.now().add(Duration(days: index)),
  );

  List<DateTime> get _months {
    final now = DateTime.now();
    return List.generate(
      6,
      (index) => DateTime(now.year, now.month + index, 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<MovieBloc, MovieState>(
        builder: (context, state) {
          if (state.status == MovieStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final months = _months;
          final activeMonthIndex = _selectedMonthIndex.clamp(
            0,
            months.length - 1,
          );
          final selectedMonth = months[activeMonthIndex];

          final activeDateIndex = _selectedDateIndex.clamp(
            0,
            _dates.length - 1,
          );
          final selectedDate = _dates[activeDateIndex];

          final List<Movie> moviesList;
          if (_selectedTabIndex == 0) {
            moviesList = _getMoviesForDate(
              selectedDate,
              activeDateIndex,
              state,
            );
          } else {
            moviesList = state.upcomingMovies.where((movie) {
              try {
                final dt = DateTime.parse(movie.releaseDate);
                return dt.year == selectedMonth.year &&
                    dt.month == selectedMonth.month;
              } catch (_) {
                return false;
              }
            }).toList();
          }

          final showDateSelector = _selectedTabIndex == 0;

          final isDesktop = ResponsiveShell.isDesktop(context);
          final screenWidth = MediaQuery.of(context).size.width;

          final movieBannerSlides = state.bannerSlides
              .where((s) => s.type != BannerSlideType.promotion)
              .toList();

          final promoSlides = state.bannerSlides
              .where((s) => s.type == BannerSlideType.promotion)
              .toList();

          return Column(
            children: [
              if (!isDesktop) _buildPinnedMobileHeader(context, state),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.surfaceElevated,
                  onRefresh: () async {
                    context.read<MovieBloc>().add(LoadMoviesInitialEvent());
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(bottom: isDesktop ? 0 : 80),
                    child: Column(
                      children: [
                        // ==================== 1. FULL SCREEN WIDTH HERO CAROUSEL ====================
                        if (movieBannerSlides.isNotEmpty)
                          HeroMovieCarousel(
                            slides: movieBannerSlides,
                            movies: state.featuredMovies,
                            onSlideSelected: (slide) =>
                                _handleSlideSelected(context, slide, state),
                            onMovieSelected: (movie) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => MovieDetailsPage(
                                    movie: movie,
                                    initialLocationId: state.selectedLocationId,
                                    initialDate: _selectedTabIndex == 0
                                        ? selectedDate
                                        : null,
                                  ),
                                ),
                              );
                            },
                            onBookNow: (movie) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => MovieDetailsPage(
                                    movie: movie,
                                    initialLocationId: state.selectedLocationId,
                                    initialDate: _selectedTabIndex == 0
                                        ? selectedDate
                                        : null,
                                  ),
                                ),
                              );
                            },
                            onWatchTrailer: (movie) =>
                                TrailerModal.show(context, movie),
                          )
                        else if (state.featuredMovies.isNotEmpty)
                          HeroMovieCarousel(
                            movies: state.featuredMovies,
                            onMovieSelected: (movie) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => MovieDetailsPage(
                                    movie: movie,
                                    initialLocationId: state.selectedLocationId,
                                    initialDate: _selectedTabIndex == 0
                                        ? selectedDate
                                        : null,
                                  ),
                                ),
                              );
                            },
                            onBookNow: (movie) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => MovieDetailsPage(
                                    movie: movie,
                                    initialLocationId: state.selectedLocationId,
                                    initialDate: _selectedTabIndex == 0
                                        ? selectedDate
                                        : null,
                                  ),
                                ),
                              );
                            },
                            onWatchTrailer: (movie) =>
                                TrailerModal.show(context, movie),
                          ),

                        // ==================== 2. CENTERED CONSTRAINED PAGE CONTENT WITH SIDE SKYSCRAPER BANNERS ====================
                        SizedBox(
                          width: screenWidth,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // LEFT SKYSCRAPER BANNER (ScreenX SB19) - Centered in Left Wing
                              if (isDesktop && screenWidth >= 1240)
                                Expanded(
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 52),
                                      child: DesktopSkyscraperBanner(
                                        isLeft: true,
                                        width: (screenWidth * 0.09).clamp(
                                          130.0,
                                          165.0,
                                        ),
                                        height: 740,
                                        onTap: () {
                                          final targetMovie = state
                                              .featuredMovies
                                              .firstWhere(
                                                (m) =>
                                                    m.title
                                                        .toLowerCase()
                                                        .contains('sb19') ||
                                                    m.genres.contains('Music'),
                                                orElse: () =>
                                                    state
                                                        .featuredMovies
                                                        .isNotEmpty
                                                    ? state.featuredMovies.first
                                                    : (state
                                                              .nowShowingMovies
                                                              .isNotEmpty
                                                          ? state
                                                                .nowShowingMovies
                                                                .first
                                                          : state
                                                                .upcomingMovies
                                                                .first),
                                              );
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  MovieDetailsPage(
                                                    movie: targetMovie,
                                                    initialLocationId: state
                                                        .selectedLocationId,
                                                    initialDate: selectedDate,
                                                  ),
                                            ),
                                          );
                                        },
                                        ),
                                      ),
                                    ),
                                  ),

                                  // CENTER CONTENT (Tabs, Date Switcher, Categories, Movies Grid, Promotions)
                                  SizedBox(
                                    width: isDesktop && screenWidth >= 1240
                                        ? (screenWidth * 0.64).clamp(960.0, 1200.0)
                                        : screenWidth,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: isDesktop ? 52 : 44),

                                        // ==================== NOW SHOWING | COMING SOON TABS ====================
                                        Center(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                _buildNavTab(0, 'Now Showing'),
                                                const SizedBox(width: 32),
                                                _buildNavTab(1, 'Coming Soon'),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),

                                        // If showing schedule: Quick Date Switcher Bar
                                        if (showDateSelector) ...[
                                          _buildDateSwitcher(),
                                          const SizedBox(height: 26),
                                        ] else if (_selectedTabIndex == 1) ...[
                                          // Quick Month Switcher Bar for COMING SOON (6 months starting from current month)
                                          _buildMonthSwitcher(months, activeMonthIndex),
                                          const SizedBox(height: 26),
                                        ],

                                        // Movies Grid Display with Responsive Columns
                                        if (moviesList.isEmpty)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 40,
                                            ),
                                            child: Center(
                                              child: Column(
                                                children: [
                                                  const Icon(
                                                    Icons.movie_filter_outlined,
                                                    size: 52,
                                                    color:
                                                        AppColors.textTertiary,
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Text(
                                                    _selectedTabIndex == 1
                                                        ? 'No upcoming movies found for this month'
                                                        : 'No movies scheduled for this date',
                                                    style: AppTypography
                                                        .titleMedium
                                                        .copyWith(
                                                          color: AppColors
                                                              .textSecondary,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        else
                                          AnimatedSwitcher(
                                            duration: const Duration(
                                              milliseconds: 250,
                                            ),
                                            child: LayoutBuilder(
                                              key: ValueKey(
                                                'grid_${_selectedTabIndex}_${activeDateIndex}_$activeMonthIndex',
                                              ),
                                              builder: (context, constraints) {
                                                final width =
                                                    constraints.maxWidth;
                                                final crossAxisCount =
                                                    width > 980
                                                    ? 5
                                                    : (width > 750
                                                          ? 4
                                                          : (width > 500
                                                                ? 3
                                                                : 2));
                                                final childAspectRatio =
                                                    width > 980
                                                    ? 0.57
                                                    : (width > 750
                                                          ? 0.58
                                                          : (width > 500
                                                                ? 0.56
                                                                : 0.54));

                                                return Padding(
                                                  padding:
                                                      EdgeInsets.symmetric(
                                                        horizontal: isDesktop &&
                                                                screenWidth >=
                                                                    1240
                                                            ? 0
                                                            : 20,
                                                      ),
                                                  child: GridView.builder(
                                                    shrinkWrap: true,
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    gridDelegate:
                                                        SliverGridDelegateWithFixedCrossAxisCount(
                                                          crossAxisCount:
                                                              crossAxisCount,
                                                          childAspectRatio:
                                                              childAspectRatio,
                                                          crossAxisSpacing: 20,
                                                          mainAxisSpacing: 38,
                                                        ),
                                                    itemCount:
                                                        moviesList.length,
                                                    itemBuilder: (context, index) {
                                                      final movie =
                                                          moviesList[index];
                                                      return MoviePosterCard(
                                                        movie: movie,
                                                        customTag:
                                                            _selectedTabIndex ==
                                                                0
                                                            ? _getCustomTagForMovie(
                                                                movie,
                                                                selectedDate,
                                                                activeDateIndex,
                                                              )
                                                            : null,
                                                        width: double.infinity,
                                                        onTap: () {
                                                          Navigator.of(
                                                            context,
                                                          ).push(
                                                            MaterialPageRoute(
                                                              builder: (context) => MovieDetailsPage(
                                                                movie: movie,
                                                                initialLocationId:
                                                                    state
                                                                        .selectedLocationId,
                                                                initialDate:
                                                                    _selectedTabIndex ==
                                                                        0
                                                                    ? selectedDate
                                                                    : null,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        onBookNow: () {
                                                          Navigator.of(
                                                            context,
                                                          ).push(
                                                            MaterialPageRoute(
                                                              builder: (context) => MovieDetailsPage(
                                                                movie: movie,
                                                                initialLocationId:
                                                                    state
                                                                        .selectedLocationId,
                                                                initialDate:
                                                                    _selectedTabIndex ==
                                                                        0
                                                                    ? selectedDate
                                                                    : null,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        const SizedBox(height: 42),

                                        // ==================== WHAT'S NEW? PROMOTIONS AT THE BOTTOM ====================
                                        if (promoSlides.isNotEmpty) ...[
                                          PromotionSlideCarousel(
                                            promotions: promoSlides,
                                            onPromotionSelected: (promo) =>
                                                _handleSlideSelected(
                                                  context,
                                                  promo,
                                                  state,
                                                ),
                                          ),
                                          const SizedBox(height: 44),
                                        ],
                                      ],
                                    ),
                                  ),

                                  // RIGHT SKYSCRAPER BANNER (Infinity Vision Avengers) - Centered in Right Wing
                                  if (isDesktop && screenWidth >= 1240)
                                    Expanded(
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 52),
                                          child: DesktopSkyscraperBanner(
                                        isLeft: false,
                                        width: (screenWidth * 0.09).clamp(
                                          130.0,
                                          165.0,
                                        ),
                                        height: 740,
                                        onTap: () {
                                          final targetMovie = state
                                              .featuredMovies
                                              .firstWhere(
                                                (m) =>
                                                    m.id ==
                                                        'mov_avengers_endgame' ||
                                                    m.title
                                                        .toLowerCase()
                                                        .contains('avengers'),
                                                orElse: () =>
                                                    state
                                                        .featuredMovies
                                                        .isNotEmpty
                                                    ? state.featuredMovies.first
                                                    : (state
                                                              .nowShowingMovies
                                                              .isNotEmpty
                                                          ? state
                                                                .nowShowingMovies
                                                                .first
                                                          : state
                                                                .upcomingMovies
                                                                .first),
                                              );
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  MovieDetailsPage(
                                                    movie: targetMovie,
                                                    initialLocationId: state
                                                        .selectedLocationId,
                                                    initialDate: selectedDate,
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const AppFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPinnedMobileHeader(BuildContext context, MovieState state) {
    final branchName =
        state.selectedLocationId == 'all' || state.selectedLocationId.isEmpty
        ? 'All Cinemas'
        : (state.selectedLocationName.isNotEmpty
              ? state.selectedLocationName.replaceFirst('Sabay Cinema ', '')
              : 'All Cinemas');

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.76),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Row(
                children: [
                  // Brand Logo
                  Image.asset(
                    'assets/logo/logo-sabay.png',
                    height: 48,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.local_fire_department_rounded,
                      size: 34,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  // Location Selector Chip
                  GlassCard(
                    borderRadius: 18,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    onTap: () {
                      BranchSelectorModal.show(
                        context,
                        selectedLocationId: state.selectedLocationId,
                        onLocationSelected: (loc) {
                          context.read<MovieBloc>().add(
                            SelectLocationBranchEvent(
                              locationId: loc.id,
                              locationName: loc.name,
                            ),
                          );
                        },
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 140),
                          child: Text(
                            branchName,
                            style: AppTypography.bodyMedium.copyWith(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavTab(int index, String label) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      behavior: HitTestBehavior.opaque,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  letterSpacing: -0.3,
                ),
                child: Text(label),
              ),
              const SizedBox(height: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                height: 3,
                width: isSelected ? 44 : 0,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSwitcher() {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(_dates.length, (index) {
              final date = _dates[index];
              final isSelected = index == _selectedDateIndex;
              final dayLabel = (index == 0
                  ? 'TODAY'
                  : (index == 1
                      ? 'TMR'
                      : Formatters.formatDate(date).split(',')[0]))
                  .toUpperCase();

              return Padding(
                padding: EdgeInsets.only(
                  right: index == _dates.length - 1 ? 0 : 12,
                ),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedDateIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 100,
                      height: 84,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.14)
                            : Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.45)
                              : Colors.white.withValues(alpha: 0.08),
                          width: 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dayLabel,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? AppColors.primaryLight : AppColors.textSecondary,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${date.day}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthSwitcher(List<DateTime> months, int activeMonthIndex) {
    const monthNames = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];

    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(months.length, (index) {
              final monthDate = months[index];
              final isSelected = index == activeMonthIndex;
              final monthLabel = monthNames[monthDate.month - 1];
              final yearLabel = '${monthDate.year}';

              return Padding(
                padding: EdgeInsets.only(
                  right: index == months.length - 1 ? 0 : 12,
                ),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedMonthIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 100,
                      height: 84,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.14)
                            : Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.45)
                              : Colors.white.withValues(alpha: 0.08),
                          width: 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            yearLabel,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? AppColors.primaryLight : AppColors.textSecondary,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            monthLabel,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  void _handleSlideSelected(
    BuildContext context,
    BannerSlide slide,
    MovieState state,
  ) {
    if (slide.targetMovieId != null) {
      final allMovies = [
        ...state.nowShowingMovies,
        ...state.upcomingMovies,
        ...state.featuredMovies,
      ];
      final target = allMovies.firstWhere(
        (m) => m.id == slide.targetMovieId,
        orElse: () => allMovies.first,
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MovieDetailsPage(
            movie: target,
            initialLocationId: state.selectedLocationId,
            initialDate: _selectedTabIndex == 0
                ? _dates[_selectedDateIndex.clamp(0, _dates.length - 1)]
                : null,
          ),
        ),
      );
    } else {
      _showPromotionDetailsDialog(context, slide);
    }
  }

  void _showPromotionDetailsDialog(BuildContext context, BannerSlide slide) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.glassBorderSubtle),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: slide.imageUrl.startsWith('assets/')
                              ? Image.asset(
                                  slide.imageUrl,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  slide.imageUrl,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  webHtmlElementStrategy:
                                      WebHtmlElementStrategy.fallback,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        height: 200,
                                        color: AppColors.surfaceLighter,
                                        child: const Center(
                                          child: Icon(
                                            Icons.local_offer_rounded,
                                            size: 44,
                                            color: Colors.white38,
                                          ),
                                        ),
                                      ),
                                ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primary),
                          ),
                          child: Text(
                            slide.tag,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.verified_rounded,
                          size: 18,
                          color: AppColors.accentGold,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Official Sabay Promo',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.accentGold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (slide.khmerTitle != null)
                      Text(
                        slide.khmerTitle!,
                        style: GoogleFonts.kantumruyPro(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    Text(
                      slide.title,
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      slide.subtitle,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          slide.actionText,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
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

  // ==================== DATE-BASED MOVIE SCHEDULING ====================

  List<Movie> _getMoviesForDate(
    DateTime selectedDate,
    int dayOffset,
    MovieState state,
  ) {
    final allCatalogMovies = <Movie>[
      ...state.nowShowingMovies,
      ...state.upcomingMovies,
    ];

    final targetDay = selectedDate.day;

    // 10 premiere blockbusters showing on all days (forming 2 full rows of 5 on desktop)
    const activeMovieIds = [
      'mov_deadpool_wolverine',
      'mov_dune_2',
      'mov_the_wild_robot',
      'mov_transformers_one',
      'mov_inside_out_2',
      'mov_beetlejuice_2',
      'mov_twisters',
      'mov_alien_romulus',
      'mov_despicable_me_4',
      'mov_joker_folie',
    ];

    var scheduled = allCatalogMovies
        .where((movie) => activeMovieIds.contains(movie.id))
        .toList();

    // Deduplicate by ID
    final seen = <String>{};
    scheduled = scheduled.where((m) => seen.add(m.id)).toList();

    // Priority ordering per date: New premieres / specials at top, followed by blockbusters
    scheduled.sort((a, b) {
      final aPriority = _getMovieDatePriority(a.id, dayOffset, targetDay);
      final bPriority = _getMovieDatePriority(b.id, dayOffset, targetDay);
      return aPriority.compareTo(bPriority);
    });

    // Apply active category filter if any
    if (state.selectedCategory != 'All') {
      final cat = state.selectedCategory;
      if (cat == 'IMAX') {
        scheduled = scheduled
            .where((m) => m.availableFormats.contains(HallExperience.imaxLaser))
            .toList();
      } else if (cat == 'SCREEN X') {
        scheduled = scheduled
            .where((m) => m.availableFormats.contains(HallExperience.screenX))
            .toList();
      } else if (cat == '3D') {
        scheduled = scheduled
            .where(
              (m) => m.availableFormats.contains(HallExperience.standard3D),
            )
            .toList();
      } else {
        scheduled = scheduled.where((m) => m.genres.contains(cat)).toList();
      }
    }

    return scheduled;
  }

  int _getMovieDatePriority(String movieId, int dayOffset, int targetDay) {
    if (movieId == 'mov_joker_folie' && (dayOffset >= 5 || targetDay >= 28)) {
      return 0;
    }
    if (movieId == 'mov_the_wild_robot' &&
        (dayOffset == 0 || targetDay == 23)) {
      return 1;
    }
    if (movieId == 'mov_deadpool_wolverine') return 2;
    if (movieId == 'mov_dune_2') return 3;
    if (movieId == 'mov_transformers_one') return 4;
    if (movieId == 'mov_inside_out_2') return 5;
    if (movieId == 'mov_beetlejuice_2') return 6;
    if (movieId == 'mov_twisters') return 7;
    if (movieId == 'mov_alien_romulus') return 8;
    if (movieId == 'mov_despicable_me_4') return 9;
    return 10;
  }

  String? _getCustomTagForMovie(
    Movie movie,
    DateTime selectedDate,
    int dayOffset,
  ) {
    final id = movie.id;

    if (id == 'mov_joker_folie') {
      if (dayOffset == 0) return 'PREMIERES TODAY';
      if (dayOffset == 1) return 'PREMIERES TMR';
      return 'SNEAK PREVIEW';
    }
    if (id == 'mov_the_wild_robot') {
      return 'NEW RELEASE';
    }
    if (id == 'mov_deadpool_wolverine') {
      return 'POPULAR';
    }
    if (id == 'mov_dune_2') {
      return 'IMAX LASER';
    }
    if (id == 'mov_beetlejuice_2') {
      return 'MUST WATCH';
    }
    if (id == 'mov_twisters') {
      return 'FAST SELLING';
    }
    if (id == 'mov_alien_romulus') {
      return 'TOP RATED';
    }
    return null;
  }
}
