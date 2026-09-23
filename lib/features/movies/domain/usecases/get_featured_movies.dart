import '../../../../core/usecases/usecase.dart';
import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

class GetFeaturedMovies implements UseCase<List<Movie>, NoParams> {
  final MovieRepository repository;

  GetFeaturedMovies(this.repository);

  @override
  Future<List<Movie>> call(NoParams params) {
    return repository.getFeaturedMovies();
  }
}
