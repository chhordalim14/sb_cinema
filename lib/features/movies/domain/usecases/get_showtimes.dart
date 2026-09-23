import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/showtime.dart';
import '../repositories/movie_repository.dart';

class GetShowtimesParams extends Equatable {
  final String movieId;
  final String? locationId;
  final DateTime? date;

  const GetShowtimesParams({
    required this.movieId,
    this.locationId,
    this.date,
  });

  @override
  List<Object?> get props => [movieId, locationId, date];
}

class GetShowtimes implements UseCase<List<Showtime>, GetShowtimesParams> {
  final MovieRepository repository;

  GetShowtimes(this.repository);

  @override
  Future<List<Showtime>> call(GetShowtimesParams params) {
    return repository.getShowtimes(
      params.movieId,
      locationId: params.locationId,
      date: params.date,
    );
  }
}
