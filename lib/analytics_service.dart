import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

/// Centralized wrapper for all Firebase Analytics events.
/// Mirrors GA4 ecommerce event spec.
class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // ─── User ────────────────────────────────────────────────

  static String _sha256(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: _sha256(userId));
  }

  static Future<void> logLogin({String method = 'email'}) async {
    await _analytics.logLogin(loginMethod: method);
  }

  static Future<void> logSignUp({String method = 'email'}) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  // ─── Ecommerce ───────────────────────────────────────────
  static Future<void> logViewItemList({
    required List<AnalyticsEventItem> items,
    String itemListId = 'home_feed',
    String itemListName = 'Home Feed',
  }) async {
    await _analytics.logViewItemList(
      items: items,
      itemListId: itemListId,
      itemListName: itemListName,
    );
  }

  static Future<void> logViewItem({
    required AnalyticsEventItem item,
  }) async {
    await _analytics.logViewItem(
      currency: 'EUR',
      value: item.price?.toDouble(),
      items: [item],
    );
  }

  static Future<void> logAddToCart({
    required AnalyticsEventItem item,
  }) async {
    await _analytics.logAddToCart(
      currency: 'EUR',
      value: item.price?.toDouble(),
      items: [item],
    );
  }

  static Future<void> logBeginCheckout({
    required List<AnalyticsEventItem> items,
    required double value,
  }) async {
    await _analytics.logBeginCheckout(
      currency: 'EUR',
      value: value,
      items: items,
    );
  }

  static Future<void> logPurchase({
    required String transactionId,
    required List<AnalyticsEventItem> items,
    required double value,
    double tax = 0,
    double shipping = 0,
  }) async {
    await _analytics.logPurchase(
      transactionId: transactionId,
      currency: 'EUR',
      value: value,
      tax: tax,
      shipping: shipping,
      items: items,
    );
  }

  // ─── Helper ──────────────────────────────────────────────
  static AnalyticsEventItem buildItem({
    required String itemId,
    required String itemName,
    required String itemCategory,
    required double price,
    int quantity = 1,
  }) {
    return AnalyticsEventItem(
      itemId: itemId,
      itemName: itemName,
      itemCategory: itemCategory,
      price: price,
      quantity: quantity,
      currency: 'EUR',
    );
  }
}
