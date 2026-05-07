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
  final String location;
  final bool isFavorite;

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
    this.location = '',
    this.isFavorite = false,
  });

  /// Creates a copy of this Product with the given fields replaced.
  Product copyWith({
    String? id,
    String? name,
    String? seller,
    double? price,
    double? originalPrice,
    String? imageUrl,
    String? category,
    String? unit,
    double? rating,
    int? reviewCount,
    String? description,
    bool? isOrganic,
    bool? isPremium,
    int? stock,
    String? location,
    bool? isFavorite,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      seller: seller ?? this.seller,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      description: description ?? this.description,
      isOrganic: isOrganic ?? this.isOrganic,
      isPremium: isPremium ?? this.isPremium,
      stock: stock ?? this.stock,
      location: location ?? this.location,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
