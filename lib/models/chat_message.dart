/// Represents a single chat message.
/// Designed to be easily serializable for backend/API integration.
class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isMe;
  final MessageStatus status;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.isMe,
    this.status = MessageStatus.sent,
  });

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? text,
    DateTime? timestamp,
    bool? isMe,
    MessageStatus? status,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isMe: isMe ?? this.isMe,
      status: status ?? this.status,
    );
  }
}

/// Message delivery status for read receipts.
enum MessageStatus { sending, sent, delivered, read }

/// Represents a chat conversation thread.
class ChatConversation {
  final String id;
  final String sellerName;
  final String sellerAvatar;
  final bool isOnline;
  final String? productName;
  final String? productImage;
  final double? productPrice;
  final String? productUnit;
  final List<ChatMessage> messages;

  const ChatConversation({
    required this.id,
    required this.sellerName,
    required this.sellerAvatar,
    this.isOnline = false,
    this.productName,
    this.productImage,
    this.productPrice,
    this.productUnit,
    this.messages = const [],
  });
}
