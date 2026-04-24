import 'package:flutter/material.dart';
import '../screens/app_constants.dart';
import '../widgets/common_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AgriSmartAppBar(title: 'Pengaturan Akun', showBack: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E8B4F), Color(0xFF2ECC71)],
                ),
                borderRadius: BorderRadius.circular(AppDimens.radiusXL),
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.person,
                            color: Colors.white, size: 46),
                      ),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit,
                            size: 14, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Muh Hanif',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'muh.hanif@email.com',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StatItem(label: 'Pesanan', value: '124'),
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.white.withOpacity(0.3),
                        margin:
                            const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      _StatItem(label: 'Favorit', value: '19'),
                    ],
                  ),
                ],
              ),
            ),
            // Data diri
            _buildSection(
              context,
              title: 'DATA DIRI',
              items: [
                _ProfileItem(
                  label: 'Nama Lengkap',
                  value: 'Muhammad Hanif',
                  onEdit: () {},
                ),
                _ProfileItem(
                  label: 'Nomor Telepon',
                  value: '+62 812 3456 7890',
                  onEdit: () {},
                ),
                _ProfileItem(
                  label: 'Email',
                  value: 'muh.hanif@email.com',
                  onEdit: () {},
                ),
                _ProfileItem(
                  label: 'Tanggal Lahir',
                  value: '16 Mei 2005',
                  onEdit: () {},
                ),
                _ProfileItem(
                  label: 'Jenis Kelamin',
                  value: 'Laki-laki',
                  onEdit: () {},
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildSection(
              context,
              title: 'KEAMANAN AKUN',
              items: [
                _ProfileItem(
                  label: 'Kata Sandi',
                  value: '••••••••',
                  onEdit: () {},
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildSection(
              context,
              title: 'PREFERENSI',
              items: [
                _ProfileToggle(
                  label: 'Notifikasi',
                  icon: Icons.notifications_outlined,
                  value: true,
                ),
                _ProfileItem(
                  label: 'Bahasa',
                  value: 'Bahasa Indonesia',
                  onEdit: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Hapus Akun'),
                      content: const Text(
                          'Apakah Anda yakin ingin menghapus akun? Tindakan ini tidak dapat dibatalkan.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Hapus',
                              style: TextStyle(color: AppColors.red)),
                        ),
                      ],
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.red),
                  minimumSize: const Size(double.infinity, 46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusL),
                  ),
                ),
                child: const Text(
                  'Hapus Akun',
                  style: TextStyle(
                    color: AppColors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context,
      {required String title, required List<Widget> items}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.grey,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onEdit;

  const _ProfileItem({
    required this.label,
    required this.value,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: AppTextStyles.bodySmall,
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: GestureDetector(
        onTap: onEdit,
        child: const Icon(Icons.edit_outlined,
            size: 18, color: AppColors.grey),
      ),
      dense: true,
    );
  }
}

class _ProfileToggle extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool value;

  const _ProfileToggle({
    required this.label,
    required this.icon,
    required this.value,
  });

  @override
  State<_ProfileToggle> createState() => _ProfileToggleState();
}

class _ProfileToggleState extends State<_ProfileToggle> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(widget.icon, size: 20, color: AppColors.textSecondary),
      title: Text(
        widget.label,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Switch(
        value: _value,
        onChanged: (v) => setState(() => _value = v),
        activeColor: AppColors.primary,
      ),
      dense: true,
    );
  }
}
