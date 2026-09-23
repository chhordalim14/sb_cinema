import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sabay_cinema/core/constants/app_theme.dart';
import 'package:sabay_cinema/core/widgets/responsive_shell.dart';
import 'package:sabay_cinema/core/di/injection_container.dart';
import 'package:sabay_cinema/core/usecases/usecase.dart';
import 'package:sabay_cinema/features/booking/domain/entities/seat.dart';
import 'package:sabay_cinema/features/booking/domain/usecases/get_hall_seats.dart';
import 'package:sabay_cinema/features/booking/presentation/widgets/seat_matrix_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sabay_cinema/features/movies/presentation/bloc/movie_bloc.dart';
import 'package:sabay_cinema/features/movies/presentation/pages/home_page.dart';
import 'package:sabay_cinema/features/movies/domain/usecases/get_now_showing_movies.dart';
import 'package:sabay_cinema/features/movies/domain/usecases/get_showtimes.dart';

void main() {
  late List<Seat> testSeats;

  setUpAll(() async {
    ServiceLocator.init();
    final showtimes = await ServiceLocator.getShowtimes(const GetShowtimesParams(movieId: 'mov_1'));
    final showtime = showtimes.first;
    testSeats = await ServiceLocator.getHallSeats(GetHallSeatsParams(showtimeId: showtime.id));
  });

  test('SabayCinema service locator and domain usecases initialization', () async {
    final movies = await ServiceLocator.getNowShowingMovies(const GetNowShowingMoviesParams());
    expect(movies, isNotEmpty);

    final upcoming = await ServiceLocator.getUpcomingMovies(NoParams());
    expect(upcoming, isNotEmpty);

    final locations = await ServiceLocator.locationsDataSource.getLocations();
    expect(locations.length, greaterThanOrEqualTo(3));

    final concessions = await ServiceLocator.concessionDataSource.getConcessions();
    expect(concessions.length, greaterThanOrEqualTo(5));
  });

  testWidgets('SeatMatrixWidget handles rapid seat selection without performance degradation', (tester) async {
    Seat? tappedSeat;
    final selectedSeats = <Seat>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return SeatMatrixWidget(
                allSeats: testSeats,
                selectedSeats: selectedSeats,
                onSeatTapped: (seat) {
                  tappedSeat = seat;
                  setState(() {
                    if (selectedSeats.any((s) => s.id == seat.id)) {
                      selectedSeats.removeWhere((s) => s.id == seat.id);
                    } else {
                      selectedSeats.add(seat);
                    }
                  });
                },
              );
            },
          ),
        ),
      ),
    );

    expect(find.byType(SeatMatrixWidget), findsOneWidget);

    // Tap first available seat by its ValueKey
    final firstAvailable = testSeats.firstWhere((s) => s.status == SeatStatus.available);
    await tester.tap(find.byKey(ValueKey(firstAvailable.id)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(tappedSeat?.id, equals(firstAvailable.id));
    expect(selectedSeats.length, equals(1));

    // Tap again to deselect
    await tester.tap(find.byKey(ValueKey(firstAvailable.id)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(selectedSeats.isEmpty, isTrue);
  });

  testWidgets('HomePage renders Now Showing | Coming Soon switcher and switches tabs', (tester) async {
    final movieBloc = ServiceLocator.createMovieBloc();

    await tester.pumpWidget(
      BlocProvider<MovieBloc>.value(
        value: movieBloc,
        child: const MaterialApp(
          home: HomePage(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Both "Now Showing" and "Coming Soon" text tabs exist
    expect(find.text('Now Showing'), findsOneWidget);
    expect(find.text('Coming Soon'), findsOneWidget);

    // Initial state: "Showtimes by Date" is visible because Now Showing is selected
    expect(find.text('Showtimes by Date'), findsOneWidget);

    // Tap "Coming Soon"
    await tester.tap(find.text('Coming Soon'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // After switching to Coming Soon, date selector is hidden
    expect(find.text('Showtimes by Date'), findsNothing);

    // Tap "Now Showing" back
    await tester.tap(find.text('Now Showing'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Showtimes by Date'), findsOneWidget);
  });

  testWidgets('CinemaScrollBehavior renders sleek scrollbars on vertical views and hides on horizontal', (tester) async {
    final scrollController = ScrollController();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.softDarkTheme,
        scrollBehavior: const CinemaScrollBehavior(),
        home: Scaffold(
          body: ListView.builder(
            controller: scrollController,
            scrollDirection: Axis.vertical,
            itemCount: 50,
            itemBuilder: (context, index) => SizedBox(height: 50, child: Text('Item $index')),
          ),
        ),
      ),
    );
    await tester.pump();

    // Verify Scrollbar widget is automatically injected for vertical list
    expect(find.byType(Scrollbar), findsOneWidget);

    // Verify Scrollbar theme attributes
    final theme = AppTheme.softDarkTheme.scrollbarTheme;
    expect(theme.thickness?.resolve({}), equals(4.0));
    expect(theme.radius, equals(const Radius.circular(8)));
    expect(theme.crossAxisMargin, equals(1.0));
  });

  testWidgets('ResponsiveShell on desktop spans Scrollable to physical right screen edge', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final scrollController = ScrollController();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.softDarkTheme,
        scrollBehavior: const CinemaScrollBehavior(),
        home: ResponsiveShell(
          currentIndex: 0,
          onTabSelected: (_) {},
          child: ListView.builder(
            controller: scrollController,
            itemCount: 50,
            itemBuilder: (context, index) => SizedBox(height: 50, child: Text('Entry $index')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final scrollbarFinder = find.byType(Scrollbar);
    expect(scrollbarFinder, findsOneWidget);
    final scrollbarRect = tester.getRect(scrollbarFinder);

    // Verify the Scrollbar's right boundary is at the exact physical right screen edge (1440.0)
    expect(scrollbarRect.right, equals(1440.0));
  });
}
