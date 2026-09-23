import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../locations/domain/entities/cinema_location.dart';
import '../../domain/entities/showtime.dart';

class LegendShowtimesView extends StatefulWidget {
  final List<Showtime> showtimes;
  final List<CinemaLocation> locations;
  final Showtime? selectedShowtime;
  final DateTime selectedDate;
  final List<DateTime> availableDates;
  final String? selectedLocationId; // null or 'all' for All Locations
  final HallExperience? selectedExperienceFilter;
  final bool isLoading;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<String?> onLocationChanged;
  final ValueChanged<HallExperience?> onExperienceFilterChanged;
  final ValueChanged<Showtime> onShowtimeSelected;
  final VoidCallback onProceedToSeats;

  const LegendShowtimesView({
    super.key,
    required this.showtimes,
    required this.locations,
    required this.selectedShowtime,
    required this.selectedDate,
    required this.availableDates,
    required this.selectedLocationId,
    required this.selectedExperienceFilter,
    required this.isLoading,
    required this.onDateSelected,
    required this.onLocationChanged,
    required this.onExperienceFilterChanged,
    required this.onShowtimeSelected,
    required this.onProceedToSeats,
  });

  @override
  State<LegendShowtimesView> createState() => _LegendShowtimesViewState();
}

class _LegendShowtimesViewState extends State<LegendShowtimesView> {
  final Map<String, bool> _collapsedLocations = {};

  void _toggleLocationCollapse(String locationName, bool defaultCollapsed) {
    setState(() {
      final current = _collapsedLocations[locationName] ?? defaultCollapsed;
      _collapsedLocations[locationName] = !current;
    });
  }

  void _showLocationPickerModal() {
    final isDesktop = MediaQuery.sizeOf(context).width >= 650;
    Widget buildContent(BuildContext ctx) {
      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.75,
          maxWidth: isDesktop ? 540 : double.infinity,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.98),
          borderRadius: isDesktop
              ? BorderRadius.circular(28)
              : const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: AppColors.glassBorderSubtle, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.7),
              blurRadius: 36,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isDesktop) ...[
                const SizedBox(height: 12),
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Select Cinema Branch',
                        style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.glassBorderSubtle, height: 1),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  children: [
                    // "All Locations" Option
                    _buildLocationOptionItem(
                      id: null,
                      name: 'All Locations',
                      address: 'View showtimes across all cinema branches',
                      isSelected: widget.selectedLocationId == null || widget.selectedLocationId == 'all',
                      onTap: () {
                        Navigator.of(ctx).pop();
                        widget.onLocationChanged(null);
                      },
                    ),
                    const SizedBox(height: 8),
                    // Individual Cinema Branches
                    ...widget.locations.map((loc) {
                      final isSelected = widget.selectedLocationId == loc.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildLocationOptionItem(
                          id: loc.id,
                          name: loc.name,
                          address: loc.address,
                          distanceKm: loc.distanceKm,
                          isSelected: isSelected,
                          onTap: () {
                            Navigator.of(ctx).pop();
                            widget.onLocationChanged(loc.id);
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (isDesktop) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: buildContent(ctx),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (ctx) => buildContent(ctx),
      );
    }
  }

  Widget _buildLocationOptionItem({
    required String? id,
    required String name,
    required String address,
    double? distanceKm,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surfaceLighter,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.glassBorderSubtle,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surfaceElevated,
                shape: BoxShape.circle,
              ),
              child: Icon(
                id == null ? Icons.theater_comedy_rounded : Icons.location_on_rounded,
                size: 18,
                color: isSelected ? Colors.white : AppColors.accentCyan,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    address,
                    style: AppTypography.bodySmall.copyWith(
                      color: isSelected ? AppColors.textSecondary : AppColors.textTertiary,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (distanceKm != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  '${distanceKm.toStringAsFixed(1)} km',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.primaryLight : AppColors.textTertiary,
                  ),
                ),
              ),
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
              ),
          ],
        ),
      ),
    );
  }

  String _getSelectedLocationDisplayName() {
    if (widget.selectedLocationId == null || widget.selectedLocationId == 'all') {
      return 'All Cinema Branches';
    }
    final loc = widget.locations.where((l) => l.id == widget.selectedLocationId).firstOrNull;
    return loc?.name ?? 'All Cinema Branches';
  }

  @override
  Widget build(BuildContext context) {
    final isSingleLocation = widget.selectedLocationId != null &&
        widget.selectedLocationId!.isNotEmpty &&
        widget.selectedLocationId != 'all';

    // Filter showtimes based on location and experience
    var filteredShowtimes = widget.showtimes;
    if (isSingleLocation) {
      filteredShowtimes = filteredShowtimes
          .where((st) => st.locationId == widget.selectedLocationId)
          .toList();
    }
    if (widget.selectedExperienceFilter != null) {
      filteredShowtimes = filteredShowtimes
          .where((st) => st.experience == widget.selectedExperienceFilter)
          .toList();
    }

    // Group showtimes by locationName
    final Map<String, List<Showtime>> groupedByLocation = {};
    for (final st in filteredShowtimes) {
      groupedByLocation.putIfAbsent(st.locationName, () => []).add(st);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ==================== CINEMA BRANCH SELECTOR BAR ====================
        GestureDetector(
          onTap: _showLocationPickerModal,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: AppColors.surfaceLighter.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.glassBorderSubtle),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _getSelectedLocationDisplayName(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Change',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // ==================== DATE SWITCHER BAR ====================
        _buildDateSwitcher(),
        const SizedBox(height: 14),

        // ==================== FORMAT QUICK FILTER CHIPS ====================
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFormatFilterChip(null, 'All Formats'),
              const SizedBox(width: 8),
              _buildFormatFilterChip(HallExperience.standard2D, '2D'),
              const SizedBox(width: 8),
              _buildFormatFilterChip(HallExperience.imaxLaser, 'IMAX Laser'),
              const SizedBox(width: 8),
              _buildFormatFilterChip(HallExperience.screenX, 'ScreenX'),
              const SizedBox(width: 8),
              _buildFormatFilterChip(HallExperience.vipGold, 'VIP Gold'),
              const SizedBox(width: 8),
              _buildFormatFilterChip(HallExperience.standard3D, '3D'),
              const SizedBox(width: 8),
              _buildFormatFilterChip(HallExperience.fourDX, '4DX'),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // ==================== SHOWTIMES CONTAINER (MATCHING REFERENCE UI) ====================
        if (widget.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else if (groupedByLocation.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.surfaceLighter.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.glassBorderSubtle),
            ),
            child: Column(
              children: [
                const Icon(Icons.movie_filter_outlined, size: 40, color: AppColors.textTertiary),
                const SizedBox(height: 12),
                Text(
                  'No showtimes available for the selected filters.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    widget.onLocationChanged(null);
                    widget.onExperienceFilterChanged(null);
                  },
                  child: Text(
                    'Reset Filters',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: groupedByLocation.keys.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final locationName = groupedByLocation.keys.elementAt(index);
              final locationShowtimes = groupedByLocation[locationName]!;
              // When viewing all locations: expand ONLY the first location (index == 0) by default, collapse others.
              // When single location selected: always expand (isCollapsed = false).
              final defaultCollapsed = isSingleLocation ? false : (index != 0);
              final isCollapsed = _collapsedLocations[locationName] ?? defaultCollapsed;

              return _buildCinemaScheduleCard(
                locationName: locationName,
                showtimes: locationShowtimes,
                showLocationHeader: !isSingleLocation,
                isCollapsed: isCollapsed,
                onToggleCollapse: () => _toggleLocationCollapse(locationName, defaultCollapsed),
              );
            },
          ),
      ],
    );
  }

  Widget _buildFormatFilterChip(HallExperience? experience, String label) {
    final isSelected = widget.selectedExperienceFilter == experience;
    return GestureDetector(
      onTap: () => widget.onExperienceFilterChanged(experience),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.16) : AppColors.surfaceLighter.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.45) : AppColors.glassBorderSubtle,
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.primaryLight : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildCinemaScheduleCard({
    required String locationName,
    required List<Showtime> showtimes,
    required bool showLocationHeader,
    required bool isCollapsed,
    required VoidCallback onToggleCollapse,
  }) {
    // Group showtimes by experience
    final Map<HallExperience, List<Showtime>> formatGroups = {};
    for (final st in showtimes) {
      formatGroups.putIfAbsent(st.experience, () => []).add(st);
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF23080D), // Deep wine burgundy matching reference UI
            Color(0xFF140508),
            Color(0xFF0C0305),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Unified Cinema Location Header inside the top of the card
          if (showLocationHeader) ...[
            GestureDetector(
              onTap: onToggleCollapse,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  border: isCollapsed
                      ? null
                      : Border(
                          bottom: BorderSide(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1.0,
                          ),
                        ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: AppColors.primaryLight,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            locationName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${showtimes.length} showtimes available',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textTertiary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isCollapsed
                            ? Icons.keyboard_arrow_down_rounded
                            : Icons.keyboard_arrow_up_rounded,
                        color: isCollapsed
                            ? AppColors.textSecondary
                            : AppColors.primaryLight,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Unified Showtimes Content inside the exact same card
          if (!isCollapsed)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < formatGroups.entries.length; i++) ...[
                    _buildExperienceBlock(
                      experience: formatGroups.entries.elementAt(i).key,
                      showtimes: formatGroups.entries.elementAt(i).value,
                    ),
                    if (i < formatGroups.entries.length - 1)
                      const SizedBox(height: 44),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExperienceBlock({
    required HallExperience experience,
    required List<Showtime> showtimes,
  }) {
    // Group showtimes under this format by Hall Specification & Language combo
    // E.g. "REGULAR HALL::KH::EN, CH" vs "VATTANAC GOLD CLASS::MAND::KH, EN, CH"
    final Map<String, List<Showtime>> specGroups = {};
    for (final st in showtimes) {
      final key = '${st.hallType}::${st.spokenLanguage}::${st.subtitleLanguage}';
      specGroups.putIfAbsent(key, () => []).add(st);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ==================== FORMAT STYLIZED TITLE (2D, 3D, IMAX, etc.) ====================
        _buildStylizedFormatTitle(experience),
        const SizedBox(height: 22),

        // ==================== SPECIFICATION GROUPS ====================
        ...specGroups.entries.map((specEntry) {
          final groupShowtimes = specEntry.value;
          final first = groupShowtimes.first;

          // Sort showtimes by start time
          groupShowtimes.sort((a, b) => a.startTime.compareTo(b.startTime));

          return Padding(
            padding: const EdgeInsets.only(bottom: 38),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hall Name, Audio Language & Subtitles Row: REGULAR HALL | 🔊 KH | 💬 EN | 💬 CH
                _buildHallSpecsRow(first),
                const SizedBox(height: 20),

                // Showtime Capsule Pills: [ 10:00 AM ]  [ 01:30 PM ] ...
                Wrap(
                  spacing: 16,
                  runSpacing: 14,
                  children: groupShowtimes.map((st) {
                    final isSelected = widget.selectedShowtime?.id == st.id;
                    return _buildShowtimeCapsule(st: st, isSelected: isSelected);
                  }).toList(),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStylizedFormatTitle(HallExperience experience) {
    List<Color> gradientColors;
    String titleText;

    switch (experience) {
      case HallExperience.standard2D:
        titleText = '2D';
        gradientColors = const [
          Color(0xFF5CB8FF),
          Color(0xFF1E88E5),
          Color(0xFF0D47A1),
        ];
        break;
      case HallExperience.standard3D:
        titleText = '3D';
        gradientColors = const [
          Color(0xFFFF3D00),
          Color(0xFFFF1744),
          Color(0xFFC62828),
        ];
        break;
      case HallExperience.imaxLaser:
        titleText = 'IMAX';
        gradientColors = const [
          Color(0xFF00F5D4),
          Color(0xFF00B4D8),
          Color(0xFF0077B6),
        ];
        break;
      case HallExperience.screenX:
        titleText = 'ScreenX';
        gradientColors = const [
          Color(0xFFFF5252),
          Color(0xFFFF1744),
          Color(0xFFC2185B),
        ];
        break;
      case HallExperience.vipGold:
        titleText = 'VIP GOLD';
        gradientColors = const [
          Color(0xFFFFE082),
          Color(0xFFFFC107),
          Color(0xFFFF8F00),
        ];
        break;
      case HallExperience.dolbyAtmos:
        titleText = 'ATMOS';
        gradientColors = const [
          Color(0xFF4FACFE),
          Color(0xFF00F2FE),
          Color(0xFF0288D1),
        ];
        break;
      case HallExperience.fourDX:
        titleText = '4DX';
        gradientColors = const [
          Color(0xFFFF5252),
          Color(0xFFD50000),
          Color(0xFF8B0000),
        ];
        break;
      case HallExperience.kids:
        titleText = 'KIDS';
        gradientColors = const [
          Color(0xFFFF80AB),
          Color(0xFFFF4081),
          Color(0xFFC2185B),
        ];
        break;
    }

    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: gradientColors,
      ).createShader(bounds),
      child: Text(
        titleText,
        style: const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          color: Colors.white,
          letterSpacing: -0.5,
          height: 1.0,
        ),
      ),
    );
  }

  Widget _buildHallSpecsRow(Showtime first) {
    final hallTypeUpper = first.hallType.toUpperCase();
    final isGoldClass = hallTypeUpper.contains('GOLD') ||
        hallTypeUpper.contains('VIP') ||
        hallTypeUpper.contains('VATTANAC') ||
        first.experience == HallExperience.vipGold;
    final hasDolbyAtmos = first.experience == HallExperience.dolbyAtmos ||
        hallTypeUpper.contains('ATMOS');

    // Parse subtitle languages (e.g. "EN, CH" or "KH, EN, CH")
    final subLanguages = first.subtitleLanguage
        .split(RegExp(r'[,/]'))
        .map((s) => s.trim().toUpperCase())
        .where((s) => s.isNotEmpty)
        .toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Optional Dolby Atmos Brand Badge
          if (hasDolbyAtmos) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Double-D Dolby symbol
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 11,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.horizontal(right: Radius.circular(5.5)),
                      ),
                    ),
                    const SizedBox(width: 1.5),
                    Container(
                      width: 7,
                      height: 11,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.horizontal(left: Radius.circular(5.5)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                const Text(
                  'Dolby Atmos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
            _buildSpecDivider(),
          ],

          // 2. Hall Name: Stacked REGULAR HALL or GOLD CLASS
          if (isGoldClass) ...[
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'GOLD',
                  style: TextStyle(
                    color: Color(0xFFDDAC44),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.8,
                    height: 1.0,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'CLASS',
                  style: TextStyle(
                    color: Color(0xFFDDAC44),
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3.2,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ] else ...[
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'REGULAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    height: 1.0,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'HALL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3.5,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ],

          // Divider
          _buildSpecDivider(),

          // 3. Audio Language Spec (Speaker Icon + Code)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 1.0),
                ),
                child: const Icon(Icons.volume_up_rounded, size: 9, color: Colors.white),
              ),
              const SizedBox(width: 4),
              Text(
                first.spokenLanguage.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),

          // 4. Subtitle Language Spec(s) (Speech Bubble + Code)
          for (final sub in subLanguages) ...[
            _buildSpecDivider(),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.chat_bubble_rounded, size: 10.5, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  sub,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSpecDivider() {
    return Container(
      width: 1.2,
      height: 12,
      color: Colors.white.withValues(alpha: 0.35),
      margin: const EdgeInsets.symmetric(horizontal: 10),
    );
  }

  Widget _buildShowtimeCapsule({
    required Showtime st,
    required bool isSelected,
  }) {
    final startTimeStr = Formatters.formatTime(st.startTime);
    final endTimeStr = Formatters.formatTime(st.endTime);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.onShowtimeSelected(st),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: 144,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [
                      Color(0xFFFF334B),
                      AppColors.primary,
                      Color(0xFFB00612),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [
                      const Color(0xFF2C1620).withValues(alpha: 0.95),
                      const Color(0xFF1B0B12).withValues(alpha: 0.95),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.85)
                  : AppColors.primary.withValues(alpha: 0.45),
              width: isSelected ? 1.8 : 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.55),
                      blurRadius: 14,
                      spreadRadius: 1,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.45),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.access_time_filled_rounded,
                    size: 13.5,
                    color: isSelected ? Colors.white : AppColors.primaryLight,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    startTimeStr,
                    style: GoogleFonts.plusJakartaSans(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.95),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                '~ $endTimeStr',
                style: GoogleFonts.plusJakartaSans(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.85)
                      : AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSwitcher() {
    if (widget.availableDates.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 76,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.availableDates.length,
        itemBuilder: (context, index) {
          final date = widget.availableDates[index];
          final isSelected = date.year == widget.selectedDate.year &&
              date.month == widget.selectedDate.month &&
              date.day == widget.selectedDate.day;

          final now = DateTime.now();
          final isToday = date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;
          final isTmrw = date.year == now.year &&
              date.month == now.month &&
              date.day == now.day + 1;

          final dayLabel = isToday
              ? 'Today'
              : (isTmrw
                  ? 'Tmrw'
                  : Formatters.formatDate(date).split(',')[0]);

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => widget.onDateSelected(date),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 72,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : AppColors.surfaceLighter.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.45)
                        : AppColors.glassBorderSubtle,
                    width: 1.0,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dayLabel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.primaryLight
                            : AppColors.textSecondary,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${date.day}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 19,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

