import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/booking.dart';
import '../entities/ticket.dart';
import '../repositories/booking_repository.dart';

class CreateBookingParams extends Equatable {
  final Booking booking;

  const CreateBookingParams({required this.booking});

  @override
  List<Object?> get props => [booking];
}

class CreateBooking implements UseCase<Ticket, CreateBookingParams> {
  final BookingRepository repository;

  CreateBooking(this.repository);

  @override
  Future<Ticket> call(CreateBookingParams params) {
    return repository.createBooking(params.booking);
  }
}
