import 'package:flutter/foundation.dart';
import '../data/api_service.dart';
import '../core/constants/api_constants.dart';
import '../models/store.dart';

class StoreProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  Store? _store;
  bool _isLoading = false;
  double _balance = 0.0;
  List<Map<String, dynamic>> _transactions = [];

  Store? get store => _store;
  bool get isLoading => _isLoading;
  bool get hasStore => _store != null;
  double get balance => _balance;
  List<Map<String, dynamic>> get transactions => List.unmodifiable(_transactions);

  /// Fetch store data for a specific user ID.
  Future<void> fetchMyStore(String userId) async {
    if (userId.isEmpty) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.get('${ApiConstants.stores}/me/$userId');
      if (response['success'] == true && response['data'] != null) {
        _store = Store.fromJson(response['data']);
        _balance = _store?.balance ?? 0.0;
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

  /// Update store profile details.
  Future<bool> updateStore(Map<String, dynamic> data) async {
    if (_store == null) return false;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.put(
        '${ApiConstants.stores}/${_store!.id}',
        body: data,
      );
      if (response['success'] == true && response['data'] != null) {
        _store = Store.fromJson(response['data']);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Failed to update store: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Toggle store active status.
  Future<void> toggleStoreActive() async {
    if (_store == null) return;
    final newStatus = !_store!.isActive;
    _store = _store!.copyWith(isActive: newStatus);
    notifyListeners();
    await updateStore({'is_active': newStatus ? 1 : 0});
  }

  /// Fetch finance data (balance + transaction history).
  Future<void> fetchFinance() async {
    if (_store == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.get('${ApiConstants.stores}/${_store!.id}/finance');
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        _balance = (data['balance'] as num?)?.toDouble() ?? 0.0;
        final txList = data['transactions'] as List? ?? [];
        _transactions = txList.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('Failed to fetch finance: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Request a withdrawal.
  Future<bool> withdraw({required double amount, required String bankName}) async {
    if (_store == null) return false;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.post(
        '${ApiConstants.stores}/${_store!.id}/withdraw',
        body: {'amount': amount, 'bank_name': bankName},
      );
      if (response['success'] == true) {
        await fetchFinance(); // Refresh balance after withdrawal
        return true;
      }
    } catch (e) {
      debugPrint('Failed to withdraw: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}
