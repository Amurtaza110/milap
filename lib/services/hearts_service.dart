import 'package:flutter/material.dart';
import 'user_service.dart';

/// Service for handling hearts/currency transactions
class HeartsService {
  static final HeartsService _instance = HeartsService._internal();
  final UserService _userService = UserService();

  factory HeartsService() {
    return _instance;
  }

  HeartsService._internal();

  /// Heart package options available for purchase
  static const List<HeartPackage> packages = [
    HeartPackage(
      id: 'hearts_5',
      hearts: 5,
      price: 0.99,
      priceDisplay: '\$0.99',
      isPopular: false,
    ),
    HeartPackage(
      id: 'hearts_20',
      hearts: 20,
      price: 2.99,
      priceDisplay: '\$2.99',
      isPopular: false,
    ),
    HeartPackage(
      id: 'hearts_50',
      hearts: 50,
      price: 4.99,
      priceDisplay: '\$4.99',
      isPopular: true,
    ),
    HeartPackage(
      id: 'hearts_100',
      hearts: 100,
      price: 9.99,
      priceDisplay: '\$9.99',
      isPopular: false,
    ),
    HeartPackage(
      id: 'hearts_300',
      hearts: 300,
      price: 24.99,
      priceDisplay: '\$24.99',
      isPopular: false,
    ),
  ];

  /// Purchase hearts package
  Future<bool> purchaseHearts(
      String uid, int currentBalance, HeartPackage package) async {
    try {
      // 1. Simulate payment processing delay (External Payment Gateway)
      await Future.delayed(const Duration(seconds: 2));

      // 2. Update hearts balance in Firestore
      final newBalance = currentBalance + package.hearts;
      await _userService.updateHeartsBalance(uid, newBalance);

      return true;
    } catch (e) {
      throw Exception('Failed to purchase hearts: $e');
    }
  }

  /// Restore previous purchases
  Future<List<HeartPackage>> restorePurchases() async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // In a real app, this would:
      // 1. Query payment gateway for user's purchase history
      // 2. Validate and restore completed purchases
      // 3. Add any missing hearts to account

      return [];
    } catch (e) {
      throw Exception('Failed to restore purchases: $e');
    }
  }

  /// Get available discounts or promotions
  Future<List<HeartsPromotion>> getPromotions() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // Example promotions
      return [
        HeartsPromotion(
          id: 'first_purchase',
          title: 'First Purchase Bonus',
          description: 'Get 20% bonus hearts on your first purchase',
          bonusPercentage: 20,
          isActive: true,
        ),
      ];
    } catch (e) {
      throw Exception('Failed to fetch promotions: $e');
    }
  }

  /// Check if user has subscription active
  Future<bool> hasActiveSubscription() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get subscription options
  Future<List<HeartSubscription>> getSubscriptions() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      return [
        HeartSubscription(
          id: 'hearts_monthly',
          name: 'Monthly Hearts',
          description: '50 hearts every month',
          hearts: 50,
          price: 4.99,
          priceDisplay: '\$4.99/month',
          duration: 30,
        ),
        HeartSubscription(
          id: 'hearts_yearly',
          name: 'Yearly Hearts',
          description: '600 hearts every year (save 33%)',
          hearts: 600,
          price: 39.99,
          priceDisplay: '\$39.99/year',
          duration: 365,
        ),
      ];
    } catch (e) {
      throw Exception('Failed to fetch subscriptions: $e');
    }
  }

  /// Get user's transaction history
  Future<List<HeartsTransaction>> getTransactionHistory(String userId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // In a real app, fetch from backend
      return [];
    } catch (e) {
      throw Exception('Failed to fetch transaction history: $e');
    }
  }
}

/// Model for heart packages
class HeartPackage {
  final String id;
  final int hearts;
  final double price;
  final String priceDisplay;
  final bool isPopular;

  const HeartPackage({
    required this.id,
    required this.hearts,
    required this.price,
    required this.priceDisplay,
    required this.isPopular,
  });

  String get bonusHearts {
    if (hearts >= 300) return '+75 bonus';
    if (hearts >= 100) return '+25 bonus';
    if (hearts >= 50) return '+10 bonus';
    return '';
  }

  double get costPerHeart => price / hearts;
}

/// Model for heart promotions
class HeartsPromotion {
  final String id;
  final String title;
  final String description;
  final int bonusPercentage;
  final bool isActive;

  HeartsPromotion({
    required this.id,
    required this.title,
    required this.description,
    required this.bonusPercentage,
    required this.isActive,
  });
}

/// Model for heart subscription
class HeartSubscription {
  final String id;
  final String name;
  final String description;
  final int hearts;
  final double price;
  final String priceDisplay;
  final int duration; // days

  HeartSubscription({
    required this.id,
    required this.name,
    required this.description,
    required this.hearts,
    required this.price,
    required this.priceDisplay,
    required this.duration,
  });
}

/// Model for transaction history
class HeartsTransaction {
  final String id;
  final String userId;
  final int heartsAmount;
  final double priceAmount;
  final String type; // 'purchase', 'bonus', 'refund'
  final DateTime timestamp;

  HeartsTransaction({
    required this.id,
    required this.userId,
    required this.heartsAmount,
    required this.priceAmount,
    required this.type,
    required this.timestamp,
  });
}
