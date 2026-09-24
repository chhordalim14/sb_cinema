import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_footer.dart';
import '../../../../core/widgets/responsive_shell.dart';
import '../../domain/entities/banner_slide.dart';
import '../bloc/movie_bloc.dart';
import '../bloc/movie_event.dart';
import '../bloc/movie_state.dart';
import 'movie_details_page.dart';

class PromotionsPage extends StatefulWidget {
  const PromotionsPage({super.key});

  @override
  State<PromotionsPage> createState() => _PromotionsPageState();
}

class _PromotionsPageState extends State<PromotionsPage> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Special Deals',
    'Bank & Partners',
    'Combos & Food',
    'Discounts',
  ];

  @override
  void initState() {
    super.initState();
    final state = context.read<MovieBloc>().state;
    if (state.bannerSlides.isEmpty) {
      context.read<MovieBloc>().add(LoadMoviesInitialEvent());
    }
  }

  List<BannerSlide> _filterSlides(List<BannerSlide> slides) {
    if (_selectedCategory == 'All') {
      return slides;
    }
    if (_selectedCategory == 'Special Deals') {
      return slides.where((s) {
        final tag = s.tag.toUpperCase();
        return s.type == BannerSlideType.promotion ||
            tag.contains('PROMO') ||
            tag.contains('DEAL') ||
            tag.contains('SPECIAL');
      }).toList();
    }
    if (_selectedCategory == 'Bank & Partners') {
      return slides.where((s) {
        final tag = s.tag.toUpperCase();
        final title = s.title.toUpperCase();
        return s.type == BannerSlideType.partner ||
            tag.contains('PARTNER') ||
            title.contains('ABA') ||
            title.contains('BANK') ||
            title.contains('GANZBERG') ||
            title.contains('BACCHUS');
      }).toList();
    }
    if (_selectedCategory == 'Combos & Food') {
      return slides.where((s) {
        final tag = s.tag.toUpperCase();
        final title = s.title.toUpperCase();
        final sub = s.subtitle.toUpperCase();
        return tag.contains('BUCKET') ||
            tag.contains('COMBO') ||
            title.contains('FOODPANDA') ||
            title.contains('POPCORN') ||
            sub.contains('POPCORN') ||
            sub.contains('DRINK');
      }).toList();
    }
    if (_selectedCategory == 'Discounts') {
      return slides.where((s) {
        final tag = s.tag.toUpperCase();
        final title = s.title.toUpperCase();
        final sub = s.subtitle.toUpperCase();
        return tag.contains('OFF') ||
            tag.contains('STUDENT') ||
            s.type == BannerSlideType.pricing ||
            title.contains('PRICE') ||
            sub.contains('DISCOUNT');
      }).toList();
    }
    return slides;
  }

  void _handleSlideTap(BuildContext context, BannerSlide slide, MovieState state) {
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
                                  errorBuilder:
                                      (context, error, stackTrace) => Container(
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

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveShell.isDesktop(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: AppColors.background.withValues(alpha: 0.72),
              elevation: 0,
              centerTitle: true,
              title: Text(
                'Promotions',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
      body: BlocBuilder<MovieBloc, MovieState>(
        builder: (context, state) {
          final allSlides = state.bannerSlides;
          final filteredSlides = _filterSlides(allSlides);

          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surfaceElevated,
            onRefresh: () async {
              context.read<MovieBloc>().add(LoadMoviesInitialEvent());
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: ResponsiveShell.maxContentWidth,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),

                            // Hero Banner Header on Desktop
                            if (isDesktop) ...[
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Exclusive Promotions',
                                        style: AppTypography.displayMedium.copyWith(
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Discover exclusive combos, bank partner discounts, and student perks.',
                                        style: AppTypography.bodyMedium.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: AppColors.primary.withValues(alpha: 0.35),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.local_offer_rounded,
                                          color: AppColors.primary,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${allSlides.length} Active Offers',
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                            ],

                            // Category Filter Chips
                            SizedBox(
                              height: 42,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _categories.length,
                                separatorBuilder: (_, _) => const SizedBox(width: 10),
                                itemBuilder: (context, index) {
                                  final category = _categories[index];
                                  final isSelected = _selectedCategory == category;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() => _selectedCategory = category);
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 10,
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
                                      child: Center(
                                        child: Text(
                                          category,
                                          style: TextStyle(
                                            color: isSelected
                                                ? AppColors.primaryLight
                                                : AppColors.textSecondary,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Promotions Grid
                            if (filteredSlides.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(40),
                                alignment: Alignment.center,
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.local_offer_outlined,
                                      size: 56,
                                      color: Colors.white24,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No promotions found in this category.',
                                      style: AppTypography.titleMedium.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final width = constraints.maxWidth;
                                  final crossAxisCount = width > 900
                                      ? 3
                                      : (width > 600 ? 2 : 1);
                                  final childAspectRatio = width > 900
                                      ? 0.78
                                      : (width > 600 ? 0.82 : 1.15);

                                  return GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      childAspectRatio: childAspectRatio,
                                      crossAxisSpacing: 20,
                                      mainAxisSpacing: 22,
                                    ),
                                    itemCount: filteredSlides.length,
                                    itemBuilder: (context, index) {
                                      final slide = filteredSlides[index];
                                      return _buildPromotionCard(
                                        context,
                                        slide,
                                        state,
                                      );
                                    },
                                  );
                                },
                              ),
                            const SizedBox(height: 48),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: AppFooter(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPromotionCard(
    BuildContext context,
    BannerSlide slide,
    MovieState state,
  ) {
    final isLocal = slide.imageUrl.startsWith('assets/');

    return GestureDetector(
      onTap: () => _handleSlideTap(context, slide, state),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.glassBorderSubtle,
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Artwork
              Expanded(
                flex: 12,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    isLocal
                        ? Image.asset(
                            slide.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: AppColors.surfaceLighter,
                              child: const Center(
                                child: Icon(
                                  Icons.local_offer_rounded,
                                  size: 40,
                                  color: Colors.white24,
                                ),
                              ),
                            ),
                          )
                        : Image.network(
                            slide.imageUrl,
                            fit: BoxFit.cover,
                            webHtmlElementStrategy:
                                WebHtmlElementStrategy.fallback,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: AppColors.surfaceLighter,
                              child: const Center(
                                child: Icon(
                                  Icons.local_offer_rounded,
                                  size: 40,
                                  color: Colors.white24,
                                ),
                              ),
                            ),
                          ),
                    // Gradient overlay at bottom of image
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 48,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.surfaceElevated.withValues(alpha: 0.9),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Tag Badge
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.burgundy.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.6),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Text(
                          slide.tag,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content Details
              Expanded(
                flex: 11,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (slide.khmerTitle != null) ...[
                            Text(
                              slide.khmerTitle!,
                              style: GoogleFonts.kantumruyPro(
                                color: AppColors.textSecondary,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                          ],
                          Text(
                            slide.title,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              height: 1.25,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            slide.subtitle,
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.textSecondary,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w400,
                              height: 1.35,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.verified_rounded,
                                size: 14,
                                color: AppColors.accentGold,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Sabay Promo',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.accentGold,
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              slide.actionText.isNotEmpty
                                  ? slide.actionText
                                  : 'View Offer',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
