import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_theme.dart';
import 'core/constants/app_typography.dart';
import 'core/di/injection_container.dart';
import 'core/widgets/custom_nav_bar.dart';
import 'core/widgets/glass_card.dart';
import 'core/widgets/responsive_shell.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/booking/presentation/bloc/booking_bloc.dart';
import 'features/booking/presentation/bloc/booking_event.dart';
import 'features/concessions/presentation/pages/food_beverage_page.dart';
import 'features/locations/presentation/pages/locations_page.dart';
import 'features/movies/presentation/bloc/movie_bloc.dart';
import 'features/movies/presentation/bloc/movie_event.dart';
import 'features/movies/presentation/bloc/movie_state.dart';
import 'features/movies/presentation/pages/home_page.dart';
import 'features/movies/presentation/pages/promotions_page.dart';
import 'features/movies/presentation/widgets/branch_selector_modal.dart';
import 'features/tickets/presentation/pages/my_tickets_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set immersive system overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Dependency Injection
  ServiceLocator.init();

  runApp(const SabayCinemaApp());
}

class SabayCinemaApp extends StatelessWidget {
  final int initialIndex;
  final GlobalKey<MainNavigationShellState>? shellKey;

  const SabayCinemaApp({
    super.key,
    this.initialIndex = 0,
    this.shellKey,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(),
        ),
        BlocProvider<MovieBloc>(
          create: (context) => ServiceLocator.createMovieBloc()..add(LoadMoviesInitialEvent()),
        ),
        BlocProvider<BookingBloc>(
          create: (context) => ServiceLocator.createBookingBloc()..add(LoadActiveTicketsEvent()),
        ),
      ],
      child: MaterialApp(
        title: 'SabayCinema',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.softDarkTheme,
        scrollBehavior: const CinemaScrollBehavior(),
        home: MainNavigationShell(
          key: shellKey,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  final int initialIndex;

  const MainNavigationShell({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationShell> createState() => MainNavigationShellState();
}

class MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    ResponsiveShell.onGlobalTabSelected = selectTab;
  }

  @override
  void dispose() {
    if (ResponsiveShell.onGlobalTabSelected == selectTab) {
      ResponsiveShell.onGlobalTabSelected = null;
    }
    super.dispose();
  }

  void selectTab(int index) {
    if (mounted && _currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  final List<Widget> _pages = const [
    HomePage(),
    FoodBeveragePage(),
    PromotionsPage(),
    MyTicketsPage(),
    LocationsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = ResponsiveShell.isDesktop(context);

    return ResponsiveShell(
      currentIndex: _currentIndex,
      onTabSelected: (index) => setState(() => _currentIndex = index),
      trailing: BlocBuilder<MovieBloc, MovieState>(
        builder: (context, state) {
          final branchName = state.selectedLocationName.isNotEmpty
              ? state.selectedLocationName.replaceFirst('Sabay Cinema ', '')
              : 'Aeon Mall Sen Sok';
          return GlassCard(
            borderRadius: 20,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
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
                const Icon(Icons.location_on_rounded, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  branchName,
                  style: AppTypography.bodyMedium.copyWith(
                    fontSize: 13.5,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.textSecondary),
              ],
            ),
          );
        },
      ),
      child: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          if (!isWide)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CustomNavBar(
                currentIndex: _currentIndex,
                onTabSelected: (index) => setState(() => _currentIndex = index),
              ),
            ),
        ],
      ),
    );
  }
}
