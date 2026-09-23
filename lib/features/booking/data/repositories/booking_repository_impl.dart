import '../../domain/entities/booking.dart';
import '../../domain/entities/seat.dart';
import '../../domain/entities/ticket.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_data_source.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingDataSource dataSource;

  BookingRepositoryImpl({required this.dataSource});

  @override
  Future<List<Seat>> getHallSeats(String showtimeId) {
    return dataSource.getHallSeats(showtimeId);
  }

  @override
  Future<Ticket> createBooking(Booking booking) {
    return dataSource.saveBooking(booking);
  }

  @override
  Future<List<Ticket>> getActiveTickets() {
    return dataSource.getActiveTickets();
  }
}
