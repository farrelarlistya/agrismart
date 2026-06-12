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

  /// Creates a Product from a JSON map (API response).
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      seller: json['seller'] as String? ?? '',
      price: json['price'] != null ? double.tryParse(json['price'].toString()) ?? 0 : 0,
      originalPrice: json['original_price'] != null
          ? double.tryParse(json['original_price'].toString())
          : null,
      imageUrl: json['image_url'] as String? ?? '',
      category: json['category'] as String? ?? '',
      unit: json['unit'] as String? ?? 'kg',
      rating: json['rating'] != null ? double.tryParse(json['rating'].toString()) ?? 4.5 : 4.5,
      reviewCount: json['review_count'] != null ? int.tryParse(json['review_count'].toString()) ?? 0 : 0,
      description: json['description'] as String? ?? '',
      isOrganic: json['is_organic'] == 1 || json['is_organic'] == true,
      isPremium: json['is_premium'] == 1 || json['is_premium'] == true,
      stock: json['stock'] != null ? int.tryParse(json['stock'].toString()) ?? 100 : 100,
      location: json['location'] as String? ?? '',
    );
  }

  /// Converts this Product to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'seller': seller,
      'price': price,
      'original_price': originalPrice,
      'image_url': imageUrl,
      'category': category,
      'unit': unit,
      'rating': rating,
      'review_count': reviewCount,
      'description': description,
      'is_organic': isOrganic,
      'is_premium': isPremium,
      'stock': stock,
      'location': location,
    };
  }

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
