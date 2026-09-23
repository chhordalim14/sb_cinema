import '../../../../core/usecases/usecase.dart';
import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

class GetUpcomingMovies implements UseCase<List<Movie>, NoParams> {
  final MovieRepository repository;

  GetUpcomingMovies(this.repository);

  @override
  Future<List<Movie>> call(NoParams params) {
    return repository.getUpcomingMovies();
  }
}
