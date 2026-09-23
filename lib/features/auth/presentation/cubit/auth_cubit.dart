import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_profile.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  Timer? _countdownTimer;

  AuthCubit() : super(const AuthInitial());

  Future<void> sendPhoneOtp(String phone) async {
    final cleaned = phone.trim();
    if (cleaned.isEmpty || cleaned.length < 8) {
      emit(const AuthError('Please enter a valid phone number'));
      return;
    }

    emit(const AuthLoading(loadingMessage: 'Sending SMS verification code...'));
    await Future.delayed(const Duration(milliseconds: 600));

    const demoOtp = '123456';
    emit(AuthOtpSent(
      target: cleaned,
      isEmail: false,
      expectedOtp: demoOtp,
      resendSeconds: 30,
    ));

    _startCountdown();
  }

  Future<void> sendEmailOtp(String email) async {
    final cleaned = email.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (cleaned.isEmpty || !emailRegex.hasMatch(cleaned)) {
      emit(const AuthError('Please enter a valid email address'));
      return;
    }

    emit(const AuthLoading(loadingMessage: 'Sending email verification code...'));
    await Future.delayed(const Duration(milliseconds: 600));

    const demoOtp = '123456';
    emit(AuthOtpSent(
      target: cleaned,
      isEmail: true,
      expectedOtp: demoOtp,
      resendSeconds: 30,
    ));

    _startCountdown();
  }

  Future<bool> verifyOtp(String enteredOtp) async {
    final currentState = state;
    AuthOtpSent? otpState;

    if (currentState is AuthOtpSent) {
      otpState = currentState;
    } else if (currentState is AuthError && currentState.previousState is AuthOtpSent) {
      otpState = currentState.previousState as AuthOtpSent;
    }

    if (otpState == null) {
      emit(const AuthError('Session expired. Please request a new code.'));
      return false;
    }

    emit(const AuthLoading(loadingMessage: 'Verifying code...'));
    await Future.delayed(const Duration(milliseconds: 500));

    final trimmed = enteredOtp.trim();
    if (trimmed == otpState.expectedOtp || trimmed == '123456') {
      _countdownTimer?.cancel();
      final displayName = otpState.isEmail
          ? otpState.target.split('@')[0]
          : 'VIP ${otpState.target.substring(otpState.target.length - 4)}';

      final user = UserProfile(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        name: displayName,
        phoneNumber: otpState.isEmail ? null : otpState.target,
        email: otpState.isEmail ? otpState.target : null,
        isPhoneAuth: !otpState.isEmail,
      );

      emit(AuthAuthenticated(user));
      return true;
    } else {
      emit(AuthError(
        'Incorrect OTP code. Please enter the 6-digit code or tap 123456.',
        previousState: otpState,
      ));
      return false;
    }
  }

  void resendOtp() {
    final currentState = state;
    if (currentState is AuthOtpSent) {
      emit(currentState.copyWith(resendSeconds: 30));
      _startCountdown();
    } else if (currentState is AuthError && currentState.previousState is AuthOtpSent) {
      final prev = currentState.previousState as AuthOtpSent;
      emit(prev.copyWith(resendSeconds: 30));
      _startCountdown();
    }
  }

  void cancelOtp() {
    _countdownTimer?.cancel();
    emit(const AuthInitial());
  }

  void signOut() {
    _countdownTimer?.cancel();
    emit(const AuthInitial());
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final current = state;
      if (current is AuthOtpSent) {
        if (current.resendSeconds > 0) {
          emit(current.copyWith(resendSeconds: current.resendSeconds - 1));
        } else {
          timer.cancel();
        }
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    return super.close();
  }
}
