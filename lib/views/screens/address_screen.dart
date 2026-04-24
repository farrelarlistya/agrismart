import 'package:flutter/material.dart';
import '../screens/app_constants.dart';
import '../widgets/common_widgets.dart';

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  final List<Map<String, dynamic>> _addresses = const [
    {
      'name': 'Julian Harvest',
      'phone': '0812-3456-7890',
      'address':
          'Jl. Raya Kebun raya No. 58, Blok C2, Villa Agrikultura, Kecamatan Cisarua, Kabupaten Bogor, Jawa Barat, 16793',
      'isPrimary': true,
    },
    {
      'name': 'Julian Harvest (Warehouse)',
      'phone': '0812-9382-7768',
      'address':
          'Kawasan Industri Sentral, Pergudangan AgriSmart Blok C-12, Cileungsi, Kabupaten Bogor, Jawa Barat, 16870',
      'isPrimary': false,
    },
    {
      'name': 'Bapak Harvest',
      'phone': '0811-1111-2323',
      'address':
          'Desa Sukamakur, RT 05 RW 02, Kec. Sukamakmur, Kab. Bogor, Jawa Barat, 16810',
      'isPrimary': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AgriSmartAppBar(title: 'Alamat Pengiriman', showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header info
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.greenBadge,
              borderRadius: BorderRadius.circular(AppDimens.radiusL),
            ),
            child: const Row(
              children: [
                Icon(Icons.location_on, color: AppColors.primary, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Daftar Alamat\nKelola lokasi pengiriman hasil panen dan logistik pertanian Anda dengan presisi.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Add new address
          GestureDetector(
            onTap: () => _showAddAddressSheet(context),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppDimens.radiusL),
                border: Border.all(
                  color: AppColors.primary,
                  style: BorderStyle.solid,
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline,
                      color: AppColors.primary, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Tambah Alamat Baru',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Address list
          ..._addresses.map(
            (addr) => _AddressCard(address: addr),
          ),
        ],
      ),
    );
  }

  void _showAddAddressSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tambah Alamat Baru',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            AppTextField(label: 'Nama Penerima', hint: 'Cth: Julian Harvest'),
            const SizedBox(height: 12),
            AppTextField(label: 'Nomor Telepon', hint: '+62 812 xxxx xxxx'),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Alamat Lengkap',
              hint: 'Jl., RT/RW, Kelurahan, Kecamatan...',
            ),
            const SizedBox(height: 20),
            PrimaryButton(text: 'Simpan Alamat', onPressed: () => Navigator.pop(context)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final Map<String, dynamic> address;

  const _AddressCard({required this.address});

  @override
  Widget build(BuildContext context) {
    final isPrimary = address['isPrimary'] as bool;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        border: isPrimary
            ? Border.all(color: AppColors.primary, width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                address['name'] as String,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (isPrimary) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.greenBadge,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'ALAMAT TERPILIH',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            address['phone'] as String,
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            address['address'] as String,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _AddrButton(label: 'Ubah', onTap: () {}),
              const SizedBox(width: 8),
              _AddrButton(label: 'Salin', onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddrButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AddrButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
