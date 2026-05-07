class Product {
  final String id;
  final String name;
  final String seller;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final String category;
  final String unit;
  final double rating;
  final int reviewCount;
  final String description;
  final bool isOrganic;
  final bool isPremium;
  final int stock;

  const Product({
    required this.id,
    required this.name,
    required this.seller,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    required this.category,
    this.unit = 'kg',
    this.rating = 4.5,
    this.reviewCount = 0,
    this.description = '',
    this.isOrganic = false,
    this.isPremium = false,
    this.stock = 100,
  });
}
