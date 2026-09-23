import 'package:equatable/equatable.dart';
import '../../../concessions/domain/entities/concession_item.dart';
import '../../../movies/domain/entities/movie.dart';
import '../../../movies/domain/entities/showtime.dart';
import '../../domain/entities/seat.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class InitBookingSessionEvent extends BookingEvent {
  final Movie movie;
  final Showtime showtime;

  const InitBookingSessionEvent({required this.movie, required this.showtime});

  @override
  List<Object?> get props => [movie, showtime];
}

class ToggleSeatEvent extends BookingEvent {
  final Seat seat;

  const ToggleSeatEvent(this.seat);

  @override
  List<Object?> get props => [seat];
}

class UpdateConcessionQuantityEvent extends BookingEvent {
  final ConcessionItem item;
  final int delta; // +1 or -1

  const UpdateConcessionQuantityEvent({required this.item, required this.delta});

  @override
  List<Object?> get props => [item, delta];
}

class ApplyPromoCodeEvent extends BookingEvent {
  final String promoCode;

  const ApplyPromoCodeEvent(this.promoCode);

  @override
  List<Object?> get props => [promoCode];
}

class SelectPaymentMethodEvent extends BookingEvent {
  final String paymentMethod;

  const SelectPaymentMethodEvent(this.paymentMethod);

  @override
  List<Object?> get props => [paymentMethod];
}

class UpdateCustomerInfoEvent extends BookingEvent {
  final String name;
  final String phone;
  final String email;

  const UpdateCustomerInfoEvent({
    required this.name,
    required this.phone,
    required this.email,
  });

  @override
  List<Object?> get props => [name, phone, email];
}

class ConfirmCheckoutEvent extends BookingEvent {}

class LoadActiveTicketsEvent extends BookingEvent {}

class ResetBookingSessionEvent extends BookingEvent {}
