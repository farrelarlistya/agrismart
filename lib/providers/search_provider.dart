import 'package:flutter/foundation.dart';
import '../data/api_service.dart';
import '../core/constants/api_constants.dart';
import '../models/product.dart';

/// Manages product search state with API-backed filtering.
class SearchProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  String _query = '';
  List<Product> _results = [];
  bool _isSearching = false;

  String get query => _query;
  List<Product> get results => _results;
  bool get isSearching => _isSearching;

  void search(String query) {
    _query = query;
    if (query.trim().isEmpty) {
      _results = [];
      _isSearching = false;
      notifyListeners();
      return;
    }
    _isSearching = true;
    notifyListeners();

    _searchFromApi(query);
  }

  Future<void> _searchFromApi(String query) async {
    try {
      final response = await _api.get(
        ApiConstants.products,
        queryParams: {'search': query},
      );
      final List data = response['data'] as List? ?? [];
      _results = data.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Search error: $e');
      _results = [];
    }
    _isSearching = false;
    notifyListeners();
  }

  void clearSearch() {
    _query = '';
    _results = [];
    _isSearching = false;
    notifyListeners();
  }
}
