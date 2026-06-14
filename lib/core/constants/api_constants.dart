import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// API configuration constants for the AgriSmart backend.
///
/// [baseUrl] is resolved automatically at startup via [init]:
///   • Android Emulator  → http://10.0.2.2:3000
///   • Physical device    → scans the local network to discover the backend
///   • Fallback           → http://localhost:3000
class ApiConstants {
  ApiConstants._();

  static const int port = 3000;

  /// Resolved base URL. Call [init] before using.
  static String _baseUrl = 'http://localhost:$port';
  static String get baseUrl => _baseUrl;

  // ──────────────────────────────────────────────────────────
  //  Initialization — call once in main() before runApp()
  // ──────────────────────────────────────────────────────────

  /// Discovers the backend server and sets [baseUrl].
  static Future<void> init() async {
    try {
      final ip = await _discoverServerIp();
      _baseUrl = 'http://$ip:$port';
      debugPrint('✅ ApiConstants: baseUrl resolved to $_baseUrl');
    } catch (e) {
      debugPrint('⚠️ ApiConstants: auto‑discovery failed ($e), '
          'using fallback $_baseUrl');
    }
  }

  /// Try to find the backend server automatically.
  static Future<String> _discoverServerIp() async {
    // 1. Android Emulator special alias
    if (Platform.isAndroid) {
      if (await _isReachable('10.0.2.2')) {
        debugPrint('📱 Detected Android Emulator (10.0.2.2)');
        return '10.0.2.2';
      }
    }

    // 2. iOS Simulator / macOS — localhost works
    if (Platform.isIOS || Platform.isMacOS) {
      if (await _isReachable('127.0.0.1')) {
        return '127.0.0.1';
      }
    }

    // 3. Physical device: find the gateway IP from device interfaces
    //    then scan common host IPs in the same subnet.
    final gatewaySubnet = await _getDeviceSubnet();
    if (gatewaySubnet != null) {
      debugPrint('🔍 Scanning subnet $gatewaySubnet.x …');
      // Scan popular host addresses in parallel (1‑20)
      final futures = <Future<String?>>[];
      for (int i = 1; i <= 20; i++) {
        final candidate = '$gatewaySubnet.$i';
        futures.add(_isReachable(candidate).then((ok) => ok ? candidate : null));
      }
      // Also try .100 and .254 (common static IPs)
      for (final extra in [100, 200, 254]) {
        final candidate = '$gatewaySubnet.$extra';
        futures.add(_isReachable(candidate).then((ok) => ok ? candidate : null));
      }

      final results = await Future.wait(futures);
      final found = results.firstWhere((ip) => ip != null, orElse: () => null);
      if (found != null) {
        debugPrint('🎯 Found server at $found');
        return found;
      }
    }

    // 4. Last resort — localhost
    return 'localhost';
  }

  /// Returns the first 3 octets of the device's LAN IP, e.g. "192.168.100".
  static Future<String?> _getDeviceSubnet() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
      );
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          final ip = addr.address;
          // Skip virtual / Docker / VPN addresses
          if (ip.startsWith('127.') || ip.startsWith('172.')) continue;
          final parts = ip.split('.');
          if (parts.length == 4) {
            return '${parts[0]}.${parts[1]}.${parts[2]}';
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Could not list network interfaces: $e');
    }
    return null;
  }

  /// Check if the AgriSmart server is reachable at the given [ip].
  static Future<bool> _isReachable(String ip) async {
    try {
      final uri = Uri.parse('http://$ip:$port/');
      final response = await http.get(uri).timeout(
        const Duration(milliseconds: 800),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ──────────────────────────────────────────────────────────
  //  API endpoints (unchanged)
  // ──────────────────────────────────────────────────────────

  static const String products = '/api/products';
  static const String categories = '/api/categories';
  static const String users = '/api/users';
  static const String stores = '/api/stores';
  static const String orders = '/api/orders';
  static const String login = '/api/users/login';
  static const String register = '/api/users/register';

  /// Get the full URL for a given path.
  static String url(String path) => '$baseUrl$path';

  /// Resolves an image URL from the database.
  ///
  /// Handles these cases:
  ///   1. Server path     → `/uploads/products/x.jpg`  → prepend baseUrl
  ///   2. Legacy full URL → `http://old-ip:3000/uploads/...` → replace host with current baseUrl
  ///   3. Local file path → `/data/user/0/...` → skip (invalid, returns empty)
  ///   4. Empty / null    → returns empty string
  static String fullImageUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.isEmpty) return '';

    // Server-relative path like "/uploads/..."
    if (rawUrl.startsWith('/uploads/')) {
      return '$baseUrl$rawUrl';
    }

    // Legacy absolute URL with old IP — extract the path and re-attach
    if (rawUrl.startsWith('http')) {
      final uri = Uri.tryParse(rawUrl);
      if (uri != null && uri.path.startsWith('/uploads/')) {
        return '$baseUrl${uri.path}';
      }
      // If it's an http URL but NOT an /uploads/ path, return as-is
      // (could be an external image URL)
      return rawUrl;
    }

    // Anything else (local file paths like /data/user/...) is invalid
    // Return empty so the error widget is shown instead of a broken image
    return '';
  }

  /// User addresses endpoint.
  static String userAddresses(String userId) => '/api/users/$userId/addresses';

  /// User favorites endpoint.
  static String userFavorites(String userId) => '/api/users/$userId/favorites';

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
  static String chatConversations(String userId) =>
      '/api/chats/conversations?user_id=$userId';
  static const String createConversation = '/api/chats/conversations';
  static String chatMessages(String conversationId) =>
      '/api/chats/conversations/$conversationId/messages';
  static const String sendMessage = '/api/chats/messages';
}
