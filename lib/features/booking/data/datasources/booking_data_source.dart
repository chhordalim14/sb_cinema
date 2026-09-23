import '../../domain/entities/booking.dart';
import '../../domain/entities/seat.dart';
import '../../domain/entities/ticket.dart';

abstract class BookingDataSource {
  Future<List<Seat>> getHallSeats(String showtimeId);
  Future<Ticket> saveBooking(Booking booking);
  Future<List<Ticket>> getActiveTickets();
}

class BookingDataSourceImpl implements BookingDataSource {
  final List<Ticket> _storedTickets = [];

  @override
  Future<List<Seat>> getHallSeats(String showtimeId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final List<Seat> seats = [];

    // Rows A to H
    final rows = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
    // Pre-reserved seat patterns based on showtime ID hash for realism
    final occupiedKeys = {
      'C4', 'C5', 'D6', 'D7', 'E5', 'E6', 'E7', 'F5', 'F8', 'G4', 'H1_H2'
    };

    for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) {
      final row = rows[rowIndex];

      // Row H: Twin Bed Lounges (Pairs: H1-H2, H3-H4, H5-H6, H7-H8)
      if (row == 'H') {
        for (var pair = 1; pair <= 4; pair++) {
          final seat1Num = (pair * 2) - 1;
          final seat2Num = pair * 2;
          final pairKey = 'H${seat1Num}_H$seat2Num';
          final isReserved = occupiedKeys.contains(pairKey);

          seats.add(Seat(
            id: 'seat_H$seat1Num',
            row: row,
            number: seat1Num,
            type: SeatType.twinBed,
            status: isReserved ? SeatStatus.reserved : SeatStatus.available,
            price: 8.00,
            pairedSeatId: 'seat_H$seat2Num',
          ));
          seats.add(Seat(
            id: 'seat_H$seat2Num',
            row: row,
            number: seat2Num,
            type: SeatType.twinBed,
            status: isReserved ? SeatStatus.reserved : SeatStatus.available,
            price: 8.00,
            pairedSeatId: 'seat_H$seat1Num',
          ));
        }
        continue;
      }

      // Row G: VIP Recliner Couches (8 spacious seats)
      if (row == 'G') {
        for (var num = 1; num <= 8; num++) {
          final isReserved = occupiedKeys.contains('$row$num');
          seats.add(Seat(
            id: 'seat_$row$num',
            row: row,
            number: num,
            type: SeatType.vipCouch,
            status: isReserved ? SeatStatus.reserved : SeatStatus.available,
            price: 9.00,
          ));
        }
        continue;
      }

      // Rows D-F: Premium Prime Seats (10 seats per row)
      if (rowIndex >= 3 && rowIndex <= 5) {
        for (var num = 1; num <= 10; num++) {
          final isReserved = occupiedKeys.contains('$row$num');
          seats.add(Seat(
            id: 'seat_$row$num',
            row: row,
            number: num,
            type: SeatType.standard,
            status: isReserved ? SeatStatus.reserved : SeatStatus.available,
            price: 6.00,
          ));
        }
        continue;
      }

      // Rows A-C: Standard Seats (10 seats per row with wheelchair spot at A1 & A10)
      for (var num = 1; num <= 10; num++) {
        final isWheelchair = (row == 'A' && (num == 1 || num == 10));
        final isReserved = occupiedKeys.contains('$row$num');
        seats.add(Seat(
          id: 'seat_$row$num',
          row: row,
          number: num,
          type: isWheelchair ? SeatType.wheelchair : SeatType.standard,
          status: isReserved ? SeatStatus.reserved : SeatStatus.available,
          price: 4.50,
        ));
      }
    }

    return seats;
  }

  @override
  Future<Ticket> saveBooking(Booking booking) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final ticket = Ticket.fromBooking(booking);
    _storedTickets.insert(0, ticket);
    return ticket;
  }

  @override
  Future<List<Ticket>> getActiveTickets() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (_storedTickets.isEmpty) {
      // Add a sample upcoming ticket so user sees a realistic pass immediately
      _storedTickets.add(
        Ticket(
          ticketNumber: 'SBY-849204',
          bookingId: 'book_sample_01',
          movieTitle: 'Avengers: Endgame (IMAX Encore)',
          moviePosterUrl: 'https://images.unsplash.com/photo-1635805737707-575885ab0820?w=800&q=80',
          cinemaName: 'Sabay Cinema Aeon Sen Sok (Aeon 2)',
          hallName: 'Hall 7 (IMAX Laser)',
          format: 'IMAX Laser',
          showtime: DateTime.now().add(const Duration(hours: 4, minutes: 30)),
          seatCodes: const ['E6', 'E7'],
          totalPaid: 12.00,
          qrData: 'SABAY://TICKET?id=book_sample_01&seats=E6,E7&code=SBY-849204',
          barcode: '88500293847291',
          issueTime: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      );
    }
    return _storedTickets;
  }
}
