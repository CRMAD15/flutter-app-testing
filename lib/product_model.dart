class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final String description;
  final String emoji;
  final List<String> tags;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.emoji,
    required this.tags,
  });
}

/// Mock product catalog
final List<Product> mockProducts = [
  Product(
    id: 'tshirt_basic_white',
    name: 'Basic White Tee',
    category: 'T-Shirts',
    price: 19.99,
    description:
        'A timeless essential. 100% organic cotton, pre-washed for extra softness. Perfect for any occasion.',
    emoji: '👕',
    tags: ['Bestseller', 'Organic'],
  ),
  Product(
    id: 'tshirt_graphic_black',
    name: 'Graphic Black Tee',
    category: 'T-Shirts',
    price: 29.99,
    description:
        'Bold statement tee with original artwork. Heavyweight cotton blend, unisex fit.',
    emoji: '🖤',
    tags: ['New', 'Limited'],
  ),
  Product(
    id: 'hoodie_classic_grey',
    name: 'Classic Grey Hoodie',
    category: 'Hoodies',
    price: 59.99,
    description:
        'The hoodie that goes with everything. Brushed fleece interior, kangaroo pocket, adjustable drawstring.',
    emoji: '🧥',
    tags: ['Bestseller'],
  ),
  Product(
    id: 'hoodie_zip_navy',
    name: 'Zip-Up Navy Hoodie',
    category: 'Hoodies',
    price: 69.99,
    description:
        'Full-zip hoodie in deep navy. Two side pockets, ribbed cuffs. Made from recycled materials.',
    emoji: '🫐',
    tags: ['Eco', 'New'],
  ),
  Product(
    id: 'cap_logo_black',
    name: 'Logo Cap',
    category: 'Accessories',
    price: 24.99,
    description:
        'Structured 6-panel cap with embroidered logo. Adjustable snapback closure.',
    emoji: '🧢',
    tags: ['Accessory'],
  ),
  Product(
    id: 'tote_canvas_natural',
    name: 'Canvas Tote Bag',
    category: 'Accessories',
    price: 14.99,
    description:
        'Heavy-duty canvas tote. Reinforced handles, inner pocket. Carry everything in style.',
    emoji: '🛍️',
    tags: ['Eco', 'Accessory'],
  ),
];
