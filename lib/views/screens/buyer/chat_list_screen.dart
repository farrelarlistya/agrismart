import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/agrismart_app_bar.dart';
import 'chat_detail_screen.dart';

/// Screen displaying the list of chat conversations.
/// Ready to be connected to a real messaging backend or state management layer.
class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  // Dummy conversations for UI demonstration
  static const List<Map<String, dynamic>> _dummyChats = [
    {
      'name': 'AgriFresh Bandung',
      'avatar': 'A',
      'lastMessage': 'Tomat organiknya ready stock, Kak!',
      'time': '14:30',
      'unread': 2,
      'isOnline': true,
      'productName': 'Tomat Organik',
      'productImage': 'assets/images/tomato.png',
      'productPrice': 20000.0,
      'productUnit': 'kg',
    },
    {
      'name': 'Tani Maju',
      'avatar': 'T',
      'lastMessage': 'Pesanan sudah kami proses ya',
      'time': '12:15',
      'unread': 0,
      'isOnline': false,
      'productName': 'Brokoli Segar',
      'productImage': 'assets/images/broccoli.png',
      'productPrice': 15000.0,
      'productUnit': 'kg',
    },
    {
      'name': 'Kebun Sehat',
      'avatar': 'K',
      'lastMessage': 'Buncis muda baru panen pagi ini 🌱',
      'time': 'Kemarin',
      'unread': 1,
      'isOnline': true,
      'productName': 'Buncis Muda',
      'productImage': 'assets/images/beans.png',
      'productPrice': 12000.0,
      'productUnit': 'kg',
    },
    {
      'name': 'Sawah Organik',
      'avatar': 'S',
      'lastMessage': 'Terima kasih sudah belanja!',
      'time': 'Kemarin',
      'unread': 0,
      'isOnline': false,
    },
    {
      'name': 'Lebah Alam',
      'avatar': 'L',
      'lastMessage': 'Madu hutan ready kak, fresh from farm',
      'time': '05 Mei',
      'unread': 0,
      'isOnline': false,
      'productName': 'Madu Hutan Murni',
      'productImage': 'assets/images/honey.png',
      'productPrice': 85000.0,
      'productUnit': 'botol',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AgriSmartAppBar(
        title: 'Pesan',
        showBack: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _dummyChats.length,
        separatorBuilder: (_, __) => const Divider(
          height: 1,
          indent: 76,
          endIndent: 16,
          color: AppColors.divider,
        ),
        itemBuilder: (context, index) {
          final chat = _dummyChats[index];
          return _ChatTile(
            name: chat['name'] as String,
            avatarLetter: chat['avatar'] as String,
            lastMessage: chat['lastMessage'] as String,
            time: chat['time'] as String,
            unreadCount: chat['unread'] as int,
            isOnline: chat['isOnline'] as bool? ?? false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatDetailScreen(
                    sellerName: chat['name'] as String,
                    sellerAvatar: chat['avatar'] as String,
                    isOnline: chat['isOnline'] as bool? ?? false,
                    productName: chat['productName'] as String?,
                    productImage: chat['productImage'] as String?,
                    productPrice: chat['productPrice'] as double?,
                    productUnit: chat['productUnit'] as String?,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final String name;
  final String avatarLetter;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isOnline;
  final VoidCallback? onTap;

  const _ChatTile({
    required this.name,
    required this.avatarLetter,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    this.isOnline = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar with online indicator
            Stack(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E8B4F), Color(0xFF2ECC71)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppDimens.radiusL),
                  ),
                  child: Center(
                    child: Text(
                      avatarLetter,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (isOnline)
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
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: unreadCount > 0
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 11,
                          color: unreadCount > 0
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage,
                          style: TextStyle(
                            fontSize: 13,
                            color: unreadCount > 0
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight: unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$unreadCount',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
