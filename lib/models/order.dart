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
}
