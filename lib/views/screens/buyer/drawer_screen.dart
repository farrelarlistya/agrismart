import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/auth_guard.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/store_provider.dart';
import 'profile_screen.dart';
import 'address_screen.dart';
import 'chat_list_screen.dart';
import '../auth/login_screen.dart';
import '../seller/seller_main_screen.dart';
import '../seller/seller_register_screen.dart';

class DrawerScreen extends StatelessWidget {
  const DrawerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.white,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const Divider(color: AppColors.divider, height: 1),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection('AKUN SAYA', [
                      _DrawerItem(
                        icon: Icons.person_outline,
                        label: 'Pengaturan Akun',
                        onTap: () {
                          Navigator.pop(context);
                          AuthGuard.run(context, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProfileScreen(),
                              ),
                            );
                          });
                        },
                      ),
                      _DrawerItem(
                        icon: Icons.location_on_outlined,
                        label: 'Alamat Pengiriman',
                        onTap: () {
                          Navigator.pop(context);
                          AuthGuard.run(context, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddressScreen(),
                              ),
                            );
                          });
                        },
                      ),
                    ]),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Divider(color: AppColors.divider),
                    ),
                    Consumer<StoreProvider>(
                      builder: (context, storeProv, _) {
                        final hasStore = storeProv.hasStore;
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              AuthGuard.run(context, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => hasStore
                                        ? const SellerMainScreen()
                                        : const SellerRegisterScreen(),
                                  ),
                                );
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius:
                                    BorderRadius.circular(AppDimens.radiusM),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    hasStore ? Icons.storefront : Icons.store,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    hasStore ? 'Toko Saya' : 'Buat Toko',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white,
                                    size: 14,
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildSection('LAINNYA', [
                      _DrawerItem(
                        icon: Icons.chat_bubble_outline,
                        label: 'Pesan',
                        onTap: () {
                          Navigator.pop(context);
                          AuthGuard.run(context, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ChatListScreen(),
                              ),
                            );
                          });
                        },
                      ),
                      _DrawerItem(
                        icon: Icons.help_outline,
                        label: 'Bantuan',
                        onTap: () => Navigator.pop(context),
                      ),
                      _DrawerItem(
                        icon: Icons.info_outline,
                        label: 'Tentang AgriSmart',
                        onTap: () => Navigator.pop(context),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
            const Divider(color: AppColors.divider, height: 1),
            Consumer<UserProvider>(
              builder: (context, userProv, _) {
                final isGuest = userProv.user.id.isEmpty;
                return _DrawerItem(
                  icon: isGuest ? Icons.login : Icons.logout,
                  label: isGuest ? 'Masuk' : 'Keluar',
                  iconColor: isGuest ? AppColors.primary : AppColors.red,
                  textColor: isGuest ? AppColors.primary : AppColors.red,
                  onTap: () {
                    Navigator.pop(context);
                    if (isGuest) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    } else {
                      userProv.logout();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProv, _) {
        final isGuest = userProv.user.id.isEmpty;
        return GestureDetector(
          onTap: isGuest
              ? () {
                  Navigator.pop(context); // Close drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              : null,
          child: Container(
            color: Colors.transparent,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.greenBadge,
                    shape: BoxShape.circle,
                    image: !isGuest && userProv.user.avatarUrl != null
                        ? DecorationImage(
                            image: NetworkImage(userProv.user.avatarUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: (!isGuest && userProv.user.avatarUrl != null)
                      ? null
                      : Center(
                          child: Text(
                            !isGuest && userProv.user.name.isNotEmpty
                                ? userProv.user.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        !isGuest ? userProv.user.name : 'Tamu',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        !isGuest
                            ? userProv.user.email
                            : 'Ketuk untuk masuk ke akun Anda',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isGuest)
                  IconButton(
                    icon: const Icon(
                      Icons.chat_bubble_outline,
                      color: AppColors.textPrimary,
                      size: 22,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChatListScreen()),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.grey,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          ...items,
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.textSecondary, size: 20),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: textColor ?? AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      minLeadingWidth: 24,
      horizontalTitleGap: 8,
      dense: true,
      onTap: onTap,
    );
  }
}
