import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_banner_slides.dart';
import '../../domain/usecases/get_featured_movies.dart';
import '../../domain/usecases/get_movie_details.dart';
import '../../domain/usecases/get_now_showing_movies.dart';
import '../../domain/usecases/get_upcoming_movies.dart';
import '../../domain/usecases/search_movies.dart';
import 'movie_event.dart';
import 'movie_state.dart';

class MovieBloc extends Bloc<MovieEvent, MovieState> {
  final GetBannerSlides getBannerSlides;
  final GetNowShowingMovies getNowShowingMovies;
  final GetUpcomingMovies getUpcomingMovies;
  final GetFeaturedMovies getFeaturedMovies;
  final GetMovieDetails getMovieDetails;
  final SearchMovies searchMovies;

  MovieBloc({
    required this.getBannerSlides,
    required this.getNowShowingMovies,
    required this.getUpcomingMovies,
    required this.getFeaturedMovies,
    required this.getMovieDetails,
    required this.searchMovies,
  }) : super(const MovieState()) {
    on<LoadMoviesInitialEvent>(_onLoadMoviesInitial);
    on<SelectGenreCategoryEvent>(_onSelectCategory);
    on<SelectLocationBranchEvent>(_onSelectLocation);
    on<SearchMoviesEvent>(_onSearchMovies);
    on<SelectMovieEvent>(_onSelectMovie);
  }

  Future<void> _onLoadMoviesInitial(
    LoadMoviesInitialEvent event,
    Emitter<MovieState> emit,
  ) async {
    emit(state.copyWith(status: MovieStatus.loading));
    try {
      final bannerSlides = await getBannerSlides(NoParams());
      final nowShowing = await getNowShowingMovies(
        GetNowShowingMoviesParams(
          category: state.selectedCategory,
          locationId: state.selectedLocationId,
        ),
      );
      final upcoming = await getUpcomingMovies(NoParams());
      final featured = await getFeaturedMovies(NoParams());

      emit(state.copyWith(
        status: MovieStatus.loaded,
        bannerSlides: bannerSlides,
        nowShowingMovies: nowShowing,
        upcomingMovies: upcoming,
        featuredMovies: featured,
        searchResults: nowShowing,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MovieStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSelectCategory(
    SelectGenreCategoryEvent event,
    Emitter<MovieState> emit,
  ) async {
    emit(state.copyWith(selectedCategory: event.category));
    try {
      final nowShowing = await getNowShowingMovies(
        GetNowShowingMoviesParams(
          category: event.category,
          locationId: state.selectedLocationId,
        ),
      );
      emit(state.copyWith(nowShowingMovies: nowShowing));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onSelectLocation(
    SelectLocationBranchEvent event,
    Emitter<MovieState> emit,
  ) async {
    emit(state.copyWith(
      selectedLocationId: event.locationId,
      selectedLocationName: event.locationName,
    ));
    try {
      final nowShowing = await getNowShowingMovies(
        GetNowShowingMoviesParams(
          category: state.selectedCategory,
          locationId: event.locationId,
        ),
      );
      emit(state.copyWith(nowShowingMovies: nowShowing));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onSearchMovies(
    SearchMoviesEvent event,
    Emitter<MovieState> emit,
  ) async {
    try {
      final results = await searchMovies(
        SearchMoviesParams(
          query: event.query,
          genre: event.genre,
          ageRating: event.ageRating,
        ),
      );
      emit(state.copyWith(searchResults: results));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onSelectMovie(
    SelectMovieEvent event,
    Emitter<MovieState> emit,
  ) async {
    try {
      final movie = await getMovieDetails(
        GetMovieDetailsParams(movieId: event.movieId),
      );
      emit(state.copyWith(selectedMovie: movie));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}
