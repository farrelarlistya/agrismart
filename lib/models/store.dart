import '../core/constants/api_constants.dart';

class Store {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final String picName;
  final String province;
  final String city;
  final String postalCode;
  final String address;
  final String nik;
  final String? logoUrl;
  final String? email;
  final String? dob;
  final bool isActive;
  final double balance;
  final String? createdAt;

  const Store({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.picName,
    required this.province,
    required this.city,
    required this.postalCode,
    required this.address,
    required this.nik,
    this.logoUrl,
    this.email,
    this.dob,
    this.isActive = true,
    this.balance = 0.0,
    this.createdAt,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      picName: json['pic_name'] as String? ?? '',
      province: json['province'] as String? ?? '',
      city: json['city'] as String? ?? '',
      postalCode: json['postal_code'] as String? ?? '',
      address: json['address'] as String? ?? '',
      nik: json['nik'] as String? ?? '',
      logoUrl: ApiConstants.fullImageUrl(json['logo_url'] as String?),
      email: json['email'] as String?,
      dob: json['dob'] as String?,
      isActive: (json['is_active'] as int? ?? 1) == 1,
      balance: double.tryParse(json['balance']?.toString() ?? '0') ?? 0.0,
      createdAt: json['created_at'] as String?,
    );
  }

  Store copyWith({
    String? name,
    String? phone,
    String? picName,
    String? province,
    String? city,
    String? postalCode,
    String? address,
    String? nik,
    String? logoUrl,
    String? email,
    String? dob,
    bool? isActive,
    double? balance,
  }) {
    return Store(
      id: id,
      userId: userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      picName: picName ?? this.picName,
      province: province ?? this.province,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      address: address ?? this.address,
      nik: nik ?? this.nik,
      logoUrl: logoUrl ?? this.logoUrl,
      email: email ?? this.email,
      dob: dob ?? this.dob,
      isActive: isActive ?? this.isActive,
      balance: balance ?? this.balance,
      createdAt: createdAt,
    );
  }
}
