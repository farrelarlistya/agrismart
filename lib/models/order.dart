import 'cart_item.dart';

class Order {
  final String id;
  final String date;
  final String status;
  final List<CartItem> items;
  final double totalPrice;
  final String buyerName;
  final String address;

  const Order({
    required this.id,
    required this.date,
    required this.status,
    required this.items,
    required this.totalPrice,
    required this.buyerName,
    required this.address,
  });

  /// Creates an Order from a JSON map (API response).
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String? ?? '',
      date: json['date'] as String? ?? '',
      status: json['status'] as String? ?? '',
      items: const [], // Items loaded separately if needed
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0,
      buyerName: json['buyer_name'] as String? ?? '',
      address: json['address'] as String? ?? '',
    );
  }

  /// Converts this Order to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'status': status,
      'total_price': totalPrice,
      'buyer_name': buyerName,
      'address': address,
    };
  }
}
