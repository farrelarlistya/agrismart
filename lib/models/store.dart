class Store {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final String warehouseName;
  final String picName;
  final String picPhone;
  final String province;
  final String city;
  final String district;
  final String postalCode;
  final String address;
  final String nik;
  final String? logoUrl;

  const Store({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.warehouseName,
    required this.picName,
    required this.picPhone,
    required this.province,
    required this.city,
    required this.district,
    required this.postalCode,
    required this.address,
    required this.nik,
    this.logoUrl,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      warehouseName: json['warehouse_name'] as String? ?? '',
      picName: json['pic_name'] as String? ?? '',
      picPhone: json['pic_phone'] as String? ?? '',
      province: json['province'] as String? ?? '',
      city: json['city'] as String? ?? '',
      district: json['district'] as String? ?? '',
      postalCode: json['postal_code'] as String? ?? '',
      address: json['address'] as String? ?? '',
      nik: json['nik'] as String? ?? '',
      logoUrl: json['logo_url'] as String?,
    );
  }
}
