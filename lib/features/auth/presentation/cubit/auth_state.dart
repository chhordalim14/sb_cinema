import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  bool get isAuthenticated => this is AuthAuthenticated;
  UserProfile? get currentUser => this is AuthAuthenticated ? (this as AuthAuthenticated).user : null;

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  final String? loadingMessage;
  const AuthLoading({this.loadingMessage});

  @override
  List<Object?> get props => [loadingMessage];
}

class AuthOtpSent extends AuthState {
  final String target;
  final bool isEmail;
  final String expectedOtp;
  final int resendSeconds;

  const AuthOtpSent({
    required this.target,
    required this.isEmail,
    required this.expectedOtp,
    this.resendSeconds = 30,
  });

  AuthOtpSent copyWith({
    String? target,
    bool? isEmail,
    String? expectedOtp,
    int? resendSeconds,
  }) {
    return AuthOtpSent(
      target: target ?? this.target,
      isEmail: isEmail ?? this.isEmail,
      expectedOtp: expectedOtp ?? this.expectedOtp,
      resendSeconds: resendSeconds ?? this.resendSeconds,
    );
  }

  @override
  List<Object?> get props => [target, isEmail, expectedOtp, resendSeconds];
}

class AuthAuthenticated extends AuthState {
  final UserProfile user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthError extends AuthState {
  final String message;
  final AuthState? previousState;

  const AuthError(this.message, {this.previousState});

  @override
  List<Object?> get props => [message, previousState];
}
