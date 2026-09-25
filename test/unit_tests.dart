import 'package:flutter_test/flutter_test.dart';
import 'package:sabay_cinema/core/di/injection_container.dart';
import 'package:sabay_cinema/core/usecases/usecase.dart';
import 'package:sabay_cinema/features/booking/domain/entities/booking.dart';
import 'package:sabay_cinema/features/booking/domain/entities/seat.dart';
import 'package:sabay_cinema/features/booking/domain/usecases/get_hall_seats.dart';
import 'package:sabay_cinema/features/movies/domain/usecases/get_now_showing_movies.dart';
import 'package:sabay_cinema/features/movies/domain/usecases/get_showtimes.dart';
import 'package:sabay_cinema/features/movies/presentation/bloc/movie_event.dart';
import 'package:sabay_cinema/features/movies/presentation/bloc/movie_state.dart';
import 'package:sabay_cinema/features/booking/presentation/bloc/booking_event.dart';
import 'package:sabay_cinema/features/booking/presentation/bloc/booking_state.dart';

void main() {
  setUpAll(() {
    ServiceLocator.init();
  });

  group('Clean Architecture - Movie Layer Tests', () {
    test('GetBannerSlides returns authentic Sabay Cinema slides', () async {
      final slides = await ServiceLocator.getBannerSlides(NoParams());
      expect(slides, isNotEmpty);
      expect(slides.any((s) => s.title.contains('Avengers')), isTrue);
      expect(slides.any((s) => s.title.contains('GANZBERG')), isTrue);
      expect(slides.any((s) => s.title.contains('ABA')), isTrue);
    });

    test('GetNowShowingMovies returns non-empty list of active movies', () async {
      final movies = await ServiceLocator.getNowShowingMovies(const GetNowShowingMoviesParams());
      expect(movies, isNotEmpty);
      expect(movies.first.title, contains('Deadpool & Wolverine'));
    });

    test('GetUpcomingMovies returns future releases', () async {
      final upcoming = await ServiceLocator.getUpcomingMovies(NoParams());
      expect(upcoming, isNotEmpty);
      expect(upcoming.any((m) => !m.isNowShowing), isTrue);
    });

    test('MovieBloc emits loaded state with bannerSlides and movies', () async {
      final bloc = ServiceLocator.createMovieBloc();
      bloc.add(LoadMoviesInitialEvent());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<MovieState>((s) => s.status == MovieStatus.loading),
          predicate<MovieState>((s) =>
              s.status == MovieStatus.loaded &&
              s.bannerSlides.isNotEmpty &&
              s.nowShowingMovies.isNotEmpty),
        ]),
      );
    });
  });

  group('Clean Architecture - Booking Layer Tests', () {
    test('GetHallSeats generates standard, prime, VIP and Twin bed seats', () async {
      final seats = await ServiceLocator.getHallSeats(const GetHallSeatsParams(showtimeId: 'st_1'));
      expect(seats, isNotEmpty);
      expect(seats.any((s) => s.type == SeatType.vipCouch), isTrue);
      expect(seats.any((s) => s.type == SeatType.twinBed), isTrue);
    });

    test('Booking calculations work correctly with tickets, snacks, and discounts', () async {
      final movies = await ServiceLocator.getNowShowingMovies(const GetNowShowingMoviesParams());
      final showtimes = await ServiceLocator.getShowtimes(GetShowtimesParams(movieId: movies.first.id));

      final booking = Booking(
        id: 'book_test_1',
        movie: movies.first,
        showtime: showtimes.first,
        selectedSeats: const [
          Seat(
            id: 'seat_E5',
            row: 'E',
            number: 5,
            type: SeatType.standard,
            status: SeatStatus.selected,
            price: 6.00,
          ),
          Seat(
            id: 'seat_E6',
            row: 'E',
            number: 6,
            type: SeatType.standard,
            status: SeatStatus.selected,
            price: 6.00,
          ),
        ],
        discountAmount: 2.00,
        createdAt: DateTime.now(),
      );

      expect(booking.ticketSubtotal, equals(12.00));
      expect(booking.totalAmount, equals(10.00));
    });

    test('BookingBloc seat selection toggles properly', () async {
      final bloc = ServiceLocator.createBookingBloc();
      const testSeat = Seat(
        id: 'seat_A2',
        row: 'A',
        number: 2,
        type: SeatType.standard,
        status: SeatStatus.available,
        price: 4.50,
      );

      bloc.add(const ToggleSeatEvent(testSeat));
      await expectLater(
        bloc.stream,
        emits(predicate<BookingState>((s) => s.selectedSeats.length == 1)),
      );

      bloc.add(const ToggleSeatEvent(testSeat));
      await expectLater(
        bloc.stream,
        emits(predicate<BookingState>((s) => s.selectedSeats.isEmpty)),
      );
    });
  });
}
