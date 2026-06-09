import 'package:flutter/material.dart';
import 'analytics_service.dart';
import 'product_model.dart';
import 'theme.dart';
import 'dart:math';

class CheckoutScreen extends StatefulWidget {
  final Product product;
  const CheckoutScreen({super.key, required this.product});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cardController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _logBeginCheckout();
  }

  Future<void> _logBeginCheckout() async {
    final item = AnalyticsService.buildItem(
      itemId: widget.product.id,
      itemName: widget.product.name,
      itemCategory: widget.product.category,
      price: widget.product.price,
    );
    await AnalyticsService.logBeginCheckout(
      items: [item],
      value: widget.product.price,
    );
  }

  Future<void> _onPlaceOrder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1200));

    final transactionId =
        'TXN-${Random().nextInt(900000) + 100000}';

    final item = AnalyticsService.buildItem(
      itemId: widget.product.id,
      itemName: widget.product.name,
      itemCategory: widget.product.category,
      price: widget.product.price,
    );
    await AnalyticsService.logPurchase(
      transactionId: transactionId,
      items: [item],
      value: widget.product.price,
      tax: double.parse((widget.product.price * 0.21).toStringAsFixed(2)),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.pushReplacementNamed(context, '/confirmation', arguments: {
      'product': widget.product,
      'transactionId': transactionId,
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cardController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final double tax = double.parse((p.price * 0.21).toStringAsFixed(2));
    final double total = double.parse((p.price + tax).toStringAsFixed(2));

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Order summary ────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: HolaflyTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: HolaflyTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Order Summary',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: HolaflyTheme.background,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                              child: Text(p.emoji,
                                  style: const TextStyle(fontSize: 24))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14)),
                              Text(p.category,
                                  style: const TextStyle(
                                      color: HolaflyTheme.textSecondary,
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                        Text('€${p.price.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const Divider(height: 20),
                    _SummaryRow(label: 'Subtotal', value: '€${p.price.toStringAsFixed(2)}'),
                    const SizedBox(height: 4),
                    _SummaryRow(label: 'VAT (21%)', value: '€${tax.toStringAsFixed(2)}'),
                    const SizedBox(height: 4),
                    _SummaryRow(label: 'Shipping', value: 'Free'),
                    const Divider(height: 16),
                    _SummaryRow(
                        label: 'Total',
                        value: '€${total.toStringAsFixed(2)}',
                        bold: true),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Shipping info ────────────────────────────
              _SectionHeader(icon: Icons.local_shipping_outlined, label: 'Shipping information'),
              const SizedBox(height: 12),
              _Field(controller: _nameController, label: 'Full name', icon: Icons.person_outline),
              const SizedBox(height: 12),
              _Field(controller: _emailController, label: 'Email', icon: Icons.mail_outline, type: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _Field(controller: _addressController, label: 'Delivery address', icon: Icons.home_outlined),

              const SizedBox(height: 24),

              // ── Payment ──────────────────────────────────
              _SectionHeader(icon: Icons.credit_card_outlined, label: 'Payment'),
              const SizedBox(height: 12),
              _Field(
                controller: _cardController,
                label: 'Card number',
                icon: Icons.credit_card,
                type: TextInputType.number,
                hint: '•••• •••• •••• ••••',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _Field(
                      controller: _expiryController,
                      label: 'MM/YY',
                      icon: Icons.calendar_today_outlined,
                      type: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Field(
                      controller: _cvvController,
                      label: 'CVV',
                      icon: Icons.lock_outline,
                      type: TextInputType.number,
                      obscure: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ── Place order button ────────────────────────
              ElevatedButton(
                onPressed: _isLoading ? null : _onPlaceOrder,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text('Place Order · €${total.toStringAsFixed(2)}'),
              ),

              const SizedBox(height: 16),
              const Center(
                child: Text(
                  '🔒  Secured payment · Test mode only',
                  style: TextStyle(
                      color: HolaflyTheme.textSecondary, fontSize: 12),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: HolaflyTheme.primary),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType type;
  final String? hint;
  final bool obscure;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.type = TextInputType.text,
    this.hint,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _SummaryRow(
      {required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 13,
                color: bold ? HolaflyTheme.textPrimary : HolaflyTheme.textSecondary,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
                color: bold ? HolaflyTheme.primary : HolaflyTheme.textPrimary)),
      ],
    );
  }
}
