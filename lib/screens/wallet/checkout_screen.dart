import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class CheckoutScreen extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback onBack;
  final Function(String method) onPaymentSuccess;

  const CheckoutScreen({
    Key? key,
    required this.item,
    required this.onBack,
    required this.onPaymentSuccess,
  }) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedMethod = 'card';
  bool _isLoading = false;

  void _processPayment() async {
    setState(() => _isLoading = true);
    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() => _isLoading = false);
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.milapPlusSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: AppColors.success, size: 40),
              ),
              const SizedBox(height: 24),
              Text('Payment Successful!',
                  style: AppTextStyles.h3.copyWith(color: Colors.white)),
              const SizedBox(height: 8),
              Text('Your transaction was complete.',
                  style: AppTextStyles.body
                      .copyWith(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    widget.onPaymentSuccess(_selectedMethod);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.milapPlusPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text('DONE',
                      style: AppTextStyles.label.copyWith(color: Colors.black)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: widget.onBack,
          icon: const Icon(Icons.close_rounded, color: Colors.white),
        ),
        title: Text('Checkout',
            style: AppTextStyles.h4.copyWith(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildItemSummary(),
            const SizedBox(height: 40),
            Text('CHOOSE PAYMENT METHOD',
                style: AppTextStyles.label
                    .copyWith(color: Colors.white30, fontSize: 10)),
            const SizedBox(height: 20),
            _buildPaymentOption('card', 'Credit/Debit Card', 'Visa, Mastercard',
                Icons.credit_card_rounded, Colors.blue),
            _buildPaymentOption('easypaisa', 'EasyPaisa', 'Mobile Wallet',
                Icons.account_balance_wallet_rounded, Colors.green),
            _buildPaymentOption('jazzcash', 'JazzCash', 'Mobile Wallet',
                Icons.payments_rounded, Colors.red),
            const SizedBox(height: 40),
            _buildSecureBadge(),
          ],
        ),
      ),
      bottomNavigationBar: _buildPayButton(),
    );
  }

  Widget _buildItemSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.milapPlusSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.milapPlusPrimary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.milapPlusPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(widget.item['icon'] ?? '💰',
                  style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.item['name'],
                    style: AppTextStyles.h4.copyWith(color: Colors.white)),
                Text(widget.item['description'] ?? '',
                    style: AppTextStyles.body
                        .copyWith(color: Colors.white30, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(widget.item['price_display'],
                  style: AppTextStyles.h4
                      .copyWith(color: AppColors.milapPlusPrimary)),
              Text('Total',
                  style: AppTextStyles.label
                      .copyWith(color: Colors.white24, fontSize: 8)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
      String id, String name, String subtitle, IconData icon, Color color) {
    final isSelected = _selectedMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color:
              isSelected ? color.withOpacity(0.05) : AppColors.milapPlusSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected ? color : Colors.white.withOpacity(0.05),
              width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? color : Colors.white24, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: AppTextStyles.body.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style: AppTextStyles.label.copyWith(
                          color: Colors.white24,
                          letterSpacing: 0,
                          fontSize: 9)),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSecureBadge() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shield_rounded,
                color: Colors.green.withOpacity(0.5), size: 14),
            const SizedBox(width: 8),
            Text('SECURE 256-BIT ENCRYPTED PAYMENT',
                style: AppTextStyles.label
                    .copyWith(color: Colors.white24, fontSize: 8)),
          ],
        ),
      ),
    );
  }

  Widget _buildPayButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.milapPlusPrimary,
          padding: const EdgeInsets.symmetric(vertical: 20),
          disabledBackgroundColor: AppColors.milapPlusSurface,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.black))
            : Text('PAY ${widget.item['price_display']}',
                style: AppTextStyles.label.copyWith(
                    color: Colors.black, fontWeight: FontWeight.w900)),
      ),
    );
  }
}
