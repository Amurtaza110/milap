import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../wallet/checkout_screen.dart';

class UpgradeGoldScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onUpgrade;

  const UpgradeGoldScreen({
    Key? key,
    required this.onBack,
    required this.onUpgrade,
  }) : super(key: key);

  @override
  State<UpgradeGoldScreen> createState() => _UpgradeGoldScreenState();
}

class _UpgradeGoldScreenState extends State<UpgradeGoldScreen> {
  void _openCheckout() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          item: const {
            'id': 'milap_gold_monthly',
            'name': 'Milap Gold',
            'description': '1 Month Subscription • Premium Benefits',
            'price': 950,
            'price_display': 'PKR 950',
            'icon': '👑',
          },
          onBack: () => Navigator.pop(context),
          onPaymentSuccess: (method) {
            Navigator.pop(context); // Close checkout
            widget.onUpgrade(); // Notify success
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.milapPlusPrimary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
          ),

          // Header
          Positioned(
            top: 64,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: widget.onBack,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.close_rounded,
                        size: 20, color: Colors.white),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.milapPlusPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.milapPlusPrimary.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 14, color: AppColors.milapPlusPrimary),
                      const SizedBox(width: 4),
                      Text('PREMIUM',
                          style: AppTextStyles.label.copyWith(
                              color: AppColors.milapPlusPrimary,
                              fontSize: 9,
                              fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 120, 24, 0),
            child: _buildBenefits(),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefits() {
    final benefits = [
      {
        'title': 'Soul Radar+',
        'desc': 'See who liked your profile instantly.',
        'icon': '⚡'
      },
      {
        'title': 'Unlimited Vibes',
        'desc': 'No limits on matches or connections.',
        'icon': '🔥'
      },
      {
        'title': 'Priority Profile',
        'desc': 'Get 5x more visibility in your city.',
        'icon': '🔝'
      },
      {
        'title': 'Milap Vault Pro',
        'desc': 'Encrypted storage for high-res videos.',
        'icon': '🔐'
      },
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.milapPlusSurface,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                    color: AppColors.milapPlusPrimary.withOpacity(0.2),
                    blurRadius: 30)
              ],
              border: Border.all(
                  color: AppColors.milapPlusPrimary.withOpacity(0.2)),
            ),
            child:
                const Center(child: Text('👑', style: TextStyle(fontSize: 44))),
          ),
          const SizedBox(height: 24),
          Text('Milap Gold',
              style:
                  AppTextStyles.h1.copyWith(fontSize: 36, color: Colors.white)),
          const SizedBox(height: 8),
          Text('THE ULTIMATE SOUL-MAPPING EXPERIENCE',
              style: AppTextStyles.label.copyWith(
                  color: Colors.white30, letterSpacing: 1.5, fontSize: 9)),
          const SizedBox(height: 40),
          ...benefits.map((b) => _buildBenefitCard(b)).toList(),
          const SizedBox(height: 40),
          _buildActivationCard(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildBenefitCard(Map<String, String> b) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.milapPlusSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Row(
        children: [
          Text(b['icon']!, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b['title']!,
                    style: AppTextStyles.h4
                        .copyWith(color: Colors.white, fontSize: 16)),
                Text(b['desc']!.toUpperCase(),
                    style: AppTextStyles.label
                        .copyWith(color: Colors.white24, fontSize: 9)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivationCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.milapPlusSurface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.milapPlusPrimary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text('STARTING AT',
              style: AppTextStyles.label
                  .copyWith(color: Colors.white24, fontSize: 10)),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(children: [
              TextSpan(
                  text: 'PKR 950',
                  style: AppTextStyles.h1
                      .copyWith(fontSize: 32, color: Colors.white)),
              TextSpan(
                  text: '/mo',
                  style: AppTextStyles.body
                      .copyWith(color: Colors.white24, fontSize: 14)),
            ]),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _openCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.milapPlusPrimary,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: Text('ACTIVATE GOLD',
                  style: AppTextStyles.label.copyWith(
                      color: Colors.black, fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}
