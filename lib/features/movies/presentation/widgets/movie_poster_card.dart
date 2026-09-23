import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/movie.dart';

class MoviePosterCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;
  final VoidCallback? onBookNow;
  final double width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final bool isGridMode;
  final String? customTag;

  const MoviePosterCard({
    super.key,
    required this.movie,
    required this.onTap,
    this.onBookNow,
    this.width = double.infinity,
    this.height,
    this.margin,
    this.isGridMode = true,
    this.customTag,
  });

  Widget _buildPosterImage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          movie.posterUrl,
          fit: BoxFit.cover,
          width: isGridMode ? double.infinity : width,
          height: isGridMode ? null : (height ?? (width * 1.5)),
          webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
          errorBuilder: (context, error, stackTrace) => Container(
            width: isGridMode ? double.infinity : width,
            height: isGridMode ? null : (height ?? (width * 1.5)),
            color: AppColors.surfaceLighter,
            child: const Center(
              child: Icon(
                Icons.movie_creation_rounded,
                color: AppColors.textSecondary,
                size: 36,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardMargin =
        margin ??
        (isGridMode ? EdgeInsets.zero : const EdgeInsets.only(right: 16));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isGridMode ? null : width,
        margin: cardMargin,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: isGridMode ? MainAxisSize.max : MainAxisSize.min,
          children: [
            // Pure clean poster image with rounded corners
            if (isGridMode)
              Expanded(child: _buildPosterImage())
            else
              _buildPosterImage(),

            const SizedBox(height: 9),

            // Line 1: Custom Tag or Release Date in uppercase cinema gold (#DDAC44)
            Text(
              (customTag ?? Formatters.formatReleaseDate(movie.releaseDate)).toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFDDAC44),
                letterSpacing: 0.7,
              ),
            ),

            const SizedBox(height: 3),

            // Line 2: Movie Title in heavy bold white
            Text(
              movie.title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.1,
                height: 1.22,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
