import 'package:flutter/material.dart';
import 'product_model.dart';
import 'theme.dart';

class ConfirmationScreen extends StatelessWidget {
  final Product product;
  final String transactionId;

  const ConfirmationScreen({
    super.key,
    required this.product,
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context) {
    final double tax =
        double.parse((product.price * 0.21).toStringAsFixed(2));
    final double total =
        double.parse((product.price + tax).toStringAsFixed(2));

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              // ── Success icon ──────────────────────────────
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: HolaflyTheme.success.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.check_circle_rounded,
                      color: HolaflyTheme.success, size: 56),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Order Confirmed!',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(
                'Thanks for your purchase. Your order is on its way.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: HolaflyTheme.textSecondary, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 32),

              // ── Order card ────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: HolaflyTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: HolaflyTheme.border),
                ),
                child: Column(
                  children: [
                    Text(product.emoji, style: const TextStyle(fontSize: 48)),
                    const SizedBox(height: 10),
                    Text(product.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(product.category,
                        style: const TextStyle(
                            color: HolaflyTheme.textSecondary, fontSize: 13)),
                    const Divider(height: 24),
                    _Row(label: 'Transaction ID', value: transactionId),
                    const SizedBox(height: 6),
                    _Row(
                        label: 'Amount paid',
                        value: '€${total.toStringAsFixed(2)}',
                        valueColor: HolaflyTheme.primary),
                    const SizedBox(height: 6),
                    _Row(label: 'Estimated delivery', value: '3–5 business days'),
                  ],
                ),
              ),

              const Spacer(),

              // ── Back to home ──────────────────────────────
              ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context, '/', (route) => false),
                child: const Text('Back to Home'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {},
                child: const Text('Track my order'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _Row({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: HolaflyTheme.textSecondary, fontSize: 13)),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: valueColor ?? HolaflyTheme.textPrimary)),
      ],
    );
  }
}
