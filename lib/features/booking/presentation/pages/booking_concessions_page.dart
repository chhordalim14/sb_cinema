import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/responsive_shell.dart';
import '../../../../core/widgets/soft_button.dart';
import '../../../concessions/domain/entities/concession_item.dart';
import '../../../movies/domain/entities/movie.dart';
import '../../../movies/domain/entities/showtime.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import '../widgets/booking_progress_bar.dart';
import 'checkout_summary_page.dart';

class BookingConcessionsPage extends StatefulWidget {
  final Movie? movie;
  final Showtime? showtime;

  const BookingConcessionsPage({
    super.key,
    this.movie,
    this.showtime,
  });

  @override
  State<BookingConcessionsPage> createState() => _BookingConcessionsPageState();
}

class _BookingConcessionsPageState extends State<BookingConcessionsPage> {
  ConcessionCategory? _selectedCategory; // null = all
  List<ConcessionItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConcessions();
  }

  Future<void> _loadConcessions() async {
    final list = await ServiceLocator.concessionDataSource.getConcessions();
    if (mounted) {
      setState(() {
        _items = list;
        _isLoading = false;
      });
    }
  }

  void _navigateToCheckout(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CheckoutSummaryPage(),
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
              backgroundColor: AppColors.headerBackground,
              elevation: 0,
              centerTitle: true,
              title: Text(
                'Snacks & Drinks',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
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
                TextButton(
                  onPressed: () => _navigateToCheckout(context),
                  child: Text(
                    'Skip',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
      body: Column(
        children: [
          if (isDesktop) ...[
            ResponsiveShell.buildDesktopHeader(context, currentIndex: 0),
            _buildDesktopSubHeader(context),
          ] else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: BookingProgressBar(
                currentStep: BookingStep.orderReview,
                onStepTapped: (step) {
                  if (step == BookingStep.chooseSeat || step == BookingStep.showtime) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ],
          Expanded(
            child: BlocBuilder<BookingBloc, BookingState>(
              builder: (context, state) {
                final movie = widget.movie ?? state.movie;
                final showtime = widget.showtime ?? state.showtime;

                if (movie == null || showtime == null) {
                  return const Center(child: Text('Booking session expired'));
                }

                final filteredItems = _selectedCategory == null
                    ? _items
                    : _items.where((i) => i.category == _selectedCategory).toList();

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: ResponsiveShell.maxContentWidth,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Booking Context Banner
                                _buildBookingContextCard(movie, showtime, state),
                                const SizedBox(height: 20),

                                // Category Selector Pills
                                _buildCategoryPills(),
                                const SizedBox(height: 18),

                                // Items Section Header
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _selectedCategory == null
                                          ? 'All Concessions & Treats'
                                          : _getCategoryTitle(_selectedCategory!),
                                      style: AppTypography.titleMedium.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      '${filteredItems.length} items',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Items List / Grid
                                if (_isLoading)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(48.0),
                                      child: CircularProgressIndicator(color: AppColors.primary),
                                    ),
                                  )
                                else
                                  _buildConcessionGrid(context, filteredItems, state),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Bottom Bar
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
          constraints: const BoxConstraints(
            maxWidth: ResponsiveShell.maxContentWidth,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                GlassCard(
                  borderRadius: 14,
                  padding: const EdgeInsets.all(8),
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Select Snacks & Drinks',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                BookingProgressBar(
                  currentStep: BookingStep.orderReview,
                  onStepTapped: (step) {
                    if (step == BookingStep.chooseSeat || step == BookingStep.showtime) {
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

  Widget _buildBookingContextCard(Movie movie, Showtime showtime, BookingState state) {
    final seatCodes = state.selectedSeats.map((s) => s.seatCode).join(', ');

    return GlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              movie.posterUrl,
              width: 52,
              height: 74,
              fit: BoxFit.cover,
              webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 52,
                height: 74,
                color: AppColors.surfaceElevated,
                child: const Icon(Icons.movie_rounded, color: Colors.white38),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  style: AppTypography.titleSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${showtime.locationName} • ${showtime.hallName}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        'Seats: $seatCodes',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primaryLight,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLighter.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.glassBorderSubtle),
                      ),
                      child: Text(
                        Formatters.formatTime(showtime.startTime),
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
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

  Widget _buildCategoryPills() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildCategoryPill(null, 'All Concessions', Icons.grid_view_rounded),
          const SizedBox(width: 8),
          _buildCategoryPill(ConcessionCategory.combos, 'Combos & Meals', Icons.fastfood_rounded),
          const SizedBox(width: 8),
          _buildCategoryPill(ConcessionCategory.popcorn, 'Popcorn', Icons.grain_rounded),
          const SizedBox(width: 8),
          _buildCategoryPill(ConcessionCategory.drinks, 'Drinks', Icons.local_drink_rounded),
          const SizedBox(width: 8),
          _buildCategoryPill(ConcessionCategory.snacks, 'Warm Snacks', Icons.lunch_dining_rounded),
        ],
      ),
    );
  }

  Widget _buildCategoryPill(ConcessionCategory? category, String label, IconData icon) {
    final isSelected = _selectedCategory == category;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategory = category),
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.16)
              : AppColors.surfaceLighter.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.glassBorderSubtle,
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
              style: AppTypography.labelSmall.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  String _getCategoryTitle(ConcessionCategory cat) {
    switch (cat) {
      case ConcessionCategory.combos:
        return 'Value Combos & Sets';
      case ConcessionCategory.popcorn:
        return 'Fresh Gourmet Popcorn';
      case ConcessionCategory.drinks:
        return 'Chilled Drinks & Beverages';
      case ConcessionCategory.snacks:
        return 'Hot & Savory Snacks';
    }
  }

  Widget _buildConcessionGrid(
    BuildContext context,
    List<ConcessionItem> items,
    BookingState state,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;

        if (isWide) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              mainAxisExtent: 130,
            ),
            itemBuilder: (context, index) {
              return _buildItemCard(context, items[index], state);
            },
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildItemCard(context, items[index], state),
            );
          },
        );
      },
    );
  }

  Widget _buildItemCard(
    BuildContext context,
    ConcessionItem item,
    BookingState state,
  ) {
    final orderItem = state.selectedConcessions[item.id];
    final quantity = orderItem?.quantity ?? 0;

    return GlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Item Image with Popular & Calories Badges
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  item.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: AppColors.surfaceElevated,
                    child: const Icon(Icons.fastfood_rounded, color: Colors.white38),
                  ),
                ),
              ),
              if (item.isPopular)
                Positioned(
                  top: 5,
                  left: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Text(
                      'POPULAR',
                      style: TextStyle(
                        fontSize: 7.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),

          // Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.name,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  item.description,
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 10.5,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      Formatters.formatCurrency(item.price),
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.accentGold,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (item.calories.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        '• ${item.calories}',
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 10,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Stepper +/-
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: quantity > 0
                    ? AppColors.primary.withValues(alpha: 0.5)
                    : AppColors.glassBorderSubtle,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (quantity > 0) ...[
                  _buildStepBtn(
                    icon: Icons.remove_rounded,
                    onTap: () {
                      context.read<BookingBloc>().add(
                            UpdateConcessionQuantityEvent(item: item, delta: -1),
                          );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '$quantity',
                      style: AppTypography.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
                _buildStepBtn(
                  icon: Icons.add_rounded,
                  isPrimary: true,
                  onTap: () {
                    context.read<BookingBloc>().add(
                          UpdateConcessionQuantityEvent(item: item, delta: 1),
                        );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepBtn({
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          gradient: isPrimary ? AppColors.primaryGradient : null,
          color: isPrimary ? null : AppColors.surfaceLighter,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }

  Widget _buildBottomDrawer(BuildContext context, BookingState state) {
    final hasConcessions = state.selectedConcessions.isNotEmpty;
    final totalConcessionsCount = state.selectedConcessions.values
        .fold(0, (sum, item) => sum + item.quantity);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        border: const Border(
          top: BorderSide(color: AppColors.glassBorder, width: 1.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.65),
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
              child: Row(
                children: [
                  // Total Info
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasConcessions
                              ? '$totalConcessionsCount Snacks Added'
                              : 'No Snacks Selected',
                          style: AppTypography.bodySmall.copyWith(
                            color: hasConcessions ? AppColors.primaryLight : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          hasConcessions
                              ? Formatters.formatCurrency(state.totalAmount)
                              : Formatters.formatCurrency(state.ticketSubtotal),
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

                  // Skip Button (if no concessions or wants to skip)
                  if (!hasConcessions) ...[
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.glassBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onPressed: () => _navigateToCheckout(context),
                      child: Text(
                        'Skip',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],

                  // Continue to Payment Button
                  SoftButton(
                    text: hasConcessions ? 'Continue to Checkout' : 'Continue',
                    icon: Icons.arrow_forward_rounded,
                    height: 52,
                    borderRadius: 18,
                    onPressed: () => _navigateToCheckout(context),
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
