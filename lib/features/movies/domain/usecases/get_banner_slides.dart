import '../../../../core/usecases/usecase.dart';
import '../entities/banner_slide.dart';
import '../repositories/movie_repository.dart';

class GetBannerSlides implements UseCase<List<BannerSlide>, NoParams> {
  final MovieRepository repository;

  GetBannerSlides(this.repository);

  @override
  Future<List<BannerSlide>> call(NoParams params) {
    return repository.getBannerSlides();
  }
}
