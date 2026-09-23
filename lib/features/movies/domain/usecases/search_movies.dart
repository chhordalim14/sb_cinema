import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

class SearchMoviesParams extends Equatable {
  final String query;
  final String? genre;
  final String? ageRating;

  const SearchMoviesParams({
    required this.query,
    this.genre,
    this.ageRating,
  });

  @override
  List<Object?> get props => [query, genre, ageRating];
}

class SearchMovies implements UseCase<List<Movie>, SearchMoviesParams> {
  final MovieRepository repository;

  SearchMovies(this.repository);

  @override
  Future<List<Movie>> call(SearchMoviesParams params) {
    return repository.searchMovies(
      params.query,
      genre: params.genre,
      ageRating: params.ageRating,
    );
  }
}
