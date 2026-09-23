import '../entities/banner_slide.dart';
import '../entities/movie.dart';
import '../entities/showtime.dart';

abstract class MovieRepository {
  Future<List<BannerSlide>> getBannerSlides();
  Future<List<Movie>> getNowShowingMovies({String? category, String? locationId});
  Future<List<Movie>> getUpcomingMovies();
  Future<List<Movie>> getFeaturedMovies();
  Future<Movie> getMovieDetails(String movieId);
  Future<List<Showtime>> getShowtimes(String movieId, {String? locationId, DateTime? date});
  Future<List<Movie>> searchMovies(String query, {String? genre, String? ageRating});
}

