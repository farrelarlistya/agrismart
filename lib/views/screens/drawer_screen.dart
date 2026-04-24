import 'package:flutter/material.dart';
import '../screens/app_constants.dart';
import '../widgets/common_widgets.dart';
import 'profile_screen.dart';
import 'address_screen.dart';
import 'login.dart';
import 'seller_main_screen.dart';

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
                    _buildSection('AKUN TOKO', [
                      _DrawerItem(
                        icon: Icons.person_outline,
                        label: 'Pengaturan Akun',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ProfileScreen()),
                          );
                        },
                      ),
                      _DrawerItem(
                        icon: Icons.location_on_outlined,
                        label: 'Alamat Pengiriman',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AddressScreen()),
                          );
                        },
                      ),
                    ]),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Divider(color: AppColors.divider),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SellerMainScreen()),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius:
                                BorderRadius.circular(AppDimens.radiusM),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.store,
                                  color: Colors.white, size: 18),
                              const SizedBox(width: 10),
                              const Text(
                                'Buat Toko',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.arrow_forward_ios,
                                  color: Colors.white, size: 14),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSection('APLIKASI LAIN', [
                      _DrawerItem(
                        icon: Icons.notifications_outlined,
                        label: 'Notifikasi',
                        onTap: () => Navigator.pop(context),
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
            _DrawerItem(
              icon: Icons.logout,
              label: 'Keluar',
              iconColor: AppColors.red,
              textColor: AppColors.red,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.greenBadge,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person,
                color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Muh Hanif',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Text(
                  'muh.hanif@email.com',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: AppColors.textPrimary, size: 22),
            onPressed: () {},
          ),
        ],
      ),
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
  final String? trailing;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.textColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? AppColors.textSecondary,
        size: 20,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: textColor ?? AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing != null
          ? Text(trailing!,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary))
          : const Icon(Icons.chevron_right, size: 18, color: AppColors.grey),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      dense: true,
      onTap: onTap,
    );
  }
}
