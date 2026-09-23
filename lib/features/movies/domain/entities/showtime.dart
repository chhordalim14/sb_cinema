import 'package:equatable/equatable.dart';

enum HallExperience {
  imaxLaser,
  dolbyAtmos,
  fourDX,
  vipGold,
  screenX,
  standard2D,
  standard3D,
  kids,
}

extension HallExperienceExtension on HallExperience {
  String get displayName {
    switch (this) {
      case HallExperience.imaxLaser:
        return 'IMAX Laser';
      case HallExperience.dolbyAtmos:
        return 'Dolby Atmos 7.1';
      case HallExperience.fourDX:
        return '4DX Motion';
      case HallExperience.vipGold:
        return 'VIP Gold Suite';
      case HallExperience.screenX:
        return 'ScreenX 270°';
      case HallExperience.standard2D:
        return 'Digital 2D';
      case HallExperience.standard3D:
        return 'Digital 3D';
      case HallExperience.kids:
        return 'Kids Hall';
    }
  }

  String get shortTag {
    switch (this) {
      case HallExperience.imaxLaser:
        return 'IMAX';
      case HallExperience.dolbyAtmos:
        return 'ATMOS';
      case HallExperience.fourDX:
        return '4DX';
      case HallExperience.vipGold:
        return 'VIP';
      case HallExperience.screenX:
        return 'SCREENX';
      case HallExperience.standard2D:
        return '2D';
      case HallExperience.standard3D:
        return '3D';
      case HallExperience.kids:
        return 'KIDS';
    }
  }
}

class Showtime extends Equatable {
  final String id;
  final String movieId;
  final String locationId;
  final String locationName;
  final String hallName;
  final String hallType; // e.g. "REGULAR HALL", "VIP SUITE", "LASER HALL"
  final HallExperience experience;
  final DateTime startTime;
  final DateTime endTime;
  final double basePrice;
  final int totalSeats;
  final int availableSeats;
  final String languageSubtitle; // e.g. "EN / KH Sub"
  final String spokenLanguage; // e.g. "EN", "KH", "MAND", "THAI"
  final String subtitleLanguage; // e.g. "KH", "EN", "CH"

  const Showtime({
    required this.id,
    required this.movieId,
    required this.locationId,
    required this.locationName,
    required this.hallName,
    this.hallType = 'REGULAR HALL',
    required this.experience,
    required this.startTime,
    required this.endTime,
    required this.basePrice,
    required this.totalSeats,
    required this.availableSeats,
    required this.languageSubtitle,
    this.spokenLanguage = 'EN',
    this.subtitleLanguage = 'KH',
  });

  bool get isAlmostFull => availableSeats <= 12 && availableSeats > 0;
  bool get isSoldOut => availableSeats == 0;

  @override
  List<Object?> get props => [
        id,
        movieId,
        locationId,
        locationName,
        hallName,
        hallType,
        experience,
        startTime,
        endTime,
        basePrice,
        totalSeats,
        availableSeats,
        languageSubtitle,
        spokenLanguage,
        subtitleLanguage,
      ];
}
