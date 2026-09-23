import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/app_footer.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/responsive_shell.dart';
import '../../../../core/widgets/soft_button.dart';
import '../../domain/entities/cinema_location.dart';
import '../../../movies/presentation/bloc/movie_bloc.dart';
import '../../../movies/presentation/bloc/movie_event.dart';
import '../../../movies/presentation/bloc/movie_state.dart';

class LocationsPage extends StatefulWidget {
  const LocationsPage({super.key});

  @override
  State<LocationsPage> createState() => _LocationsPageState();
}

class _LocationsPageState extends State<LocationsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<CinemaLocation> _locations = [];
  List<String> _cities = [];
  String _selectedCity = 'All';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final cities = await ServiceLocator.locationsDataSource.getCities();
    final list = await ServiceLocator.locationsDataSource.getLocations(
      city: _selectedCity,
      searchQuery: _searchController.text,
    );
    if (mounted) {
      setState(() {
        _cities = cities;
        _locations = list;
        _isLoading = false;
      });
    }
  }

  void _onCityChanged(String city) {
    setState(() {
      _selectedCity = city;
      _isLoading = true;
    });
    _loadData();
  }

  void _onSearchChanged(String query) {
    _loadData();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedCity = 'All';
      _isLoading = true;
    });
    _loadData();
  }

  void _selectCinemaBranch(BuildContext context, CinemaLocation loc) {
    context.read<MovieBloc>().add(
          SelectLocationBranchEvent(
            locationId: loc.id,
            locationName: loc.name,
          ),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Selected ${loc.name} as your cinema',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.glassBorderSubtle),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _browseShowtimesForCinema(BuildContext context, CinemaLocation loc) {
    context.read<MovieBloc>().add(
          SelectLocationBranchEvent(
            locationId: loc.id,
            locationName: loc.name,
          ),
        );
    ResponsiveShell.navigateToTab(context, 0, null);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveShell.isDesktop(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. Soft atmospheric background glows
          Positioned(
            top: -60,
            left: -80,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.burgundy.withValues(alpha: 0.28),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 220,
            right: -100,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 2. Main Scrollable Content
          SafeArea(
            bottom: false,
            child: BlocBuilder<MovieBloc, MovieState>(
              builder: (context, movieState) {
                final currentSelectedId = movieState.selectedLocationId;

                return CustomScrollView(
                  slivers: [
                    // Page Header
                    SliverToBoxAdapter(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: ResponsiveShell.maxContentWidth,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Cinema Branches',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: isDesktop ? 30 : 24,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: -0.6,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Discover Sabay Cinema locations, halls & premium experiences',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Total Locations Count Pill
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
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
                                      const Icon(
                                        Icons.pin_drop_rounded,
                                        size: 15,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${_locations.length} Locations',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12.5,
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
                    ),

                    // Search Input & City Filter Chips
                    SliverToBoxAdapter(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: ResponsiveShell.maxContentWidth,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Clean Frosted Search Bar
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceElevated,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.glassBorderSubtle,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.25),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: _onSearchChanged,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontSize: 13.5,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Search cinema branch, mall, or street...',
                                      hintStyle: GoogleFonts.plusJakartaSans(
                                        color: AppColors.textTertiary,
                                        fontSize: 13,
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.search_rounded,
                                        color: AppColors.primary,
                                        size: 19,
                                      ),
                                      suffixIcon: _searchController.text.isNotEmpty
                                          ? IconButton(
                                              icon: const Icon(
                                                Icons.close_rounded,
                                                size: 17,
                                                color: AppColors.textSecondary,
                                              ),
                                              onPressed: () {
                                                _searchController.clear();
                                                _onSearchChanged('');
                                              },
                                            )
                                          : null,
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 14),

                                // City Filter Chips
                                SizedBox(
                                  height: 36,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _cities.length,
                                    itemBuilder: (context, index) {
                                      final city = _cities[index];
                                      final isSelected = city == _selectedCity;
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: GestureDetector(
                                          onTap: () => _onCityChanged(city),
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 220),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 7,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppColors.primary.withValues(alpha: 0.16)
                                                  : AppColors.surfaceElevated,
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
                                                  city == 'All'
                                                      ? Icons.apartment_rounded
                                                      : Icons.location_on_rounded,
                                                  size: 13,
                                                  color: isSelected
                                                      ? AppColors.primary
                                                      : AppColors.textSecondary,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  city,
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontSize: 12,
                                                    fontWeight: isSelected
                                                        ? FontWeight.w700
                                                        : FontWeight.w500,
                                                    color: isSelected
                                                        ? Colors.white
                                                        : AppColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Content Area: Loading / Empty / Cinema List
                    if (_isLoading)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2.5,
                          ),
                        ),
                      )
                    else if (_locations.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(22),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceElevated,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.glassBorderSubtle,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.location_off_outlined,
                                    size: 44,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No cinema branches found',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Try searching for a different branch name, street, or city.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                SoftButton(
                                  text: 'Reset Filters',
                                  icon: Icons.refresh_rounded,
                                  variant: SoftButtonVariant.glass,
                                  height: 42,
                                  borderRadius: 18,
                                  onPressed: _clearFilters,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          20,
                          4,
                          20,
                          isDesktop ? 40 : 120,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: ResponsiveShell.maxContentWidth,
                              ),
                              child: isDesktop
                                  ? _buildDesktopGrid(context, currentSelectedId)
                                  : _buildMobileList(context, currentSelectedId),
                            ),
                          ),
                        ),
                      ),

                    // AppFooter for Desktop View
                    if (isDesktop)
                      const SliverToBoxAdapter(
                        child: AppFooter(),
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

  Widget _buildDesktopGrid(BuildContext context, String currentSelectedId) {
    // 2-column layout on desktop
    final pairs = <List<CinemaLocation>>[];
    for (var i = 0; i < _locations.length; i += 2) {
      if (i + 1 < _locations.length) {
        pairs.add([_locations[i], _locations[i + 1]]);
      } else {
        pairs.add([_locations[i]]);
      }
    }

    return Column(
      children: pairs.map((pair) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildCinemaCard(
                  context: context,
                  loc: pair[0],
                  isCurrentSelected: pair[0].id == currentSelectedId,
                  isDesktop: true,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: pair.length > 1
                    ? _buildCinemaCard(
                        context: context,
                        loc: pair[1],
                        isCurrentSelected: pair[1].id == currentSelectedId,
                        isDesktop: true,
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMobileList(BuildContext context, String currentSelectedId) {
    return Column(
      children: _locations.map((loc) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: _buildCinemaCard(
            context: context,
            loc: loc,
            isCurrentSelected: loc.id == currentSelectedId,
            isDesktop: false,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCinemaCard({
    required BuildContext context,
    required CinemaLocation loc,
    required bool isCurrentSelected,
    required bool isDesktop,
  }) {
    return GlassCard(
      borderRadius: 24,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Branch Image Header with Gradient & Badges
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Stack(
              children: [
                Image.network(
                  loc.imageUrl,
                  height: isDesktop ? 200 : 160,
                  width: double.infinity,
                  webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: isDesktop ? 200 : 160,
                    color: AppColors.surfaceElevated,
                    child: const Center(
                      child: Icon(
                        Icons.movie_creation_outlined,
                        size: 44,
                        color: Colors.white24,
                      ),
                    ),
                  ),
                ),

                // Soft dark gradient overlay for smooth image transition
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.2),
                          Colors.transparent,
                          AppColors.surface.withValues(alpha: 0.9),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),

                // Top Left: "YOUR CINEMA" Badge (if selected)
                if (isCurrentSelected)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.45),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 13,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'YOUR CINEMA',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.primary,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Top Right: Halls count & City Badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.glassBorderSubtle,
                      ),
                    ),
                    child: Text(
                      '${loc.totalHalls} Halls • ${loc.city}',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Branch Details & Amenities
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Branch Name
                Text(
                  loc.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),

                // Address
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 15,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        loc.address,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Opening Hours & Phone
                Wrap(
                  spacing: 16,
                  runSpacing: 6,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: AppColors.accentCyan,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          loc.openingHours,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.phone_rounded,
                          size: 13,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          loc.phone,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 3. Action Buttons Row
                Row(
                  children: [
                    // Primary Action: Browse Showtimes / Set as My Cinema
                    Expanded(
                      flex: 6,
                      child: GestureDetector(
                        onTap: () => _browseShowtimesForCinema(context, loc),
                        child: Container(
                          height: 42,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            gradient: isCurrentSelected
                                ? AppColors.primaryGradient
                                : null,
                            color: isCurrentSelected
                                ? null
                                : AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isCurrentSelected
                                  ? Colors.transparent
                                  : AppColors.primary.withValues(alpha: 0.5),
                            ),
                            boxShadow: isCurrentSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.35),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isCurrentSelected
                                    ? Icons.movie_filter_rounded
                                    : Icons.check_circle_outline_rounded,
                                size: 16,
                                color: isCurrentSelected
                                    ? Colors.white
                                    : AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  isCurrentSelected
                                      ? 'Browse Movies'
                                      : 'Select Cinema',
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: isCurrentSelected
                                        ? Colors.white
                                        : AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Directions Button
                    Expanded(
                      flex: 4,
                      child: SoftButton(
                        text: 'Map',
                        icon: Icons.navigation_rounded,
                        variant: SoftButtonVariant.glass,
                        height: 42,
                        borderRadius: 14,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Opening map for ${loc.name}...'),
                              backgroundColor: AppColors.surfaceElevated,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Call Button
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.glassBorderSubtle,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.call_rounded,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        padding: EdgeInsets.zero,
                        tooltip: 'Call Branch',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Dialing ${loc.phone}...'),
                              backgroundColor: AppColors.surfaceElevated,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
