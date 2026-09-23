import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String name;
  final String? phoneNumber;
  final String? email;
  final bool isPhoneAuth;
  final String avatarUrl;

  const UserProfile({
    required this.id,
    required this.name,
    this.phoneNumber,
    this.email,
    required this.isPhoneAuth,
    this.avatarUrl = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80',
  });

  String get displayIdentifier => isPhoneAuth ? (phoneNumber ?? '') : (email ?? '');

  @override
  List<Object?> get props => [id, name, phoneNumber, email, isPhoneAuth, avatarUrl];
}
