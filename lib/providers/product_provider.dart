import 'package:flutter/foundation.dart';
import '../data/api_service.dart';
import '../core/constants/api_constants.dart';
import '../models/product.dart';

/// Manages product data fetched from the API, replacing AppData.products.
class ProductProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Product> _products = [];
  List<String> _categories = ['Semua'];
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;

  List<Product> get products => List.unmodifiable(_products);
  List<String> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch all products from the API.
  Future<void> fetchProducts() async {
    if (_isInitialized) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get(ApiConstants.products);
      final List data = response['data'] as List? ?? [];
      _products = data.map((json) => Product.fromJson(json)).toList();
      _isInitialized = true;
    } catch (e) {
      _error = 'Gagal memuat produk: $e';
      debugPrint('Failed to fetch products: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Fetch categories from the API.
  Future<void> fetchCategories() async {
    try {
      final response = await _api.get(ApiConstants.categories);
      final List data = response['data'] as List? ?? [];
      _categories = ['Semua', ...data.map((c) => c['name'] as String)];
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to fetch categories: $e');
    }
  }

  /// Force re-fetch products.
  Future<void> refreshProducts() async {
    _isInitialized = false;
    await fetchProducts();
  }

  /// Get products filtered by category.
  List<Product> getByCategory(String category) {
    if (category == 'Semua') return _products;
    return _products.where((p) => p.category == category).toList();
  }

  /// Find a product by ID.
  Product? findById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get related products (same category, excluding the given product).
  List<Product> getRelated(Product product, {int limit = 4}) {
    return _products
        .where((p) => p.category == product.category && p.id != product.id)
        .take(limit)
        .toList();
  }
}
