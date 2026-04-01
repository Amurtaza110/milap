import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/hearts_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

import 'checkout_screen.dart';

class HeartStoreScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onUpgradeToGold;

  const HeartStoreScreen({
    super.key,
    required this.onBack,
    required this.onUpgradeToGold,
  });

  @override
  State<HeartStoreScreen> createState() => _HeartStoreScreenState();
}

class _HeartStoreScreenState extends State<HeartStoreScreen> {
  bool _adLoading = false;

  void _handleWatchAd(UserProvider provider) async {
    if (!mounted) return;
    setState(() => _adLoading = true);
    // Simulate Ad playback
    await Future.delayed(const Duration(seconds: 3));
    
    await provider.earnHeartByAd();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✓ Thanks for watching! +1 Heart added.'), backgroundColor: Colors.green)
      );
      setState(() => _adLoading = false);
    }
  }

  void _openCheckout(UserProvider provider, HeartPackage package, String emoji) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          item: {
            'id': package.id,
            'name': '${package.hearts} Hearts',
            'description': 'Instantly add ${package.hearts} hearts to your balance.',
            'price': package.price.toInt(),
            'price_display': package.priceDisplay,
            'icon': emoji,
          },
          onBack: () => Navigator.pop(context),
          onPaymentSuccess: (method) async {
            if (!mounted) return;
            Navigator.pop(context); // Close checkout
            
            final success = await provider.processHeartPurchase(package, method);
            
            if (success && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✓ ${package.hearts} Hearts added via $method!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    if (user == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32)),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: widget.onBack,
                  icon: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Heart Store', style: AppTextStyles.h2.copyWith(color: AppColors.textMain, fontSize: 28)),
                      Text(
                          'BALANCE: ${user.isMilapGold ? 'UNLIMITED' : user.heartsBalance}',
                          style: AppTextStyles.label.copyWith(color: AppColors.primary, fontSize: 10, letterSpacing: 1.2)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Ad Section
                  _buildAdCard(userProvider),
                  const SizedBox(height: 40),
                  _buildSectionHeader('PURCHASE PACKS'),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildPackCard(userProvider, HeartsService.packages[0], '❤️'),
                      const SizedBox(width: 16),
                      _buildPackCard(userProvider, HeartsService.packages[1], '💖'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildWidePackCard(userProvider, HeartsService.packages[2], '💝', 'Best Value Pack'),
                  const SizedBox(height: 48),
                  _buildSectionHeader('OR GO LIMITLESS'),
                  const SizedBox(height: 24),
                  _buildGoldUpsell(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdCard(UserProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Watch Daily Ad', style: AppTextStyles.h4.copyWith(color: AppColors.textMain)),
                Text('GET 1 FREE HEART', style: AppTextStyles.label.copyWith(color: AppColors.textMuted, fontSize: 9)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _adLoading ? null : () => _handleWatchAd(provider),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(_adLoading ? 'WAIT...' : 'WATCH', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: AppTextStyles.label.copyWith(color: AppColors.textMuted, fontSize: 10, letterSpacing: 1.5)),
    );
  }

  Widget _buildPackCard(UserProvider provider, HeartPackage package, String emoji) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _openCheckout(provider, package, emoji),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: package.isPopular ? AppColors.primary : AppColors.border, width: package.isPopular ? 1.5 : 1),
          ),
          child: Column(
            children: [
              if (package.isPopular)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                  child: const Text('POPULAR', style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w900)),
                ),
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 12),
              Text('${package.hearts}', style: AppTextStyles.h2.copyWith(color: AppColors.textMain, fontSize: 24)),
              Text('HEARTS', style: AppTextStyles.label.copyWith(color: AppColors.textMuted, fontSize: 8)),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                child: Center(child: Text(package.priceDisplay, style: AppTextStyles.label.copyWith(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWidePackCard(UserProvider provider, HeartPackage package, String emoji, String subtitle) {
    return GestureDetector(
      onTap: () => _openCheckout(provider, package, emoji),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${package.hearts} Hearts', style: AppTextStyles.h4.copyWith(color: AppColors.textMain)),
                  Text(subtitle.toUpperCase(), style: AppTextStyles.label.copyWith(color: AppColors.textMuted, fontSize: 9)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
              child: Text(package.priceDisplay, style: AppTextStyles.label.copyWith(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoldUpsell() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 30, offset: const Offset(0, 10))],
        gradient: LinearGradient(colors: [Colors.white, AppColors.primaryLight.withOpacity(0.2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Column(
        children: [
          const Text('👑', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 16),
          Text('Milap Gold', style: AppTextStyles.h3.copyWith(color: AppColors.textMain)),
          const SizedBox(height: 8),
          Text('Unlimited searches, profile boosts, and see who likes you.', textAlign: TextAlign.center, style: AppTextStyles.body.copyWith(color: AppColors.textLight, fontSize: 12)),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onUpgradeToGold,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('UPGRADE NOW', style: AppTextStyles.label.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}
