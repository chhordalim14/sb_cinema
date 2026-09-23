import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

class GetMovieDetailsParams extends Equatable {
  final String movieId;

  const GetMovieDetailsParams({required this.movieId});

  @override
  List<Object?> get props => [movieId];
}

class GetMovieDetails implements UseCase<Movie, GetMovieDetailsParams> {
  final MovieRepository repository;

  GetMovieDetails(this.repository);

  @override
  Future<Movie> call(GetMovieDetailsParams params) {
    return repository.getMovieDetails(params.movieId);
  }
}
