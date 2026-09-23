import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class SignInDialog extends StatefulWidget {
  final VoidCallback? onSignedIn;

  const SignInDialog({super.key, this.onSignedIn});

  static Future<bool> show(BuildContext context, {VoidCallback? onSignedIn}) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<AuthCubit>(),
        child: SignInDialog(onSignedIn: onSignedIn),
      ),
    );
    return result ?? false;
  }

  @override
  State<SignInDialog> createState() => _SignInDialogState();
}

class _SignInDialogState extends State<SignInDialog> {
  int _selectedTabIndex = 0; // 0: Phone, 1: Email
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();

  final String _countryCode = '+855';

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  void _onSendPhoneOtp() {
    final phone = _phoneController.text.trim();
    final fullNumber = '$_countryCode $phone';
    context.read<AuthCubit>().sendPhoneOtp(fullNumber);
  }

  void _onSendEmailOtp() {
    final email = _emailController.text.trim();
    context.read<AuthCubit>().sendEmailOtp(email);
  }

  Future<void> _onVerifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length < 6) return;

    final success = await context.read<AuthCubit>().verifyOtp(otp);
    if (success && mounted) {
      Navigator.of(context).pop(true);
      widget.onSignedIn?.call();
    }
  }

  void _autoFillDemoCode() {
    _otpController.text = '123456';
    setState(() {});
    _onVerifyOtp();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthOtpSent) {
          _otpController.clear();
          Future.delayed(const Duration(milliseconds: 150), () {
            if (mounted) _otpFocusNode.requestFocus();
          });
        }
      },
      builder: (context, state) {
        final isOtpStep = state is AuthOtpSent ||
            (state is AuthError && state.previousState is AuthOtpSent);

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF140306), // Deep cinema dark burgundy
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.glassBorder.withValues(alpha: 0.3),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.8),
                    blurRadius: 36,
                    offset: const Offset(0, 16),
                  ),
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 40,
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  child: isOtpStep
                      ? _buildOtpVerificationView(context, state)
                      : _buildInputMethodsView(context, state),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ==================== 1. PHONE & EMAIL INPUT VIEW ====================
  Widget _buildInputMethodsView(BuildContext context, AuthState state) {
    final isLoading = state is AuthLoading;
    final errorMessage = state is AuthError ? state.message : null;

    return SingleChildScrollView(
      key: const ValueKey('input_methods_view'),
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top bar: Cinema icon & Close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                  ),
                ),
                child: const Icon(
                  Icons.local_activity_rounded,
                  color: AppColors.primaryLight,
                  size: 22,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                onPressed: () => Navigator.of(context).pop(false),
                splashRadius: 20,
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Title & Subtitle
          Text(
            'Sign In to Continue',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Enter your phone number or email to book your showtime tickets.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // ==================== TWO TABS SWITCHER ====================
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton(
                    index: 0,
                    label: 'Phone Number',
                    icon: Icons.phone_iphone_rounded,
                  ),
                ),
                Expanded(
                  child: _buildTabButton(
                    index: 1,
                    label: 'Email',
                    icon: Icons.mail_outline_rounded,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // ==================== TAB CONTENT ====================
          if (_selectedTabIndex == 0) ...[
            _buildPhoneInput(),
          ] else ...[
            _buildEmailInput(),
          ],

          if (errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, size: 16, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 26),

          // Primary Submit Button
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : (_selectedTabIndex == 0 ? _onSendPhoneOtp : _onSendEmailOtp),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
                shadowColor: AppColors.primary.withValues(alpha: 0.3),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Send OTP Code',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),

          // Notice
          Center(
            child: Text(
              'By signing in, you agree to Sabay Cinema Terms & Privacy',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedTabIndex == index;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.16)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.38)
                  : Colors.transparent,
              width: 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppColors.primary : AppColors.textTertiary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.09),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Country code picker badge (Cambodia default)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Text('🇰🇭', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      _countryCode,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Phone text input field
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: '096 888 9999',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      color: AppColors.textTertiary,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmailInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.09),
              width: 1,
            ),
          ),
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.alternate_email_rounded,
                color: AppColors.textTertiary,
                size: 20,
              ),
              hintText: 'example@gmail.com',
              hintStyle: GoogleFonts.plusJakartaSans(
                color: AppColors.textTertiary,
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== 2. OTP VERIFICATION VIEW ====================
  Widget _buildOtpVerificationView(BuildContext context, AuthState state) {
    final isLoading = state is AuthLoading;
    final errorMessage = state is AuthError ? state.message : null;

    final target = (state is AuthOtpSent)
        ? state.target
        : ((state is AuthError && state.previousState is AuthOtpSent)
            ? (state.previousState as AuthOtpSent).target
            : '');
    final resendSeconds = (state is AuthOtpSent)
        ? state.resendSeconds
        : ((state is AuthError && state.previousState is AuthOtpSent)
            ? (state.previousState as AuthOtpSent).resendSeconds
            : 0);

    return SingleChildScrollView(
      key: const ValueKey('otp_verification_view'),
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top bar: Back arrow to change target & Close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () {
                  context.read<AuthCubit>().cancelOtp();
                },
                splashRadius: 20,
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                onPressed: () => Navigator.of(context).pop(false),
                splashRadius: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Title & target display
          Text(
            'Verify Your Code',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'We sent a 6-digit verification code to:',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                target,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryLight,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => context.read<AuthCubit>().cancelOtp(),
                child: const Icon(
                  Icons.edit_rounded,
                  size: 15,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 6-digit OTP Input Boxes
          _buildOtpBoxes(),

          if (errorMessage != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, size: 16, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 18),

          // Quick Demo Code autofill pill
          GestureDetector(
            onTap: _autoFillDemoCode,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFE5A93C).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE5A93C).withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.bolt_rounded,
                    size: 16,
                    color: Color(0xFFE5A93C),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Tap to auto-fill demo OTP: 123456',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFE5A93C),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),

          // Submit Verify Button
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: isLoading ? null : _onVerifyOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
                shadowColor: AppColors.primary.withValues(alpha: 0.3),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Verify & Proceed to Seats',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),

          // Resend Code timer
          Center(
            child: resendSeconds > 0
                ? Text(
                    'Resend code in ${resendSeconds}s',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppColors.textTertiary,
                    ),
                  )
                : TextButton(
                    onPressed: () {
                      context.read<AuthCubit>().resendOtp();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryLight,
                      visualDensity: VisualDensity.compact,
                    ),
                    child: Text(
                      'Resend Code',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpBoxes() {
    return Stack(
      children: [
        // Invisible textfield to capture keyboard and clipboard inputs cleanly
        Opacity(
          opacity: 0,
          child: TextField(
            controller: _otpController,
            focusNode: _otpFocusNode,
            keyboardType: TextInputType.number,
            autofocus: true,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            onChanged: (val) {
              setState(() {});
              if (val.length == 6) {
                _onVerifyOtp();
              }
            },
          ),
        ),

        // Beautiful 6 PIN Boxes display
        GestureDetector(
          onTap: () => _otpFocusNode.requestFocus(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (i) {
              final text = _otpController.text;
              final digit = i < text.length ? text[i] : '';
              final isFocused = _otpFocusNode.hasFocus && (i == text.length || (i == 5 && text.length == 6));

              return Container(
                width: 48,
                height: 56,
                decoration: BoxDecoration(
                  color: digit.isNotEmpty
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : AppColors.surfaceElevated.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isFocused
                        ? AppColors.primary
                        : (digit.isNotEmpty
                            ? AppColors.primary.withValues(alpha: 0.5)
                            : AppColors.glassBorderSubtle),
                    width: isFocused ? 2 : 1.2,
                  ),
                  boxShadow: isFocused
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  digit,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
