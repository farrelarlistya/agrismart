/// Model for a user profile.
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatarUrl;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatarUrl,
  });

  /// Creates a UserProfile from a JSON map (API response).
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  /// Converts this UserProfile to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar_url': avatarUrl,
    };
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
