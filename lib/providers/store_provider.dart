import 'package:flutter/foundation.dart';
import '../data/api_service.dart';
import '../core/constants/api_constants.dart';
import '../models/store.dart';

class StoreProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  Store? _store;
  bool _isLoading = false;

  Store? get store => _store;
  bool get isLoading => _isLoading;
  bool get hasStore => _store != null;

  /// Fetch store data for a specific user ID.
  Future<void> fetchMyStore(String userId) async {
    if (userId.isEmpty) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.get('${ApiConstants.stores}/me/$userId');
      if (response['success'] == true && response['data'] != null) {
        _store = Store.fromJson(response['data']);
      } else {
        _store = null;
      }
    } catch (e) {
      debugPrint('Failed to fetch store: $e');
      _store = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Register a new store for the user.
  Future<bool> registerStore(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.post(
        '${ApiConstants.stores}/register',
        body: data,
      );
      if (response['success'] == true) {
        // Registration successful, fetch the full store data or at least mark it
        // Depending on backend, we might get partial data. Fetch it fully:
        if (data['user_id'] != null) {
          await fetchMyStore(data['user_id']);
        }
        return true;
      }
    } catch (e) {
      debugPrint('Failed to register store: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}
