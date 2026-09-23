import '../../domain/entities/movie.dart';

class CastMemberModel extends CastMember {
  const CastMemberModel({
    required super.name,
    required super.role,
    required super.avatarUrl,
  });

  factory CastMemberModel.fromJson(Map<String, dynamic> json) {
    return CastMemberModel(
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'role': role,
        'avatarUrl': avatarUrl,
      };
}

class MovieReviewModel extends MovieReview {
  const MovieReviewModel({
    required super.author,
    required super.rating,
    required super.date,
    required super.comment,
    required super.avatarUrl,
  });

  factory MovieReviewModel.fromJson(Map<String, dynamic> json) {
    return MovieReviewModel(
      author: json['author'] as String? ?? 'Anonymous',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      date: json['date'] as String? ?? '',
      comment: json['comment'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'author': author,
        'rating': rating,
        'date': date,
        'comment': comment,
        'avatarUrl': avatarUrl,
      };
}

class MovieModel extends Movie {
  const MovieModel({
    required super.id,
    required super.title,
    super.originalTitle,
    required super.synopsis,
    required super.rating,
    required super.voteCount,
    required super.durationMinutes,
    required super.releaseDate,
    required super.ageRating,
    required super.genres,
    required super.posterUrl,
    required super.backdropUrl,
    required super.trailerVideoId,
    required super.director,
    required super.cast,
    required super.reviews,
    required super.availableFormats,
    required super.isNowShowing,
    super.isFeatured,
    super.isTrending,
    super.language,
  });

  factory MovieModel.fromEntity(Movie movie) {
    return MovieModel(
      id: movie.id,
      title: movie.title,
      originalTitle: movie.originalTitle,
      synopsis: movie.synopsis,
      rating: movie.rating,
      voteCount: movie.voteCount,
      durationMinutes: movie.durationMinutes,
      releaseDate: movie.releaseDate,
      ageRating: movie.ageRating,
      genres: movie.genres,
      posterUrl: movie.posterUrl,
      backdropUrl: movie.backdropUrl,
      trailerVideoId: movie.trailerVideoId,
      director: movie.director,
      cast: movie.cast,
      reviews: movie.reviews,
      availableFormats: movie.availableFormats,
      isNowShowing: movie.isNowShowing,
      isFeatured: movie.isFeatured,
      isTrending: movie.isTrending,
      language: movie.language,
    );
  }
}
