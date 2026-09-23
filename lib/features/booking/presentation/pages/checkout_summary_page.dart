import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/responsive_shell.dart';
import '../../../../core/widgets/soft_button.dart';
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
  final TextEditingController _nameController =
      TextEditingController(text: 'Chhorda Lim');
  final TextEditingController _phoneController =
      TextEditingController(text: '+855 12 345 678');
  final TextEditingController _emailController =
      TextEditingController(text: 'lim.chhorda@sabay.com');

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'ABA KHQR',
      'title': 'ABA PAY / KHQR',
      'subtitle': 'Scan with ABA Mobile or Bakong',
      'icon': Icons.qr_code_2_rounded,
      'isPopular': true,
      'badge': 'KHQR',
      'badgeColor': AppColors.secondary,
    },
    {
      'id': 'Credit Card',
      'title': 'Credit or Debit Card',
      'subtitle': 'Visa, Mastercard, JCB',
      'icon': Icons.credit_card_rounded,
      'isPopular': false,
      'badge': 'Cards',
      'badgeColor': AppColors.accentCyan,
    },
    {
      'id': 'Wing Bank',
      'title': 'Wing Bank / WingPay',
      'subtitle': 'Wing App or Account',
      'icon': Icons.account_balance_wallet_rounded,
      'isPopular': false,
      'badge': null,
      'badgeColor': null,
    },
    {
      'id': 'Apple Pay',
      'title': 'Apple Pay',
      'subtitle': 'One-touch biometric checkout',
      'icon': Icons.apple_rounded,
      'isPopular': false,
      'badge': null,
      'badgeColor': null,
    },
  ];

  @override
  void dispose() {
    _promoController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onConfirmPay(BuildContext context, BookingState state) {
    context.read<BookingBloc>().add(
      UpdateCustomerInfoEvent(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
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

                return Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: ResponsiveShell.maxContentWidth,
                          ),
                          child: SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(
                              isDesktop ? 32 : 16,
                              isDesktop ? 24 : 16,
                              isDesktop ? 32 : 16,
                              isDesktop ? 40 : 20,
                            ),
                            child: isDesktop
                                ? _buildDesktopLayout(context, state)
                                : _buildMobileLayout(context, state),
                          ),
                        ),
                      ),
                    ),
                    if (!isDesktop) _buildMobileBottomBar(context, state),
                  ],
                );
              },
            ),
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
  // DESKTOP LAYOUT
  // ==========================================
  Widget _buildDesktopLayout(BuildContext context, BookingState state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column (Customer info, Payment, Promo, Security) - 58%
        Expanded(
          flex: 58,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Customer Information', Icons.person_outline_rounded),
              const SizedBox(height: 12),
              _buildContactGroupCard(),
              const SizedBox(height: 26),
              _buildSectionHeader('Payment Method', Icons.account_balance_wallet_outlined),
              const SizedBox(height: 12),
              _buildPaymentMethodsList(state),
              const SizedBox(height: 26),
              _buildSectionHeader('Promo Code', Icons.confirmation_number_outlined),
              const SizedBox(height: 12),
              _buildPromoSection(state),
              const SizedBox(height: 22),
              _buildSecurityTrustNotice(),
            ],
          ),
        ),
        const SizedBox(width: 32),

        // Right Column (Ticket Pass & Price Summary) - 42%
        Expanded(
          flex: 42,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Order Summary', Icons.receipt_long_rounded),
              const SizedBox(height: 12),
              _buildCinemaTicketPass(context, state),
              const SizedBox(height: 18),
              _buildOrderBreakdownCard(context, state, isDesktop: true),
            ],
          ),
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
        // 1. Cinema Ticket Pass
        _buildCinemaTicketPass(context, state),
        const SizedBox(height: 22),

        // 2. Customer Information
        _buildSectionHeader('Customer Information', Icons.person_outline_rounded),
        const SizedBox(height: 10),
        _buildContactGroupCard(),
        const SizedBox(height: 22),

        // 3. Payment Method Selection
        _buildSectionHeader('Payment Method', Icons.account_balance_wallet_outlined),
        const SizedBox(height: 10),
        _buildPaymentMethodsList(state),
        const SizedBox(height: 22),

        // 4. Promo Section
        _buildSectionHeader('Promo Code', Icons.confirmation_number_outlined),
        const SizedBox(height: 10),
        _buildPromoSection(state),
        const SizedBox(height: 22),

        // 5. Price Breakdown
        _buildOrderBreakdownCard(context, state, isDesktop: false),
        const SizedBox(height: 18),

        // 6. Security Note
        _buildSecurityTrustNotice(),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: AppColors.primaryLight),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // CINEMA TICKET PASS
  // ==========================================
  Widget _buildCinemaTicketPass(BuildContext context, BookingState state) {
    final movie = state.movie!;
    final showtime = state.showtime!;
    final seatCodes = state.selectedSeats.map((s) => s.seatCode).join(', ');
    final hasConcessions = state.selectedConcessions.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16161E),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.glassBorderSubtle, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Movie Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    movie.posterUrl,
                    width: 66,
                    height: 92,
                    fit: BoxFit.cover,
                    webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 66,
                      height: 92,
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
                      Wrap(
                        spacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppColors.secondary.withValues(alpha: 0.6),
                              ),
                            ),
                            child: Text(
                              movie.ageRating,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              showtime.experience.name.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primaryLight,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        movie.title,
                        style: AppTypography.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${showtime.locationName} • ${showtime.hallName}',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Dashed Divider Line
          _buildTicketPerforation(),

          // Key Booking Parameters (Date, Time, Seats)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                _buildTicketInfoCell(
                  label: 'DATE',
                  value: Formatters.formatDate(showtime.startTime),
                  icon: Icons.calendar_today_rounded,
                ),
                _buildVerticalSeparator(),
                _buildTicketInfoCell(
                  label: 'TIME',
                  value: Formatters.formatTime(showtime.startTime),
                  icon: Icons.access_time_filled_rounded,
                ),
                _buildVerticalSeparator(),
                _buildTicketInfoCell(
                  label: 'SEATS (${state.totalSeatCount})',
                  value: seatCodes,
                  icon: Icons.chair_rounded,
                  highlight: true,
                ),
              ],
            ),
          ),

          // Concessions Row (Optional Add/Edit)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLighter.withValues(alpha: 0.35),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
              border: const Border(
                top: BorderSide(color: AppColors.glassBorderSubtle, width: 1),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.fastfood_outlined,
                  size: 17,
                  color: AppColors.accentGold,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hasConcessions
                        ? '${state.selectedConcessions.values.fold<int>(0, (sum, i) => sum + i.quantity)} Snacks (${Formatters.formatCurrency(state.concessionSubtotal)})'
                        : 'Snacks & Drinks',
                    style: TextStyle(
                      color: hasConcessions ? Colors.white : AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: hasConcessions ? FontWeight.w700 : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      hasConcessions ? 'Edit' : '+ Add',
                      style: const TextStyle(
                        color: AppColors.primaryLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketPerforation() {
    return SizedBox(
      height: 16,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 16,
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final boxWidth = constraints.constrainWidth();
                const dashWidth = 5.0;
                const dashSpace = 4.0;
                final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(dashCount, (_) {
                    return SizedBox(
                      width: dashWidth,
                      height: 1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.glassBorderSubtle,
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
          Container(
            width: 8,
            height: 16,
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketInfoCell({
    required String label,
    required String value,
    required IconData icon,
    bool highlight = false,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: highlight ? AppColors.accentGold : Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalSeparator() {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: AppColors.glassBorderSubtle,
    );
  }

  // ==========================================
  // CONTACT DETAILS (CLEAN GROUPED CARD)
  // ==========================================
  Widget _buildContactGroupCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLighter.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.glassBorderSubtle),
      ),
      child: Column(
        children: [
          _buildGroupedInputRow(
            controller: _nameController,
            label: 'FULL NAME',
            hint: 'Your name',
            icon: Icons.person_outline_rounded,
          ),
          const Divider(height: 1, color: AppColors.glassBorderSubtle),
          _buildGroupedInputRow(
            controller: _phoneController,
            label: 'PHONE NUMBER',
            hint: '+855 ...',
            icon: Icons.phone_iphone_rounded,
            keyboardType: TextInputType.phone,
          ),
          const Divider(height: 1, color: AppColors.glassBorderSubtle),
          _buildGroupedInputRow(
            controller: _emailController,
            label: 'EMAIL ADDRESS',
            hint: 'example@email.com',
            icon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedInputRow({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textTertiary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textTertiary,
                    letterSpacing: 0.4,
                  ),
                ),
                TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    border: InputBorder.none,
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
  // PAYMENT METHODS
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
    final badge = method['badge'] as String?;
    final badgeColor = method['badgeColor'] as Color?;

    return GestureDetector(
      onTap: () {
        context.read<BookingBloc>().add(
          SelectPaymentMethodEvent(method['id'] as String),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.14)
              : AppColors.surfaceLighter.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.glassBorderSubtle,
            width: isSelected ? 1.2 : 1.0,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.4)
                      : AppColors.glassBorderSubtle,
                ),
              ),
              child: Icon(
                method['icon'] as IconData,
                color: isSelected ? AppColors.primary : Colors.white70,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Titles
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        method['title'] as String,
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontSize: 14.5,
                        ),
                      ),
                      if (badge != null && badgeColor != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: badgeColor.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: badgeColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    method['subtitle'] as String,
                    style: AppTypography.bodySmall.copyWith(
                      fontSize: 12,
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

            // Radio Indicator
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.textTertiary,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, size: 13, color: Colors.black)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // PROMO CODE
  // ==========================================
  Widget _buildPromoSection(BookingState state) {
    final hasAppliedPromo =
        state.promoCode.isNotEmpty && state.discountAmount > 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLighter.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorderSubtle),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _promoController,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter promo code (e.g. SABAY20)',
                    hintStyle: const TextStyle(
                      color: Colors.white30,
                      fontSize: 13,
                      letterSpacing: 0,
                      fontWeight: FontWeight.normal,
                    ),
                    prefixIcon: const Icon(
                      Icons.discount_outlined,
                      size: 18,
                      color: AppColors.textTertiary,
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 20,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 38,
                child: SoftButton(
                  text: 'Apply',
                  height: 38,
                  borderRadius: 12,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  onPressed: () => _applyPromoCode(context),
                ),
              ),
            ],
          ),
          if (hasAppliedPromo) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF10B981),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Code "${state.promoCode}" applied (-${Formatters.formatCurrency(state.discountAmount)})',
                      style: const TextStyle(
                        color: Color(0xFF34D399),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
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

  // ==========================================
  // ORDER BREAKDOWN & GRAND TOTAL
  // ==========================================
  Widget _buildOrderBreakdownCard(
    BuildContext context,
    BookingState state, {
    required bool isDesktop,
  }) {
    final hasConcessions = state.selectedConcessions.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16161E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorderSubtle),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Breakdown',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 14),

          // Movie Tickets
          _buildBreakdownRow(
            'Movie Tickets (${state.totalSeatCount}x)',
            Formatters.formatCurrency(state.ticketSubtotal),
          ),

          // Concessions
          if (hasConcessions) ...[
            const SizedBox(height: 8),
            _buildBreakdownRow(
              'Snacks & Beverages',
              Formatters.formatCurrency(state.concessionSubtotal),
            ),
          ],

          // Booking Fee
          const SizedBox(height: 8),
          _buildBreakdownRow(
            'Convenience & Booking Fee',
            'FREE',
            valueColor: const Color(0xFF10B981),
          ),

          // Promo Discount
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
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Total Amount',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              Text(
                Formatters.formatCurrency(state.totalAmount),
                style: AppTypography.displayMedium.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.accentGold,
                  fontSize: 26,
                ),
              ),
            ],
          ),

          // Desktop Confirm Button
          if (isDesktop) ...[
            const SizedBox(height: 20),
            SoftButton(
              text: 'Pay ${Formatters.formatCurrency(state.totalAmount)} & Confirm',
              icon: Icons.lock_outline_rounded,
              height: 52,
              borderRadius: 16,
              onPressed: () => _onConfirmPay(context, state),
            ),
          ],
        ],
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
            fontSize: 13.5,
          ),
        ),
        Text(
          value,
          style: AppTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor ?? Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // SECURITY & TRUST
  // ==========================================
  Widget _buildSecurityTrustNotice() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLighter.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorderSubtle),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.verified_user_outlined,
            size: 18,
            color: AppColors.accentCyan,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '256-bit SSL encrypted. Instant E-Ticket delivery.',
              style: AppTypography.bodySmall.copyWith(
                fontSize: 11.5,
                color: AppColors.textTertiary,
              ),
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
