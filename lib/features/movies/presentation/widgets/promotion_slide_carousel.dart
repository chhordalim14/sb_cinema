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
      viewportFraction: 0.85,
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
        duration: const Duration(milliseconds: 700),
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

    final screenWidth = MediaQuery.of(context).size.width;
    // Exactly the same height calculation as top hero carousel
    final carouselHeight = (screenWidth * 0.52).clamp(220.0, 360.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header: "Promotion"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Promotion',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Carousel Card with stationary progress points
        SizedBox(
          height: carouselHeight,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              PageView.builder(
                controller: _pageController,
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
                  final card = _buildPromotionCard(slide);

                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double scale = 1.0;
                      if (_pageController.position.haveDimensions) {
                        final page =
                            _pageController.page ?? _initialPage.toDouble();
                        final diff = (page - index).abs();
                        scale = (1.0 - (diff * 0.10)).clamp(0.88, 1.0);
                      } else {
                        scale = (index == _initialPage) ? 1.0 : 0.90;
                      }
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: card,
                  );
                },
              ),

              // Centered stationary Progress Indicator (does not slide with card)
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Center(child: _buildProgressPoints()),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressPoints() {
    return Row(
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
            margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
            width: isActive ? 20 : 6,
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: isActive
                  ? AppColors.primary
                  : Colors.white.withValues(alpha: 0.45),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPromotionCard(BannerSlide slide) {
    final isLocal = slide.imageUrl.startsWith('assets/');

    return GestureDetector(
      onTap: () => widget.onPromotionSelected(slide),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
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
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Background artwork (with right-aligned popcorn, drink, etc.)
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

              // 3. Left-aligned content: Title, Description, and "Learn More" button
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 16, 26),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 11,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Headline e.g. 🐼🍿 Special Exclusive...
                            Text(
                              slide.title,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 17.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),

                            // Subtitle / promotional description
                            Text(
                              slide.subtitle,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white.withValues(alpha: 0.88),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w400,
                                height: 1.38,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 14),

                            // "Learn More" Pill Button
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => widget.onPromotionSelected(slide),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.25,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    slide.actionText.isNotEmpty
                                        ? slide.actionText
                                        : 'Learn More',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFFC62828),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Leaves the right half for the graphic (popcorn bucket, drink, etc.)
                      const Spacer(flex: 10),
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
