import 'package:equatable/equatable.dart';

enum BannerSlideType {
  movie,
  promotion,
  partner,
  pricing,
}

class BannerSlide extends Equatable {
  final String id;
  final String title;
  final String? khmerTitle;
  final String subtitle;
  final String tag; // e.g. "IMAX Laser", "PROMOTION", "NOW SHOWING", "PARTNER", "BEST VALUE"
  final String imageUrl;
  final String actionText; // e.g. "GET TICKETS", "BOOK NOW", "VIEW PROMO", "EXPLORE"
  final BannerSlideType type;
  final String? targetMovieId; // Link to movie entity if type is movie
  final String? externalUrl;

  const BannerSlide({
    required this.id,
    required this.title,
    this.khmerTitle,
    required this.subtitle,
    required this.tag,
    required this.imageUrl,
    required this.actionText,
    required this.type,
    this.targetMovieId,
    this.externalUrl,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        khmerTitle,
        subtitle,
        tag,
        imageUrl,
        actionText,
        type,
        targetMovieId,
        externalUrl,
      ];
}
