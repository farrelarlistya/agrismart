import 'package:flutter/foundation.dart';
import '../data/api_service.dart';
import '../core/constants/api_constants.dart';

/// Manages the favorite products state with API backend sync.
class FavoriteProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  String? _userId = 'user_001'; // Default fallback user ID

  final Set<String> _favoriteIds = {};
  bool _isInitialized = false;

  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);
  int get count => _favoriteIds.length;

  bool isFavorite(String productId) => _favoriteIds.contains(productId);

  /// Update active user ID and fetch favorites.
  void updateUserId(String? userId) {
    if (_userId != userId) {
      _userId = userId;
      _isInitialized = false;
      _favoriteIds.clear();
      notifyListeners();
      if (userId != null && userId.isNotEmpty) {
        fetchFavorites();
      }
    }
  }

  /// Fetch favorites from the API.
  Future<void> fetchFavorites() async {
    if (_isInitialized) return;
    if (_userId == null || _userId!.isEmpty) return;
    try {
      final response = await _api.get(ApiConstants.userFavorites(_userId!));
      final List data = response['data'] as List? ?? [];
      _favoriteIds.clear();
      for (final item in data) {
        _favoriteIds.add(item['product_id'].toString());
      }
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to fetch favorites: $e');
    }
  }

  /// Toggle a favorite via API (add or remove).
  Future<void> toggleFavorite(String productId) async {
    if (_userId == null || _userId!.isEmpty) return;
    // Optimistic UI update
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
    } else {
      _favoriteIds.add(productId);
    }
    notifyListeners();

    try {
      await _api.post(ApiConstants.userFavorites(_userId!), body: {
        'product_id': int.tryParse(productId) ?? productId,
      });
    } catch (e) {
      debugPrint('Failed to toggle favorite: $e');
      // Revert on failure
      if (_favoriteIds.contains(productId)) {
        _favoriteIds.remove(productId);
      } else {
        _favoriteIds.add(productId);
      }
      notifyListeners();
    }
  }

  void addFavorite(String productId) {
    if (_userId == null || _userId!.isEmpty) return;
    _favoriteIds.add(productId);
    notifyListeners();
    _api.post(ApiConstants.userFavorites(_userId!), body: {
      'product_id': int.tryParse(productId) ?? productId,
    }).catchError((e) => debugPrint('Failed to add favorite: $e'));
  }

  void removeFavorite(String productId) {
    if (_userId == null || _userId!.isEmpty) return;
    _favoriteIds.remove(productId);
    notifyListeners();
    _api.delete(ApiConstants.userFavorite(_userId!, productId))
        .catchError((e) => debugPrint('Failed to remove favorite: $e'));
  }
}
