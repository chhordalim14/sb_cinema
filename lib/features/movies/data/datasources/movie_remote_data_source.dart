import '../../domain/entities/banner_slide.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/showtime.dart';
import '../models/banner_slide_model.dart';
import '../models/movie_model.dart';

abstract class MovieRemoteDataSource {
  Future<List<BannerSlide>> getBannerSlides();
  Future<List<Movie>> getNowShowingMovies({String? category, String? locationId});
  Future<List<Movie>> getUpcomingMovies();
  Future<List<Movie>> getFeaturedMovies();
  Future<Movie> getMovieDetails(String movieId);
  Future<List<Showtime>> getShowtimes(String movieId, {String? locationId, DateTime? date});
  Future<List<Movie>> searchMovies(String query, {String? genre, String? ageRating});
}

class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  // ==================== AUTHENTIC SABAY CINEMA BANNER SLIDES ====================
  static final List<BannerSlideModel> _mockBanners = [
    const BannerSlideModel(
      id: 'slide_avengers_endgame',
      title: 'Avengers: Endgame Encore',
      khmerTitle: 'អាវែនជ័រ: អ៊ែនហ្គេម អិនខ័រ',
      subtitle: 'រូបរាងកាយសារជាថ្មីក្នុងទម្រង់ IMAX | Exclusive at Sabay Cinema',
      tag: 'IMAX LASER',
      imageUrl: 'https://www.sabaycinema.com/load_file/ads/file_20262611102641.png',
      actionText: 'GET TICKETS',
      type: BannerSlideType.movie,
      targetMovieId: 'mov_avengers_endgame',
      externalUrl: 'https://sabaycinema.com/showtime?movies=HO00002137',
    ),
    const BannerSlideModel(
      id: 'slide_aba_sabay',
      title: 'Win with ABA KHQR & Mobile',
      khmerTitle: 'Sabay Cinema x ABA Bank Campaign',
      subtitle: 'ឈ្នះដំណើរកម្សាន្តទៅសិង្ហបុរី ៤ នាក់, iPhone 17 Pro Max, iPad Air M4 & សំបុត្រកុន 900 រង្វាន់',
      tag: 'SPECIAL PROMO',
      imageUrl: 'https://www.sabaycinema.com/load_file/ads/file_20265311025305.jpg',
      actionText: 'LEARN MORE',
      type: BannerSlideType.partner,
      externalUrl: 'https://www.sabaycinema.com/promotions',
    ),
    const BannerSlideModel(
      id: 'slide_ganzberg',
      title: 'GANZBERG German Premium Beer',
      khmerTitle: 'ស្រាបៀរ ហ្កានស្បឺក កម្រិតពិភពលោក',
      subtitle: 'Monde Selection GOLD 2026 Beer Awards | Amazing Taste',
      tag: 'OFFICIAL PARTNER',
      imageUrl: 'https://www.sabaycinema.com/load_file/ads/file_20262928022939.png',
      actionText: 'EXPLORE',
      type: BannerSlideType.partner,
    ),
    const BannerSlideModel(
      id: 'slide_bacchus',
      title: 'Bacchus Energy Drink',
      khmerTitle: 'បាខាស់ ភេសជ្ជៈប៉ូវកម្លាំង',
      subtitle: 'Drive Your Energy | Premium Korean Energy Drink with Taurine & Vitamin B',
      tag: 'ENERGY BOOST',
      imageUrl: 'https://www.sabaycinema.com/load_file/ads/file_20261803111845.png',
      actionText: 'EXPLORE',
      type: BannerSlideType.partner,
    ),
    const BannerSlideModel(
      id: 'slide_sabay_brand',
      title: 'Sabay Cinema',
      khmerTitle: 'សប្បាយ ស៊ីនេម៉ា',
      subtitle: 'Sharing HAPPINESS Beyond THE SCREEN | IMAX Laser & ScreenX 270°',
      tag: 'CINEMA EXPERIENCE',
      imageUrl: 'https://www.sabaycinema.com/load_file/ads/file_20264407094429.png',
      actionText: 'EXPLORE',
      type: BannerSlideType.partner,
    ),
    const BannerSlideModel(
      id: 'slide_imax_laser',
      title: 'Crystal Clear IMAX with Laser',
      khmerTitle: 'បច្ចេកវិទ្យា IMAX with Laser ទំនើបចុងក្រោយ',
      subtitle: 'Next-Generation 4K Laser Projection & 12-Channel Immersive Sound',
      tag: 'IMAX LASER',
      imageUrl: 'https://www.sabaycinema.com/load_file/ads/file_20265818095807.png',
      actionText: 'DISCOVER',
      type: BannerSlideType.partner,
    ),
    const BannerSlideModel(
      id: 'slide_sabay_app',
      title: 'Download Sabay Cinema App',
      khmerTitle: 'ទាញយក Sabay Cinema App ឥឡូវនេះ',
      subtitle: 'Fast Booking, Exclusive Deals & E-Tickets | Available on iOS & Android',
      tag: 'MOBILE APP',
      imageUrl: 'https://www.sabaycinema.com/load_file/ads/file_20261219101207.jpg',
      actionText: 'DOWNLOAD',
      type: BannerSlideType.partner,
      externalUrl: 'https://www.sabaycinema.com',
    ),
    const BannerSlideModel(
      id: 'slide_sabay_bowl',
      title: 'Sabay Cinema x Sabay Bowl',
      khmerTitle: 'មើលកុន លេងប៊ូលីងហ្វ្រី (Sabay Bowl Your Ways)',
      subtitle: 'Watch Movies & Enjoy Free Bowling Games | Valid Until 31 October 2026',
      tag: 'COMBO DEAL',
      imageUrl: 'https://www.sabaycinema.com/load_file/ads/file_20263828083802.png',
      actionText: 'CHECK OFFER',
      type: BannerSlideType.partner,
    ),
    const BannerSlideModel(
      id: 'slide_sabay_ticket_price',
      title: 'Sabay Cinema New Ticket Price!',
      khmerTitle: 'តម្លៃសំបុត្រពិសេសគ្រប់សាខា',
      subtitle: 'Standard 2D ត្រឹមតែ \$2.50 | 3D Experience ត្រឹមតែ \$3.00! សន្សំសំចៃខ្ពស់បំផុត',
      tag: 'BEST VALUE',
      imageUrl: 'https://www.sabaycinema.com/load_file/ads/file_20264828034846.png',
      actionText: 'CHECK PRICES',
      type: BannerSlideType.pricing,
    ),
    const BannerSlideModel(
      id: 'slide_foodpanda_promo',
      title: 'Special Exclusive Combo',
      khmerTitle: 'ប្រូម៉ូសិនពិសេសផ្ដាច់មុខជាមួយ Foodpanda',
      subtitle: 'Exclusive combo with Foodpanda! Big Popcorn Bucket + Free Cold Drink for only \$5.90!',
      tag: 'BIG BUCKET FREE DRINK',
      imageUrl: 'assets/promotions/promo_foodpanda_popcorn.jpg',
      actionText: 'LEARN MORE',
      type: BannerSlideType.promotion,
      externalUrl: 'https://www.sabaycinema.com/promotions/foodpanda',
    ),
    const BannerSlideModel(
      id: 'slide_aba_promo',
      title: 'Win with ABA KHQR',
      khmerTitle: 'Sabay Cinema x ABA Bank Campaign',
      subtitle: 'Pay via ABA KHQR for tickets & snacks to enter the draw to win Singapore trip for 4, iPad Air & 900 free tickets!',
      tag: 'SPECIAL PROMO',
      imageUrl: 'assets/promotions/promo_aba_bank.jpg',
      actionText: 'LEARN MORE',
      type: BannerSlideType.promotion,
      externalUrl: 'https://www.sabaycinema.com/promotions',
    ),
    const BannerSlideModel(
      id: 'slide_student_discount',
      title: 'Student Movie Mania',
      khmerTitle: 'បញ្ចុះតម្លៃ ៥០% សម្រាប់សិស្ស-និស្សិត',
      subtitle: 'Show your student ID every Wednesday for 50% OFF all 2D & 3D movie tickets at all Sabay Cinema branches!',
      tag: '50% OFF STUDENT',
      imageUrl: 'assets/promotions/promo_student_discount.jpg',
      actionText: 'LEARN MORE',
      type: BannerSlideType.promotion,
      externalUrl: 'https://www.sabaycinema.com/promotions/students',
    ),
  ];

  // ==================== AUTHENTIC SABAY CINEMA MOVIES (TMDB) ====================
  static final List<MovieModel> _mockMovies = [
    // 1. Deadpool & Wolverine (TMDB ID: 533535)
    const MovieModel(
      id: 'mov_deadpool_wolverine',
      title: 'Deadpool & Wolverine',
      originalTitle: 'Deadpool & Wolverine (Marvel Studios)',
      synopsis:
          'A listless Wade Wilson toils away in civilian life with his days as the morally flexible mercenary, Deadpool, behind him. But when his homeworld faces an existential threat, Wade must reluctantly suit-up again with an even more reluctant Wolverine.',
      rating: 7.7,
      voteCount: 58400,
      durationMinutes: 128,
      releaseDate: '2026-09-18',
      ageRating: 'R-18',
      genres: ['Action', 'Comedy', 'Sci-Fi'],
      posterUrl: 'https://image.tmdb.org/t/p/w500/8cdWjvZQUExUUTzyp4t6EDMubfO.jpg',
      backdropUrl: 'https://image.tmdb.org/t/p/w1280/lgkPzcOSnTvjeMnuFzozRO5HHw1.jpg',
      trailerVideoId: '73_1biulkYk',
      director: 'Shawn Levy',
      cast: [
        CastMember(
          name: 'Ryan Reynolds',
          role: 'Wade Wilson / Deadpool',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/4SYrm5OCx2yFe3h1J1P39f20c29.jpg',
        ),
        CastMember(
          name: 'Hugh Jackman',
          role: 'Logan / Wolverine',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/4XujBEq4qg49g7e5Qk7k0z92.jpg',
        ),
        CastMember(
          name: 'Emma Corrin',
          role: 'Cassandra Nova',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/8Zz4351aE1V76z6u9f18m9g.jpg',
        ),
        CastMember(
          name: 'Matthew Macfadyen',
          role: 'Mr. Paradox',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/2E20VzS2YtM2Z2mH8Lz3r6Yp.jpg',
        ),
      ],
      reviews: [
        MovieReview(
          author: 'Sophea V.',
          rating: 5.0,
          date: 'Yesterday',
          comment: 'Hilarious and action-packed! The IMAX Laser experience at Aeon Sen Sok was mind-blowing!',
          avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&q=80',
        ),
        MovieReview(
          author: 'Dara Chan',
          rating: 4.8,
          date: '2 days ago',
          comment: 'Best Marvel movie in years. Ryan Reynolds and Hugh Jackman chemistry is unmatched.',
          avatarUrl: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=100&q=80',
        ),
      ],
      availableFormats: [
        HallExperience.imaxLaser,
        HallExperience.screenX,
        HallExperience.standard2D,
        HallExperience.standard3D,
      ],
      isNowShowing: true,
      isFeatured: true,
      isTrending: true,
      language: 'English (Khmer Sub)',
    ),

    // 2. Dune: Part Two (TMDB ID: 693134)
    const MovieModel(
      id: 'mov_dune_2',
      title: 'Dune: Part Two',
      originalTitle: 'Dune: Part Two (Warner Bros.)',
      synopsis:
          'Follow the mythic journey of Paul Atreides as he unites with Chani and the Fremen while on a path of revenge against the conspirators who destroyed his family. Facing a choice between the love of his life and the fate of the universe, he endeavors to prevent a terrible future.',
      rating: 8.2,
      voteCount: 56200,
      durationMinutes: 166,
      releaseDate: '2026-09-17',
      ageRating: 'PG-13',
      genres: ['Sci-Fi', 'Adventure', 'Action', 'Drama'],
      posterUrl: 'https://image.tmdb.org/t/p/w500/1pdfLvkbY9ohJlCjQH2CZjjYVvJ.jpg',
      backdropUrl: 'https://image.tmdb.org/t/p/w1280/xOMo8BRK7PfcJv9JCnx7s5hj0x2.jpg',
      trailerVideoId: 'Way9Dexny3w',
      director: 'Denis Villeneuve',
      cast: [
        CastMember(
          name: 'Timothée Chalamet',
          role: 'Paul Atreides',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/BE2sdjpgsa2rNTFa66ULvd6hnP.jpg',
        ),
        CastMember(
          name: 'Zendaya',
          role: 'Chani',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/r3A7evR12r9m4Z6k4e38e6P6.jpg',
        ),
        CastMember(
          name: 'Rebecca Ferguson',
          role: 'Lady Jessica',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/6NRdH1E94yK92k6e38e6.jpg',
        ),
        CastMember(
          name: 'Javier Bardem',
          role: 'Stilgar',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/p12P8pL0fH1K9V2Y1z7J9s.jpg',
        ),
      ],
      reviews: [
        MovieReview(
          author: 'Vireak Meas',
          rating: 5.0,
          date: '3 days ago',
          comment: 'A true cinematic triumph! The audio design in Dolby Atmos shook the entire hall.',
          avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&q=80',
        ),
      ],
      availableFormats: [
        HallExperience.imaxLaser,
        HallExperience.screenX,
        HallExperience.vipGold,
        HallExperience.standard2D,
      ],
      isNowShowing: true,
      isFeatured: true,
      isTrending: true,
      language: 'English (Khmer & English Sub)',
    ),

    // 3. Inside Out 2 (TMDB ID: 1022789)
    const MovieModel(
      id: 'mov_inside_out_2',
      title: 'Inside Out 2',
      originalTitle: 'Inside Out 2 (Disney / Pixar)',
      synopsis:
          'Teenager Riley\'s mind headquarters is undergoing a sudden demolition to make room for something entirely unexpected: new Emotions! Joy, Sadness, Anger, Fear and Disgust aren\'t sure how to feel when Anxiety, Envy, Ennui and Embarrassment arrive.',
      rating: 7.6,
      voteCount: 52100,
      durationMinutes: 96,
      releaseDate: '2026-09-15',
      ageRating: 'G',
      genres: ['Animation', 'Family', 'Adventure', 'Comedy'],
      posterUrl: 'https://image.tmdb.org/t/p/w500/vpnVM9B6NMmQpWeZvzLvDESb2QY.jpg',
      backdropUrl: 'https://image.tmdb.org/t/p/w1280/xg27NrXi7VXCGUr7MG75UqLl6Vg.jpg',
      trailerVideoId: 'LEjhY15eCx0',
      director: 'Kelsey Mann',
      cast: [
        CastMember(
          name: 'Amy Poehler',
          role: 'Joy (Voice)',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/vnp5mR97R2M0z0P1r0E9f9s8L.jpg',
        ),
        CastMember(
          name: 'Maya Hawke',
          role: 'Anxiety (Voice)',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/xP6z1Qz6k2r6L1Z2z3Y4x5W.jpg',
        ),
        CastMember(
          name: 'Phyllis Smith',
          role: 'Sadness (Voice)',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/tK9r1P2Q3R4S5T6U7V8W9X.jpg',
        ),
      ],
      reviews: [
        MovieReview(
          author: 'Kalyan T.',
          rating: 5.0,
          date: 'Yesterday',
          comment: 'Brought my family to the Sabay Cinema Kids Hall. Beautiful message for all ages!',
          avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&q=80',
        ),
      ],
      availableFormats: [
        HallExperience.standard2D,
        HallExperience.standard3D,
        HallExperience.kids,
      ],
      isNowShowing: true,
      isFeatured: true,
      isTrending: true,
      language: 'English / Khmer Dub',
    ),

    // 4. The Wild Robot (TMDB ID: 1184918)
    const MovieModel(
      id: 'mov_wild_robot',
      title: 'The Wild Robot',
      originalTitle: 'The Wild Robot (DreamWorks Animation)',
      synopsis:
          'After a shipwreck, an intelligent robot named ROZZUM unit 7134 ("Roz") is stranded on an uninhabited island. To survive the harsh environment, Roz bonds with the island\'s animals and cares for an orphaned baby goose.',
      rating: 8.4,
      voteCount: 36400,
      durationMinutes: 102,
      releaseDate: '2026-09-14',
      ageRating: 'G',
      genres: ['Animation', 'Sci-Fi', 'Family', 'Adventure'],
      posterUrl: 'https://image.tmdb.org/t/p/w500/wTnV3PCVW5O92JMrvgZevRby2Ce.jpg',
      backdropUrl: 'https://image.tmdb.org/t/p/w1280/8rpDcsfLJypbO6vREc0547VKqEv.jpg',
      trailerVideoId: '67vbA5ZJb3E',
      director: 'Chris Sanders',
      cast: [
        CastMember(
          name: 'Lupita Nyong\'o',
          role: 'ROZ (Voice)',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/87r6w7q1p9r0t2s4v5w8x9y0.jpg',
        ),
        CastMember(
          name: 'Pedro Pascal',
          role: 'Fink (Voice)',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/4c5v6w7x8y9z0a1b2c3d4e5.jpg',
        ),
        CastMember(
          name: 'Kit Connor',
          role: 'Brightbill (Voice)',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/5d6e7f8g9h0i1j2k3l4m5n.jpg',
        ),
      ],
      reviews: [
        MovieReview(
          author: 'Sreyleak Chhum',
          rating: 5.0,
          date: '4 days ago',
          comment: 'One of the greatest animated films ever made. Bring tissues, so heartfelt!',
          avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&q=80',
        ),
      ],
      availableFormats: [
        HallExperience.standard2D,
        HallExperience.standard3D,
        HallExperience.kids,
        HallExperience.vipGold,
      ],
      isNowShowing: true,
      isFeatured: true,
      isTrending: true,
      language: 'English (Khmer Sub)',
    ),

    // 5. Alien: Romulus (TMDB ID: 945961)
    const MovieModel(
      id: 'mov_alien_romulus',
      title: 'Alien: Romulus',
      originalTitle: 'Alien: Romulus (20th Century Studios)',
      synopsis:
          'While scavenging the derelict Renaissance space station, a crew of youthful space scavengers accidentally awaken the most lethal predatory organism in the cosmos.',
      rating: 7.3,
      voteCount: 28900,
      durationMinutes: 119,
      releaseDate: '2026-09-12',
      ageRating: 'R-18',
      genres: ['Sci-Fi', 'Horror', 'Thriller'],
      posterUrl: 'https://image.tmdb.org/t/p/w500/b33nnKl1GSFbao4l3fZDDqsMx0F.jpg',
      backdropUrl: 'https://image.tmdb.org/t/p/w1280/dvBCdCohwWbsP5qAaglOXagDMtk.jpg',
      trailerVideoId: 'x0XDEhP4MQs',
      director: 'Fede Álvarez',
      cast: [
        CastMember(
          name: 'Cailee Spaeny',
          role: 'Rain Carradine',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/p12P8pL0fH1K9V2Y1z7J9s.jpg',
        ),
        CastMember(
          name: 'David Jonsson',
          role: 'Andy',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/tK9r1P2Q3R4S5T6U7V8W9X.jpg',
        ),
        CastMember(
          name: 'Archie Renaux',
          role: 'Tyler',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/4c5v6w7x8y9z0a1b2c3d4e5.jpg',
        ),
      ],
      reviews: [
        MovieReview(
          author: 'Chenda K.',
          rating: 4.8,
          date: '3 days ago',
          comment: 'Pure fear and claustrophobia. Sound design in Dolby Atmos was terrifyingly realistic.',
          avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&q=80',
        ),
      ],
      availableFormats: [
        HallExperience.imaxLaser,
        HallExperience.dolbyAtmos,
        HallExperience.screenX,
        HallExperience.standard2D,
      ],
      isNowShowing: true,
      isFeatured: false,
      isTrending: true,
      language: 'English (Khmer Sub)',
    ),

    // 6. Avengers: Endgame (TMDB ID: 299534)
    const MovieModel(
      id: 'mov_avengers_endgame',
      title: 'Avengers: Endgame',
      originalTitle: 'Avengers: Endgame (Marvel Studios)',
      synopsis:
          'After the devastating events of Infinity War, the universe is in ruins. With the help of remaining allies, the Avengers assemble once more to reverse Thanos\' actions and restore balance in this exclusive IMAX with Laser re-release celebration.',
      rating: 8.3,
      voteCount: 94200,
      durationMinutes: 181,
      releaseDate: '2026-09-23',
      ageRating: 'PG-13',
      genres: ['Action', 'Sci-Fi', 'Adventure', 'Drama'],
      posterUrl: 'https://image.tmdb.org/t/p/w500/ulzhLuWrPK07P1YkdWQLZnQh1JL.jpg',
      backdropUrl: 'https://image.tmdb.org/t/p/w1280/7RyHsO4yDXtBv1zUU3mTpHeQ0d5.jpg',
      trailerVideoId: 'TcMBFSGVi1c',
      director: 'Anthony Russo & Joe Russo',
      cast: [
        CastMember(
          name: 'Robert Downey Jr.',
          role: 'Tony Stark / Iron Man',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/1YjdSym1jA75mA9ryio322rAv1x.jpg',
        ),
        CastMember(
          name: 'Chris Evans',
          role: 'Steve Rogers / Captain America',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/3bOGNsHlrswhyW79uvIHH1V43JI.jpg',
        ),
        CastMember(
          name: 'Scarlett Johansson',
          role: 'Natasha Romanoff',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/6NsMbJXRlDZuDzatNmakoxHQZII.jpg',
        ),
      ],
      reviews: [
        MovieReview(
          author: 'Dara Chan',
          rating: 5.0,
          date: 'Yesterday',
          comment: 'Watching Endgame on Sabay\'s new IMAX Laser screen gave me chills all over again. Unmatched!',
          avatarUrl: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=100&q=80',
        ),
      ],
      availableFormats: [
        HallExperience.imaxLaser,
        HallExperience.standard3D,
        HallExperience.vipGold,
        HallExperience.standard2D,
      ],
      isNowShowing: true,
      isFeatured: true,
      isTrending: true,
      language: 'English (Khmer & English Sub)',
    ),

    // 7. Spider-Man: Across the Spider-Verse (TMDB ID: 569094)
    const MovieModel(
      id: 'mov_spider_verse',
      title: 'Spider-Man: Across the Spider-Verse',
      originalTitle: 'Spider-Man: Across the Spider-Verse (Sony Pictures)',
      synopsis:
          'After reuniting with Gwen Stacy, Brooklyn\'s friendly neighborhood Spider-Man is catapulted across the Multiverse, where he encounters the Spider Society, a team of Spider-People charged with protecting the Multiverse\'s very existence.',
      rating: 8.4,
      voteCount: 68500,
      durationMinutes: 140,
      releaseDate: '2026-09-10',
      ageRating: 'PG-13',
      genres: ['Animation', 'Action', 'Adventure', 'Sci-Fi'],
      posterUrl: 'https://image.tmdb.org/t/p/w500/8Vt6mWEReuy4Of61Lnj5Xj704m8.jpg',
      backdropUrl: 'https://image.tmdb.org/t/p/w1280/9xfDWXAUbFXQK585JvByT5pEAhe.jpg',
      trailerVideoId: 'cqGjhVJWtEg',
      director: 'Joaquim Dos Santos, Kemp Powers',
      cast: [
        CastMember(
          name: 'Shameik Moore',
          role: 'Miles Morales (Voice)',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/2E20VzS2YtM2Z2mH8Lz3r6Yp.jpg',
        ),
        CastMember(
          name: 'Hailee Steinfeld',
          role: 'Gwen Stacy (Voice)',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/vnp5mR97R2M0z0P1r0E9f9s8L.jpg',
        ),
        CastMember(
          name: 'Oscar Isaac',
          role: 'Miguel O\'Hara (Voice)',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/p12P8pL0fH1K9V2Y1z7J9s.jpg',
        ),
      ],
      reviews: [
        MovieReview(
          author: 'Vireak C.',
          rating: 5.0,
          date: '5 days ago',
          comment: 'Visual masterclass! Every single frame belongs in an art museum.',
          avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&q=80',
        ),
      ],
      availableFormats: [
        HallExperience.imaxLaser,
        HallExperience.standard2D,
        HallExperience.standard3D,
      ],
      isNowShowing: true,
      isFeatured: false,
      isTrending: true,
      language: 'English (Khmer Sub)',
    ),

    // 8. Oppenheimer (TMDB ID: 872585)
    const MovieModel(
      id: 'mov_oppenheimer',
      title: 'Oppenheimer',
      originalTitle: 'Oppenheimer (Universal Pictures / Syncopy)',
      synopsis:
          'The story of J. Robert Oppenheimer\'s role in the development of the atomic bomb during World War II, exploring the profound moral, personal, and geopolitical consequences of humanity\'s most destructive invention.',
      rating: 8.1,
      voteCount: 91400,
      durationMinutes: 181,
      releaseDate: '2026-09-08',
      ageRating: 'R-18',
      genres: ['Drama', 'History', 'Biography'],
      posterUrl: 'https://image.tmdb.org/t/p/w500/8Gxv8gSFCU0XGDykEGv7zR1n2ua.jpg',
      backdropUrl: 'https://image.tmdb.org/t/p/w1280/nb3xI8XI3w4pMVZ38VijbsyBqP4.jpg',
      trailerVideoId: 'uYPbbksJxIg',
      director: 'Christopher Nolan',
      cast: [
        CastMember(
          name: 'Cillian Murphy',
          role: 'J. Robert Oppenheimer',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/360R3zsdtb3BE7y5h12p1W.jpg',
        ),
        CastMember(
          name: 'Emily Blunt',
          role: 'Katherine \'Kitty\' Oppenheimer',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/nPJXaRMguvg3qN7p.jpg',
        ),
        CastMember(
          name: 'Robert Downey Jr.',
          role: 'Lewis Strauss',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/1YjdSym1jA75mA9ryio322rAv1x.jpg',
        ),
      ],
      reviews: [
        MovieReview(
          author: 'Kosal Heng',
          rating: 5.0,
          date: '1 week ago',
          comment: 'Riveting from beginning to end. Cillian Murphy gave the performance of a lifetime.',
          avatarUrl: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=100&q=80',
        ),
      ],
      availableFormats: [
        HallExperience.imaxLaser,
        HallExperience.dolbyAtmos,
        HallExperience.vipGold,
        HallExperience.standard2D,
      ],
      isNowShowing: true,
      isFeatured: false,
      isTrending: false,
      language: 'English (Khmer Sub)',
    ),

    // 9. Despicable Me 4 (TMDB ID: 519182)
    const MovieModel(
      id: 'mov_despicable_me_4',
      title: 'Despicable Me 4',
      originalTitle: 'Despicable Me 4 (Illumination / Universal)',
      synopsis:
          'Gru and Lucy and their girls welcome a new member to the Gru family, Gru Jr., who is intent on tormenting his dad. Gru faces a new nemesis in Maxime Le Mal and his femme fatale girlfriend Valentina, forcing the family to go on the run.',
      rating: 7.1,
      voteCount: 24200,
      durationMinutes: 95,
      releaseDate: '2026-09-05',
      ageRating: 'G',
      genres: ['Animation', 'Family', 'Comedy', 'Action'],
      posterUrl: 'https://image.tmdb.org/t/p/w500/wNApq8ee4cNr92G42j642y47yYx.jpg',
      backdropUrl: 'https://image.tmdb.org/t/p/w1280/lgkPzcOSnTvjeMnuFzozRO5HHw1.jpg',
      trailerVideoId: 'qQlr9-rF32A',
      director: 'Chris Renaud',
      cast: [
        CastMember(
          name: 'Steve Carell',
          role: 'Gru (Voice)',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/3bOGNsHlrswhyW79uvIHH1V43JI.jpg',
        ),
        CastMember(
          name: 'Kristen Wiig',
          role: 'Lucy (Voice)',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/nPJXaRMguvg3qN7p.jpg',
        ),
        CastMember(
          name: 'Will Ferrell',
          role: 'Maxime Le Mal (Voice)',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/2E20VzS2YtM2Z2mH8Lz3r6Yp.jpg',
        ),
      ],
      reviews: [
        MovieReview(
          author: 'Sreyleak N.',
          rating: 4.9,
          date: '2 weeks ago',
          comment: 'The Mega Minions were hilarious! Great laughter with my kids.',
          avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100&q=80',
        ),
      ],
      availableFormats: [
        HallExperience.standard2D,
        HallExperience.standard3D,
        HallExperience.kids,
      ],
      isNowShowing: true,
      isFeatured: false,
      isTrending: true,
      language: 'Khmer Dub / English Sub',
    ),

    // ==================== COMING SOON MOVIES (TMDB) ====================
    // 10. Gladiator II (TMDB ID: 558449)
    const MovieModel(
      id: 'mov_gladiator_2',
      title: 'Gladiator II',
      originalTitle: 'Gladiator II (Paramount Pictures)',
      synopsis:
          'Years after witnessing the death of Maximus at the hands of his uncle, Lucius must enter the Colosseum after his home is conquered by the tyrannical Emperors who now lead Rome with an iron fist.',
      rating: 7.8,
      voteCount: 28500,
      durationMinutes: 148,
      releaseDate: '2026-11-22',
      ageRating: 'R-18',
      genres: ['Action', 'Drama', 'Adventure'],
      posterUrl: 'https://image.tmdb.org/t/p/w500/b5UXjzW5cLZhprMnlAmsVAA3G4t.jpg',
      backdropUrl: 'https://image.tmdb.org/t/p/w1280/euYIwmwkmz95mnXvufEmbL6ovhZ.jpg',
      trailerVideoId: '4rgYUipGJNo',
      director: 'Ridley Scott',
      cast: [
        CastMember(
          name: 'Paul Mescal',
          role: 'Lucius',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/p12P8pL0fH1K9V2Y1z7J9s.jpg',
        ),
        CastMember(
          name: 'Pedro Pascal',
          role: 'Marcus Acacius',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/4c5v6w7x8y9z0a1b2c3d4e5.jpg',
        ),
        CastMember(
          name: 'Denzel Washington',
          role: 'Macrinus',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/3bOGNsHlrswhyW79uvIHH1V43JI.jpg',
        ),
      ],
      reviews: [],
      availableFormats: [
        HallExperience.imaxLaser,
        HallExperience.dolbyAtmos,
        HallExperience.vipGold,
        HallExperience.standard2D,
      ],
      isNowShowing: false,
      isFeatured: true,
      isTrending: true,
      language: 'English (Khmer Sub)',
    ),

    // 11. Moana 2 (TMDB ID: 1241982)
    const MovieModel(
      id: 'mov_moana_2',
      title: 'Moana 2',
      originalTitle: 'Moana 2 (Walt Disney Animation)',
      synopsis:
          'After receiving an unexpected call from her wayfinding ancestors, Moana must journey to the far seas of Oceania and into dangerous, long-lost waters for an adventure unlike anything she’s ever faced.',
      rating: 7.5,
      voteCount: 19400,
      durationMinutes: 100,
      releaseDate: '2026-11-27',
      ageRating: 'G',
      genres: ['Animation', 'Adventure', 'Comedy', 'Family', 'Musical'],
      posterUrl: 'https://image.tmdb.org/t/p/w500/xDGbZ0JJ3mYaGKy4Nzd9Kph6M9L.jpg',
      backdropUrl: 'https://image.tmdb.org/t/p/w1280/tElnmtQ6yz1PjN1kePNl8yMSb59.jpg',
      trailerVideoId: 'hDZ7y8RP5HE',
      director: 'David Derrick Jr.',
      cast: [
        CastMember(
          name: 'Auliʻi Cravalho',
          role: 'Moana (Voice)',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/vnp5mR97R2M0z0P1r0E9f9s8L.jpg',
        ),
        CastMember(
          name: 'Dwayne Johnson',
          role: 'Maui (Voice)',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/4SYrm5OCx2yFe3h1J1P39f20c29.jpg',
        ),
      ],
      reviews: [],
      availableFormats: [
        HallExperience.standard2D,
        HallExperience.standard3D,
        HallExperience.kids,
      ],
      isNowShowing: false,
      isFeatured: false,
      isTrending: true,
      language: 'English (Khmer Sub)',
    ),

    // 12. Venom: The Last Dance (TMDB ID: 912649)
    const MovieModel(
      id: 'mov_venom_last_dance',
      title: 'Venom: The Last Dance',
      originalTitle: 'Venom: The Last Dance (Sony Pictures / Marvel)',
      synopsis:
          'Eddie and Venom are on the run. Hunted by both of their worlds and with the net closing in, the duo are forced into a devastating decision that will bring the curtains down on Venom and Eddie\'s last dance.',
      rating: 7.2,
      voteCount: 18200,
      durationMinutes: 110,
      releaseDate: '2026-10-25',
      ageRating: 'PG-13',
      genres: ['Action', 'Sci-Fi', 'Adventure'],
      posterUrl: 'https://image.tmdb.org/t/p/w500/kbr1t7h6p7hP8Lq4t4gY4C5i0oP.jpg',
      backdropUrl: 'https://image.tmdb.org/t/p/w1280/3Z7u46G8K0Jk1M8E9V21V6G2L3H.jpg',
      trailerVideoId: '__2bsPW88EE',
      director: 'Kelly Marcel',
      cast: [
        CastMember(
          name: 'Tom Hardy',
          role: 'Eddie Brock / Venom',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/4XujBEq4qg49g7e5Qk7k0z92.jpg',
        ),
        CastMember(
          name: 'Chiwetel Ejiofor',
          role: 'Rex Strickland',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/3bOGNsHlrswhyW79uvIHH1V43JI.jpg',
        ),
        CastMember(
          name: 'Juno Temple',
          role: 'Dr. Teddy Payne',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/8Zz4351aE1V76z6u9f18m9g.jpg',
        ),
      ],
      reviews: [],
      availableFormats: [
        HallExperience.imaxLaser,
        HallExperience.screenX,
        HallExperience.standard2D,
        HallExperience.standard3D,
      ],
      isNowShowing: false,
      isFeatured: false,
      isTrending: true,
      language: 'English (Khmer Sub)',
    ),

    // 13. Joker: Folie à Deux (TMDB ID: 889737)
    const MovieModel(
      id: 'mov_joker_folie',
      title: 'Joker: Folie à Deux',
      originalTitle: 'Joker: Folie à Deux (DC Studios / Warner Bros.)',
      synopsis:
          'Arthur Fleck is institutionalized at Arkham awaiting trial for his crimes as Joker. While struggling with his dual identity, Arthur not only stumbles upon true love, but also finds the music inside him.',
      rating: 6.2,
      voteCount: 21900,
      durationMinutes: 138,
      releaseDate: '2026-09-28',
      ageRating: 'R-18',
      genres: ['Crime', 'Drama', 'Musical', 'Thriller'],
      posterUrl: 'https://image.tmdb.org/t/p/w500/aciP8Km0waTL31Mf0ezbtGy0mkm.jpg',
      backdropUrl: 'https://image.tmdb.org/t/p/w1280/uGmYqxh8flqkudioyKpDhuUjvNI.jpg',
      trailerVideoId: '_OKAwz2NiJs',
      director: 'Todd Phillips',
      cast: [
        CastMember(
          name: 'Joaquin Phoenix',
          role: 'Arthur Fleck / Joker',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/4c5v6w7x8y9z0a1b2c3d4e5.jpg',
        ),
        CastMember(
          name: 'Lady Gaga',
          role: 'Harleen Quinzel / Lee',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/nPJXaRMguvg3qN7p.jpg',
        ),
        CastMember(
          name: 'Brendan Gleeson',
          role: 'Jackie Sullivan',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/3bOGNsHlrswhyW79uvIHH1V43JI.jpg',
        ),
      ],
      reviews: [],
      availableFormats: [
        HallExperience.imaxLaser,
        HallExperience.dolbyAtmos,
        HallExperience.standard2D,
      ],
      isNowShowing: false,
      isFeatured: false,
      isTrending: false,
      language: 'English (Khmer Sub)',
    ),

    // 14. Interstellar (10th Anniversary IMAX) (TMDB ID: 157336)
    const MovieModel(
      id: 'mov_interstellar',
      title: 'Interstellar (10th Anniversary)',
      originalTitle: 'Interstellar (Paramount / Warner Bros. / Syncopy)',
      synopsis:
          'The adventures of a group of explorers who make use of a newly discovered wormhole to surpass the limitations on human space travel and conquer the vast distances involved in an interstellar voyage.',
      rating: 8.4,
      voteCount: 35200,
      durationMinutes: 169,
      releaseDate: '2026-12-06',
      ageRating: 'PG-13',
      genres: ['Sci-Fi', 'Drama', 'Adventure'],
      posterUrl: 'https://image.tmdb.org/t/p/w500/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
      backdropUrl: 'https://image.tmdb.org/t/p/w1280/xu9zaAevzQ5nnrsXN6JcahLnG4i.jpg',
      trailerVideoId: 'zSWdZVtXT7E',
      director: 'Christopher Nolan',
      cast: [
        CastMember(
          name: 'Matthew McConaughey',
          role: 'Joseph Cooper',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/3bOGNsHlrswhyW79uvIHH1V43JI.jpg',
        ),
        CastMember(
          name: 'Anne Hathaway',
          role: 'Dr. Amelia Brand',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/nPJXaRMguvg3qN7p.jpg',
        ),
        CastMember(
          name: 'Jessica Chastain',
          role: 'Murphy Cooper',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/6NsMbJXRlDZuDzatNmakoxHQZII.jpg',
        ),
      ],
      reviews: [],
      availableFormats: [
        HallExperience.imaxLaser,
        HallExperience.vipGold,
        HallExperience.screenX,
        HallExperience.standard2D,
      ],
      isNowShowing: false,
      isFeatured: false,
      isTrending: true,
      language: 'English (Khmer Sub)',
    ),

    // 15. Avatar: Fire and Ash (TMDB ID: 83533)
    const MovieModel(
      id: 'mov_avatar_fire_ash',
      title: 'Avatar: Fire and Ash',
      originalTitle: 'Avatar 3: Fire and Ash (Lightstorm / 20th Century)',
      synopsis:
          'Jake Sully and Neytiri encounter the Ash People, a more aggressive volcanic tribe of Na\'vi on Pandora, challenging the family\'s ideals of peace in an escalating war.',
      rating: 8.8,
      voteCount: 14200,
      durationMinutes: 192,
      releaseDate: '2026-12-19',
      ageRating: 'PG-13',
      genres: ['Action', 'Sci-Fi', 'Adventure', 'Fantasy'],
      posterUrl: 'https://image.tmdb.org/t/p/w500/t6HIqrRAclMCA60NsSmeqe9RmNV.jpg',
      backdropUrl: 'https://image.tmdb.org/t/p/w1280/vL5LR6WdxWPjLPFRLe133jXWsh5.jpg',
      trailerVideoId: 'd9MyW72ELq0',
      director: 'James Cameron',
      cast: [
        CastMember(
          name: 'Sam Worthington',
          role: 'Jake Sully',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/4c5v6w7x8y9z0a1b2c3d4e5.jpg',
        ),
        CastMember(
          name: 'Zoe Saldana',
          role: 'Neytiri',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/6NsMbJXRlDZuDzatNmakoxHQZII.jpg',
        ),
        CastMember(
          name: 'Sigourney Weaver',
          role: 'Kiri',
          avatarUrl: 'https://image.tmdb.org/t/p/w185/nPJXaRMguvg3qN7p.jpg',
        ),
      ],
      reviews: [],
      availableFormats: [
        HallExperience.imaxLaser,
        HallExperience.screenX,
        HallExperience.standard3D,
        HallExperience.vipGold,
      ],
      isNowShowing: false,
      isFeatured: false,
      isTrending: true,
      language: 'English (Khmer Sub)',
    ),
  ];


  @override
  Future<List<BannerSlide>> getBannerSlides() async {
    await Future.delayed(const Duration(milliseconds: 120));
    return _mockBanners;
  }

  @override
  Future<List<Movie>> getNowShowingMovies({String? category, String? locationId}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    var movies = _mockMovies.where((m) => m.isNowShowing).toList();

    if (category != null && category != 'All') {
      if (category == 'IMAX') {
        movies = movies.where((m) => m.availableFormats.contains(HallExperience.imaxLaser)).toList();
      } else if (category == 'SCREEN X') {
        movies = movies.where((m) => m.availableFormats.contains(HallExperience.screenX)).toList();
      } else if (category == '3D') {
        movies = movies.where((m) => m.availableFormats.contains(HallExperience.standard3D)).toList();
      } else {
        movies = movies.where((m) => m.genres.contains(category)).toList();
      }
    }

    return movies;
  }

  @override
  Future<List<Movie>> getUpcomingMovies() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _mockMovies.where((m) => !m.isNowShowing).toList();
  }

  @override
  Future<List<Movie>> getFeaturedMovies() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockMovies.where((m) => m.isFeatured).toList();
  }

  @override
  Future<Movie> getMovieDetails(String movieId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockMovies.firstWhere(
      (m) => m.id == movieId,
      orElse: () => _mockMovies.first,
    );
  }

  @override
  Future<List<Showtime>> getShowtimes(String movieId, {String? locationId, DateTime? date}) async {
    await Future.delayed(const Duration(milliseconds: 120));
    final now = DateTime.now();
    final y = now.year;
    final m = now.month;
    final d = date?.day ?? now.day;

    // Authentic Sabay Cinema Pricing & Realistic Cinema Schedule matching reference UI
    final allShowtimes = [
      // ==================== Aeon 1 (0000008101) ====================
      // 2D - Regular Hall (KH Audio | EN, CH Subtitles)
      Showtime(
        id: 'st_aeon1_2d_1',
        movieId: movieId,
        locationId: '0000008101',
        locationName: 'Sabay Cinema Aeon Phnom Penh (Aeon 1)',
        hallName: 'Hall 1',
        hallType: 'REGULAR HALL',
        experience: HallExperience.standard2D,
        startTime: DateTime(y, m, d, 14, 5), // 02:05 PM
        endTime: DateTime(y, m, d, 16, 20),
        basePrice: 2.50,
        totalSeats: 120,
        availableSeats: 74,
        languageSubtitle: 'EN / CH Sub',
        spokenLanguage: 'KH',
        subtitleLanguage: 'EN, CH',
      ),
      Showtime(
        id: 'st_aeon1_2d_2',
        movieId: movieId,
        locationId: '0000008101',
        locationName: 'Sabay Cinema Aeon Phnom Penh (Aeon 1)',
        hallName: 'Hall 1',
        hallType: 'REGULAR HALL',
        experience: HallExperience.standard2D,
        startTime: DateTime(y, m, d, 15, 40), // 03:40 PM
        endTime: DateTime(y, m, d, 17, 55),
        basePrice: 2.50,
        totalSeats: 120,
        availableSeats: 58,
        languageSubtitle: 'EN / CH Sub',
        spokenLanguage: 'KH',
        subtitleLanguage: 'EN, CH',
      ),
      Showtime(
        id: 'st_aeon1_2d_3',
        movieId: movieId,
        locationId: '0000008101',
        locationName: 'Sabay Cinema Aeon Phnom Penh (Aeon 1)',
        hallName: 'Hall 1',
        hallType: 'REGULAR HALL',
        experience: HallExperience.standard2D,
        startTime: DateTime(y, m, d, 18, 35), // 06:35 PM
        endTime: DateTime(y, m, d, 20, 50),
        basePrice: 2.50,
        totalSeats: 120,
        availableSeats: 42,
        languageSubtitle: 'EN / CH Sub',
        spokenLanguage: 'KH',
        subtitleLanguage: 'EN, CH',
      ),
      Showtime(
        id: 'st_aeon1_2d_4',
        movieId: movieId,
        locationId: '0000008101',
        locationName: 'Sabay Cinema Aeon Phnom Penh (Aeon 1)',
        hallName: 'Hall 1',
        hallType: 'REGULAR HALL',
        experience: HallExperience.standard2D,
        startTime: DateTime(y, m, d, 21, 30), // 09:30 PM
        endTime: DateTime(y, m, d, 23, 45),
        basePrice: 2.50,
        totalSeats: 120,
        availableSeats: 30,
        languageSubtitle: 'EN / CH Sub',
        spokenLanguage: 'KH',
        subtitleLanguage: 'EN, CH',
      ),
      Showtime(
        id: 'st_aeon1_2d_5',
        movieId: movieId,
        locationId: '0000008101',
        locationName: 'Sabay Cinema Aeon Phnom Penh (Aeon 1)',
        hallName: 'Hall 1',
        hallType: 'REGULAR HALL',
        experience: HallExperience.standard2D,
        startTime: DateTime(y, m, d, 23, 15), // 11:15 PM
        endTime: DateTime(y, m, d, 25, 30),
        basePrice: 2.50,
        totalSeats: 120,
        availableSeats: 65,
        languageSubtitle: 'EN / CH Sub',
        spokenLanguage: 'KH',
        subtitleLanguage: 'EN, CH',
      ),

      // 2D - Vattanac Gold Class (MAND Audio | KH, EN, CH Subtitles)
      Showtime(
        id: 'st_aeon1_vattanac_gold_1',
        movieId: movieId,
        locationId: '0000008101',
        locationName: 'Sabay Cinema Aeon Phnom Penh (Aeon 1)',
        hallName: 'Gold Suite',
        hallType: 'VATTANAC GOLD CLASS',
        experience: HallExperience.standard2D,
        startTime: DateTime(y, m, d, 18, 55), // 06:55 PM
        endTime: DateTime(y, m, d, 21, 10),
        basePrice: 8.00,
        totalSeats: 48,
        availableSeats: 22,
        languageSubtitle: 'KH / EN / CH Sub',
        spokenLanguage: 'MAND',
        subtitleLanguage: 'KH, EN, CH',
      ),

      // IMAX Laser Hall (EN Audio | KH Subtitles)
      Showtime(
        id: 'st_aeon1_imax_1',
        movieId: movieId,
        locationId: '0000008101',
        locationName: 'Sabay Cinema Aeon Phnom Penh (Aeon 1)',
        hallName: 'IMAX Laser Hall',
        hallType: 'IMAX LASER 4K',
        experience: HallExperience.imaxLaser,
        startTime: DateTime(y, m, d, 13, 15), // 01:15 PM
        endTime: DateTime(y, m, d, 15, 45),
        basePrice: 6.00,
        totalSeats: 260,
        availableSeats: 110,
        languageSubtitle: 'KH Sub',
        spokenLanguage: 'EN',
        subtitleLanguage: 'KH',
      ),
      Showtime(
        id: 'st_aeon1_imax_2',
        movieId: movieId,
        locationId: '0000008101',
        locationName: 'Sabay Cinema Aeon Phnom Penh (Aeon 1)',
        hallName: 'IMAX Laser Hall',
        hallType: 'IMAX LASER 4K',
        experience: HallExperience.imaxLaser,
        startTime: DateTime(y, m, d, 16, 45), // 04:45 PM
        endTime: DateTime(y, m, d, 19, 15),
        basePrice: 6.00,
        totalSeats: 260,
        availableSeats: 94,
        languageSubtitle: 'KH Sub',
        spokenLanguage: 'EN',
        subtitleLanguage: 'KH',
      ),
      Showtime(
        id: 'st_aeon1_imax_3',
        movieId: movieId,
        locationId: '0000008101',
        locationName: 'Sabay Cinema Aeon Phnom Penh (Aeon 1)',
        hallName: 'IMAX Laser Hall',
        hallType: 'IMAX LASER 4K',
        experience: HallExperience.imaxLaser,
        startTime: DateTime(y, m, d, 20, 15), // 08:15 PM
        endTime: DateTime(y, m, d, 22, 45),
        basePrice: 6.00,
        totalSeats: 260,
        availableSeats: 68,
        languageSubtitle: 'KH Sub',
        spokenLanguage: 'EN',
        subtitleLanguage: 'KH',
      ),

      // VIP Suite (EN Audio | KH, CH Subtitles)
      Showtime(
        id: 'st_aeon1_vip_1',
        movieId: movieId,
        locationId: '0000008101',
        locationName: 'Sabay Cinema Aeon Phnom Penh (Aeon 1)',
        hallName: 'VIP Suite 1',
        hallType: 'VIP GOLD SUITE',
        experience: HallExperience.vipGold,
        startTime: DateTime(y, m, d, 15, 30), // 03:30 PM
        endTime: DateTime(y, m, d, 18, 00),
        basePrice: 10.00,
        totalSeats: 40,
        availableSeats: 18,
        languageSubtitle: 'KH / CH Sub',
        spokenLanguage: 'EN',
        subtitleLanguage: 'KH, CH',
      ),
      Showtime(
        id: 'st_aeon1_vip_2',
        movieId: movieId,
        locationId: '0000008101',
        locationName: 'Sabay Cinema Aeon Phnom Penh (Aeon 1)',
        hallName: 'VIP Suite 1',
        hallType: 'VIP GOLD SUITE',
        experience: HallExperience.vipGold,
        startTime: DateTime(y, m, d, 19, 00), // 07:00 PM
        endTime: DateTime(y, m, d, 21, 30),
        basePrice: 10.00,
        totalSeats: 40,
        availableSeats: 12,
        languageSubtitle: 'KH / CH Sub',
        spokenLanguage: 'EN',
        subtitleLanguage: 'KH, CH',
      ),

      // ==================== Aeon Sen Sok (0000008104) ====================
      Showtime(
        id: 'st_aeon2_2d_1',
        movieId: movieId,
        locationId: '0000008104',
        locationName: 'Sabay Cinema Aeon Sen Sok (Aeon 2)',
        hallName: 'Hall 3',
        hallType: 'REGULAR HALL',
        experience: HallExperience.standard2D,
        startTime: DateTime(y, m, d, 13, 00),
        endTime: DateTime(y, m, d, 15, 15),
        basePrice: 2.50,
        totalSeats: 140,
        availableSeats: 80,
        languageSubtitle: 'EN / CH Sub',
        spokenLanguage: 'KH',
        subtitleLanguage: 'EN, CH',
      ),
      Showtime(
        id: 'st_aeon2_2d_2',
        movieId: movieId,
        locationId: '0000008104',
        locationName: 'Sabay Cinema Aeon Sen Sok (Aeon 2)',
        hallName: 'Hall 3',
        hallType: 'REGULAR HALL',
        experience: HallExperience.standard2D,
        startTime: DateTime(y, m, d, 16, 45),
        endTime: DateTime(y, m, d, 19, 00),
        basePrice: 2.50,
        totalSeats: 140,
        availableSeats: 62,
        languageSubtitle: 'EN / CH Sub',
        spokenLanguage: 'KH',
        subtitleLanguage: 'EN, CH',
      ),
      Showtime(
        id: 'st_aeon2_2d_3',
        movieId: movieId,
        locationId: '0000008104',
        locationName: 'Sabay Cinema Aeon Sen Sok (Aeon 2)',
        hallName: 'Hall 3',
        hallType: 'REGULAR HALL',
        experience: HallExperience.standard2D,
        startTime: DateTime(y, m, d, 20, 30),
        endTime: DateTime(y, m, d, 22, 45),
        basePrice: 2.50,
        totalSeats: 140,
        availableSeats: 45,
        languageSubtitle: 'EN / CH Sub',
        spokenLanguage: 'KH',
        subtitleLanguage: 'EN, CH',
      ),
      Showtime(
        id: 'st_aeon2_imax_1',
        movieId: movieId,
        locationId: '0000008104',
        locationName: 'Sabay Cinema Aeon Sen Sok (Aeon 2)',
        hallName: 'Hall 7 (IMAX Laser)',
        hallType: 'IMAX LASER 4K',
        experience: HallExperience.imaxLaser,
        startTime: DateTime(y, m, d, 14, 00),
        endTime: DateTime(y, m, d, 16, 30),
        basePrice: 6.00,
        totalSeats: 320,
        availableSeats: 145,
        languageSubtitle: 'KH Sub',
        spokenLanguage: 'EN',
        subtitleLanguage: 'KH',
      ),
      Showtime(
        id: 'st_aeon2_imax_2',
        movieId: movieId,
        locationId: '0000008104',
        locationName: 'Sabay Cinema Aeon Sen Sok (Aeon 2)',
        hallName: 'Hall 7 (IMAX Laser)',
        hallType: 'IMAX LASER 4K',
        experience: HallExperience.imaxLaser,
        startTime: DateTime(y, m, d, 18, 30),
        endTime: DateTime(y, m, d, 21, 00),
        basePrice: 6.00,
        totalSeats: 320,
        availableSeats: 112,
        languageSubtitle: 'KH Sub',
        spokenLanguage: 'EN',
        subtitleLanguage: 'KH',
      ),
      Showtime(
        id: 'st_aeon2_screenx_1',
        movieId: movieId,
        locationId: '0000008104',
        locationName: 'Sabay Cinema Aeon Sen Sok (Aeon 2)',
        hallName: 'Hall 5 (ScreenX)',
        hallType: 'SCREENX 270°',
        experience: HallExperience.screenX,
        startTime: DateTime(y, m, d, 15, 30),
        endTime: DateTime(y, m, d, 17, 45),
        basePrice: 5.00,
        totalSeats: 180,
        availableSeats: 62,
        languageSubtitle: 'KH / EN Sub',
        spokenLanguage: 'EN',
        subtitleLanguage: 'KH, EN',
      ),
      Showtime(
        id: 'st_aeon2_screenx_2',
        movieId: movieId,
        locationId: '0000008104',
        locationName: 'Sabay Cinema Aeon Sen Sok (Aeon 2)',
        hallName: 'Hall 5 (ScreenX)',
        hallType: 'SCREENX 270°',
        experience: HallExperience.screenX,
        startTime: DateTime(y, m, d, 19, 15),
        endTime: DateTime(y, m, d, 21, 30),
        basePrice: 5.00,
        totalSeats: 180,
        availableSeats: 48,
        languageSubtitle: 'KH / EN Sub',
        spokenLanguage: 'EN',
        subtitleLanguage: 'KH, EN',
      ),

      // ==================== Aeon Mall Mean Chey (0000008106) ====================
      Showtime(
        id: 'st_aeon3_2d_1',
        movieId: movieId,
        locationId: '0000008106',
        locationName: 'Sabay Cinema Aeon Mall Mean Chey (Aeon 3)',
        hallName: 'Hall 1',
        hallType: 'REGULAR HALL',
        experience: HallExperience.standard2D,
        startTime: DateTime(y, m, d, 14, 30),
        endTime: DateTime(y, m, d, 16, 45),
        basePrice: 2.50,
        totalSeats: 150,
        availableSeats: 92,
        languageSubtitle: 'EN / KH Sub',
        spokenLanguage: 'KH',
        subtitleLanguage: 'EN, KH',
      ),
      Showtime(
        id: 'st_aeon3_2d_2',
        movieId: movieId,
        locationId: '0000008106',
        locationName: 'Sabay Cinema Aeon Mall Mean Chey (Aeon 3)',
        hallName: 'Hall 1',
        hallType: 'REGULAR HALL',
        experience: HallExperience.standard2D,
        startTime: DateTime(y, m, d, 19, 00),
        endTime: DateTime(y, m, d, 21, 15),
        basePrice: 2.50,
        totalSeats: 150,
        availableSeats: 52,
        languageSubtitle: 'EN / KH Sub',
        spokenLanguage: 'KH',
        subtitleLanguage: 'EN, KH',
      ),
      Showtime(
        id: 'st_aeon3_screenx_1',
        movieId: movieId,
        locationId: '0000008106',
        locationName: 'Sabay Cinema Aeon Mall Mean Chey (Aeon 3)',
        hallName: 'Hall 3 (ScreenX)',
        hallType: 'SCREENX 270°',
        experience: HallExperience.screenX,
        startTime: DateTime(y, m, d, 16, 00),
        endTime: DateTime(y, m, d, 18, 15),
        basePrice: 5.00,
        totalSeats: 200,
        availableSeats: 88,
        languageSubtitle: 'EN / KH Sub',
        spokenLanguage: 'EN',
        subtitleLanguage: 'KH',
      ),

      // ==================== Sorya Center Point (0000008103) ====================
      Showtime(
        id: 'st_sorya_2d_1',
        movieId: movieId,
        locationId: '0000008103',
        locationName: 'Sabay Cinema Sorya Center Point',
        hallName: 'Hall 2',
        hallType: 'REGULAR HALL',
        experience: HallExperience.standard2D,
        startTime: DateTime(y, m, d, 11, 00),
        endTime: DateTime(y, m, d, 13, 15),
        basePrice: 2.50,
        totalSeats: 110,
        availableSeats: 64,
        languageSubtitle: 'EN / KH Sub',
        spokenLanguage: 'EN',
        subtitleLanguage: 'KH',
      ),
      Showtime(
        id: 'st_sorya_2d_2',
        movieId: movieId,
        locationId: '0000008103',
        locationName: 'Sabay Cinema Sorya Center Point',
        hallName: 'Hall 2',
        hallType: 'REGULAR HALL',
        experience: HallExperience.standard2D,
        startTime: DateTime(y, m, d, 14, 20),
        endTime: DateTime(y, m, d, 16, 35),
        basePrice: 2.50,
        totalSeats: 110,
        availableSeats: 55,
        languageSubtitle: 'EN / KH Sub',
        spokenLanguage: 'KH',
        subtitleLanguage: 'EN, CH',
      ),
      Showtime(
        id: 'st_sorya_2d_3',
        movieId: movieId,
        locationId: '0000008103',
        locationName: 'Sabay Cinema Sorya Center Point',
        hallName: 'Hall 2',
        hallType: 'REGULAR HALL',
        experience: HallExperience.standard2D,
        startTime: DateTime(y, m, d, 17, 45),
        endTime: DateTime(y, m, d, 20, 00),
        basePrice: 2.50,
        totalSeats: 110,
        availableSeats: 32,
        languageSubtitle: 'EN / KH Sub',
        spokenLanguage: 'KH',
        subtitleLanguage: 'EN, CH',
      ),

      // ==================== Siem Reap (0000008102) ====================
      Showtime(
        id: 'st_sr_2d_1',
        movieId: movieId,
        locationId: '0000008102',
        locationName: 'Sabay Cinema Siem Reap Heritage',
        hallName: 'Hall 1',
        hallType: 'REGULAR HALL',
        experience: HallExperience.standard2D,
        startTime: DateTime(y, m, d, 13, 00),
        endTime: DateTime(y, m, d, 15, 15),
        basePrice: 2.50,
        totalSeats: 120,
        availableSeats: 70,
        languageSubtitle: 'EN / KH Sub',
        spokenLanguage: 'EN',
        subtitleLanguage: 'KH',
      ),
      Showtime(
        id: 'st_sr_2d_2',
        movieId: movieId,
        locationId: '0000008102',
        locationName: 'Sabay Cinema Siem Reap Heritage',
        hallName: 'Hall 1',
        hallType: 'REGULAR HALL',
        experience: HallExperience.standard2D,
        startTime: DateTime(y, m, d, 16, 30),
        endTime: DateTime(y, m, d, 18, 45),
        basePrice: 2.50,
        totalSeats: 120,
        availableSeats: 51,
        languageSubtitle: 'EN / KH Sub',
        spokenLanguage: 'KH',
        subtitleLanguage: 'EN, CH',
      ),
      Showtime(
        id: 'st_sr_3d_1',
        movieId: movieId,
        locationId: '0000008102',
        locationName: 'Sabay Cinema Siem Reap Heritage',
        hallName: 'Hall 3 (3D)',
        hallType: 'STANDARD 3D',
        experience: HallExperience.standard3D,
        startTime: DateTime(y, m, d, 19, 15),
        endTime: DateTime(y, m, d, 21, 30),
        basePrice: 3.00,
        totalSeats: 120,
        availableSeats: 45,
        languageSubtitle: 'EN / KH Sub',
        spokenLanguage: 'EN',
        subtitleLanguage: 'KH',
      ),

      // ==================== Poipet (0000008105) ====================
      Showtime(
        id: 'st_poipet_2d_1',
        movieId: movieId,
        locationId: '0000008105',
        locationName: 'Sabay Cinema Big C Poipet',
        hallName: 'Hall 1',
        hallType: 'REGULAR HALL',
        experience: HallExperience.standard2D,
        startTime: DateTime(y, m, d, 14, 00),
        endTime: DateTime(y, m, d, 16, 15),
        basePrice: 2.50,
        totalSeats: 100,
        availableSeats: 58,
        languageSubtitle: 'EN / KH Sub',
        spokenLanguage: 'EN',
        subtitleLanguage: 'KH',
      ),
      Showtime(
        id: 'st_poipet_2d_2',
        movieId: movieId,
        locationId: '0000008105',
        locationName: 'Sabay Cinema Big C Poipet',
        hallName: 'Hall 1',
        hallType: 'REGULAR HALL',
        experience: HallExperience.standard2D,
        startTime: DateTime(y, m, d, 17, 30),
        endTime: DateTime(y, m, d, 19, 45),
        basePrice: 2.50,
        totalSeats: 100,
        availableSeats: 42,
        languageSubtitle: 'EN / KH Sub',
        spokenLanguage: 'KH',
        subtitleLanguage: 'EN, CH',
      ),
    ];

    if (locationId != null && locationId.isNotEmpty && locationId != 'all') {
      return allShowtimes.where((st) => st.locationId == locationId).toList();
    }

    return allShowtimes;
  }

  @override
  Future<List<Movie>> searchMovies(String query, {String? genre, String? ageRating}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    var results = _mockMovies.where((m) {
      final matchesQuery = query.isEmpty ||
          m.title.toLowerCase().contains(query.toLowerCase()) ||
          m.originalTitle.toLowerCase().contains(query.toLowerCase()) ||
          m.director.toLowerCase().contains(query.toLowerCase()) ||
          m.cast.any((c) => c.name.toLowerCase().contains(query.toLowerCase()));
      return matchesQuery;
    }).toList();

    if (genre != null && genre != 'All') {
      results = results.where((m) => m.genres.contains(genre)).toList();
    }
    if (ageRating != null && ageRating != 'All') {
      results = results.where((m) => m.ageRating == ageRating).toList();
    }
    return results;
  }
}
