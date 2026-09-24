import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/responsive_shell.dart';
import '../../../../core/widgets/soft_button.dart';
import '../../../../core/widgets/app_footer.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import '../widgets/payment_qr_dialog.dart';
import 'ticket_pass_page.dart';

class CheckoutSummaryPage extends StatefulWidget {
  const CheckoutSummaryPage({super.key});

  @override
  State<CheckoutSummaryPage> createState() => _CheckoutSummaryPageState();
}

class _CheckoutSummaryPageState extends State<CheckoutSummaryPage> {
  final TextEditingController _promoController = TextEditingController();

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'ABA KHQR',
      'title': 'ABA PAY / KHQR',
      'subtitle': 'Scan with ABA Mobile or Bakong',
      'icon': Icons.qr_code_2_rounded,
    },
    {
      'id': 'Credit Card',
      'title': 'Credit or Debit Card',
      'subtitle': 'Visa, Mastercard, JCB',
      'icon': Icons.credit_card_rounded,
    },
    {
      'id': 'Wing Bank',
      'title': 'Wing Bank / WingPay',
      'subtitle': 'Wing App or Account',
      'icon': Icons.account_balance_wallet_rounded,
    },
    {
      'id': 'Apple Pay',
      'title': 'Apple Pay',
      'subtitle': 'One-touch biometric checkout',
      'icon': Icons.apple_rounded,
    },
  ];

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _onConfirmPay(BuildContext context, BookingState state) {
    final authState = context.read<AuthCubit>().state;
    final user = authState.currentUser;
    final customerName = user?.name ?? state.customerName;
    final customerPhone = user?.phoneNumber ?? state.customerPhone;
    final customerEmail = user?.email ?? state.customerEmail;

    context.read<BookingBloc>().add(
      UpdateCustomerInfoEvent(
        name: customerName,
        phone: customerPhone,
        email: customerEmail,
      ),
    );

    if (state.paymentMethod == 'ABA KHQR') {
      PaymentQrDialog.show(
        context,
        amount: state.totalAmount,
        movieTitle: state.movie?.title ?? 'Sabay Cinema',
        onPaymentSuccess: () {
          context.read<BookingBloc>().add(ConfirmCheckoutEvent());
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const TicketPassPage()),
          );
        },
      );
    } else {
      context.read<BookingBloc>().add(ConfirmCheckoutEvent());
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const TicketPassPage()),
      );
    }
  }

  void _applyPromoCode(BuildContext context) {
    final code = _promoController.text.trim();
    if (code.isEmpty) return;
    context.read<BookingBloc>().add(ApplyPromoCodeEvent(code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('Voucher code "$code" applied!'),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveShell.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isDesktop ? null : _buildMobileAppBar(context),
      body: Column(
        children: [
          if (isDesktop) ...[
            ResponsiveShell.buildDesktopHeader(context, currentIndex: 0),
            _buildDesktopSubHeader(context),
          ],
          Expanded(
            child: BlocBuilder<BookingBloc, BookingState>(
              builder: (context, state) {
                final movie = state.movie;
                final showtime = state.showtime;

                if (movie == null || showtime == null) {
                  return const Center(
                    child: Text(
                      'Booking session expired',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                return CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          isDesktop ? 36 : 16,
                          isDesktop ? 26 : 16,
                          isDesktop ? 36 : 16,
                          isDesktop ? 40 : 20,
                        ),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 1040,
                            ),
                            child: isDesktop
                                ? _buildDesktopLayout(context, state)
                                : _buildMobileLayout(context, state),
                          ),
                        ),
                      ),
                    ),
                    if (isDesktop)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: AppFooter(),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          if (!isDesktop)
            BlocBuilder<BookingBloc, BookingState>(
              builder: (context, state) => _buildMobileBottomBar(context, state),
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildMobileAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surfaceGlass,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Review & Checkout',
        style: AppTypography.titleMedium.copyWith(
          fontWeight: FontWeight.w800,
          color: Colors.white,
          fontSize: 18,
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GlassCard(
          borderRadius: 14,
          padding: EdgeInsets.zero,
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopSubHeader(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: AppColors.surfaceGlass,
        border: Border(
          bottom: BorderSide(color: AppColors.glassBorderSubtle, width: 1),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: ResponsiveShell.maxContentWidth,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                GlassCard(
                  borderRadius: 14,
                  padding: const EdgeInsets.all(8),
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Review & Checkout',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // DESKTOP LAYOUT (CLEAN & BALANCED)
  // ==========================================
  Widget _buildDesktopLayout(BuildContext context, BookingState state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column (Payment & Promo) - 54%
        Expanded(
          flex: 54,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Payment Method'),
              const SizedBox(height: 12),
              _buildPaymentMethodsList(state),
              const SizedBox(height: 22),
              _buildSectionHeader('Promo Code'),
              const SizedBox(height: 12),
              _buildPromoSection(state),
              const SizedBox(height: 22),
              _buildAccountDeliveryNote(context, state),
            ],
          ),
        ),
        const SizedBox(width: 32),

        // Right Column (Unified Order Summary Card) - 46%
        Expanded(
          flex: 46,
          child: _buildUnifiedOrderSummaryCard(context, state, isDesktop: true),
        ),
      ],
    );
  }

  // ==========================================
  // MOBILE LAYOUT
  // ==========================================
  Widget _buildMobileLayout(BuildContext context, BookingState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUnifiedOrderSummaryCard(context, state, isDesktop: false),
        const SizedBox(height: 22),
        _buildSectionHeader('Payment Method'),
        const SizedBox(height: 12),
        _buildPaymentMethodsList(state),
        const SizedBox(height: 20),
        _buildSectionHeader('Promo Code'),
        const SizedBox(height: 12),
        _buildPromoSection(state),
        const SizedBox(height: 18),
        _buildAccountDeliveryNote(context, state),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTypography.titleMedium.copyWith(
        fontWeight: FontWeight.w700,
        color: Colors.white,
        fontSize: 15,
        letterSpacing: -0.2,
      ),
    );
  }

  // ==========================================
  // UNIFIED ORDER SUMMARY CARD (SOFT & MODERN)
  // ==========================================
  Widget _buildUnifiedOrderSummaryCard(
    BuildContext context,
    BookingState state, {
    required bool isDesktop,
  }) {
    final movie = state.movie!;
    final showtime = state.showtime!;
    final seatCodes = state.selectedSeats.map((s) => s.seatCode).join(', ');
    final hasConcessions = state.selectedConcessions.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLighter.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.glassBorderSubtle, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Movie Mini Banner
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  movie.posterUrl,
                  width: 58,
                  height: 82,
                  fit: BoxFit.cover,
                  webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 58,
                    height: 82,
                    color: AppColors.surfaceElevated,
                    child: const Icon(Icons.movie_rounded, color: Colors.white38),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            movie.ageRating,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            showtime.experience.name.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primaryLight,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      movie.title,
                      style: AppTypography.titleSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${showtime.locationName} • ${showtime.hallName}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Session Chips (Date, Time, Seats)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.glassBorderSubtle),
            ),
            child: Row(
              children: [
                _buildSessionChip(Icons.calendar_today_rounded, Formatters.formatDate(showtime.startTime)),
                _buildSessionDot(),
                _buildSessionChip(Icons.access_time_filled_rounded, Formatters.formatTime(showtime.startTime)),
                _buildSessionDot(),
                _buildSessionChip(Icons.chair_rounded, 'Seats $seatCodes', isHighlight: true),
              ],
            ),
          ),

          // Concessions Row (if any)
          if (hasConcessions) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.glassBorderSubtle),
              ),
              child: Row(
                children: [
                  const Icon(Icons.fastfood_outlined, size: 15, color: AppColors.accentGold),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${state.selectedConcessions.values.fold<int>(0, (sum, i) => sum + i.quantity)} Snacks Added',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    Formatters.formatCurrency(state.concessionSubtotal),
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 8),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Text(
                        'Edit',
                        style: TextStyle(
                          color: AppColors.primaryLight,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primaryLight.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          const Divider(color: AppColors.glassBorderSubtle, height: 1),
          const SizedBox(height: 14),

          // Price Breakdown
          _buildBreakdownRow(
            'Movie Tickets (${state.totalSeatCount}x)',
            Formatters.formatCurrency(state.ticketSubtotal),
          ),
          if (hasConcessions) ...[
            const SizedBox(height: 8),
            _buildBreakdownRow(
              'Snacks & Beverages',
              Formatters.formatCurrency(state.concessionSubtotal),
            ),
          ],
          if (state.discountAmount > 0) ...[
            const SizedBox(height: 8),
            _buildBreakdownRow(
              'Voucher Discount (${state.promoCode})',
              '-${Formatters.formatCurrency(state.discountAmount)}',
              valueColor: const Color(0xFF10B981),
            ),
          ],

          const SizedBox(height: 14),
          const Divider(color: AppColors.glassBorderSubtle, height: 1),
          const SizedBox(height: 14),

          // Total Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                Formatters.formatCurrency(state.totalAmount),
                style: const TextStyle(
                  color: AppColors.accentGold,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          // Desktop Pay Button & Security Reassurance
          if (isDesktop) ...[
            const SizedBox(height: 20),
            SoftButton(
              text: 'Pay ${Formatters.formatCurrency(state.totalAmount)} & Confirm',
              icon: Icons.lock_outline_rounded,
              height: 50,
              borderRadius: 16,
              onPressed: () => _onConfirmPay(context, state),
            ),
            const SizedBox(height: 12),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shield_outlined, size: 14, color: AppColors.textTertiary),
                  const SizedBox(width: 6),
                  Text(
                    '256-bit encrypted • Instant E-Ticket delivery',
                    style: AppTypography.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSessionChip(IconData icon, String text, {bool isHighlight = false}) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: isHighlight ? AppColors.accentGold : AppColors.textTertiary),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
                color: isHighlight ? AppColors.accentGold : Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionDot() {
    return Container(
      width: 3,
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: const BoxDecoration(
        color: AppColors.textTertiary,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: AppTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor ?? Colors.white,
            fontSize: 13.5,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // PAYMENT METHODS (SOFT & MODERN)
  // ==========================================
  Widget _buildPaymentMethodsList(BookingState state) {
    return Column(
      children: _paymentMethods.map((m) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildPaymentOptionCard(m, state),
        );
      }).toList(),
    );
  }

  Widget _buildPaymentOptionCard(Map<String, dynamic> method, BookingState state) {
    final isSelected = state.paymentMethod == method['id'];

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          context.read<BookingBloc>().add(
            SelectPaymentMethodEvent(method['id'] as String),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.surfaceLighter.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.glassBorderSubtle,
              width: 1.0,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Soft Icon Container
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : AppColors.surfaceElevated.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  method['icon'] as IconData,
                  color: isSelected ? AppColors.primary : Colors.white70,
                  size: 19,
                ),
              ),
              const SizedBox(width: 12),

              // Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method['title'] as String,
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      method['subtitle'] as String,
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 11.5,
                        color: isSelected
                            ? AppColors.primaryLight
                            : AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Radio Check Indicator
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.textTertiary,
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check_rounded, size: 12, color: Colors.black)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // PROMO CODE (CLEAN & SOFT)
  // ==========================================
  Widget _buildPromoSection(BookingState state) {
    final hasAppliedPromo =
        state.promoCode.isNotEmpty && state.discountAmount > 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLighter.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorderSubtle),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          const Icon(
            Icons.discount_outlined,
            size: 18,
            color: AppColors.textTertiary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _promoController,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              decoration: const InputDecoration(
                hintText: 'Promo code (e.g. SABAY20)',
                hintStyle: TextStyle(
                  color: Colors.white24,
                  fontSize: 13,
                  letterSpacing: 0,
                  fontWeight: FontWeight.normal,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SoftButton(
            text: hasAppliedPromo ? 'Applied' : 'Apply',
            height: 34,
            borderRadius: 10,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            onPressed: () => _applyPromoCode(context),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ACCOUNT & DIGITAL DELIVERY NOTE (SOFT PILL)
  // ==========================================
  Widget _buildAccountDeliveryNote(BuildContext context, BookingState state) {
    final authState = context.watch<AuthCubit>().state;
    final user = authState.currentUser;
    final userName = user?.name ?? state.customerName;
    final userIdentifier = user?.displayIdentifier.isNotEmpty == true
        ? user!.displayIdentifier
        : (state.customerEmail.isNotEmpty ? state.customerEmail : state.customerPhone);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLighter.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.14),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: const Icon(
              Icons.confirmation_number_outlined,
              size: 16,
              color: AppColors.primaryLight,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Account: $userName',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (userIdentifier.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(
                        '($userIdentifier)',
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'E-Tickets & QR pass will be linked to your account in My Tickets',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // MOBILE BOTTOM BAR
  // ==========================================
  Widget _buildMobileBottomBar(BuildContext context, BookingState state) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        border: const Border(
          top: BorderSide(color: AppColors.glassBorder, width: 1.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.65),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Amount',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                    Text(
                      Formatters.formatCurrency(state.totalAmount),
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.accentGold,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              SoftButton(
                text: 'Pay & Confirm',
                icon: Icons.lock_outline_rounded,
                height: 50,
                borderRadius: 16,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                onPressed: () => _onConfirmPay(context, state),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
