/// Model for a shipping address.
class ShippingAddress {
  final String id;
  final String recipientName;
  final String phone;
  final String address;
  final bool isDefault;

  const ShippingAddress({
    required this.id,
    required this.recipientName,
    required this.phone,
    required this.address,
    this.isDefault = false,
  });

  ShippingAddress copyWith({
    String? recipientName,
    String? phone,
    String? address,
    bool? isDefault,
  }) {
    return ShippingAddress(
      id: id,
      recipientName: recipientName ?? this.recipientName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
