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
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoScrollTimer;
  bool _isPlaying = true;
  double _viewportFraction = 0.72;

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final width = MediaQuery.of(context).size.width;
    // Desktop widescreen: 72% center card with 14% peeking on left & right
    // Tablet: 78% center card
    // Mobile: 86% center card
    final newFraction = width >= 1200
        ? 0.72
        : (width >= 800 ? 0.78 : 0.86);

    if ((_viewportFraction - newFraction).abs() > 0.01) {
      _viewportFraction = newFraction;
      final currentActual = _pageController.hasClients
          ? (_pageController.page?.round() ?? _initialPage)
          : _initialPage;
      _pageController.dispose();
      _pageController = PageController(
        viewportFraction: _viewportFraction,
        initialPage: currentActual,
      );
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    if (_itemCount <= 1 || !_isPlaying) return;
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted || _itemCount == 0 || !_pageController.hasClients || !_isPlaying) {
        return;
      }
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
    if (_itemCount == 0) return const SizedBox.shrink();

    final width = MediaQuery.of(context).size.width;
    // Cinematic banner height scaling
    final carouselHeight = width >= 1200
        ? (width * 0.25).clamp(380.0, 520.0)
        : (width >= 800
            ? (width * 0.36).clamp(300.0, 420.0)
            : (width * 0.54).clamp(220.0, 320.0));

    return Container(
      width: double.infinity,
      height: carouselHeight,
      margin: const EdgeInsets.only(top: 10, bottom: 6),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 1. Sliding Cards with Peeking Neighbors
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index % _itemCount);
              if (_isPlaying) _startAutoScroll();
            },
            itemCount:
                _itemCount > 1 ? _itemCount * _kLoopMultiplier : _itemCount,
            itemBuilder: (context, index) {
              final actualIndex = index % _itemCount;
              final child = _hasSlides
                  ? _buildBannerSlideItem(widget.slides![actualIndex])
                  : _buildMovieSlideItem(widget.movies![actualIndex]);

              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double scale = 1.0;
                  double opacity = 1.0;

                  if (_pageController.position.haveDimensions) {
                    final page =
                        _pageController.page ?? _initialPage.toDouble();
                    final diff = (page - index).abs().clamp(0.0, 1.0);
                    // Center card: scale 1.0, opacity 1.0
                    // Peeking side cards: scale ~0.94, opacity ~0.42 (dimmed so center card pops)
                    scale = 1.0 - (diff * 0.06);
                    opacity = 1.0 - (diff * 0.58);
                  } else {
                    final isCenter = (index == _initialPage);
                    scale = isCenter ? 1.0 : 0.94;
                    opacity = isCenter ? 1.0 : 0.42;
                  }

                  return Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: opacity.clamp(0.2, 1.0),
                      child: child,
                    ),
                  );
                },
                child: child,
              );
            },
          ),

          // 2. Soft Edge Dimming Vignettes on Left & Right screen edges
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 48,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppColors.background.withValues(alpha: 0.65),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 48,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      AppColors.background.withValues(alpha: 0.65),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. Slide Indicator Dots
          Positioned(
            bottom: 18,
            child: _buildSlideIndicators(),
          ),
        ],
      ),
    );
  }

  Widget _buildSlideIndicators() {
    return Row(
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
            margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
            width: isActive ? 26 : 7,
            height: 7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isActive
                  ? Colors.white
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

  Widget _buildBannerSlideItem(BannerSlide slide) {
    final isLocal = slide.imageUrl.startsWith('assets/');

    return GestureDetector(
      onTap: () => widget.onSlideSelected?.call(slide),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.65),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              isLocal
                  ? Image.asset(
                      slide.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.surfaceLighter,
                        child: const Center(
                          child: Icon(
                            Icons.movie_rounded,
                            size: 48,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    )
                  : Image.network(
                      slide.imageUrl,
                      fit: BoxFit.cover,
                      webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.surfaceLighter,
                        child: const Center(
                          child: Icon(
                            Icons.movie_rounded,
                            size: 48,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMovieSlideItem(Movie movie) {
    return GestureDetector(
      onTap: () => widget.onMovieSelected?.call(movie),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.65),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.network(
            movie.backdropUrl,
            fit: BoxFit.cover,
            webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
            errorBuilder: (context, error, stackTrace) => Container(
              color: AppColors.surfaceLighter,
              child: const Center(
                child: Icon(
                  Icons.movie_rounded,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
