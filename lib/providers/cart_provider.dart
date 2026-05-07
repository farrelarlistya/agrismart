import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

/// Manages the shopping cart state across the entire app.
class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  int get selectedCount => _items.where((i) => i.selected).length;

  double get subtotal {
    double total = 0;
    for (final item in _items) {
      if (item.selected) total += item.totalPrice;
    }
    return total;
  }

  /// Add a product to the cart. If it already exists, increase quantity.
  void addToCart(Product product, {int quantity = 1}) {
    final index = _items.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  /// Remove a product from the cart.
  void removeFromCart(String productId) {
    _items.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  /// Update quantity for a specific cart item.
  void updateQuantity(String productId, int quantity) {
    final index = _items.indexWhere((i) => i.product.id == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      notifyListeners();
    }
  }

  /// Toggle selection for a cart item.
  void toggleSelection(String productId) {
    final index = _items.indexWhere((i) => i.product.id == productId);
    if (index >= 0) {
      _items[index].selected = !_items[index].selected;
      notifyListeners();
    }
  }

  /// Select or deselect all items.
  void selectAll(bool value) {
    for (final item in _items) {
      item.selected = value;
    }
    notifyListeners();
  }

  bool get allSelected => _items.isNotEmpty && _items.every((i) => i.selected);

  /// Get selected items for checkout.
  List<CartItem> get selectedItems => _items.where((i) => i.selected).toList();

  /// Clear selected items after checkout.
  void clearSelected() {
    _items.removeWhere((i) => i.selected);
    notifyListeners();
  }

  /// Clear entire cart.
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  /// Check if a product is in the cart.
  bool isInCart(String productId) => _items.any((i) => i.product.id == productId);
}
