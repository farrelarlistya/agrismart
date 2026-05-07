import 'package:flutter/foundation.dart';
import '../models/shipping_address.dart';

/// Manages multiple shipping addresses with CRUD operations.
class AddressProvider extends ChangeNotifier {
  final List<ShippingAddress> _addresses = [
    const ShippingAddress(
      id: 'addr_1',
      recipientName: 'Julian Harvest',
      phone: '0812-3456-7890',
      address:
          'Jl. Raya Kebun Raya No. 58, Blok C2, Villa Agrikultura, Kecamatan Cisarua, Kabupaten Bogor, Jawa Barat, 16793',
      isDefault: true,
    ),
    const ShippingAddress(
      id: 'addr_2',
      recipientName: 'Julian Harvest (Warehouse)',
      phone: '0812-9382-7768',
      address:
          'Kawasan Industri Sentral, Pergudangan AgriSmart Blok C-12, Cileungsi, Kabupaten Bogor, Jawa Barat, 16870',
    ),
    const ShippingAddress(
      id: 'addr_3',
      recipientName: 'Bapak Harvest',
      phone: '0811-1111-2323',
      address:
          'Desa Sukamakur, RT 05 RW 02, Kec. Sukamakmur, Kab. Bogor, Jawa Barat, 16810',
    ),
  ];

  int _nextId = 4;

  List<ShippingAddress> get addresses => List.unmodifiable(_addresses);

  ShippingAddress? get defaultAddress {
    try {
      return _addresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }

  /// Add a new address.
  void addAddress({
    required String recipientName,
    required String phone,
    required String address,
    bool isDefault = false,
  }) {
    if (isDefault) {
      _clearDefault();
    }
    _addresses.add(ShippingAddress(
      id: 'addr_${_nextId++}',
      recipientName: recipientName,
      phone: phone,
      address: address,
      isDefault: isDefault || _addresses.isEmpty,
    ));
    notifyListeners();
  }

  /// Update an existing address.
  void updateAddress(String id, {String? recipientName, String? phone, String? address}) {
    final index = _addresses.indexWhere((a) => a.id == id);
    if (index >= 0) {
      _addresses[index] = _addresses[index].copyWith(
        recipientName: recipientName,
        phone: phone,
        address: address,
      );
      notifyListeners();
    }
  }

  /// Delete an address.
  void deleteAddress(String id) {
    final wasDefault = _addresses.any((a) => a.id == id && a.isDefault);
    _addresses.removeWhere((a) => a.id == id);
    // If the deleted address was default, set the first one as default
    if (wasDefault && _addresses.isNotEmpty) {
      _addresses[0] = _addresses[0].copyWith(isDefault: true);
    }
    notifyListeners();
  }

  /// Set an address as default.
  void setDefault(String id) {
    _clearDefault();
    final index = _addresses.indexWhere((a) => a.id == id);
    if (index >= 0) {
      _addresses[index] = _addresses[index].copyWith(isDefault: true);
    }
    notifyListeners();
  }

  void _clearDefault() {
    for (int i = 0; i < _addresses.length; i++) {
      if (_addresses[i].isDefault) {
        _addresses[i] = _addresses[i].copyWith(isDefault: false);
      }
    }
  }
}
