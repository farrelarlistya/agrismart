import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../data/api_service.dart';
import '../core/constants/api_constants.dart';
import '../models/user_profile.dart';

/// Manages user profile state with API backend.
class UserProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  UserProfile _user = const UserProfile(
    id: '',
    name: '',
    email: '',
    phone: '',
  );

  bool _isLoading = false;
  bool _isInitialized = false;

  UserProfile get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  /// Fetch the user profile from the API.
  Future<void> fetchUser() async {
    if (_isInitialized || _user.id.isEmpty) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.get(ApiConstants.user(_user.id));
      _user = UserProfile.fromJson(response['data']);
      _isInitialized = true;
    } catch (e) {
      debugPrint('Failed to fetch user: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Log in a user.
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.post(
        ApiConstants.login,
        body: {
          'email': email,
          'password': password,
        },
      );
      if (response['success'] == true) {
        _user = UserProfile.fromJson(response['data']);
        _isInitialized = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Failed to login: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Register a user.
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.post(
        ApiConstants.register,
        body: {
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
        },
      );
      if (response['success'] == true) {
        _user = UserProfile.fromJson(response['data']);
        _isInitialized = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Failed to register: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Update the user profile via API. Returns true on success.
  Future<bool> updateProfile({String? name, String? email, String? phone}) async {
    if (_user.id.isEmpty) return false;
    _isLoading = true;
    notifyListeners();

    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;
      if (phone != null) body['phone'] = phone;

      final response = await _api.put(ApiConstants.user(_user.id), body: body);
      if (response['success'] == true && response['data'] != null) {
        _user = UserProfile.fromJson(response['data']);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Failed to update user via API: $e');
      // Optimistic local fallback so UI stays responsive
      _user = _user.copyWith(name: name, email: email, phone: phone);
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Upload and update user avatar via API (base64 JSON).
  Future<bool> uploadAvatar(String imagePath) async {
    if (_user.id.isEmpty) return false;
    _isLoading = true;
    notifyListeners();

    try {
      // Read the image file and encode as base64
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);
      final extension = imagePath.split('.').last.toLowerCase();

      debugPrint('📤 Uploading avatar for user ${_user.id}, size=${bytes.length} bytes, ext=$extension');

      final response = await _api.post(
        '${ApiConstants.users}/${_user.id}/avatar',
        body: {
          'image_data': base64Image,
          'image_type': extension,
        },
      );
      if (response['success'] == true && response['data'] != null) {
        _user = UserProfile.fromJson(response['data']);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      debugPrint('❌ Avatar upload: API returned success=false: $response');
    } catch (e) {
      debugPrint('❌ Failed to upload avatar: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Log out user.
  void logout() {
    _user = const UserProfile(
      id: '',
      name: '',
      email: '',
      phone: '',
    );
    _isInitialized = false;
    notifyListeners();
  }

  /// Set loading state externally (for form validation etc.)
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
