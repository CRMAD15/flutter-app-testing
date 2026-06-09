import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'analytics_service.dart';
import 'product_model.dart';
import 'theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'T-Shirts', 'Hoodies', 'Accessories'];

  @override
  void initState() {
    super.initState();
    _logViewItemList();
  }

  Future<void> _logViewItemList() async {
    final items = mockProducts
        .map((p) => AnalyticsService.buildItem(
              itemId: p.id,
              itemName: p.name,
              itemCategory: p.category,
              price: p.price,
            ))
        .toList();
    await AnalyticsService.logViewItemList(items: items);
  }

  List<Product> get _filteredProducts {
    if (_selectedCategory == 'All') return mockProducts;
    return mockProducts.where((p) => p.category == _selectedCategory).toList();
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: HolaflyTheme.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Center(
                child: Text('H',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16)),
              ),
            ),
            const SizedBox(width: 8),
            const Text('Holafly Store'),
          ],
        ),
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: const Icon(Icons.logout_rounded),
                tooltip: 'Logout',
                onPressed: _logout,
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/login'),
                child: const Text('Login'),
              ),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero banner ──────────────────────────────────
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [HolaflyTheme.primary, Color(0xFF00E5C6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('New Season',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 8),
                const Text('Fresh drops,\nfresh vibes.',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.2)),
                const SizedBox(height: 4),
                const Text('Free shipping over €50',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w400)),
              ],
            ),
          ),

          // ── Category filter ──────────────────────────────
          const SizedBox(height: 20),
          SizedBox(
            height: 36,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final cat = _categories[i];
                final selected = cat == _selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? HolaflyTheme.primary
                          : HolaflyTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? HolaflyTheme.primary
                            : HolaflyTheme.border,
                      ),
                    ),
                    child: Text(cat,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? Colors.white
                                : HolaflyTheme.textSecondary)),
                  ),
                );
              },
            ),
          ),

          // ── Product grid ─────────────────────────────────
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, i) {
                final product = _filteredProducts[i];
                return _ProductCard(product: product);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, '/pdp', arguments: product),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image placeholder
            Expanded(
              child: Container(
                width: double.infinity,
                color: HolaflyTheme.background,
                child: Center(
                  child: Text(product.emoji,
                      style: const TextStyle(fontSize: 56)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags
                  if (product.tags.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      children: product.tags
                          .take(2)
                          .map((tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: tag == 'Bestseller'
                                      ? HolaflyTheme.primary.withOpacity(0.12)
                                      : HolaflyTheme.secondary.withOpacity(0.07),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(tag,
                                    style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: tag == 'Bestseller'
                                            ? HolaflyTheme.primary
                                            : HolaflyTheme.textSecondary)),
                              ))
                          .toList(),
                    ),
                  const SizedBox(height: 4),
                  Text(product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('€${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: HolaflyTheme.primary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
