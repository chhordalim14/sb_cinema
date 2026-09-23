import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/di/injection_container.dart';
import '../../../locations/domain/entities/cinema_location.dart';

class BranchSelectorModal extends StatefulWidget {
  final String selectedLocationId;
  final Function(CinemaLocation) onLocationSelected;
  final bool isDialog;

  const BranchSelectorModal({
    super.key,
    required this.selectedLocationId,
    required this.onLocationSelected,
    this.isDialog = false,
  });

  static const CinemaLocation allLocationsOption = CinemaLocation(
    id: 'all',
    name: 'All Cinemas',
    address: 'View showtimes and movies across all cinema branches',
    city: 'All',
    phone: '+855 23 888 222',
    imageUrl:
        'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=800&q=80',
    experiences: ['IMAX Laser', 'ScreenX', 'VIP Gold', 'Standard 2D/3D'],
    totalHalls: 35,
    distanceKm: 0.0,
    openingHours: 'Open daily',
  );

  static void show(
    BuildContext context, {
    required String selectedLocationId,
    required Function(CinemaLocation) onLocationSelected,
  }) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 650;
    if (isDesktop) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 32,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: BranchSelectorModal(
              selectedLocationId: selectedLocationId,
              onLocationSelected: onLocationSelected,
              isDialog: true,
            ),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => BranchSelectorModal(
          selectedLocationId: selectedLocationId,
          onLocationSelected: onLocationSelected,
          isDialog: false,
        ),
      );
    }
  }

  @override
  State<BranchSelectorModal> createState() => _BranchSelectorModalState();
}

class _BranchSelectorModalState extends State<BranchSelectorModal> {
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

  @override
  Widget build(BuildContext context) {
    final isDesktop =
        widget.isDialog || MediaQuery.sizeOf(context).width >= 650;
    return Container(
      constraints: BoxConstraints(
        maxHeight: isDesktop
            ? MediaQuery.sizeOf(context).height * 0.82
            : MediaQuery.sizeOf(context).height * 0.85,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF131418),
        borderRadius: isDesktop
            ? BorderRadius.circular(24)
            : const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.65),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(22, isDesktop ? 22 : 16, 22, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle (Mobile only)
          if (!isDesktop) ...[
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Cinema Branch',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${_locations.length} Locations Available',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 13.5,
              ),
              decoration: InputDecoration(
                hintText: 'Search cinema branch or mall...',
                hintStyle: GoogleFonts.plusJakartaSans(
                  color: AppColors.textTertiary,
                  fontSize: 13.5,
                ),
                icon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                  size: 19,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 11),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear_rounded,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // City selector chips
          SizedBox(
            height: 34,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _cities.length,
              itemBuilder: (context, index) {
                final city = _cities[index];
                final isSelected = city == _selectedCity;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => _onCityChanged(city),
                    borderRadius: BorderRadius.circular(17),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.14)
                            : Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.45)
                              : Colors.white.withValues(alpha: 0.08),
                          width: 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.12),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
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
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),

          // Cinema Locations List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _locations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.location_off_outlined,
                          size: 40,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No cinema branch found',
                          style: AppTypography.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : Builder(
                    builder: (context) {
                      final allItems = [
                        BranchSelectorModal.allLocationsOption,
                        ..._locations,
                      ];
                      return ListView.builder(
                        itemCount: allItems.length,
                        itemBuilder: (context, index) {
                          final loc = allItems[index];
                          final isSelected =
                              (loc.id == 'all' &&
                                  (widget.selectedLocationId == 'all' ||
                                      widget.selectedLocationId.isEmpty)) ||
                              (loc.id != 'all' &&
                                  loc.id == widget.selectedLocationId);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  widget.onLocationSelected(loc);
                                  Navigator.of(context).pop();
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary.withValues(
                                            alpha: 0.08,
                                          )
                                        : Colors.white.withValues(alpha: 0.03),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary.withValues(
                                              alpha: 0.45,
                                            )
                                          : Colors.white.withValues(
                                              alpha: 0.06,
                                            ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Thumbnail / Icon
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: loc.id == 'all'
                                            ? Container(
                                                width: 52,
                                                height: 52,
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary
                                                      .withValues(alpha: 0.12),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: AppColors.primary
                                                        .withValues(
                                                          alpha: 0.25,
                                                        ),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: const Icon(
                                                  Icons.theaters_rounded,
                                                  color: AppColors.primary,
                                                  size: 24,
                                                ),
                                              )
                                            : Image.network(
                                                loc.imageUrl,
                                                width: 52,
                                                height: 52,
                                                fit: BoxFit.cover,
                                                webHtmlElementStrategy:
                                                    WebHtmlElementStrategy
                                                        .fallback,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) => Container(
                                                      width: 52,
                                                      height: 52,
                                                      color: AppColors
                                                          .surfaceElevated,
                                                      child: const Icon(
                                                        Icons
                                                            .location_city_rounded,
                                                        color: Colors.white38,
                                                        size: 22,
                                                      ),
                                                    ),
                                              ),
                                      ),
                                      const SizedBox(width: 13),
                                      // Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    loc.name,
                                                    style:
                                                        GoogleFonts.plusJakartaSans(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                        ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (isSelected) ...[
                                                  const SizedBox(width: 6),
                                                  const Icon(
                                                    Icons.check_circle_rounded,
                                                    color: AppColors.primary,
                                                    size: 18,
                                                  ),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              loc.address,
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                    fontSize: 11.5,
                                                    color:
                                                        AppColors.textSecondary,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 5),
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 7,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withValues(
                                                          alpha: 0.05,
                                                        ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    '${loc.totalHalls} Halls',
                                                    style:
                                                        GoogleFonts.plusJakartaSans(
                                                          fontSize: 10.5,
                                                          color: AppColors
                                                              .textSecondary,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  loc.city,
                                                  style:
                                                      GoogleFonts.plusJakartaSans(
                                                        fontSize: 11,
                                                        color: AppColors
                                                            .textTertiary,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                ),
                                                const Spacer(),
                                                if (loc.distanceKm > 0)
                                                  Text(
                                                    '${loc.distanceKm} km',
                                                    style:
                                                        GoogleFonts.plusJakartaSans(
                                                          fontSize: 11,
                                                          color: AppColors
                                                              .textTertiary,
                                                          fontWeight:
                                                              FontWeight.w500,
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
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
