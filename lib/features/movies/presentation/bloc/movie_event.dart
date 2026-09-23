import 'package:equatable/equatable.dart';

abstract class MovieEvent extends Equatable {
  const MovieEvent();

  @override
  List<Object?> get props => [];
}

class LoadMoviesInitialEvent extends MovieEvent {}

class SelectGenreCategoryEvent extends MovieEvent {
  final String category;

  const SelectGenreCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class SelectLocationBranchEvent extends MovieEvent {
  final String locationId;
  final String locationName;

  const SelectLocationBranchEvent({
    required this.locationId,
    required this.locationName,
  });

  @override
  List<Object?> get props => [locationId, locationName];
}

class SearchMoviesEvent extends MovieEvent {
  final String query;
  final String? genre;
  final String? ageRating;

  const SearchMoviesEvent({
    required this.query,
    this.genre,
    this.ageRating,
  });

  @override
  List<Object?> get props => [query, genre, ageRating];
}

class SelectMovieEvent extends MovieEvent {
  final String movieId;

  const SelectMovieEvent(this.movieId);

  @override
  List<Object?> get props => [movieId];
}
