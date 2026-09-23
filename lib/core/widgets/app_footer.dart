import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/movies/presentation/bloc/movie_bloc.dart';
import '../../features/movies/presentation/bloc/movie_event.dart';
import '../../features/movies/presentation/widgets/branch_selector_modal.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import 'responsive_shell.dart';

/// AppFooter component replicating the official cinema footer layout
/// with Sabay Cinemas branding, links, app downloads, social channels, and payment partners.
class AppFooter extends StatelessWidget {
  final VoidCallback? onPromotionsTap;

  const AppFooter({
    super.key,
    this.onPromotionsTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 800;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.footerBackground,
        gradient: AppColors.footerGradient,
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1.0,
          ),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: ResponsiveShell.maxContentWidth),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 24 : 20,
              vertical: 40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top section: Links + App Download & Social Media
                if (isDesktop)
                  _buildDesktopTopRow(context)
                else
                  _buildMobileTopSection(context),

                const SizedBox(height: 36),

                // Payment Section
                _buildPaymentSection(context),

                const SizedBox(height: 36),

                // Divider line
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.1),
                ),

                const SizedBox(height: 24),

                // Bottom Copyright centered text (Sabay Cinemas)
                Center(
                  child: Text(
                    '© 2026 Sabay Cinemas. All rights reserved.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 13,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== DESKTOP LAYOUT ====================
  Widget _buildDesktopTopRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Column 1: Company
        SizedBox(
          width: 170,
          child: _buildLinkColumn(
            title: 'Company',
            items: [
              _FooterLinkItem('About Us', () => _showAboutModal(context)),
              _FooterLinkItem('Contact Us', () => _showContactModal(context)),
              _FooterLinkItem('Cinemas', () => _handleCinemasTap(context)),
            ],
          ),
        ),

        const SizedBox(width: 40),

        // Column 2: More
        SizedBox(
          width: 200,
          child: _buildLinkColumn(
            title: 'More',
            items: [
              _FooterLinkItem('Food & Drinks', () => ResponsiveShell.navigateToTab(context, 1, null)),
              _FooterLinkItem(
                'Promotions',
                onPromotionsTap ?? () => ResponsiveShell.navigateToTab(context, 2, null),
              ),
              _FooterLinkItem('News & Activity', () => _showInfoModal(context, 'News & Activity', 'Stay tuned for upcoming movie festivals, premiere galas, and fan screenings at Sabay Cinemas.')),
              _FooterLinkItem('My Ticket', () => ResponsiveShell.navigateToTab(context, 3, null)),
              _FooterLinkItem('Terms & Conditions', () => _showInfoModal(context, 'Terms & Conditions', 'Tickets purchased are non-refundable and subject to cinema house rules.')),
              _FooterLinkItem('Privacy & Policy', () => _showInfoModal(context, 'Privacy & Policy', 'Sabay Cinemas respects your personal data privacy and adheres to data protection guidelines.')),
            ],
          ),
        ),

        const Spacer(),

        // Column 3 (Right aligned): Download App & Follow Social Media
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Download Our App
            _buildSectionHeader('Download Our App'),
            const SizedBox(height: 14),
            Row(
              children: [
                _buildGooglePlayButton(context),
                const SizedBox(width: 12),
                _buildAppleStoreButton(context),
              ],
            ),

            const SizedBox(height: 28),

            // Follow Our Social Media
            _buildSectionHeader('Follow Our Social Media'),
            const SizedBox(height: 14),
            Row(
              children: [
                _buildSocialIcon(
                  context,
                  tooltip: 'Facebook',
                  child: const Text(
                    'f',
                    style: TextStyle(
                      fontFamily: 'sans-serif',
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _buildSocialIcon(
                  context,
                  tooltip: 'Instagram',
                  child: CustomPaint(
                    size: const Size(18, 18),
                    painter: _InstagramIconPainter(),
                  ),
                ),
                const SizedBox(width: 10),
                _buildSocialIcon(
                  context,
                  tooltip: 'YouTube',
                  child: CustomPaint(
                    size: const Size(18, 14),
                    painter: _YouTubeIconPainter(),
                  ),
                ),
                const SizedBox(width: 10),
                _buildSocialIcon(
                  context,
                  tooltip: 'TikTok',
                  child: const Icon(
                    Icons.music_note_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                _buildSocialIcon(
                  context,
                  tooltip: 'Telegram',
                  child: const Icon(
                    Icons.send_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ==================== MOBILE LAYOUT ====================
  Widget _buildMobileTopSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildLinkColumn(
                title: 'Company',
                items: [
                  _FooterLinkItem('About Us', () => _showAboutModal(context)),
                  _FooterLinkItem('Contact Us', () => _showContactModal(context)),
                  _FooterLinkItem('Cinemas', () => _handleCinemasTap(context)),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildLinkColumn(
                title: 'More',
                items: [
                  _FooterLinkItem('Food & Drinks', () => ResponsiveShell.navigateToTab(context, 1, null)),
                  _FooterLinkItem(
                    'Promotions',
                    onPromotionsTap ?? () => ResponsiveShell.navigateToTab(context, 2, null),
                  ),
                  _FooterLinkItem('News & Activity', () => _showInfoModal(context, 'News & Activity', 'Stay tuned for upcoming movie festivals, premiere galas, and fan screenings at Sabay Cinemas.')),
                  _FooterLinkItem('My Ticket', () => ResponsiveShell.navigateToTab(context, 3, null)),
                  _FooterLinkItem('Terms & Conditions', () => _showInfoModal(context, 'Terms & Conditions', 'Tickets purchased are non-refundable and subject to cinema house rules.')),
                  _FooterLinkItem('Privacy & Policy', () => _showInfoModal(context, 'Privacy & Policy', 'Sabay Cinemas respects your personal data privacy and adheres to data protection guidelines.')),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Download Our App
        _buildSectionHeader('Download Our App'),
        const SizedBox(height: 14),
        Row(
          children: [
            _buildGooglePlayButton(context),
            const SizedBox(width: 12),
            _buildAppleStoreButton(context),
          ],
        ),

        const SizedBox(height: 28),

        // Follow Our Social Media
        _buildSectionHeader('Follow Our Social Media'),
        const SizedBox(height: 14),
        Row(
          children: [
            _buildSocialIcon(
              context,
              tooltip: 'Facebook',
              child: const Text(
                'f',
                style: TextStyle(
                  fontFamily: 'sans-serif',
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            _buildSocialIcon(
              context,
              tooltip: 'Instagram',
              child: CustomPaint(
                size: const Size(18, 18),
                painter: _InstagramIconPainter(),
              ),
            ),
            const SizedBox(width: 10),
            _buildSocialIcon(
              context,
              tooltip: 'YouTube',
              child: CustomPaint(
                size: const Size(18, 14),
                painter: _YouTubeIconPainter(),
              ),
            ),
            const SizedBox(width: 10),
            _buildSocialIcon(
              context,
              tooltip: 'TikTok',
              child: const Icon(
                Icons.music_note_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            _buildSocialIcon(
              context,
              tooltip: 'Telegram',
              child: const Icon(
                Icons.send_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==================== PAYMENT SECTION ====================
  Widget _buildPaymentSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Payment'),
        const SizedBox(height: 16),
        Wrap(
          spacing: 28,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // ABA' PAYWAY
            InkWell(
              onTap: () => _showPaymentInfo(context, 'ABA PayWay', 'Accepted via ABA Mobile KHQR and ABA PayWay direct gateway.'),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ABA\'',
                      style: AppTypography.titleMedium.copyWith(
                        color: const Color(0xFF00B2D6),
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'PAYWAY',
                      style: AppTypography.titleSmall.copyWith(
                        color: const Color(0xFF00B2D6),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // VISA
            InkWell(
              onTap: () => _showPaymentInfo(context, 'VISA', 'Accepted across all major international and local Visa credit & debit cards.'),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  'VISA',
                  style: AppTypography.titleMedium.copyWith(
                    color: const Color(0xFF2566AF),
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),

            // Mastercard (Two overlapping circles)
            InkWell(
              onTap: () => _showPaymentInfo(context, 'Mastercard', 'Accepted across all major Mastercard credit & debit cards.'),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: SizedBox(
                  width: 38,
                  height: 24,
                  child: Stack(
                    children: [
                      // Red circle
                      Positioned(
                        left: 0,
                        top: 1,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEB001B),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      // Amber/Orange circle with blending
                      Positioned(
                        left: 14,
                        top: 1,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF79E1B).withValues(alpha: 0.88),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==================== HELPER WIDGETS ====================
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTypography.titleSmall.copyWith(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
      ),
    );
  }

  Widget _buildLinkColumn({
    required String title,
    required List<_FooterLinkItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title),
        const SizedBox(height: 16),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _FooterHoverLink(
              label: item.label,
              onTap: item.onTap,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGooglePlayButton(BuildContext context) {
    return _buildStoreButton(
      context: context,
      tooltip: 'Google Play',
      child: CustomPaint(
        size: const Size(18, 20),
        painter: _GooglePlayIconPainter(),
      ),
      onTap: () => _showAppDownloadNotice(context, 'Google Play Store'),
    );
  }

  Widget _buildAppleStoreButton(BuildContext context) {
    return _buildStoreButton(
      context: context,
      tooltip: 'App Store',
      child: const Icon(
        Icons.apple_rounded,
        size: 24,
        color: Colors.white,
      ),
      onTap: () => _showAppDownloadNotice(context, 'Apple App Store'),
    );
  }

  Widget _buildStoreButton({
    required BuildContext context,
    required String tooltip,
    required Widget child,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.28),
              width: 1.2,
            ),
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }

  Widget _buildSocialIcon(
    BuildContext context, {
    required String tooltip,
    required Widget child,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening Sabay Cinemas on $tooltip...'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.surfaceElevated,
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.35),
              width: 1.2,
            ),
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }

  // ==================== ACTIONS & MODALS ====================
  void _handleCinemasTap(BuildContext context) {
    final movieBloc = context.read<MovieBloc>();
    final state = movieBloc.state;
    BranchSelectorModal.show(
      context,
      selectedLocationId: state.selectedLocationId,
      onLocationSelected: (loc) {
        movieBloc.add(
          SelectLocationBranchEvent(
            locationId: loc.id,
            locationName: loc.name,
          ),
        );
      },
    );
  }

  void _showAppDownloadNotice(BuildContext context, String storeName) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Redirecting to $storeName for Sabay Cinemas App...'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceElevated,
      ),
    );
  }

  void _showAboutModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceLighter,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Image.asset(
              'assets/logo/logo-sabay.png',
              height: 26,
              errorBuilder: (_, __, ___) => const Icon(Icons.movie_rounded, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            const Text(
              'About Sabay Cinemas',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Sabay Cinemas is Cambodia\'s premier modern cinema experience, delivering crystal-clear projection, 360° Dolby sound, and luxury VIP experiences across Phnom Penh and major provinces.',
          style: TextStyle(color: AppColors.textSecondary, height: 1.5, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showContactModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceLighter,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Contact Sabay Cinemas',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer Care: +855 23 888 222', style: TextStyle(color: Colors.white, fontSize: 14)),
            SizedBox(height: 8),
            Text('Support Email: care@sabaycinema.com', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            SizedBox(height: 8),
            Text('Head Office: Phnom Penh, Kingdom of Cambodia', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showInfoModal(BuildContext context, String title, String description) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceLighter,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Text(
          description,
          style: const TextStyle(color: AppColors.textSecondary, height: 1.5, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got It', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showPaymentInfo(BuildContext context, String provider, String details) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$provider: $details'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceElevated,
      ),
    );
  }
}

class _FooterLinkItem {
  final String label;
  final VoidCallback onTap;

  _FooterLinkItem(this.label, this.onTap);
}

class _FooterHoverLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _FooterHoverLink({
    required this.label,
    required this.onTap,
  });

  @override
  State<_FooterHoverLink> createState() => _FooterHoverLinkState();
}

class _FooterHoverLinkState extends State<_FooterHoverLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 150),
          style: AppTypography.bodyMedium.copyWith(
            color: _isHovered ? Colors.white : const Color(0xFF9E9EA7),
            fontSize: 14,
            fontWeight: _isHovered ? FontWeight.w500 : FontWeight.w400,
          ),
          child: Text(widget.label),
        ),
      ),
    );
  }
}

// ==================== VECTOR PAINTERS FOR EXACT ICONS ====================

/// Google Play Store 4-color triangle badge
class _GooglePlayIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final midY = h * 0.5;
    final junctionX = w * 0.52;

    final paint = Paint()..style = PaintingStyle.fill;

    // Blue polygon (left)
    paint.color = const Color(0xFF00C3FF);
    final bluePath = Path()
      ..moveTo(1, 1)
      ..lineTo(junctionX, midY)
      ..lineTo(1, h - 1)
      ..close();
    canvas.drawPath(bluePath, paint);

    // Green polygon (top)
    paint.color = const Color(0xFF00E676);
    final greenPath = Path()
      ..moveTo(1, 1)
      ..lineTo(w * 0.72, h * 0.34)
      ..lineTo(junctionX, midY)
      ..close();
    canvas.drawPath(greenPath, paint);

    // Red polygon (bottom)
    paint.color = const Color(0xFFFF334B);
    final redPath = Path()
      ..moveTo(1, h - 1)
      ..lineTo(junctionX, midY)
      ..lineTo(w * 0.72, h * 0.66)
      ..close();
    canvas.drawPath(redPath, paint);

    // Yellow polygon (right tip)
    paint.color = const Color(0xFFFFD000);
    final yellowPath = Path()
      ..moveTo(junctionX, midY)
      ..lineTo(w * 0.72, h * 0.34)
      ..lineTo(w - 1, midY)
      ..lineTo(w * 0.72, h * 0.66)
      ..close();
    canvas.drawPath(yellowPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Instagram camera outline painter
class _InstagramIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Outer rounded rect
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(5.5),
    );
    canvas.drawRRect(rrect, strokePaint);

    // Center circle
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, 4.2, strokePaint);

    // Top-right dot
    canvas.drawCircle(Offset(size.width - 4.2, 4.2), 1.0, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// YouTube rounded rectangle with play triangle
class _YouTubeIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Outer rounded rect
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(4.5),
    );
    canvas.drawRRect(rrect, strokePaint);

    // Play triangle
    final midX = size.width / 2;
    final midY = size.height / 2;
    final triPath = Path()
      ..moveTo(midX - 2.5, midY - 3.2)
      ..lineTo(midX + 3.5, midY)
      ..lineTo(midX - 2.5, midY + 3.2)
      ..close();
    canvas.drawPath(triPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
