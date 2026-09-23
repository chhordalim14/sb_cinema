import 'package:equatable/equatable.dart';
import '../../domain/entities/banner_slide.dart';
import '../../domain/entities/movie.dart';

enum MovieStatus { initial, loading, loaded, error }

class MovieState extends Equatable {
  final MovieStatus status;
  final List<BannerSlide> bannerSlides;
  final List<Movie> nowShowingMovies;
  final List<Movie> upcomingMovies;
  final List<Movie> featuredMovies;
  final List<Movie> searchResults;
  final String selectedCategory;
  final String selectedLocationId;
  final String selectedLocationName;
  final Movie? selectedMovie;
  final String? errorMessage;

  const MovieState({
    this.status = MovieStatus.initial,
    this.bannerSlides = const [],
    this.nowShowingMovies = const [],
    this.upcomingMovies = const [],
    this.featuredMovies = const [],
    this.searchResults = const [],
    this.selectedCategory = 'All',
    this.selectedLocationId = 'all',
    this.selectedLocationName = 'All Cinemas',
    this.selectedMovie,
    this.errorMessage,
  });

  MovieState copyWith({
    MovieStatus? status,
    List<BannerSlide>? bannerSlides,
    List<Movie>? nowShowingMovies,
    List<Movie>? upcomingMovies,
    List<Movie>? featuredMovies,
    List<Movie>? searchResults,
    String? selectedCategory,
    String? selectedLocationId,
    String? selectedLocationName,
    Movie? selectedMovie,
    String? errorMessage,
  }) {
    return MovieState(
      status: status ?? this.status,
      bannerSlides: bannerSlides ?? this.bannerSlides,
      nowShowingMovies: nowShowingMovies ?? this.nowShowingMovies,
      upcomingMovies: upcomingMovies ?? this.upcomingMovies,
      featuredMovies: featuredMovies ?? this.featuredMovies,
      searchResults: searchResults ?? this.searchResults,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedLocationId: selectedLocationId ?? this.selectedLocationId,
      selectedLocationName: selectedLocationName ?? this.selectedLocationName,
      selectedMovie: selectedMovie ?? this.selectedMovie,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        bannerSlides,
        nowShowingMovies,
        upcomingMovies,
        featuredMovies,
        searchResults,
        selectedCategory,
        selectedLocationId,
        selectedLocationName,
        selectedMovie,
        errorMessage,
      ];
}
