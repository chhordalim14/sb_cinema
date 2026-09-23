import 'package:equatable/equatable.dart';
import '../../../movies/domain/entities/movie.dart';
import '../../../movies/domain/entities/showtime.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/seat.dart';
import '../../domain/entities/ticket.dart';

enum BookingStatus { initial, loading, seatsLoaded, checkingOut, success, error }

class BookingState extends Equatable {
  final BookingStatus status;
  final Movie? movie;
  final Showtime? showtime;
  final List<Seat> allSeats;
  final List<Seat> selectedSeats;
  final Map<String, ConcessionOrderItem> selectedConcessions;
  final String promoCode;
  final double discountAmount;
  final String paymentMethod;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final Ticket? confirmedTicket;
  final List<Ticket> activeTickets;
  final String? errorMessage;
  final int holdTimerSeconds;

  const BookingState({
    this.status = BookingStatus.initial,
    this.movie,
    this.showtime,
    this.allSeats = const [],
    this.selectedSeats = const [],
    this.selectedConcessions = const {},
    this.promoCode = '',
    this.discountAmount = 0.0,
    this.paymentMethod = 'ABA KHQR',
    this.customerName = 'Chhorda Lim',
    this.customerPhone = '+855 12 345 678',
    this.customerEmail = 'lim.chhorda@sabay.com',
    this.confirmedTicket,
    this.activeTickets = const [],
    this.errorMessage,
    this.holdTimerSeconds = 600, // 10 minutes hold
  });

  double get ticketSubtotal =>
      selectedSeats.fold(0.0, (sum, seat) => sum + seat.price);

  double get concessionSubtotal => selectedConcessions.values
      .fold(0.0, (sum, orderItem) => sum + orderItem.totalPrice);

  double get totalAmount => (ticketSubtotal + concessionSubtotal - discountAmount)
      .clamp(0.0, double.infinity);

  int get totalSeatCount => selectedSeats.length;

  BookingState copyWith({
    BookingStatus? status,
    Movie? movie,
    Showtime? showtime,
    List<Seat>? allSeats,
    List<Seat>? selectedSeats,
    Map<String, ConcessionOrderItem>? selectedConcessions,
    String? promoCode,
    double? discountAmount,
    String? paymentMethod,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    Ticket? confirmedTicket,
    List<Ticket>? activeTickets,
    String? errorMessage,
    int? holdTimerSeconds,
  }) {
    return BookingState(
      status: status ?? this.status,
      movie: movie ?? this.movie,
      showtime: showtime ?? this.showtime,
      allSeats: allSeats ?? this.allSeats,
      selectedSeats: selectedSeats ?? this.selectedSeats,
      selectedConcessions: selectedConcessions ?? this.selectedConcessions,
      promoCode: promoCode ?? this.promoCode,
      discountAmount: discountAmount ?? this.discountAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      confirmedTicket: confirmedTicket ?? this.confirmedTicket,
      activeTickets: activeTickets ?? this.activeTickets,
      errorMessage: errorMessage ?? this.errorMessage,
      holdTimerSeconds: holdTimerSeconds ?? this.holdTimerSeconds,
    );
  }

  @override
  List<Object?> get props => [
        status,
        movie,
        showtime,
        allSeats,
        selectedSeats,
        selectedConcessions,
        promoCode,
        discountAmount,
        paymentMethod,
        customerName,
        customerPhone,
        customerEmail,
        confirmedTicket,
        activeTickets,
        errorMessage,
        holdTimerSeconds,
      ];
}
