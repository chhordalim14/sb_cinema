import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/banner_slide.dart';
import '../../domain/entities/movie.dart';

class HeroMovieCarousel extends StatefulWidget {
  final List<BannerSlide>? slides;
  final List<Movie>? movies;
  final Function(BannerSlide slide)? onSlideSelected;
  final Function(Movie movie)? onMovieSelected;
  final Function(Movie movie)? onBookNow;
  final Function(Movie movie)? onWatchTrailer;

  const HeroMovieCarousel({
    super.key,
    this.slides,
    this.movies,
    this.onSlideSelected,
    this.onMovieSelected,
    this.onBookNow,
    this.onWatchTrailer,
  });

  @override
  State<HeroMovieCarousel> createState() => _HeroMovieCarouselState();
}

class _HeroMovieCarouselState extends State<HeroMovieCarousel> {
  static const int _kLoopMultiplier = 1000;
  static const double _viewportFraction = 0.85;

  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoScrollTimer;
  final bool _isPlaying = true;

  bool get _hasSlides => widget.slides != null && widget.slides!.isNotEmpty;
  int get _itemCount =>
      _hasSlides ? widget.slides!.length : (widget.movies?.length ?? 0);

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
    if (_itemCount <= 1 || !_isPlaying) return;
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted ||
          _itemCount == 0 ||
          !_pageController.hasClients ||
          !_isPlaying) {
        return;
      }
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
    if (_itemCount == 0) return const SizedBox.shrink();

    final width = MediaQuery.of(context).size.width;
    // Aspect ratio matched to reference photo (center card ~16:9 to 1.8:1)
    final carouselHeight = width >= 1200
        ? (width * 0.28).clamp(340.0, 480.0)
        : (width >= 800
              ? (width * 0.40).clamp(260.0, 360.0)
              : (width * 0.52).clamp(195.0, 280.0));

    return MouseRegion(
      onEnter: (_) => _autoScrollTimer?.cancel(),
      onExit: (_) {
        if (_isPlaying) _startAutoScroll();
      },
      child: Container(
        width: double.infinity,
        height: carouselHeight,
        margin: const EdgeInsets.only(top: 8, bottom: 8),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // 1. Sliding Cards with Clear Peeking Neighbors (no edge dimming vignettes)
            PageView.builder(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                setState(() => _currentPage = index % _itemCount);
                if (_isPlaying) _startAutoScroll();
              },
              itemCount: _itemCount > 1
                  ? _itemCount * _kLoopMultiplier
                  : _itemCount,
              itemBuilder: (context, index) {
                final actualIndex = index % _itemCount;

                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double scale = 1.0;

                    if (_pageController.position.haveDimensions) {
                      final page =
                          _pageController.page ?? _initialPage.toDouble();
                      final diff = (page - index).abs().clamp(0.0, 1.0);
                      // Center card: scale 1.0
                      // Neighbor cards: scale 0.90 (gives clean height step like reference photo)
                      scale = 1.0 - (diff * 0.10);
                    } else {
                      final isCenter = (index == _initialPage);
                      scale = isCenter ? 1.0 : 0.90;
                    }

                    return Transform.scale(scale: scale, child: child);
                  },
                  child: GestureDetector(
                    onTap: () {
                      final currentActual = _pageController.hasClients
                          ? (_pageController.page?.round() ?? _initialPage)
                          : _initialPage;
                      if (index == currentActual) {
                        if (_hasSlides) {
                          widget.onSlideSelected?.call(
                            widget.slides![actualIndex],
                          );
                        } else if (widget.movies != null &&
                            widget.movies!.isNotEmpty) {
                          widget.onMovieSelected?.call(
                            widget.movies![actualIndex],
                          );
                        }
                      } else {
                        // Tapping a peeking neighbor smoothly slides it into center
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 450),
                          curve: Curves.easeInOutCubic,
                        );
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: _hasSlides
                        ? _buildBannerSlideItem(widget.slides![actualIndex])
                        : _buildMovieSlideItem(widget.movies![actualIndex]),
                  ),
                );
              },
            ),

            // 2. Slide Indicator Capsule at Bottom Center
            Positioned(bottom: 12, child: _buildSlideIndicators()),
          ],
        ),
      ),
    );
  }

  Widget _buildSlideIndicators() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(_itemCount, (dotIndex) {
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
              width: isActive ? 22 : 6,
              height: 5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: isActive
                    ? AppColors.primary
                    : Colors.white.withValues(alpha: 0.45),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.5),
                          blurRadius: 6,
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

  Widget _buildBannerSlideItem(BannerSlide slide) {
    final isLocal = slide.imageUrl.startsWith('assets/');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.40),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: isLocal
            ? Image.asset(
                slide.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholder(),
              )
            : Image.network(
                slide.imageUrl,
                fit: BoxFit.cover,
                webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholder(),
              ),
      ),
    );
  }

  Widget _buildMovieSlideItem(Movie movie) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.40),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          movie.backdropUrl,
          fit: BoxFit.cover,
          webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.surfaceLighter,
      child: const Center(
        child: Icon(
          Icons.movie_rounded,
          size: 48,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
