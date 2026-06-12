/// API configuration constants for the AgriSmart backend.
class ApiConstants {
  // Use 10.0.2.2 for Android emulator (maps to host's localhost)
  // Use localhost for web or physical device on same network
  static const String baseUrl = 'http://10.0.2.2:3000';

  // API endpoints
  static const String products = '/api/products';
  static const String categories = '/api/categories';
  static const String users = '/api/users';
  static const String stores = '/api/stores';
  static const String orders = '/api/orders';
  static const String login = '/api/users/login';
  static const String register = '/api/users/register';

  /// Get the full URL for a given path.
  static String url(String path) => '$baseUrl$path';

  /// User addresses endpoint.
  static String userAddresses(String userId) =>
      '/api/users/$userId/addresses';

  /// User favorites endpoint.
  static String userFavorites(String userId) =>
      '/api/users/$userId/favorites';

  /// Remove a specific favorite.
  static String userFavorite(String userId, String productId) =>
      '/api/users/$userId/favorites/$productId';

  /// Single address endpoint.
  static String address(String id) => '/api/addresses/$id';

  /// Set address as default.
  static String addressDefault(String id) => '/api/addresses/$id/default';

  /// Single product endpoint.
  static String product(String id) => '/api/products/$id';

  /// Single user endpoint.
  static String user(String id) => '/api/users/$id';

  /// Single order endpoint.
  static String order(String id) => '/api/orders/$id';
}
