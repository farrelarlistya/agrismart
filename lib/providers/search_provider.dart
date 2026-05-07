import 'package:flutter/foundation.dart';
import '../data/dummy_data.dart';
import '../models/product.dart';

/// Manages product search state with instant filtering.
class SearchProvider extends ChangeNotifier {
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

    // Simulate a short delay for realistic feel
    Future.delayed(const Duration(milliseconds: 200), () {
      final lowerQuery = query.toLowerCase();
      _results = AppData.products.where((p) {
        return p.name.toLowerCase().contains(lowerQuery) ||
            p.seller.toLowerCase().contains(lowerQuery) ||
            p.category.toLowerCase().contains(lowerQuery) ||
            p.location.toLowerCase().contains(lowerQuery);
      }).toList();
      _isSearching = false;
      notifyListeners();
    });
  }

  void clearSearch() {
    _query = '';
    _results = [];
    _isSearching = false;
    notifyListeners();
  }
}
