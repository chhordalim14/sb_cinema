import '../../domain/entities/banner_slide.dart';

class BannerSlideModel extends BannerSlide {
  const BannerSlideModel({
    required super.id,
    required super.title,
    super.khmerTitle,
    required super.subtitle,
    required super.tag,
    required super.imageUrl,
    required super.actionText,
    required super.type,
    super.targetMovieId,
    super.externalUrl,
  });

  factory BannerSlideModel.fromJson(Map<String, dynamic> json) {
    return BannerSlideModel(
      id: json['id'] as String,
      title: json['title'] as String,
      khmerTitle: json['khmerTitle'] as String?,
      subtitle: json['subtitle'] as String,
      tag: json['tag'] as String,
      imageUrl: json['imageUrl'] as String,
      actionText: json['actionText'] as String? ?? 'GET TICKETS',
      type: BannerSlideType.values.firstWhere(
        (t) => t.name == (json['type'] as String?),
        orElse: () => BannerSlideType.movie,
      ),
      targetMovieId: json['targetMovieId'] as String?,
      externalUrl: json['externalUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'khmerTitle': khmerTitle,
        'subtitle': subtitle,
        'tag': tag,
        'imageUrl': imageUrl,
        'actionText': actionText,
        'type': type.name,
        'targetMovieId': targetMovieId,
        'externalUrl': externalUrl,
      };
}
