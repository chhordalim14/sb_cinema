import '../entities/booking.dart';
import '../entities/seat.dart';
import '../entities/ticket.dart';

abstract class BookingRepository {
  Future<List<Seat>> getHallSeats(String showtimeId);
  Future<Ticket> createBooking(Booking booking);
  Future<List<Ticket>> getActiveTickets();
}
