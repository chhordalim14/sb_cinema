import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sabay_cinema/core/di/injection_container.dart';
import 'package:sabay_cinema/features/booking/domain/entities/seat.dart';
import 'package:sabay_cinema/features/booking/domain/entities/ticket.dart';
import 'package:sabay_cinema/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:sabay_cinema/features/booking/presentation/bloc/booking_event.dart';
import 'package:sabay_cinema/features/booking/presentation/pages/checkout_summary_page.dart';
import 'package:sabay_cinema/features/booking/presentation/pages/seat_selection_page.dart';
import 'package:sabay_cinema/features/booking/presentation/widgets/payment_qr_dialog.dart';
import 'package:sabay_cinema/features/booking/presentation/widgets/ticket_boarding_pass.dart';
import 'package:sabay_cinema/features/movies/domain/entities/movie.dart';
import 'package:sabay_cinema/features/movies/domain/entities/showtime.dart';
import 'package:sabay_cinema/features/movies/domain/usecases/get_now_showing_movies.dart';
import 'package:sabay_cinema/features/movies/domain/usecases/get_showtimes.dart';
import 'package:sabay_cinema/features/movies/presentation/bloc/movie_bloc.dart';
import 'package:sabay_cinema/features/movies/presentation/pages/movie_details_page.dart';
import 'package:sabay_cinema/features/movies/presentation/widgets/branch_selector_modal.dart';
import 'package:sabay_cinema/features/movies/presentation/widgets/trailer_modal.dart';
import 'package:sabay_cinema/main.dart';

// 1x1 transparent PNG bytes for mock network responses
final List<int> _transparentImageBytes = [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
];

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _MockHttpClient();
}

class _MockHttpClient extends Fake implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest();
  @override
  bool autoUncompress = true;
}

class _MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  final HttpHeaders headers = _MockHttpHeaders();
  @override
  Future<HttpClientResponse> close() async => _MockHttpClientResponse();
}

class _MockHttpHeaders extends Fake implements HttpHeaders {
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class _MockHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;
  @override
  int get contentLength => _transparentImageBytes.length;
  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;
  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value(_transparentImageBytes).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

void main() {
  late Movie testMovie;
  late Showtime testShowtime;

  setUpAll(() async {
    HttpOverrides.global = _TestHttpOverrides();
    ServiceLocator.init();
    final movies = await ServiceLocator.getNowShowingMovies(const GetNowShowingMoviesParams());
    testMovie = movies.first;
    final showtimes = await ServiceLocator.getShowtimes(GetShowtimesParams(movieId: testMovie.id));
    testShowtime = showtimes.first;
  });

  group('Multi-Device Responsive Shell Layout Tests', () {
    final viewports = [
      {'name': 'Compact Mobile (320x568)', 'size': const Size(320, 568)},
      {'name': 'Standard Mobile (375x667)', 'size': const Size(375, 667)},
      {'name': 'Modern Flagship (393x852)', 'size': const Size(393, 852)},
      {'name': 'Tablet Portrait (768x1024)', 'size': const Size(768, 1024)},
      {'name': 'Desktop/Web (1280x800)', 'size': const Size(1280, 800)},
      {'name': 'Landscape Mobile (667x375)', 'size': const Size(667, 375)},
    ];

    for (final vp in viewports) {
      final name = vp['name'] as String;
      final size = vp['size'] as Size;

      testWidgets('Zero overflow on $name across all navigation tabs', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final shellKey = GlobalKey<MainNavigationShellState>();
        await tester.pumpWidget(SabayCinemaApp(shellKey: shellKey));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(tester.takeException(), isNull, reason: 'Tab 0 (Home) overflowed on $name');

        // Switch to Catalog (tab 1)
        shellKey.currentState?.selectTab(1);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull, reason: 'Tab 1 (Catalog) overflowed on $name');

        // Switch to Tickets (tab 2)
        shellKey.currentState?.selectTab(2);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull, reason: 'Tab 2 (Tickets) overflowed on $name');

        // Switch to Locations (tab 3)
        shellKey.currentState?.selectTab(3);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull, reason: 'Tab 3 (Locations) overflowed on $name');
      });
    }
  });

  group('Deep Screen & Modal Responsive Overflow Tests (320px ultra compact)', () {
    testWidgets('MovieDetailsPage renders without overflow on 320x568', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<MovieBloc>(create: (_) => ServiceLocator.createMovieBloc()),
            BlocProvider<BookingBloc>(create: (_) => ServiceLocator.createBookingBloc()),
          ],
          child: MaterialApp(
            home: MovieDetailsPage(movie: testMovie),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    });

    testWidgets('SeatSelectionPage renders without overflow on 320x568', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<BookingBloc>(
              create: (_) => ServiceLocator.createBookingBloc()
                ..add(InitBookingSessionEvent(movie: testMovie, showtime: testShowtime)),
            ),
          ],
          child: MaterialApp(
            home: SeatSelectionPage(movie: testMovie, showtime: testShowtime),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    });

    testWidgets('CheckoutSummaryPage renders without overflow on 320x568', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final bookingBloc = ServiceLocator.createBookingBloc()
        ..add(InitBookingSessionEvent(movie: testMovie, showtime: testShowtime))
        ..add(const ToggleSeatEvent(Seat(
          id: 'seat_A1',
          row: 'A',
          number: 1,
          type: SeatType.standard,
          status: SeatStatus.available,
          price: 5.0,
        )));

      FlutterErrorDetails? caughtDetails;
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        caughtDetails = details;
      };

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<BookingBloc>.value(value: bookingBloc),
          ],
          child: const MaterialApp(
            home: CheckoutSummaryPage(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      FlutterError.onError = oldHandler;

      if (caughtDetails != null) {
        // ignore: avoid_print
        print('CHECKOUT SUMMARY OFFENDING WIDGET:');
        // ignore: avoid_print
        print(caughtDetails!.exceptionAsString());
        // ignore: avoid_print
        print(caughtDetails!.informationCollector?.call().map((d) => d.toString()).join('\n'));
      }
      expect(caughtDetails, isNull);
    });

    testWidgets('PaymentQrDialog renders without overflow on 320x568', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      FlutterErrorDetails? caughtDetails;
      final oldHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        caughtDetails = details;
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaymentQrDialog(
              amount: 15.50,
              movieTitle: 'Dune: Part Two (IMAX 3D Experience Extended Edition)',
              onPaymentSuccess: () {},
            ),
          ),
        ),
      );
      // Pump frame without pumpAndSettle due to active countdown Timer
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      FlutterError.onError = oldHandler;

      if (caughtDetails != null) {
        // ignore: avoid_print
        print('OFFENDING WIDGET DETAILS:');
        // ignore: avoid_print
        print(caughtDetails!.exceptionAsString());
        // ignore: avoid_print
        print(caughtDetails!.informationCollector?.call().map((d) => d.toString()).join('\n'));
      }
      expect(caughtDetails, isNull);
    });

    testWidgets('TrailerModal renders without overflow on 320x480 landscape/small height', (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrailerModal(movie: testMovie),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });

    testWidgets('BranchSelectorModal renders without overflow on 320x568', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BranchSelectorModal(
              selectedLocationId: 'loc_1',
              onLocationSelected: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);
    });

    testWidgets('TicketBoardingPass renders without overflow on 320x568', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final ticket = Ticket(
        ticketNumber: 'SBY-99281',
        bookingId: 'book_test_1',
        movieTitle: 'Spider-Man: Beyond the Spider-Verse (Dolby Atmos)',
        moviePosterUrl: 'https://images.unsplash.com/photo-1635805737707-575885ab0820?w=600',
        cinemaName: 'Sabay Cinema Aeon Mall Sensok City (Hall 5 VIP)',
        hallName: 'Hall 5 - VIP Lounge & Recliners',
        format: 'IMAX 3D Laser',
        showtime: DateTime.now().add(const Duration(hours: 4)),
        seatCodes: const ['VIP-E1', 'VIP-E2', 'VIP-E3', 'VIP-E4'],
        totalPaid: 48.00,
        qrData: 'SABAY://TICKET?id=book_test_1',
        barcode: '885002123456',
        issueTime: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TicketBoardingPass(ticket: ticket),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });
  });
}
