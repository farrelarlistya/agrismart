import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../data/api_service.dart';
import '../core/constants/api_constants.dart';

/// Manages the shopping cart state across the entire app.
class CartProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  String? _userId = 'user_001'; // Default fallback user ID
  List<CartItem> _items = [];
  bool _isLoading = false;
  bool _isInitialized = false;

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  int get selectedCount => _items.where((i) => i.selected).length;
  bool get isLoading => _isLoading;

  double get subtotal {
    double total = 0;
    for (final item in _items) {
      if (item.selected) total += item.totalPrice;
    }
    return total;
  }

  void updateUserId(String? userId) {
    if (_userId != userId) {
      _userId = userId;
      _isInitialized = false;
      _items.clear();
      notifyListeners();
      if (userId != null && userId.isNotEmpty) {
        fetchCart();
      }
    }
  }

  Future<void> fetchCart() async {
    if (_isInitialized) return;
    if (_userId == null || _userId!.isEmpty) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.get(ApiConstants.cart(_userId!));
      final List data = response['data'] as List? ?? [];
      _items = data.map((json) => CartItem.fromJson(json)).toList();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Failed to fetch cart: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshCart() async {
    _isInitialized = false;
    await fetchCart();
  }

  /// Add a product to the cart via API
  Future<void> addToCart(Product product, {int quantity = 1}) async {
    if (_userId == null) return;
    try {
      await _api.post(ApiConstants.cartBase, body: {
        'user_id': _userId,
        'product_id': product.id,
        'quantity': quantity,
      });
      _isInitialized = false;
      await fetchCart();
    } catch (e) {
      debugPrint('Failed to add to cart: $e');
    }
  }

  /// Remove a product from the cart via API
  Future<void> removeFromCart(String productId) async {
    final item = _items.firstWhere((i) => i.product.id == productId, orElse: () => throw Exception('Item not found'));
    if (item.id != null) {
      try {
        await _api.delete(ApiConstants.cartItem(item.id!));
        _items.remove(item);
        notifyListeners();
      } catch (e) {
        debugPrint('Failed to remove from cart: $e');
      }
    }
  }

  /// Update quantity for a specific cart item via API
  Future<void> updateQuantity(String productId, int quantity) async {
    final index = _items.indexWhere((i) => i.product.id == productId);
    if (index >= 0) {
      final item = _items[index];
      if (quantity <= 0) {
        await removeFromCart(productId);
      } else if (item.id != null) {
        try {
          await _api.put(ApiConstants.cartItem(item.id!), body: {'quantity': quantity});
          _items[index].quantity = quantity;
          notifyListeners();
        } catch (e) {
          debugPrint('Failed to update quantity: $e');
        }
      }
    }
  }

  /// Toggle selection for a cart item via API
  Future<void> toggleSelection(String productId) async {
    final index = _items.indexWhere((i) => i.product.id == productId);
    if (index >= 0) {
      final item = _items[index];
      if (item.id != null) {
        try {
          final newStatus = !item.selected;
          await _api.put(ApiConstants.cartItem(item.id!), body: {'selected': newStatus});
          _items[index].selected = newStatus;
          notifyListeners();
        } catch (e) {
          debugPrint('Failed to toggle selection: $e');
        }
      }
    }
  }

  /// Select or deselect all items.
  Future<void> selectAll(bool value) async {
    for (final item in _items) {
      if (item.id != null && item.selected != value) {
        try {
          await _api.put(ApiConstants.cartItem(item.id!), body: {'selected': value});
          item.selected = value;
        } catch (e) {
          debugPrint('Failed to update selection: $e');
        }
      }
    }
    notifyListeners();
  }

  bool get allSelected => _items.isNotEmpty && _items.every((i) => i.selected);

  /// Get selected items for checkout.
  List<CartItem> get selectedItems => _items.where((i) => i.selected).toList();

  /// Clear selected items after checkout.
  Future<void> clearSelected() async {
    if (_userId == null) return;
    try {
      await _api.delete(ApiConstants.clearCart(_userId!));
      _items.removeWhere((i) => i.selected);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to clear selected: $e');
    }
  }

  /// Clear entire cart (local only, for logout)
  void clearCart() {
    _items.clear();
    _isInitialized = false;
    notifyListeners();
  }

  /// Check if a product is in the cart.
  bool isInCart(String productId) => _items.any((i) => i.product.id == productId);
}
