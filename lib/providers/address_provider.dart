import 'package:flutter/foundation.dart';
import '../data/api_service.dart';
import '../core/constants/api_constants.dart';
import '../models/shipping_address.dart';

/// Manages multiple shipping addresses with API-backed CRUD operations.
class AddressProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  String? _userId = 'user_001'; // Default fallback user ID

  List<ShippingAddress> _addresses = [];
  bool _isLoading = false;
  bool _isInitialized = false;

  List<ShippingAddress> get addresses => List.unmodifiable(_addresses);
  bool get isLoading => _isLoading;

  ShippingAddress? get defaultAddress {
    try {
      return _addresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }

  /// Update active user ID and fetch their addresses.
  void updateUserId(String? userId) {
    if (_userId != userId) {
      _userId = userId;
      _isInitialized = false;
      _addresses.clear();
      notifyListeners();
      if (userId != null && userId.isNotEmpty) {
        refreshAddresses();
      }
    }
  }

  /// Fetch addresses from the API.
  Future<void> fetchAddresses() async {
    if (_isInitialized) return;
    if (_userId == null || _userId!.isEmpty) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.get(ApiConstants.userAddresses(_userId!));
      final List data = response['data'] as List? ?? [];
      _addresses = data.map((json) => ShippingAddress.fromJson(json)).toList();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Failed to fetch addresses: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Force re-fetch from API.
  Future<void> refreshAddresses() async {
    _isInitialized = false;
    await fetchAddresses();
  }

  /// Add a new address via API.
  Future<void> addAddress({
    required String recipientName,
    required String phone,
    required String address,
    bool isDefault = false,
  }) async {
    if (_userId == null || _userId!.isEmpty) return;
    try {
      await _api.post(ApiConstants.userAddresses(_userId!), body: {
        'recipient_name': recipientName,
        'phone': phone,
        'address': address,
        'is_default': isDefault,
      });
      _isInitialized = false;
      await fetchAddresses();
    } catch (e) {
      debugPrint('Failed to add address: $e');
    }
  }

  /// Update an existing address via API.
  Future<void> updateAddress(String id, {String? recipientName, String? phone, String? address}) async {
    try {
      final body = <String, dynamic>{};
      if (recipientName != null) body['recipient_name'] = recipientName;
      if (phone != null) body['phone'] = phone;
      if (address != null) body['address'] = address;

      await _api.put(ApiConstants.address(id), body: body);
      _isInitialized = false;
      await fetchAddresses();
    } catch (e) {
      debugPrint('Failed to update address: $e');
    }
  }

  /// Delete an address via API.
  Future<void> deleteAddress(String id) async {
    try {
      await _api.delete(ApiConstants.address(id));
      _isInitialized = false;
      await fetchAddresses();
    } catch (e) {
      debugPrint('Failed to delete address: $e');
    }
  }

  /// Set an address as default via API.
  Future<void> setDefault(String id) async {
    try {
      await _api.patch(ApiConstants.addressDefault(id));
      _isInitialized = false;
      await fetchAddresses();
    } catch (e) {
      debugPrint('Failed to set default address: $e');
    }
  }
}
