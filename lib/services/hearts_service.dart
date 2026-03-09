import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_service.dart';

class HeartsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final UserService _userService = UserService();

  static final HeartsService _instance = HeartsService._internal();
  factory HeartsService() => _instance;
  HeartsService._internal();

  /// Heart package options
  static const List<HeartPackage> packages = [
    HeartPackage(id: 'hearts_10', hearts: 10, price: 150, priceDisplay: 'Rs. 150', isPopular: false),
    HeartPackage(id: 'hearts_50', hearts: 50, price: 500, priceDisplay: 'Rs. 500', isPopular: true),
    HeartPackage(id: 'hearts_100', hearts: 100, price: 900, priceDisplay: 'Rs. 900', isPopular: false),
  ];

  /// Check and perform daily refill (10 hearts)
  Future<void> checkDailyRefill(String uid, int currentBalance, String lastRefillDate) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    if (lastRefillDate != today) {
      // It's a new day! Refill to 10 if current balance is lower
      int newBalance = currentBalance < 10 ? 10 : currentBalance;
      await _userService.updateHeartsBalance(uid, newBalance);
    }
  }

  /// Spend hearts for an action (Match/Reject cost 1 heart)
  Future<bool> spendHeart(String uid, int currentBalance, bool isMilapGold) async {
    if (isMilapGold) return true; // Unlimited for Gold
    if (currentBalance <= 0) return false;

    await _userService.updateHeartsBalance(uid, currentBalance - 1);
    return true;
  }

  /// Watch Ad to earn hearts (Mocked for now, gives 1 heart)
  Future<void> earnHeartByAd(String uid, int currentBalance) async {
    await _userService.updateHeartsBalance(uid, currentBalance + 1);
  }

  /// Purchase Hearts using Pakistani Payment Methods
  Future<bool> processPurchase({
    required String uid,
    required int currentBalance,
    required HeartPackage package,
    required String method, // 'easypaisa', 'jazzcash', 'card'
  }) async {
    // 1. In a real app, you would integrate a local gateway like 'Sadapay Business' or 'Fonepay'
    // For this $0 backend model, we simulate a successful transaction.

    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));

    // 2. Update balance on success
    await _userService.updateHeartsBalance(uid, currentBalance + package.hearts);
    return true;
  }

  /// Upgrade to Milap+ (Unlimited)
  Future<void> upgradeToGold(String uid) async {
    await _db.collection('users').doc(uid).update({
      'isMilapGold': true,
      'goldExpiry': DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch,
    });
  }
}

class HeartPackage {
  final String id;
  final int hearts;
  final double price;
  final String priceDisplay;
  final bool isPopular;
  const HeartPackage({required this.id, required this.hearts, required this.price, required this.priceDisplay, required this.isPopular});
}
