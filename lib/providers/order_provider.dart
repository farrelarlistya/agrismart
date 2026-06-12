import 'package:flutter/foundation.dart';
import '../data/api_service.dart';
import '../core/constants/api_constants.dart';

class OrderProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  String? _userId = 'user_001';
  bool _isLoading = false;
  bool _isInitialized = false;

  List<Map<String, dynamic>> _orders = [];

  List<Map<String, dynamic>> get orders => List.unmodifiable(_orders);
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
      // The backend handles appending user_id to /api/orders, but ApiConstants.order is for single order.
      // Let's call /api/orders?user_id=...
      final response = await _api.get('/api/orders?user_id=$_userId');
      final List data = response['data'] as List? ?? [];
      
      _orders = data.map((json) {
        return {
          'id': json['id'].toString(),
          'date': json['date'] as String? ?? '',
          'status': json['status'] as String? ?? 'Menunggu Pengiriman',
          'productName': json['product_name'] as String? ?? 'Produk',
          'productImage': json['product_image'] as String? ?? 'assets/images/placeholder.png',
          'seller': json['seller_name'] as String? ?? 'Unknown Store',
          'quantity': json['total_quantity'] as int? ?? 1,
          'unit': json['unit'] as String? ?? 'kg',
          'price': double.tryParse(json['total_price'].toString())?.toInt() ?? 0,
        };
      }).toList();

      _isInitialized = true;
    } catch (e) {
      debugPrint('Failed to fetch orders: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshOrders() async {
    _isInitialized = false;
    await fetchOrders();
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
