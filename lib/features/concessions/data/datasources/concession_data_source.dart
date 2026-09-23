import '../../domain/entities/concession_item.dart';

abstract class ConcessionDataSource {
  Future<List<ConcessionItem>> getConcessions();
}

class ConcessionDataSourceImpl implements ConcessionDataSource {
  static const List<ConcessionItem> mockConcessions = [
    ConcessionItem(
      id: 'c_combo_sabay_gold',
      name: 'Sabay Gold Duo Combo',
      description: '1 Large Truffle/Caramel Popcorn + 2 Soft Drinks (32oz) + Crispy Nachos',
      price: 8.50,
      imageUrl: 'https://images.unsplash.com/photo-1578849278619-e73505e9610f?w=600&q=80',
      category: ConcessionCategory.combos,
      calories: '980 kcal',
      isPopular: true,
    ),
    ConcessionItem(
      id: 'c_combo_solo',
      name: 'Solo Movie Craver',
      description: '1 Medium Sweet Caramel Popcorn + 1 Soft Drink (22oz)',
      price: 5.25,
      imageUrl: 'https://images.unsplash.com/photo-1585647347483-22b66260dfff?w=600&q=80',
      category: ConcessionCategory.combos,
      calories: '540 kcal',
      isPopular: true,
    ),
    ConcessionItem(
      id: 'c_popcorn_caramel',
      name: 'Caramel Supreme Popcorn',
      description: 'Artisanal kettle popped corn coated in rich golden butter caramel',
      price: 4.00,
      imageUrl: 'https://images.unsplash.com/photo-1572177191856-3cde618dee1f?w=600&q=80',
      category: ConcessionCategory.popcorn,
      calories: '420 kcal',
      isPopular: true,
    ),
    ConcessionItem(
      id: 'c_popcorn_cheese',
      name: 'Smoked Cheddar Popcorn',
      description: 'Crispy warm popcorn dusted with savory aged Wisconsin cheddar',
      price: 4.00,
      imageUrl: 'https://images.unsplash.com/photo-1505686994434-e3cc5abf1330?w=600&q=80',
      category: ConcessionCategory.popcorn,
      calories: '390 kcal',
    ),
    ConcessionItem(
      id: 'c_nachos_cheese',
      name: 'Grande Nachos & Warm Jalapeño Cheese',
      description: 'Tortilla crisps served with warm melted cheddar dip and spicy sliced jalapeños',
      price: 4.50,
      imageUrl: 'https://images.unsplash.com/photo-1513456852971-30c0b8199d4d?w=600&q=80',
      category: ConcessionCategory.snacks,
      calories: '490 kcal',
      isPopular: true,
    ),
    ConcessionItem(
      id: 'c_drink_frozen_coke',
      name: 'Ice Slushy Frozen Coca-Cola',
      description: 'Sub-zero frozen crystal beverage, ultra refreshing (Large)',
      price: 3.25,
      imageUrl: 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=600&q=80',
      category: ConcessionCategory.drinks,
      calories: '180 kcal',
    ),
    ConcessionItem(
      id: 'c_drink_tea',
      name: 'Honey Lemon Jasmine Iced Tea',
      description: 'Brewed premium jasmine tea infused with wild honey and fresh lemon',
      price: 2.75,
      imageUrl: 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=600&q=80',
      category: ConcessionCategory.drinks,
      calories: '90 kcal',
    ),
  ];

  @override
  Future<List<ConcessionItem>> getConcessions() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return mockConcessions;
  }
}
