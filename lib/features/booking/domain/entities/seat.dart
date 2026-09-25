import 'package:equatable/equatable.dart';

enum SeatType {
  standard('Standard'),
  vipCouch('VIP Couch'),
  twinBed('Twin Bed'),
  wheelchair('Accessible');

  final String displayName;
  const SeatType(this.displayName);
}

enum SeatStatus {
  available,
  selected,
  reserved,
}

class Seat extends Equatable {
  final String id;
  final String row;
  final int number;
  final SeatType type;
  final SeatStatus status;
  final double price;
  final String? pairedSeatId; // For Twin beds

  const Seat({
    required this.id,
    required this.row,
    required this.number,
    required this.type,
    required this.status,
    required this.price,
    this.pairedSeatId,
  });

  String get seatCode => '$row$number';

  Seat copyWith({
    String? id,
    String? row,
    int? number,
    SeatType? type,
    SeatStatus? status,
    double? price,
    String? pairedSeatId,
  }) {
    return Seat(
      id: id ?? this.id,
      row: row ?? this.row,
      number: number ?? this.number,
      type: type ?? this.type,
      status: status ?? this.status,
      price: price ?? this.price,
      pairedSeatId: pairedSeatId ?? this.pairedSeatId,
    );
  }

  @override
  List<Object?> get props => [id, row, number, type, status, price, pairedSeatId];
}
