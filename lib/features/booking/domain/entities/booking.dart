import 'package:equatable/equatable.dart';
import '../../../concessions/domain/entities/concession_item.dart';
import '../../../movies/domain/entities/movie.dart';
import '../../../movies/domain/entities/showtime.dart';
import 'seat.dart';

class ConcessionOrderItem extends Equatable {
  final ConcessionItem item;
  final int quantity;

  const ConcessionOrderItem({required this.item, required this.quantity});

  double get totalPrice => item.price * quantity;

  @override
  List<Object?> get props => [item, quantity];
}

class Booking extends Equatable {
  final String id;
  final Movie movie;
  final Showtime showtime;
  final List<Seat> selectedSeats;
  final List<ConcessionOrderItem> concessions;
  final String promoCode;
  final double discountAmount;
  final String paymentMethod;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final DateTime createdAt;

  const Booking({
    required this.id,
    required this.movie,
    required this.showtime,
    required this.selectedSeats,
    this.concessions = const [],
    this.promoCode = '',
    this.discountAmount = 0.0,
    this.paymentMethod = 'ABA KHQR',
    this.customerName = '',
    this.customerPhone = '',
    this.customerEmail = '',
    required this.createdAt,
  });

  double get ticketSubtotal =>
      selectedSeats.fold(0.0, (sum, seat) => sum + seat.price);

  double get concessionSubtotal =>
      concessions.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get totalAmount => (ticketSubtotal + concessionSubtotal - discountAmount)
      .clamp(0.0, double.infinity);

  @override
  List<Object?> get props => [
        id,
        movie,
        showtime,
        selectedSeats,
        concessions,
        promoCode,
        discountAmount,
        paymentMethod,
        customerName,
        customerPhone,
        customerEmail,
        createdAt,
      ];
}
