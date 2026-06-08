import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:klaviyo_flutter_sdk/klaviyo_flutter_sdk.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _trackPurchase(BuildContext context) async {
    try {
      final item = {
        'item_id': 'esim-spain',
        'item_name': 'Spain',
        'item_brand': 'Holafly',
        'item_category': 'esim',
        'item_category2': 'country',
        'item_category3': 'europe',
        'item_category4': 'spain',
        'item_category5': '',
        'item_variant': '15-days',
        'price': 0.61,
        'quantity': 1,
        'index': 1,
        'days_length': 15,
      };

      final purchaseEvent = {
        'transaction_id': 'T12345',
        'currency': 'EUR',
        'tax': 0.66,
        'value': 0.61,
        'coupon': 'REFFLY5DTO',
        'discount': 1.5,
        'payment_type': 'Credit card',
        'items': [item],
        'holacoins_available': 'true',
        'holacoins_quantity': 4000,
        'days_length': 15,
        'product_id': 'esim-spain',
        'product_type': 'esim',
        'product_quantity': 1,
        'klaviyo_item_name': 'España',
        'language': 'en',
      };

      await KlaviyoSDK().createEvent(
        KlaviyoEvent.custom(metric: 'purchase', properties: purchaseEvent),
      );
      debugPrint('Purchase enviado correctamente');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Purchase enviado')));
    } catch (e) {
      debugPrint('Error Klaviyo: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _trackBeginCheckout(BuildContext context) async {
    await KlaviyoSDK().createEvent(
      KlaviyoEvent.custom(
        metric: 'begin_checkout',
        properties: {
          'item': 'Producto Test',
          'price': 29.99,
          'currency': 'EUR',
        },
      ),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('✅ Begin Checkout enviado')));
  }

  Future<void> _trackAddPaymentInfo(BuildContext context) async {
    await KlaviyoSDK().createEvent(
      KlaviyoEvent.custom(
        metric: 'add_to_cart',
        properties: {'payment_method': 'credit_card'},
      ),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('✅ add_to_cart enviado')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Klaviyo Test')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            final user = snapshot.data;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    await KlaviyoSDK().resetProfile();
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Cerrar sesión'),
                ),
                Text(
                  user != null ? '${user.email}' : 'Lógate para continuar',
                  style: TextStyle(
                    fontSize: 14,
                    color: user != null ? Colors.black : Colors.orange,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => _trackPurchase(context),
                  child: const Text('Purchase'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _trackBeginCheckout(context),
                  child: const Text('Begin Checkout'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _trackAddPaymentInfo(context),
                  child: const Text('Add Payment Info'),
                ),
                const SizedBox(height: 32),
                OutlinedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  child: const Text('Login'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
