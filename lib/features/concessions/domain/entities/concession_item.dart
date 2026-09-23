import 'package:equatable/equatable.dart';

enum ConcessionCategory { combos, popcorn, drinks, snacks }

class ConcessionItem extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final ConcessionCategory category;
  final String calories;
  final bool isPopular;

  const ConcessionItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.calories = '',
    this.isPopular = false,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        imageUrl,
        category,
        calories,
        isPopular,
      ];
}
