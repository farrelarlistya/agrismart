import 'product.dart';

/// Represents a single item in the shopping cart.
class CartItem {
  final String? id; // Backend cart item ID
  final Product product;
  int quantity;
  bool selected;

  CartItem({
    this.id,
    required this.product,
    this.quantity = 1,
    this.selected = true,
  });

  double get totalPrice => product.price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'].toString(),
      quantity: json['quantity'] as int? ?? 1,
      selected: (json['selected'] == 1 || json['selected'] == true),
      product: Product(
        id: json['product_id'].toString(),
        name: json['product_name'] as String? ?? '',
        seller: json['store_name'] as String? ?? 'Unknown',
        price: double.tryParse(json['price'].toString()) ?? 0,
        imageUrl: json['image_url'] as String? ?? '',
        category: '', // not strictly needed for cart view
        unit: json['unit'] as String? ?? 'kg',
        stock: json['stock'] as int? ?? 0,
      ),
    );
  }
}
