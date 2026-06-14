import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../data/api_service.dart';

class OrderProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  String? _userId;
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _isSellerInitialized = false;

  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _sellerOrders = [];

  List<Map<String, dynamic>> get orders => List.unmodifiable(_orders);
  List<Map<String, dynamic>> get sellerOrders => List.unmodifiable(_sellerOrders);
  bool get isLoading => _isLoading;

  void updateUserId(String? userId) {
    if (_userId != userId) {
      _userId = userId;
      _isInitialized = false;
      _orders.clear();
      notifyListeners();
      if (userId != null && userId.isNotEmpty) {
        fetchOrders();
      }
    }
  }

  Future<void> fetchOrders() async {
    if (_isInitialized) return;
    if (_userId == null || _userId!.isEmpty) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.get('/api/orders?user_id=$_userId');
      final List data = response['data'] as List? ?? [];
      _orders = _mapOrders(data);
      _isInitialized = true;
    } catch (e) {
      debugPrint('Failed to fetch orders: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Fetch orders that belong to a specific seller store.
  Future<void> fetchSellerOrders(String storeId) async {
    if (_isSellerInitialized) return;
    if (storeId.isEmpty) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.get('/api/orders?seller_id=$storeId');
      final List data = response['data'] as List? ?? [];
      _sellerOrders = _mapOrders(data);
      _isSellerInitialized = true;
    } catch (e) {
      debugPrint('Failed to fetch seller orders: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  List<Map<String, dynamic>> _mapOrders(List data) {
    return data.map((json) {
      return {
        'id': json['id']?.toString() ?? '',
        'date': json['date'] as String? ?? '',
        'created_at': json['created_at'] as String? ?? '',
        'status': json['status'] as String? ?? 'Menunggu Pengiriman',
        'productName': json['product_name'] as String? ?? 'Produk',
        'productImage': ApiConstants.fullImageUrl(json['product_image'] as String? ?? ''),
        'seller': json['seller_name'] as String? ?? '',
        'buyer_name': json['buyer_name'] as String? ?? '',
        'quantity': json['total_quantity'] as int? ?? 1,
        'unit': json['unit'] as String? ?? 'kg',
        'price': double.tryParse(json['total_price']?.toString() ?? '0')?.toInt() ?? 0,
        'resi': json['resi'] as String?,
        'address': json['address'] as String? ?? '',
      };
    }).toList();
  }

  Future<void> refreshOrders() async {
    _isInitialized = false;
    await fetchOrders();
  }

  Future<void> refreshSellerOrders(String storeId) async {
    _isSellerInitialized = false;
    await fetchSellerOrders(storeId);
  }

  Future<void> createOrder({
    required List<Map<String, dynamic>> items,
    required double totalPrice,
    required String buyerName,
    required String address,
  }) async {
    if (_userId == null) return;
    try {
      await _api.post('/api/orders', body: {
        'user_id': _userId,
        'date': DateTime.now().toString().split(' ')[0],
        'total_price': totalPrice,
        'buyer_name': buyerName,
        'address': address,
        'items': items,
        'status': 'Menunggu Pengiriman',
      });
      _isInitialized = false;
      await fetchOrders();
    } catch (e) {
      debugPrint('Failed to create order: $e');
    }
  }
}
