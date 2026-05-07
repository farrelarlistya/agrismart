import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/address_provider.dart';
import '../../../models/shipping_address.dart';
import '../../widgets/agrismart_app_bar.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AgriSmartAppBar(title: 'Alamat Pengiriman', showBack: true),
      body: Consumer<AddressProvider>(
        builder: (context, addrProv, _) => ListView(padding: const EdgeInsets.all(16), children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.greenBadge, borderRadius: BorderRadius.circular(AppDimens.radiusL)),
            child: const Row(children: [
              Icon(Icons.location_on, color: AppColors.primary, size: 18),
              SizedBox(width: 10),
              Expanded(child: Text('Daftar Alamat\nKelola lokasi pengiriman produk pertanian Anda.', style: TextStyle(fontSize: 12, color: AppColors.primary, height: 1.5))),
            ]),
          ),
          const SizedBox(height: 16),
          // Add new address button
          GestureDetector(
            onTap: () => _showAddAddressSheet(context, addrProv),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppDimens.radiusL), border: Border.all(color: AppColors.primary)),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.add_circle_outline, color: AppColors.primary, size: 18),
                SizedBox(width: 8),
                Text('Tambah Alamat Baru', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          // Address list
          ...addrProv.addresses.map((addr) => _AddressCard(
            address: addr,
            onSetDefault: () => addrProv.setDefault(addr.id),
            onEdit: () => _showEditAddressSheet(context, addrProv, addr),
            onDelete: () => addrProv.deleteAddress(addr.id),
          )),
        ]),
      ),
    );
  }

  void _showAddAddressSheet(BuildContext context, AddressProvider addrProv) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addrCtrl = TextEditingController();
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Tambah Alamat Baru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          AppTextField(label: 'Nama Penerima', hint: 'Cth: Julian Harvest', controller: nameCtrl),
          const SizedBox(height: 12),
          AppTextField(label: 'Nomor Telepon', hint: '+62 812 xxxx xxxx', controller: phoneCtrl),
          const SizedBox(height: 12),
          AppTextField(label: 'Alamat Lengkap', hint: 'Jl., RT/RW, Kelurahan, Kecamatan...', controller: addrCtrl),
          const SizedBox(height: 20),
          PrimaryButton(text: 'Simpan Alamat', onPressed: () {
            if (nameCtrl.text.isNotEmpty && phoneCtrl.text.isNotEmpty && addrCtrl.text.isNotEmpty) {
              addrProv.addAddress(recipientName: nameCtrl.text, phone: phoneCtrl.text, address: addrCtrl.text);
              Navigator.pop(context);
            }
          }),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  void _showEditAddressSheet(BuildContext context, AddressProvider addrProv, ShippingAddress addr) {
    final nameCtrl = TextEditingController(text: addr.recipientName);
    final phoneCtrl = TextEditingController(text: addr.phone);
    final addrCtrl = TextEditingController(text: addr.address);
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Ubah Alamat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          AppTextField(label: 'Nama Penerima', hint: 'Cth: Julian Harvest', controller: nameCtrl),
          const SizedBox(height: 12),
          AppTextField(label: 'Nomor Telepon', hint: '+62 812 xxxx xxxx', controller: phoneCtrl),
          const SizedBox(height: 12),
          AppTextField(label: 'Alamat Lengkap', hint: 'Jl., RT/RW, Kelurahan, Kecamatan...', controller: addrCtrl),
          const SizedBox(height: 20),
          PrimaryButton(text: 'Simpan Perubahan', onPressed: () {
            addrProv.updateAddress(addr.id, recipientName: nameCtrl.text, phone: phoneCtrl.text, address: addrCtrl.text);
            Navigator.pop(context);
          }),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final ShippingAddress address;
  final VoidCallback onSetDefault;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _AddressCard({required this.address, required this.onSetDefault, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        border: address.isDefault ? Border.all(color: AppColors.primary, width: 1.5) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(address.recipientName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
          if (address.isDefault) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppColors.greenBadge, borderRadius: BorderRadius.circular(20)), child: const Text('UTAMA', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.primary))),
        ]),
        const SizedBox(height: 4),
        Text(address.phone, style: AppTextStyles.bodySmall),
        const SizedBox(height: 4),
        Text(address.address, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5)),
        const SizedBox(height: 12),
        Row(children: [
          _AddrButton(label: 'Ubah', onTap: onEdit),
          const SizedBox(width: 8),
          _AddrButton(label: 'Hapus', onTap: onDelete),
          if (!address.isDefault) ...[
            const SizedBox(width: 8),
            _AddrButton(label: 'Jadikan Utama', onTap: onSetDefault, isPrimary: true),
          ],
        ]),
      ]),
    );
  }
}

class _AddrButton extends StatelessWidget {
  final String label; final VoidCallback onTap; final bool isPrimary;
  const _AddrButton({required this.label, required this.onTap, this.isPrimary = false});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : Colors.transparent,
          border: Border.all(color: isPrimary ? AppColors.primary : AppColors.divider),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isPrimary ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }
}
