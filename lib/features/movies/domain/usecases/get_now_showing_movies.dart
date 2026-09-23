import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

class GetNowShowingMoviesParams extends Equatable {
  final String? category;
  final String? locationId;

  const GetNowShowingMoviesParams({this.category, this.locationId});

  @override
  List<Object?> get props => [category, locationId];
}

class GetNowShowingMovies implements UseCase<List<Movie>, GetNowShowingMoviesParams> {
  final MovieRepository repository;

  GetNowShowingMovies(this.repository);

  @override
  Future<List<Movie>> call(GetNowShowingMoviesParams params) {
    return repository.getNowShowingMovies(
      category: params.category,
      locationId: params.locationId,
    );
  }
}
