import 'package:flutter/foundation.dart';
import '../data/api_service.dart';
import '../core/constants/api_constants.dart';
import '../models/chat_message.dart';

class ChatProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  String? _userId = 'user_001';
  bool _isLoading = false;
  bool _isInitialized = false;

  List<Map<String, dynamic>> _conversations = [];
  Map<String, List<ChatMessage>> _messages = {};

  List<Map<String, dynamic>> get conversations => List.unmodifiable(_conversations);
  bool get isLoading => _isLoading;

  void updateUserId(String? userId) {
    if (_userId != userId) {
      _userId = userId;
      _isInitialized = false;
      _conversations.clear();
      _messages.clear();
      notifyListeners();
      if (userId != null && userId.isNotEmpty) {
        fetchConversations();
      }
    }
  }

  Future<void> fetchConversations() async {
    if (_isInitialized) return;
    if (_userId == null || _userId!.isEmpty) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.get(ApiConstants.chatConversations(_userId!));
      final List data = response['data'] as List? ?? [];
      
      _conversations = data.map((json) {
        return {
          'id': json['id'].toString(),
          'sellerName': json['other_name'] as String? ?? 'Pengguna',
          'sellerAvatar': json['other_image'] as String? ?? 'assets/images/placeholder.png',
          'lastMessage': json['last_message'] as String? ?? '',
          'time': _formatTime(json['last_message_time']),
          'unread': 0,
          'productName': json['product_name'],
          'productImage': json['product_image'],
          'buyerId': json['buyer_id'].toString(),
          'sellerId': json['seller_id'].toString(),
          'productId': json['product_id']?.toString(),
        };
      }).toList();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Failed to fetch conversations: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshConversations() async {
    _isInitialized = false;
    await fetchConversations();
  }

  Future<void> fetchMessages(String conversationId) async {
    try {
      final response = await _api.get(ApiConstants.chatMessages(conversationId));
      final List data = response['data'] as List? ?? [];
      
      _messages[conversationId] = data.map((json) {
        return ChatMessage(
          id: json['id'].toString(),
          senderId: json['sender_id'].toString(),
          text: json['text'] as String? ?? '',
          timestamp: DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
          isMe: json['sender_id'].toString() == _userId,
          status: _parseStatus(json['status']),
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to fetch messages: $e');
    }
  }

  List<ChatMessage> getMessages(String conversationId) {
    return _messages[conversationId] ?? [];
  }

  Future<void> sendMessage(String conversationId, String text) async {
    if (_userId == null) return;
    
    // Optimistic UI update
    final tempMsg = ChatMessage(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      senderId: _userId!,
      text: text,
      timestamp: DateTime.now(),
      isMe: true,
      status: MessageStatus.sending,
    );
    
    if (_messages[conversationId] != null) {
      _messages[conversationId]!.add(tempMsg);
      notifyListeners();
    }

    try {
      final response = await _api.post(ApiConstants.sendMessage, body: {
        'conversation_id': conversationId,
        'sender_id': _userId,
        'text': text,
      });
      
      // Update with real message
      if (response['success'] == true) {
        await fetchMessages(conversationId);
        await refreshConversations(); // to update last message
      }
    } catch (e) {
      debugPrint('Failed to send message: $e');
    }
  }

  Future<String?> createOrGetConversation(String sellerId, {String? productId}) async {
    if (_userId == null) return null;
    try {
      final response = await _api.post(ApiConstants.createConversation, body: {
        'buyer_id': _userId,
        'seller_id': sellerId,
        'product_id': productId,
      });
      
      if (response['success'] == true && response['data'] != null) {
        final convId = response['data']['id'].toString();
        await refreshConversations();
        return convId;
      }
    } catch (e) {
      debugPrint('Failed to create conversation: $e');
    }
    return null;
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      final dt = DateTime.parse(timestamp.toString()).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  MessageStatus _parseStatus(dynamic statusStr) {
    switch(statusStr) {
      case 'sent': return MessageStatus.sent;
      case 'delivered': return MessageStatus.delivered;
      case 'read': return MessageStatus.read;
      default: return MessageStatus.sending;
    }
  }
}
