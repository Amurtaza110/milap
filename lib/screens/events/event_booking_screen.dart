import 'package:flutter/material.dart';
import '../../models/social_event.dart';
import '../../models/user_profile.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class EventBookingScreen extends StatefulWidget {
  final SocialEvent event;
  final UserProfile user;
  final VoidCallback onBack;
  final VoidCallback onSuccess;

  const EventBookingScreen({
    Key? key,
    required this.event,
    required this.user,
    required this.onBack,
    required this.onSuccess,
  }) : super(key: key);

  @override
  State<EventBookingScreen> createState() => _EventBookingScreenState();
}

class _EventBookingScreenState extends State<EventBookingScreen> {
  int _step = 1;
  late String _selectedPkgId;
  int _quantity = 1;
  String _selectedPaymentMethod = 'card';
  bool _isProcessing = false;
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _recipientNameController =
      TextEditingController();
  bool _isGift = false;

  @override
  void initState() {
    super.initState();
    _selectedPkgId = widget.event.packages[0].id;
  }

  @override
  Widget build(BuildContext context) {
    if (_step == 3) return _buildPaymentView();
    if (_step == 4) return _buildSuccessView();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Column(
        children: [
          // Elegant Header
          _buildHeader(),

          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0F0F0F),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  children: [
                    _buildStepIndicator(),
                    const SizedBox(height: 24),
                    _step == 1
                        ? _buildStep1()
                        : _step == 2
                            ? _buildStep2()
                            : _buildPaymentMethodSelector(),
                  ],
                ),
              ),
            ),
          ),

          // Footer
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed:
                _step == 1 ? widget.onBack : () => setState(() => _step -= 1),
            icon: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Complete Booking',
                  style: AppTextStyles.h2.copyWith(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  widget.event.title.toUpperCase(),
                  style: AppTextStyles.label.copyWith(
                    fontSize: 10,
                    color: AppColors.primary.withOpacity(0.7),
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(3, (index) {
        final stepNum = index + 1;
        final isActive = _step >= stepNum;
        final isCurrent = _step == stepNum;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index == 2 ? 0 : 8),
            decoration: BoxDecoration(
              color:
                  isActive ? AppColors.primary : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionLabel('SELECT EXPERIENCE'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${widget.event.packages.length} PACKAGES',
                style: AppTextStyles.label.copyWith(
                  fontSize: 9,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...widget.event.packages.map((pkg) {
          final isSelected = _selectedPkgId == pkg.id;
          return GestureDetector(
            onTap: () => setState(() => _selectedPkgId = pkg.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.08)
                    : const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : Colors.white.withOpacity(0.05),
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pkg.name,
                          style: AppTextStyles.h4.copyWith(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          children: pkg.perks.map((perk) {
                            return Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                perk,
                                style: AppTextStyles.label.copyWith(
                                  fontSize: 9,
                                  color: Colors.white54,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'PKR',
                        style: AppTextStyles.label.copyWith(
                          fontSize: 9,
                          color:
                              isSelected ? AppColors.primary : Colors.white24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${pkg.price}',
                        style: AppTextStyles.h3.copyWith(
                          fontSize: 20,
                          color: isSelected ? AppColors.primary : Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 32),
        _buildSectionLabel('HOW MANY PASSES?'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildQtyBtn(Icons.remove_rounded, () {
                if (_quantity > 1) setState(() => _quantity--);
              }),
              Column(
                children: [
                  Text(
                    '$_quantity',
                    style: AppTextStyles.h2.copyWith(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    _quantity == 1 ? 'TICKET' : 'TICKETS',
                    style: AppTextStyles.label.copyWith(
                      fontSize: 9,
                      color: Colors.white38,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              _buildQtyBtn(Icons.add_rounded, () {
                setState(() => _quantity++);
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildStep2() {
    final pkg = widget.event.packages.firstWhere((p) => p.id == _selectedPkgId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('TICKET DETAILS'),
        const SizedBox(height: 16),
        _buildThemedField(
            _whatsappController, 'WhatsApp Number', Icons.phone_android_rounded,
            keyboardType: TextInputType.phone),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.card_giftcard_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Premium Gift',
                        style: AppTextStyles.h4
                            .copyWith(color: Colors.white, fontSize: 16)),
                    Text('Send ticket as a surprise gift',
                        style: AppTextStyles.label
                            .copyWith(color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ),
              Switch(
                value: _isGift,
                onChanged: (v) => setState(() => _isGift = v),
                activeColor: AppColors.primary,
                activeTrackColor: AppColors.primary.withOpacity(0.3),
              ),
            ],
          ),
        ),
        if (_isGift) ...[
          const SizedBox(height: 16),
          _buildThemedField(_recipientNameController, "Recipient's Name",
              Icons.person_outline_rounded),
        ],
        const SizedBox(height: 40),
        _buildSectionLabel('FINANCIAL SUMMARY'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A1A1A),
                const Color(0xFF151515),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              _buildSummaryRow('${pkg.name} Experience', 'PKR ${pkg.price}'),
              _buildSummaryRow('Quantity', 'x$_quantity'),
              _buildSummaryRow('Service Fees (Exclusive)',
                  'PKR ${(pkg.price * _quantity * 0.05).round()}'),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1, color: Colors.white10),
              ),
              _buildSummaryRow('TOTAL PAYABLE', 'PKR ${_calculateTotal()}',
                  isBold: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.label.copyWith(
        fontSize: 10,
        color: Colors.white38,
        letterSpacing: 2.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildThemedField(
      TextEditingController controller, String hint, IconData icon,
      {TextInputType? keyboardType}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isBold
                ? AppTextStyles.h4.copyWith(color: Colors.white, fontSize: 16)
                : AppTextStyles.body
                    .copyWith(color: Colors.white60, fontSize: 14),
          ),
          Text(
            value,
            style: isBold
                ? AppTextStyles.h3.copyWith(
                    fontSize: 22,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900)
                : AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 15),
          )
        ],
      ),
    );
  }

  int _calculateTotal() {
    final pkg = widget.event.packages.firstWhere((p) => p.id == _selectedPkgId);
    final subtotal = pkg.price * _quantity;
    return (subtotal * 1.05).round();
  }

  Widget _buildPaymentMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('SELECT PAYMENT GATEWAY'),
        const SizedBox(height: 20),
        _buildPaymentOption(
          'card',
          Icons.credit_card_rounded,
          'Instant Checkout',
          'Visa, Mastercard, AMEX',
        ),
        const SizedBox(height: 12),
        _buildPaymentOption(
          'bank',
          Icons.account_balance_rounded,
          'Bank Direct',
          'Secure wire transfer',
        ),
        const SizedBox(height: 12),
        _buildPaymentOption(
          'ewallet',
          Icons.account_balance_wallet_rounded,
          'Mobile Wallets',
          'Easypaisa, JazzCash, Zap',
        ),
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              const Icon(Icons.security_rounded,
                  color: AppColors.success, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'End-to-end encrypted payment processing. Your credentials are never stored.',
                  style: AppTextStyles.label.copyWith(
                    fontSize: 9,
                    color: Colors.white38,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption(
      String id, IconData icon, String title, String subtitle) {
    final isSelected = _selectedPaymentMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.08)
              : const Color(0xFF1A1A1A),
          border: Border.all(
            color:
                isSelected ? AppColors.primary : Colors.white.withOpacity(0.05),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon,
                  color: isSelected ? AppColors.primary : Colors.white70,
                  size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.base.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontSize: 16,
                      )),
                  Text(subtitle,
                      style: AppTextStyles.label.copyWith(
                        color: Colors.white38,
                        fontSize: 12,
                      )),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 24)
            else
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white10, width: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_step > 1) ...[
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('TOTAL',
                      style: AppTextStyles.label
                          .copyWith(fontSize: 8, color: Colors.white38)),
                  Text('PKR ${_calculateTotal()}',
                      style: AppTextStyles.h3.copyWith(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 60,
              child: ElevatedButton(
                onPressed: _isProcessing
                    ? null
                    : () {
                        if (_step < 3) {
                          setState(() => _step += 1);
                        } else {
                          _processPayment();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 8,
                  shadowColor: AppColors.primary.withOpacity(0.4),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      )
                    : Text(
                        _step == 3 ? 'PAY NOW' : 'CONTINUE',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          fontSize: 14,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _processPayment() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _isProcessing = false;
      _step = 4;
    });
  }

  Widget _buildPaymentView() {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 24),
            Text('Finalizing Secure Payment...',
                style: AppTextStyles.h4.copyWith(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.success.withOpacity(0.2)),
                ),
                child: const Icon(Icons.check_rounded,
                    color: AppColors.success, size: 60),
              ),
              const SizedBox(height: 40),
              Text("BOOKING CONFIRMED!",
                  style: AppTextStyles.h1.copyWith(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5)),
              const SizedBox(height: 16),
              Text(
                  'Your digital pass has been added to your wallet successfully.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                      color: Colors.white54, fontSize: 15, height: 1.5)),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: widget.onSuccess,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('VIEW MY TICKETS',
                      style: TextStyle(
                          fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
