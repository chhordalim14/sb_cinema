import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/seat.dart';
import '../../domain/usecases/create_booking.dart';
import '../../domain/usecases/get_active_tickets.dart';
import '../../domain/usecases/get_hall_seats.dart';
import 'booking_event.dart';
import 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final GetHallSeats getHallSeats;
  final CreateBooking createBooking;
  final GetActiveTickets getActiveTickets;

  BookingBloc({
    required this.getHallSeats,
    required this.createBooking,
    required this.getActiveTickets,
  }) : super(const BookingState()) {
    on<InitBookingSessionEvent>(_onInitBookingSession);
    on<ToggleSeatEvent>(_onToggleSeat);
    on<UpdateConcessionQuantityEvent>(_onUpdateConcessionQuantity);
    on<ApplyPromoCodeEvent>(_onApplyPromoCode);
    on<SelectPaymentMethodEvent>(_onSelectPaymentMethod);
    on<UpdateCustomerInfoEvent>(_onUpdateCustomerInfo);
    on<ConfirmCheckoutEvent>(_onConfirmCheckout);
    on<LoadActiveTicketsEvent>(_onLoadActiveTickets);
    on<ResetBookingSessionEvent>(_onResetBookingSession);
  }

  Future<void> _onInitBookingSession(
    InitBookingSessionEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(
      status: BookingStatus.loading,
      movie: event.movie,
      showtime: event.showtime,
      selectedSeats: [],
      selectedConcessions: {},
      discountAmount: 0.0,
      promoCode: '',
      confirmedTicket: null,
    ));

    try {
      final seats = await getHallSeats(GetHallSeatsParams(showtimeId: event.showtime.id));
      emit(state.copyWith(
        status: BookingStatus.seatsLoaded,
        allSeats: seats,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BookingStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onToggleSeat(
    ToggleSeatEvent event,
    Emitter<BookingState> emit,
  ) {
    final seat = event.seat;
    if (seat.status == SeatStatus.reserved) return;

    final currentSelected = List<Seat>.from(state.selectedSeats);
    final isAlreadySelected = currentSelected.any((s) => s.id == seat.id);

    if (isAlreadySelected) {
      // Unselect (and unselect pair if Twin Bed)
      currentSelected.removeWhere((s) => s.id == seat.id);
      if (seat.pairedSeatId != null) {
        currentSelected.removeWhere((s) => s.id == seat.pairedSeatId);
      }
    } else {
      // Check maximum seats limit (up to 8 seats per booking)
      if (currentSelected.length >= 8) {
        return;
      }
      currentSelected.add(seat.copyWith(status: SeatStatus.selected));

      // If Twin Bed, automatically select the paired seat
      if (seat.pairedSeatId != null) {
        final pair = state.allSeats.firstWhere(
          (s) => s.id == seat.pairedSeatId,
          orElse: () => seat,
        );
        if (pair.id != seat.id && !currentSelected.any((s) => s.id == pair.id)) {
          currentSelected.add(pair.copyWith(status: SeatStatus.selected));
        }
      }
    }

    emit(state.copyWith(selectedSeats: currentSelected));
  }

  void _onUpdateConcessionQuantity(
    UpdateConcessionQuantityEvent event,
    Emitter<BookingState> emit,
  ) {
    final currentMap = Map<String, ConcessionOrderItem>.from(state.selectedConcessions);
    final existing = currentMap[event.item.id];
    final currentQty = existing?.quantity ?? 0;
    final newQty = currentQty + event.delta;

    if (newQty <= 0) {
      currentMap.remove(event.item.id);
    } else {
      currentMap[event.item.id] = ConcessionOrderItem(item: event.item, quantity: newQty);
    }

    emit(state.copyWith(selectedConcessions: currentMap));
  }

  void _onApplyPromoCode(
    ApplyPromoCodeEvent event,
    Emitter<BookingState> emit,
  ) {
    final code = event.promoCode.trim().toUpperCase();
    double discount = 0.0;

    if (code == 'SABAY50') {
      discount = state.concessionSubtotal * 0.50;
    } else if (code == 'STUDENT20' || code == 'SABAY20') {
      discount = state.ticketSubtotal * 0.20;
    } else if (code == 'IMAXVIP') {
      discount = 3.00;
    }

    emit(state.copyWith(
      promoCode: code,
      discountAmount: discount,
    ));
  }

  void _onSelectPaymentMethod(
    SelectPaymentMethodEvent event,
    Emitter<BookingState> emit,
  ) {
    emit(state.copyWith(paymentMethod: event.paymentMethod));
  }

  void _onUpdateCustomerInfo(
    UpdateCustomerInfoEvent event,
    Emitter<BookingState> emit,
  ) {
    emit(state.copyWith(
      customerName: event.name,
      customerPhone: event.phone,
      customerEmail: event.email,
    ));
  }

  Future<void> _onConfirmCheckout(
    ConfirmCheckoutEvent event,
    Emitter<BookingState> emit,
  ) async {
    if (state.movie == null || state.showtime == null || state.selectedSeats.isEmpty) {
      return;
    }

    emit(state.copyWith(status: BookingStatus.checkingOut));

    try {
      final booking = Booking(
        id: 'book_${DateTime.now().millisecondsSinceEpoch}',
        movie: state.movie!,
        showtime: state.showtime!,
        selectedSeats: state.selectedSeats,
        concessions: state.selectedConcessions.values.toList(),
        promoCode: state.promoCode,
        discountAmount: state.discountAmount,
        paymentMethod: state.paymentMethod,
        customerName: state.customerName,
        customerPhone: state.customerPhone,
        customerEmail: state.customerEmail,
        createdAt: DateTime.now(),
      );

      final ticket = await createBooking(CreateBookingParams(booking: booking));
      final allTickets = await getActiveTickets(NoParams());

      emit(state.copyWith(
        status: BookingStatus.success,
        confirmedTicket: ticket,
        activeTickets: allTickets,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BookingStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadActiveTickets(
    LoadActiveTicketsEvent event,
    Emitter<BookingState> emit,
  ) async {
    try {
      final tickets = await getActiveTickets(NoParams());
      emit(state.copyWith(activeTickets: tickets));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  void _onResetBookingSession(
    ResetBookingSessionEvent event,
    Emitter<BookingState> emit,
  ) {
    emit(state.copyWith(
      status: BookingStatus.initial,
      selectedSeats: [],
      selectedConcessions: {},
      promoCode: '',
      discountAmount: 0.0,
      confirmedTicket: null,
    ));
  }
}
