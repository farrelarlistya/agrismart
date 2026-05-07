import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';

/// Manages user profile state (CRU — Create, Read, Update).
class UserProvider extends ChangeNotifier {
  UserProfile _user = const UserProfile(
    id: 'user_001',
    name: 'Julian Harvest',
    email: 'julian.harvest@email.com',
    phone: '0812-3456-7890',
  );

  bool _isLoading = false;

  UserProfile get user => _user;
  bool get isLoading => _isLoading;

  /// Update the user profile fields.
  void updateProfile({String? name, String? email, String? phone}) {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    Future.delayed(const Duration(milliseconds: 800), () {
      _user = _user.copyWith(name: name, email: email, phone: phone);
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Set loading state externally (for form validation etc.)
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
