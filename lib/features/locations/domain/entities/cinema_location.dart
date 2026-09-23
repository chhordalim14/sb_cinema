import 'package:equatable/equatable.dart';

class CinemaLocation extends Equatable {
  final String id;
  final String name;
  final String address;
  final String city;
  final String phone;
  final String imageUrl;
  final List<String> experiences; // e.g. ["IMAX Laser", "Dolby Atmos", "VIP Gold", "Kids Hall", "4DX"]
  final int totalHalls;
  final double distanceKm;
  final String openingHours;

  const CinemaLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.phone,
    required this.imageUrl,
    required this.experiences,
    required this.totalHalls,
    required this.distanceKm,
    required this.openingHours,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        city,
        phone,
        imageUrl,
        experiences,
        totalHalls,
        distanceKm,
        openingHours,
      ];
}
