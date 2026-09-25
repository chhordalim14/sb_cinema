import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/auth/presentation/widgets/sign_in_dialog.dart';
import '../../features/movies/presentation/bloc/movie_bloc.dart';
import '../../features/movies/presentation/bloc/movie_event.dart';
import '../../features/movies/presentation/bloc/movie_state.dart';
import '../../features/movies/presentation/widgets/branch_selector_modal.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import 'glass_card.dart';

class ResponsiveShell extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final Function(int)? onTabSelected;
  final bool showBottomNav;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? trailing;

  const ResponsiveShell({
    super.key,
    required this.child,
    this.currentIndex = 0,
    this.onTabSelected,
    this.showBottomNav = true,
    this.appBar,
    this.floatingActionButton,
    this.trailing,
  });

  static const double maxContentWidth = 1200.0;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 900;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 900;
  }

  @override
  Widget build(BuildContext context) {
    final isWide = isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: appBar,
      body: Stack(
        children: [
          // 1. Signature Sabay Cinema continuous atmospheric backdrop using Logo Colors
          Positioned.fill(child: Container(color: AppColors.background)),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: const Alignment(0.85, 0.70),
                  colors: [
                    AppColors.logoRed.withValues(alpha: 0.42),
                    AppColors.logoPurple.withValues(alpha: 0.26),
                    AppColors.logoMagenta.withValues(alpha: 0.10),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.28, 0.58, 0.90],
                ),
              ),
            ),
          ),
          // Top-Left Orb: Sabay Logo Flame Red warm cinematic glow
          Positioned(
            top: 180,
            left: -90,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.logoRed.withValues(alpha: 0.28),
                    AppColors.logoMagenta.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),
          // Upper-Right Orb: Sabay Logo Ribbon Violet / Purple ambient glow
          Positioned(
            top: 260,
            right: -110,
            child: Container(
              width: 480,
              height: 480,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.logoPurple.withValues(alpha: 0.22),
                    AppColors.logoPurpleDeep.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),
          // Mid-Left Accent Orb: Sabay Logo Flame Sun Amber warmth
          Positioned(
            top: 560,
            left: -80,
            child: Container(
              width: 420,
              height: 420,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.logoAmber.withValues(alpha: 0.10),
                    AppColors.logoOrange.withValues(alpha: 0.03),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.40, 1.0],
                ),
              ),
            ),
          ),
          // Lower Ambient Orb: Deep Logo Violet & Crimson grounding
          Positioned(
            bottom: 60,
            left: -60,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.logoPurpleDeep.withValues(alpha: 0.16),
                    AppColors.logoRed.withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.50, 1.0],
                ),
              ),
            ),
          ),

          // Main Content
          isWide
              ? Column(
                  children: [
                    _buildDesktopHeader(context),
                    Expanded(child: child),
                  ],
                )
              : child,
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildDesktopHeader(BuildContext context) {
    return buildDesktopHeader(
      context,
      currentIndex: currentIndex,
      onTabSelected: onTabSelected,
      trailing: trailing,
    );
  }

  static void Function(int index)? onGlobalTabSelected;

  static void navigateToTab(
    BuildContext context,
    int index,
    Function(int)? onTabSelected,
  ) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    if (onTabSelected != null) {
      onTabSelected(index);
    } else {
      onGlobalTabSelected?.call(index);
    }
  }

  static Widget buildDesktopHeader(
    BuildContext context, {
    int? currentIndex,
    Function(int)? onTabSelected,
    Widget? trailing,
  }) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 88,
          decoration: BoxDecoration(
            color: AppColors.headerBackground,
            gradient: AppColors.headerGradient,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.50),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: maxContentWidth),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    // Brand Logo (Clicking logo pops to root and selects Home)
                    InkWell(
                      onTap: () => navigateToTab(context, 0, onTabSelected),
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        child: Image.asset(
                          'assets/logo/logo-sabay.png',
                          height: 56,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.local_fire_department_rounded,
                                size: 38,
                                color: Colors.white,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Desktop Navigation Tabs
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildDesktopTab(
                              context,
                              0,
                              'Movies',
                              Icons.movie_filter_rounded,
                              currentIndex,
                              onTabSelected,
                            ),
                            const SizedBox(width: 6),
                            _buildDesktopTab(
                              context,
                              1,
                              'Food & Drinks',
                              Icons.fastfood_rounded,
                              currentIndex,
                              onTabSelected,
                            ),
                            const SizedBox(width: 6),
                            _buildDesktopTab(
                              context,
                              2,
                              'Promotion',
                              Icons.local_offer_rounded,
                              currentIndex,
                              onTabSelected,
                            ),
                            const SizedBox(width: 6),
                            _buildDesktopTab(
                              context,
                              3,
                              'My Tickets',
                              Icons.local_activity_rounded,
                              currentIndex,
                              onTabSelected,
                            ),
                            const SizedBox(width: 6),
                            _buildDesktopTab(
                              context,
                              4,
                              'Cinemas',
                              Icons.location_on_rounded,
                              currentIndex,
                              onTabSelected,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    // Right-aligned Location Selector & Sign In Profile
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (trailing != null)
                          trailing
                        else
                          _buildDefaultLocationTrailing(context),
                        const SizedBox(width: 10),
                        _buildAuthButton(context),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildAuthButton(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state.isAuthenticated && state.currentUser != null) {
          final user = state.currentUser!;
          return GlassCard(
            borderRadius: 20,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProfilePage(),
                ),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  user.name,
                  style: AppTypography.bodyMedium.copyWith(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          );
        }

        return ElevatedButton.icon(
          onPressed: () {
            SignInDialog.show(context);
          },
          icon: const Icon(Icons.person_outline_rounded, size: 18),
          label: const Text('Sign In'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 2,
            textStyle: AppTypography.titleSmall.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        );
      },
    );
  }

  static Widget _buildDefaultLocationTrailing(BuildContext context) {
    return BlocBuilder<MovieBloc, MovieState>(
      builder: (context, state) {
        final branchName =
            state.selectedLocationId == 'all' ||
                state.selectedLocationId.isEmpty
            ? 'All Cinemas'
            : (state.selectedLocationName.isNotEmpty
                  ? state.selectedLocationName.replaceFirst('Sabay Cinema ', '')
                  : 'All Cinemas');
        return GlassCard(
          borderRadius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          onTap: () {
            BranchSelectorModal.show(
              context,
              selectedLocationId: state.selectedLocationId,
              onLocationSelected: (loc) {
                context.read<MovieBloc>().add(
                  SelectLocationBranchEvent(
                    locationId: loc.id,
                    locationName: loc.name,
                  ),
                );
              },
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_on_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                branchName,
                style: AppTypography.bodyMedium.copyWith(
                  fontSize: 13.5,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildDesktopTab(
    BuildContext context,
    int index,
    String title,
    IconData icon,
    int? currentIndex,
    Function(int)? onTabSelected,
  ) {
    final isSelected = currentIndex == index;
    return InkWell(
      onTap: () => navigateToTab(context, index, onTabSelected),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTypography.titleSmall.copyWith(
                fontSize: 15,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
