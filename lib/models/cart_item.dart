import 'product.dart';

/// Represents a single item in the shopping cart.
class CartItem {
  final Product product;
  int quantity;
  bool selected;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.selected = true,
  });

  double get totalPrice => product.price * quantity;
}
