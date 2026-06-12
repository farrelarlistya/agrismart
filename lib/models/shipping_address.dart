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

  /// Creates a ShippingAddress from a JSON map (API response).
  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      id: json['id'].toString(),
      recipientName: json['recipient_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      isDefault: json['is_default'] == 1 || json['is_default'] == true,
    );
  }

  /// Converts this ShippingAddress to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipient_name': recipientName,
      'phone': phone,
      'address': address,
      'is_default': isDefault,
    };
  }

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
