import '../../features/booking/data/datasources/booking_data_source.dart';
import '../../features/booking/data/repositories/booking_repository_impl.dart';
import '../../features/booking/domain/repositories/booking_repository.dart';
import '../../features/booking/domain/usecases/create_booking.dart';
import '../../features/booking/domain/usecases/get_active_tickets.dart';
import '../../features/booking/domain/usecases/get_hall_seats.dart';
import '../../features/booking/presentation/bloc/booking_bloc.dart';
import '../../features/concessions/data/datasources/concession_data_source.dart';
import '../../features/locations/data/datasources/locations_data_source.dart';
import '../../features/movies/data/datasources/movie_remote_data_source.dart';
import '../../features/movies/data/repositories/movie_repository_impl.dart';
import '../../features/movies/domain/repositories/movie_repository.dart';
import '../../features/movies/domain/usecases/get_banner_slides.dart';
import '../../features/movies/domain/usecases/get_featured_movies.dart';
import '../../features/movies/domain/usecases/get_movie_details.dart';
import '../../features/movies/domain/usecases/get_now_showing_movies.dart';
import '../../features/movies/domain/usecases/get_showtimes.dart';
import '../../features/movies/domain/usecases/get_upcoming_movies.dart';
import '../../features/movies/domain/usecases/search_movies.dart';
import '../../features/movies/presentation/bloc/movie_bloc.dart';

class ServiceLocator {
  ServiceLocator._();

  // Data Sources
  static late final MovieRemoteDataSource movieRemoteDataSource;
  static late final BookingDataSource bookingDataSource;
  static late final ConcessionDataSource concessionDataSource;
  static late final LocationsDataSource locationsDataSource;

  // Repositories
  static late final MovieRepository movieRepository;
  static late final BookingRepository bookingRepository;

  // Use Cases - Movies
  static late final GetBannerSlides getBannerSlides;
  static late final GetNowShowingMovies getNowShowingMovies;
  static late final GetUpcomingMovies getUpcomingMovies;
  static late final GetFeaturedMovies getFeaturedMovies;
  static late final GetMovieDetails getMovieDetails;
  static late final GetShowtimes getShowtimes;
  static late final SearchMovies searchMovies;

  // Use Cases - Booking
  static late final GetHallSeats getHallSeats;
  static late final CreateBooking createBooking;
  static late final GetActiveTickets getActiveTickets;

  static void init() {
    // 1. Data Sources
    movieRemoteDataSource = MovieRemoteDataSourceImpl();
    bookingDataSource = BookingDataSourceImpl();
    concessionDataSource = ConcessionDataSourceImpl();
    locationsDataSource = LocationsDataSourceImpl();

    // 2. Repositories
    movieRepository = MovieRepositoryImpl(remoteDataSource: movieRemoteDataSource);
    bookingRepository = BookingRepositoryImpl(dataSource: bookingDataSource);

    // 3. Use Cases
    getBannerSlides = GetBannerSlides(movieRepository);
    getNowShowingMovies = GetNowShowingMovies(movieRepository);
    getUpcomingMovies = GetUpcomingMovies(movieRepository);
    getFeaturedMovies = GetFeaturedMovies(movieRepository);
    getMovieDetails = GetMovieDetails(movieRepository);
    getShowtimes = GetShowtimes(movieRepository);
    searchMovies = SearchMovies(movieRepository);

    getHallSeats = GetHallSeats(bookingRepository);
    createBooking = CreateBooking(bookingRepository);
    getActiveTickets = GetActiveTickets(bookingRepository);
  }

  static MovieBloc createMovieBloc() {
    return MovieBloc(
      getBannerSlides: getBannerSlides,
      getNowShowingMovies: getNowShowingMovies,
      getUpcomingMovies: getUpcomingMovies,
      getFeaturedMovies: getFeaturedMovies,
      getMovieDetails: getMovieDetails,
      searchMovies: searchMovies,
    );
  }

  static BookingBloc createBookingBloc() {
    return BookingBloc(
      getHallSeats: getHallSeats,
      createBooking: createBooking,
      getActiveTickets: getActiveTickets,
    );
  }
}
