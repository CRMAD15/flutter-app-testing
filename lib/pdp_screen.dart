import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'analytics_service.dart';
import 'product_model.dart';
import 'theme.dart';

class PdpScreen extends StatefulWidget {
  final Product product;
  const PdpScreen({super.key, required this.product});

  @override
  State<PdpScreen> createState() => _PdpScreenState();
}

class _PdpScreenState extends State<PdpScreen> {
  String _selectedSize = 'M';
  final List<String> _sizes = ['XS', 'S', 'M', 'L', 'XL'];

  @override
  void initState() {
    super.initState();
    _logViewItem();
  }

  Future<void> _logViewItem() async {
    final item = AnalyticsService.buildItem(
      itemId: widget.product.id,
      itemName: widget.product.name,
      itemCategory: widget.product.category,
      price: widget.product.price,
    );
    await AnalyticsService.logViewItem(item: item);
  }

  Future<void> _onAddToCart() async {
    final item = AnalyticsService.buildItem(
      itemId: widget.product.id,
      itemName: widget.product.name,
      itemCategory: widget.product.category,
      price: widget.product.price,
    );
    await AnalyticsService.logAddToCart(item: item);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} added to cart'),
        backgroundColor: HolaflyTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _onBuyNow() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Gate: require login before checkout
      Navigator.pushNamed(context, '/login',
          arguments: {'nextRoute': '/checkout', 'product': widget.product});
    } else {
      Navigator.pushNamed(context, '/checkout', arguments: widget.product);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final bool hasSize = p.category == 'T-Shirts' || p.category == 'Hoodies';

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(p.category),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Product hero image ────────────────────────
            Container(
              width: double.infinity,
              height: 280,
              color: HolaflyTheme.background,
              child: Center(
                child: Text(p.emoji, style: const TextStyle(fontSize: 100)),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags
                  Wrap(
                    spacing: 6,
                    children: p.tags
                        .map((tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: HolaflyTheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(tag,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: HolaflyTheme.primary)),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 10),

                  // Name & price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(p.name,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 12),
                      Text('€${p.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: HolaflyTheme.primary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(p.category,
                      style: const TextStyle(
                          color: HolaflyTheme.textSecondary, fontSize: 13)),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Description
                  const Text('Description',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(p.description,
                      style: const TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: HolaflyTheme.textSecondary)),

                  // Size selector (only for clothing)
                  if (hasSize) ...[
                    const SizedBox(height: 24),
                    const Text('Size',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Row(
                      children: _sizes
                          .map((size) => GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedSize = size),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  margin: const EdgeInsets.only(right: 8),
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: _selectedSize == size
                                        ? HolaflyTheme.primary
                                        : HolaflyTheme.surface,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: _selectedSize == size
                                          ? HolaflyTheme.primary
                                          : HolaflyTheme.border,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(size,
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: _selectedSize == size
                                                ? Colors.white
                                                : HolaflyTheme.textPrimary)),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // CTA buttons
                  ElevatedButton(
                    onPressed: _onBuyNow,
                    child: const Text('Buy Now'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: _onAddToCart,
                    child: const Text('Add to Cart'),
                  ),

                  const SizedBox(height: 24),

                  // Shipping info
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: HolaflyTheme.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_shipping_outlined,
                            color: HolaflyTheme.primary, size: 20),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Free shipping on orders over €50. Estimated delivery 3–5 days.',
                            style: TextStyle(
                                fontSize: 12,
                                color: HolaflyTheme.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
