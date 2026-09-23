import '../../domain/entities/banner_slide.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/showtime.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/movie_remote_data_source.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource remoteDataSource;

  MovieRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<BannerSlide>> getBannerSlides() {
    return remoteDataSource.getBannerSlides();
  }

  @override
  Future<List<Movie>> getNowShowingMovies({String? category, String? locationId}) {
    return remoteDataSource.getNowShowingMovies(
      category: category,
      locationId: locationId,
    );
  }

  @override
  Future<List<Movie>> getUpcomingMovies() {
    return remoteDataSource.getUpcomingMovies();
  }

  @override
  Future<List<Movie>> getFeaturedMovies() {
    return remoteDataSource.getFeaturedMovies();
  }

  @override
  Future<Movie> getMovieDetails(String movieId) {
    return remoteDataSource.getMovieDetails(movieId);
  }

  @override
  Future<List<Showtime>> getShowtimes(String movieId, {String? locationId, DateTime? date}) {
    return remoteDataSource.getShowtimes(movieId, locationId: locationId, date: date);
  }

  @override
  Future<List<Movie>> searchMovies(String query, {String? genre, String? ageRating}) {
    return remoteDataSource.searchMovies(query, genre: genre, ageRating: ageRating);
  }
}
