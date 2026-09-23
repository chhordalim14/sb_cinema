import 'package:equatable/equatable.dart';
import 'showtime.dart';

class CastMember extends Equatable {
  final String name;
  final String role;
  final String avatarUrl;

  const CastMember({
    required this.name,
    required this.role,
    required this.avatarUrl,
  });

  @override
  List<Object?> get props => [name, role, avatarUrl];
}

class MovieReview extends Equatable {
  final String author;
  final double rating;
  final String date;
  final String comment;
  final String avatarUrl;

  const MovieReview({
    required this.author,
    required this.rating,
    required this.date,
    required this.comment,
    required this.avatarUrl,
  });

  @override
  List<Object?> get props => [author, rating, date, comment, avatarUrl];
}

class Movie extends Equatable {
  final String id;
  final String title;
  final String originalTitle;
  final String synopsis;
  final double rating;
  final int voteCount;
  final int durationMinutes;
  final String releaseDate;
  final String ageRating; // "G", "PG-13", "R-18", etc.
  final List<String> genres;
  final String posterUrl;
  final String backdropUrl;
  final String trailerVideoId;
  final String director;
  final List<CastMember> cast;
  final List<MovieReview> reviews;
  final List<HallExperience> availableFormats;
  final bool isNowShowing;
  final bool isFeatured;
  final bool isTrending;
  final String language;

  const Movie({
    required this.id,
    required this.title,
    this.originalTitle = '',
    required this.synopsis,
    required this.rating,
    required this.voteCount,
    required this.durationMinutes,
    required this.releaseDate,
    required this.ageRating,
    required this.genres,
    required this.posterUrl,
    required this.backdropUrl,
    required this.trailerVideoId,
    required this.director,
    required this.cast,
    required this.reviews,
    required this.availableFormats,
    required this.isNowShowing,
    this.isFeatured = false,
    this.isTrending = false,
    this.language = 'English / Khmer Sub',
  });

  @override
  List<Object?> get props => [
        id,
        title,
        originalTitle,
        synopsis,
        rating,
        voteCount,
        durationMinutes,
        releaseDate,
        ageRating,
        genres,
        posterUrl,
        backdropUrl,
        trailerVideoId,
        director,
        cast,
        reviews,
        availableFormats,
        isNowShowing,
        isFeatured,
        isTrending,
        language,
      ];
}
