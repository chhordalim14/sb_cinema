import '../../domain/entities/cinema_location.dart';

abstract class LocationsDataSource {
  Future<List<CinemaLocation>> getLocations({String? city, String? searchQuery});
  Future<CinemaLocation> getLocationById(String id);
  Future<List<String>> getCities();
}

class LocationsDataSourceImpl implements LocationsDataSource {
  static const List<CinemaLocation> mockLocations = [
    // Phnom Penh Branches
    CinemaLocation(
      id: '0000008101',
      name: 'Sabay Cinema Aeon Phnom Penh (Aeon 1)',
      address: '#132, Street Samdach Sothearos, Sangkat Tonle Bassac, Phnom Penh (Aeon1)',
      city: 'Phnom Penh',
      phone: '+855 98 888 126',
      imageUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=800&q=80',
      experiences: ['IMAX Laser', 'Dolby Atmos', 'VIP Gold Suite', 'Standard 2D/3D'],
      totalHalls: 7,
      distanceKm: 2.1,
      openingHours: '09:00 AM - 11:30 PM',
    ),
    CinemaLocation(
      id: '0000008104',
      name: 'Sabay Cinema Aeon Sen Sok (Aeon 2)',
      address: '#1003 Street, Village Bayab, Sangkat Phnom Penh Thmey, Phnom Penh (Aeon2)',
      city: 'Phnom Penh',
      phone: '+855 10 915 802',
      imageUrl: 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=800&q=80',
      experiences: ['IMAX Laser', 'ScreenX 270°', 'Dolby Atmos', 'VIP Gold Class', 'Kids Hall'],
      totalHalls: 8,
      distanceKm: 3.4,
      openingHours: '09:00 AM - 11:30 PM',
    ),
    CinemaLocation(
      id: '0000008106',
      name: 'Sabay Cinema Aeon Mall Mean Chey (Aeon 3)',
      address: 'Phum Prek Talong 3, Sangkat Chak Angre Krom, Khan Mean Chey, Phnom Penh',
      city: 'Phnom Penh',
      phone: '+855 70 777 375',
      imageUrl: 'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=800&q=80',
      experiences: ['ScreenX 270°', 'Laser 4K', 'Dolby Atmos', 'VIP Recliner'],
      totalHalls: 9,
      distanceKm: 5.2,
      openingHours: '09:30 AM - 11:30 PM',
    ),
    CinemaLocation(
      id: '0000008103',
      name: 'Sabay Cinema Sorya Center Point',
      address: '#13-61, Street 63, Sangkat Phsar Thmei 1, Khan Daun Penh, Phnom Penh (Sorya)',
      city: 'Phnom Penh',
      phone: '+855 87 666 210',
      imageUrl: 'https://images.unsplash.com/photo-1478720568477-152d9b164e26?w=800&q=80',
      experiences: ['Dolby Atmos', 'VIP Gold Class', 'Standard 2D/3D'],
      totalHalls: 6,
      distanceKm: 1.5,
      openingHours: '09:00 AM - 11:00 PM',
    ),

    // Provincial Branches
    CinemaLocation(
      id: '0000008102',
      name: 'Sabay Cinema Siem Reap Heritage',
      address: 'Stung Thmey Village, Svay Dongkom District, Siem Reap City, Siem Reap Province',
      city: 'Siem Reap',
      phone: '+855 81 666 210',
      imageUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800&q=80',
      experiences: ['VIP Diamond', 'Dolby Atmos', 'Standard 2D/3D'],
      totalHalls: 5,
      distanceKm: 314.0,
      openingHours: '09:30 AM - 11:00 PM',
    ),
    CinemaLocation(
      id: '0000008105',
      name: 'Sabay Cinema Big C Poipet',
      address: 'Kbal Spean 1 Village, Poipet Commune, Poipet District, Banteay Meanchey Province',
      city: 'Banteay Meanchey',
      phone: '+855 96 869 4511',
      imageUrl: 'https://images.unsplash.com/photo-1574267432553-4b4628081c31?w=800&q=80',
      experiences: ['Dolby Atmos', 'Laser 4K', 'Standard 2D/3D'],
      totalHalls: 4,
      distanceKm: 395.0,
      openingHours: '10:00 AM - 10:30 PM',
    ),
  ];

  @override
  Future<List<CinemaLocation>> getLocations({String? city, String? searchQuery}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    var results = List<CinemaLocation>.from(mockLocations);

    if (city != null && city.isNotEmpty && city != 'All') {
      results = results.where((loc) => loc.city.toLowerCase() == city.toLowerCase()).toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      results = results.where((loc) {
        return loc.name.toLowerCase().contains(query) ||
            loc.address.toLowerCase().contains(query) ||
            loc.city.toLowerCase().contains(query) ||
            loc.experiences.any((exp) => exp.toLowerCase().contains(query));
      }).toList();
    }

    return results;
  }

  @override
  Future<CinemaLocation> getLocationById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return mockLocations.firstWhere(
      (loc) => loc.id == id,
      orElse: () => mockLocations.first,
    );
  }

  @override
  Future<List<String>> getCities() async {
    await Future.delayed(const Duration(milliseconds: 50));
    final cities = mockLocations.map((loc) => loc.city).toSet().toList();
    return ['All', ...cities];
  }
}
