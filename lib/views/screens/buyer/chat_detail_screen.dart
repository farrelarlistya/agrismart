import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/dummy_data.dart';
import '../../../models/chat_message.dart';
import 'product_detail_screen.dart';

/// Chat detail screen with WhatsApp/Telegram-style conversation UI.
/// Architecture is ready for real-time backend integration (e.g., WebSocket, Firebase).
class ChatDetailScreen extends StatefulWidget {
  final String sellerName;
  final String sellerAvatar;
  final bool isOnline;
  final String? productName;
  final String? productImage;
  final double? productPrice;
  final String? productUnit;

  const ChatDetailScreen({
    super.key,
    required this.sellerName,
    required this.sellerAvatar,
    this.isOnline = false,
    this.productName,
    this.productImage,
    this.productPrice,
    this.productUnit,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  // Messages list — in production, this would come from a state management layer
  late List<ChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    _messages = _generateDummyMessages();
    // Auto-scroll to bottom after build
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Scrolls the chat list to the most recent message.
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// Sends a new message. In production, this would call a messaging API.
  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderId: 'me',
        text: text,
        timestamp: DateTime.now(),
        isMe: true,
        status: MessageStatus.sent,
      ));
    });

    _messageController.clear();

    // Auto-scroll to the new message
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    // Simulate seller auto-reply after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
          id: 'msg_reply_${DateTime.now().millisecondsSinceEpoch}',
          senderId: 'seller',
          text: _getAutoReply(),
          timestamp: DateTime.now(),
          isMe: false,
          status: MessageStatus.read,
        ));
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    });
  }

  String _getAutoReply() {
    final replies = [
      'Baik kak, segera kami proses ya! 🙏',
      'Terima kasih sudah menghubungi kami!',
      'Stok masih tersedia kak, silakan order 😊',
      'Kami akan cek dan kabari secepatnya ya.',
      'Siap kak! Ada yang lain yang bisa dibantu?',
    ];
    return replies[_messages.length % replies.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Product inquiry card (if available)
          if (widget.productName != null) _buildProductInquiry(),
          // Chat messages
          Expanded(child: _buildMessageList()),
          // Input area
          _buildInputArea(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leadingWidth: 32,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        onPressed: () => Navigator.pop(context),
        color: AppColors.textPrimary,
        padding: EdgeInsets.zero,
      ),
      title: Row(
        children: [
          // Seller avatar with online indicator
          Stack(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E8B4F), Color(0xFF2ECC71)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppDimens.radiusM),
                ),
                child: Center(
                  child: Text(
                    widget.sellerAvatar,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (widget.isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          // Seller info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.sellerName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.isOnline ? 'Online' : 'Terakhir dilihat baru saja',
                  style: TextStyle(
                    fontSize: 11,
                    color: widget.isOnline
                        ? const Color(0xFF4CAF50)
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
          onPressed: () {
            // TODO: Show chat options menu
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.divider),
      ),
    );
  }

  void _navigateToProduct() {
    if (widget.productName == null) return;
    // Find the matching product from the data source
    try {
      final product = AppData.products.firstWhere(
        (p) => p.name == widget.productName,
      );
      Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)));
    } catch (_) {
      // Product not found in data — show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk tidak ditemukan'), backgroundColor: AppColors.grey),
      );
    }
  }

  Widget _buildProductInquiry() {
    return GestureDetector(
    onTap: _navigateToProduct,
    child: Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product image placeholder
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.greenBadge,
              borderRadius: BorderRadius.circular(AppDimens.radiusS),
            ),
            child: widget.productImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimens.radiusS),
                    child: Image.asset(
                      widget.productImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.eco,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                  )
                : const Icon(Icons.eco, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'INQUIRY',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.productName!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.productPrice != null)
                  Text(
                    'Rp ${_formatPrice(widget.productPrice!)}${widget.productUnit != null ? ' / ${widget.productUnit}' : ''}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.grey,
            size: 20,
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildMessageList() {
    final items = _buildMessageItemsWithSeparators();
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: items.length,
      itemBuilder: (context, index) => items[index],
    );
  }

  /// Builds the flat list of message widgets interleaved with date separators.
  List<Widget> _buildMessageItemsWithSeparators() {
    final List<Widget> items = [];
    String? lastDate;

    for (final message in _messages) {
      final dateLabel = _formatDateLabel(message.timestamp);
      if (dateLabel != lastDate) {
        items.add(_DateSeparator(label: dateLabel));
        lastDate = dateLabel;
      }
      items.add(_MessageBubble(message: message));
    }
    return items;
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        10,
        12,
        10 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Attachment button
          GestureDetector(
            onTap: () {
              // TODO: Show attachment picker (camera, gallery, file)
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.divider),
              ),
              child: const Icon(
                Icons.add,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Message input field
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 100),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(AppDimens.radiusRound),
                border: Border.all(color: AppColors.divider),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                textCapitalization: TextCapitalization.sentences,
                maxLines: null,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Pesan ${widget.sellerName}...',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.grey,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Send button
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E8B4F), Color(0xFF2ECC71)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helpers ---

  String _formatDateLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDate = DateTime(dt.year, dt.month, dt.day);

    if (msgDate == today) return 'HARI INI';
    if (msgDate == today.subtract(const Duration(days: 1))) return 'KEMARIN';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}.000';
    }
    return price.toStringAsFixed(0);
  }

  List<ChatMessage> _generateDummyMessages() {
    final now = DateTime.now();
    return [
      ChatMessage(
        id: 'msg_1',
        senderId: 'me',
        text: 'Halo kak, apakah ${widget.productName ?? 'produknya'} masih tersedia untuk pesanan minggu ini?',
        timestamp: now.subtract(const Duration(minutes: 18)),
        isMe: true,
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'msg_2',
        senderId: 'seller',
        text: 'Halo! Iya kak, kami baru panen batch segar tadi pagi. Mau pesan berapa kilogram?',
        timestamp: now.subtract(const Duration(minutes: 15)),
        isMe: false,
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'msg_3',
        senderId: 'me',
        text: 'Saya butuh sekitar 50kg untuk stall pasar organik kami akhir pekan ini. Bisa dikirim hari Kamis?',
        timestamp: now.subtract(const Duration(minutes: 12)),
        isMe: true,
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'msg_4',
        senderId: 'seller',
        text: 'Bisa kak! Untuk 50kg kami kasih harga spesial ya. Pengiriman Kamis pagi bisa diatur 🚛',
        timestamp: now.subtract(const Duration(minutes: 8)),
        isMe: false,
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'msg_5',
        senderId: 'me',
        text: 'Wah mantap! Berapa total harganya kak?',
        timestamp: now.subtract(const Duration(minutes: 5)),
        isMe: true,
        status: MessageStatus.delivered,
      ),
    ];
  }
}

// --- Private Widgets ---

/// Date separator label (e.g., "HARI INI", "KEMARIN")
class _DateSeparator extends StatelessWidget {
  final String label;
  const _DateSeparator({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColors.divider)),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppDimens.radiusRound),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Expanded(child: Divider(color: AppColors.divider)),
        ],
      ),
    );
  }
}

/// Individual chat message bubble with tail, timestamp, and delivery status.
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            // Seller avatar (small)
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(right: 6, bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.divider,
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.person,
                size: 16,
                color: AppColors.grey,
              ),
            ),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: isMe ? Colors.white : AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          fontSize: 10,
                          color: isMe
                              ? Colors.white.withValues(alpha: 0.7)
                              : AppColors.textSecondary,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        _buildStatusIcon(),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    switch (message.status) {
      case MessageStatus.sending:
        return Icon(
          Icons.access_time,
          size: 12,
          color: Colors.white.withValues(alpha: 0.7),
        );
      case MessageStatus.sent:
        return Icon(
          Icons.check,
          size: 14,
          color: Colors.white.withValues(alpha: 0.7),
        );
      case MessageStatus.delivered:
        return Icon(
          Icons.done_all,
          size: 14,
          color: Colors.white.withValues(alpha: 0.7),
        );
      case MessageStatus.read:
        return const Icon(
          Icons.done_all,
          size: 14,
          color: Color(0xFF80E8FF),
        );
    }
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
