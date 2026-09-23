import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/seat.dart';
import '../repositories/booking_repository.dart';

class GetHallSeatsParams extends Equatable {
  final String showtimeId;

  const GetHallSeatsParams({required this.showtimeId});

  @override
  List<Object?> get props => [showtimeId];
}

class GetHallSeats implements UseCase<List<Seat>, GetHallSeatsParams> {
  final BookingRepository repository;

  GetHallSeats(this.repository);

  @override
  Future<List<Seat>> call(GetHallSeatsParams params) {
    return repository.getHallSeats(params.showtimeId);
  }
}
