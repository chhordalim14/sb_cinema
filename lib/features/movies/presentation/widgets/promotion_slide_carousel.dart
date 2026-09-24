import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/banner_slide.dart';

class PromotionSlideCarousel extends StatefulWidget {
  final List<BannerSlide> promotions;
  final Function(BannerSlide promotion) onPromotionSelected;

  const PromotionSlideCarousel({
    super.key,
    required this.promotions,
    required this.onPromotionSelected,
  });

  @override
  State<PromotionSlideCarousel> createState() => _PromotionSlideCarouselState();
}

class _PromotionSlideCarouselState extends State<PromotionSlideCarousel> {
  static const int _kLoopMultiplier = 1000;
  static const double _viewportFraction = 1.0;

  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  int get _itemCount => widget.promotions.length;
  int get _initialPage =>
      _itemCount > 1 ? (_itemCount * (_kLoopMultiplier ~/ 2)) : 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: _viewportFraction,
      initialPage: _initialPage,
    );
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    if (_itemCount <= 1) return;
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted || _itemCount == 0 || !_pageController.hasClients) return;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.promotions.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final containerWidth = constraints.maxWidth;
        final isDesktop = containerWidth >= 900;
        final horizontalPadding = isDesktop ? 0.0 : 20.0;
        final carouselHeight = isDesktop
            ? (containerWidth * 0.30).clamp(240.0, 320.0)
            : (containerWidth * 0.52).clamp(190.0, 260.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header: Aligned precisely flush with the movie posters grid and card
            Padding(
              padding: EdgeInsets.only(left: horizontalPadding, bottom: 16),
              child: Text(
                'PROMOTION',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            // Carousel Card with stationary progress points
            MouseRegion(
              onEnter: (_) => _autoScrollTimer?.cancel(),
              onExit: (_) => _startAutoScroll(),
              child: SizedBox(
                height: carouselHeight,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _itemCount > 1
                          ? _itemCount * _kLoopMultiplier
                          : _itemCount,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index % _itemCount);
                        _startAutoScroll();
                      },
                      itemBuilder: (context, index) {
                        final actualIndex = index % _itemCount;
                        final slide = widget.promotions[actualIndex];

                        return AnimatedBuilder(
                          animation: _pageController,
                          builder: (context, child) {
                            double scale = 1.0;
                            if (_pageController.position.haveDimensions) {
                              final page = _pageController.page ??
                                  _initialPage.toDouble();
                              final diff = (page - index).abs().clamp(0.0, 1.0);
                              scale = 1.0 - (diff * 0.04);
                            }

                            return Transform.scale(
                              scale: scale,
                              child: GestureDetector(
                                onTap: () {
                                  final currentActual =
                                      _pageController.hasClients
                                          ? (_pageController.page?.round() ??
                                              _initialPage)
                                          : _initialPage;
                                  if (index == currentActual) {
                                    widget.onPromotionSelected(slide);
                                  } else {
                                    _pageController.animateToPage(
                                      index,
                                      duration:
                                          const Duration(milliseconds: 450),
                                      curve: Curves.easeInOutCubic,
                                    );
                                  }
                                },
                                behavior: HitTestBehavior.opaque,
                                child: _buildPromotionCard(
                                  slide,
                                  horizontalPadding: horizontalPadding,
                                  isDesktop: isDesktop,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),

                    // Centered stationary Progress Indicator (does not slide with card)
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Center(child: _buildProgressPoints()),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgressPoints() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(widget.promotions.length, (dotIndex) {
          final isActive = _currentPage == dotIndex;
          return GestureDetector(
            onTap: () {
              if (!_pageController.hasClients) return;
              final currentActual =
                  _pageController.page?.round() ?? _initialPage;
              final currentDot = currentActual % _itemCount;
              final targetPage = currentActual + (dotIndex - currentDot);
              _pageController.animateToPage(
                targetPage,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOutCubic,
              );
            },
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
              width: isActive ? 20 : 6,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: isActive
                    ? AppColors.primary
                    : Colors.white.withValues(alpha: 0.45),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.5),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPromotionCard(
    BannerSlide slide, {
    required double horizontalPadding,
    required bool isDesktop,
  }) {
    final isLocal = slide.imageUrl.startsWith('assets/');

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: const Color(0xFF8B1538).withValues(alpha: 0.25),
            blurRadius: 22,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Background artwork
            isLocal
                ? Image.asset(
                    slide.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildFallbackBackground(),
                  )
                : Image.network(
                    slide.imageUrl,
                    fit: BoxFit.cover,
                    webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildFallbackBackground(),
                  ),

            // 2. Gradient overlay ensuring high text legibility on left side
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color(0xFF5A030D).withValues(alpha: 0.94),
                    const Color(0xFF6B0815).withValues(alpha: 0.72),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.48, 0.85],
                ),
              ),
            ),

            // 3. Left-aligned content: Title, Description, and "LEARN MORE" button
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isDesktop ? 32 : 20,
                  isDesktop ? 22 : 16,
                  isDesktop ? 24 : 16,
                  isDesktop ? 26 : 22,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            slide.title,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: isDesktop ? 21 : 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            slide.subtitle,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white.withValues(alpha: 0.88),
                              fontSize: isDesktop ? 13 : 11.5,
                              fontWeight: FontWeight.w400,
                              height: 1.38,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isDesktop ? 20 : 16,
                              vertical: isDesktop ? 9 : 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              slide.actionText.isNotEmpty
                                  ? slide.actionText.toUpperCase()
                                  : 'LEARN MORE',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFFC62828),
                                fontSize: isDesktop ? 12.5 : 11.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(flex: 9),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7A0813), Color(0xFF4A030C), Color(0xFF240207)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.local_offer_rounded, size: 40, color: Colors.white38),
      ),
    );
  }
}
