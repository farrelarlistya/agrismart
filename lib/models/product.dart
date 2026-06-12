class Product {
  final String id;
  final String name;
  final String seller;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final String category;
  final String unit;
  final String description;
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
    this.description = '',
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
      description: json['description'] as String? ?? '',
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
      'description': description,
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
    String? description,
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
      description: description ?? this.description,
      stock: stock ?? this.stock,
      location: location ?? this.location,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
