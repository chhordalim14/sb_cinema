import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/responsive_shell.dart';
import '../bloc/movie_bloc.dart';
import '../bloc/movie_event.dart';
import '../bloc/movie_state.dart';
import '../widgets/movie_poster_card.dart';
import 'movie_details_page.dart';

class MovieCatalogPage extends StatefulWidget {
  const MovieCatalogPage({super.key});

  @override
  State<MovieCatalogPage> createState() => _MovieCatalogPageState();
}

class _MovieCatalogPageState extends State<MovieCatalogPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'Now Showing';
  String _selectedAgeRating = 'All';

  final List<String> _statusFilters = ['Now Showing', 'Coming Soon'];

  final List<String> _ageRatings = ['All', 'G', 'PG', 'PG-13', 'R-18'];

  @override
  void initState() {
    super.initState();
    _triggerSearch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _triggerSearch() {
    context.read<MovieBloc>().add(
      SearchMoviesEvent(
        query: _searchController.text,
        genre: null,
        ageRating: _selectedAgeRating == 'All' ? null : _selectedAgeRating,
      ),
    );
  }

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
              title: Text(
                'Search & Explore',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: AppColors.background,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: const Alignment(0.85, 0.65),
                  colors: [
                    AppColors.burgundy.withValues(alpha: 0.72),
                    const Color(0xFF40040E).withValues(alpha: 0.42),
                    const Color(0xFF200307).withValues(alpha: 0.16),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.28, 0.55, 0.85],
                ),
              ),
            ),
          ),
          SafeArea(
            left: false,
            right: false,
            child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final horizontalPadding =
                screenWidth > (ResponsiveShell.maxContentWidth + 40)
                ? (screenWidth - ResponsiveShell.maxContentWidth) / 2
                : 20.0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isDesktop) ...[
                  const SizedBox(height: 18),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Search & Explore',
                          style: AppTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLighter,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.glassBorderSubtle,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.movie_rounded,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Sabay Cinema Catalog',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.primaryLight,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ] else ...[
                  const SizedBox(height: 8),
                ],
                // Search Input Bar
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    0,
                    horizontalPadding,
                    0,
                  ),
                  child: GlassCard(
                    borderRadius: 20,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 2,
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => _triggerSearch(),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search movies, actors, directors...',
                        hintStyle: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        icon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear_rounded,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _triggerSearch();
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Filter Chips (Status: Now Playing / Coming Soon)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: SizedBox(
                    height: 38,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _statusFilters.length,
                      itemBuilder: (context, index) {
                        final status = _statusFilters[index];
                        final isSelected = status == _selectedStatus;

                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selectedStatus = status);
                              _triggerSearch();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.16)
                                    : AppColors.surfaceLighter.withValues(
                                        alpha: 0.6,
                                      ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary.withValues(alpha: 0.45)
                                      : AppColors.glassBorderSubtle,
                                  width: 1.0,
                                ),
                              ),
                              child: Text(
                                status,
                                style: AppTypography.labelSmall.copyWith(
                                  color: isSelected
                                      ? AppColors.primaryLight
                                      : AppColors.textSecondary,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Filter Chips (Age Rating)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: SizedBox(
                    height: 32,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _ageRatings.length,
                      itemBuilder: (context, index) {
                        final rating = _ageRatings[index];
                        final isSelected = rating == _selectedAgeRating;

                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selectedAgeRating = rating);
                              _triggerSearch();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.16)
                                    : AppColors.surfaceElevated.withValues(
                                        alpha: 0.6,
                                      ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary.withValues(alpha: 0.45)
                                      : AppColors.glassBorderSubtle,
                                  width: 1.0,
                                ),
                              ),
                              child: Text(
                                rating == 'All'
                                    ? 'All Ratings'
                                    : 'Rated $rating',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isSelected
                                      ? AppColors.primaryLight
                                      : AppColors.textSecondary,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Movies Grid Results
                Expanded(
                  child: BlocBuilder<MovieBloc, MovieState>(
                    builder: (context, state) {
                      var movies = state.searchResults;
                      if (_selectedStatus == 'Now Showing') {
                        movies = movies.where((m) => m.isNowShowing).toList();
                      } else if (_selectedStatus == 'Coming Soon') {
                        movies = movies.where((m) => !m.isNowShowing).toList();
                      }

                      if (movies.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(22),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceLighter.withValues(
                                    alpha: 0.6,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.movie_creation_outlined,
                                  size: 48,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No movies found',
                                style: AppTypography.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Try searching with another keyword',
                                style: AppTypography.bodySmall,
                              ),
                            ],
                          ),
                        );
                      }

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.maxWidth;
                          final crossAxisCount = width > 800
                              ? 4
                              : (width > 500 ? 3 : 2);
                          final childAspectRatio = width > 800
                              ? 0.58
                              : (width > 500 ? 0.56 : 0.54);

                          return GridView.builder(
                            padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              0,
                              horizontalPadding,
                              90,
                            ),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  childAspectRatio: childAspectRatio,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 38,
                                ),
                            itemCount: movies.length,
                            itemBuilder: (context, index) {
                              final movie = movies[index];
                              return MoviePosterCard(
                                movie: movie,
                                width: double.infinity,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => MovieDetailsPage(
                                        movie: movie,
                                        initialLocationId:
                                            state.selectedLocationId,
                                      ),
                                    ),
                                  );
                                },
                                onBookNow: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => MovieDetailsPage(
                                        movie: movie,
                                        initialLocationId:
                                            state.selectedLocationId,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      );
                    },
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
}
