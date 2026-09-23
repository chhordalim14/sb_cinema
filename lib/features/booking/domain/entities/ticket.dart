import 'package:equatable/equatable.dart';
import 'booking.dart';

class Ticket extends Equatable {
  final String ticketNumber;
  final String bookingId;
  final String movieTitle;
  final String moviePosterUrl;
  final String cinemaName;
  final String hallName;
  final String format; // IMAX Laser, Dolby Atmos, etc.
  final DateTime showtime;
  final List<String> seatCodes;
  final double totalPaid;
  final String qrData;
  final String barcode;
  final DateTime issueTime;
  final bool isUsed;

  const Ticket({
    required this.ticketNumber,
    required this.bookingId,
    required this.movieTitle,
    required this.moviePosterUrl,
    required this.cinemaName,
    required this.hallName,
    required this.format,
    required this.showtime,
    required this.seatCodes,
    required this.totalPaid,
    required this.qrData,
    required this.barcode,
    required this.issueTime,
    this.isUsed = false,
  });

  factory Ticket.fromBooking(Booking booking) {
    final ticketNo = 'SBY-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    final seatCodesList = booking.selectedSeats.map((s) => s.seatCode).toList();
    final qr = 'SABAY://TICKET?id=${booking.id}&seats=${seatCodesList.join(",")}&code=$ticketNo';
    final barcodeNum = '885002${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    return Ticket(
      ticketNumber: ticketNo,
      bookingId: booking.id,
      movieTitle: booking.movie.title,
      moviePosterUrl: booking.movie.posterUrl,
      cinemaName: booking.showtime.locationName,
      hallName: booking.showtime.hallName,
      format: booking.showtime.experience.name,
      showtime: booking.showtime.startTime,
      seatCodes: seatCodesList,
      totalPaid: booking.totalAmount,
      qrData: qr,
      barcode: barcodeNum,
      issueTime: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        ticketNumber,
        bookingId,
        movieTitle,
        moviePosterUrl,
        cinemaName,
        hallName,
        format,
        showtime,
        seatCodes,
        totalPaid,
        qrData,
        barcode,
        issueTime,
        isUsed,
      ];
}
