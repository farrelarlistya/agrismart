/// API configuration constants for the AgriSmart backend.
class ApiConstants {
  // 10.0.2.2  → hanya untuk Android Emulator
  // 192.168.x.x → IP lokal komputer, untuk HP Fisik di jaringan WiFi yang sama
  // Ganti IP di bawah jika IP WiFi Anda berubah
  static const String baseUrl = 'http://192.168.68.143:3000';

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

  /// Cart endpoints
  static String cart(String userId) => '/api/cart?user_id=$userId';
  static const String cartBase = '/api/cart';
  static String cartItem(String id) => '/api/cart/$id';
  static String clearCart(String userId) => '/api/cart/user/$userId';

  /// Chats endpoints
  static String chatConversations(String userId) => '/api/chats/conversations?user_id=$userId';
  static const String createConversation = '/api/chats/conversations';
  static String chatMessages(String conversationId) => '/api/chats/conversations/$conversationId/messages';
  static const String sendMessage = '/api/chats/messages';
}
