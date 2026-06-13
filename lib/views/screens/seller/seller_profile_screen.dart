import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/store_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

class SellerProfileScreen extends StatefulWidget {
  const SellerProfileScreen({super.key});

  @override
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _provinceController;
  late TextEditingController _cityController;
  late TextEditingController _postalCodeController;
  late TextEditingController _addressController;
  late TextEditingController _emailController;
  String? _logoPath;

  @override
  void initState() {
    super.initState();
    final store = context.read<StoreProvider>().store;
    _nameController = TextEditingController(text: store?.name ?? '');
    _phoneController = TextEditingController(text: store?.phone ?? '');
    _provinceController = TextEditingController(text: store?.province ?? '');
    _cityController = TextEditingController(text: store?.city ?? '');
    _postalCodeController = TextEditingController(text: store?.postalCode ?? '');
    _addressController = TextEditingController(text: store?.address ?? '');
    _emailController = TextEditingController(text: store?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _provinceController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) setState(() => _logoPath = image.path);
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama toko tidak boleh kosong')));
      return;
    }
    final storeProv = context.read<StoreProvider>();
    final data = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'province': _provinceController.text.trim(),
      'city': _cityController.text.trim(),
      'postal_code': _postalCodeController.text.trim(),
      'address': _addressController.text.trim(),
      'email': _emailController.text.trim(),
      if (_logoPath != null) 'logo_url': _logoPath,
    };

    final success = await storeProv.updateStore(data);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil toko berhasil diperbarui!'), backgroundColor: AppColors.primary));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memperbarui profil toko')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>().store;
    final currentLogo = _logoPath ?? store?.logoUrl;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Kelola Profil Toko', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),

            // Logo Section
            GestureDetector(
              onTap: _pickLogo,
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.greenBadge,
                      border: Border.all(color: AppColors.primary, width: 2.5),
                      image: currentLogo != null
                          ? DecorationImage(
                              image: currentLogo.startsWith('/')
                                  ? FileImage(File(currentLogo)) as ImageProvider
                                  : NetworkImage(currentLogo),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: currentLogo == null
                        ? const Icon(Icons.storefront, size: 48, color: AppColors.primary)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text('Ubah Foto Toko', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 24),

            // Form Section
            _buildSection('Informasi Toko', [
              AppTextField(label: 'Nama Toko', hint: 'Contoh: Kebun Berkah Tani', controller: _nameController),
              const SizedBox(height: 14),
              AppTextField(label: 'No. HP Toko', hint: '62812345...', controller: _phoneController, keyboardType: TextInputType.phone),
              const SizedBox(height: 14),
              AppTextField(label: 'Email Toko', hint: 'toko@email.com', controller: _emailController, keyboardType: TextInputType.emailAddress),
            ]),
            const SizedBox(height: 16),

            _buildSection('Lokasi Toko', [
              AppTextField(label: 'Provinsi', hint: 'Jawa Barat', controller: _provinceController),
              const SizedBox(height: 14),
              AppTextField(label: 'Kota / Kabupaten', hint: 'Kabupaten Bandung', controller: _cityController),
              const SizedBox(height: 14),
              AppTextField(label: 'Kode Pos', hint: '40971', controller: _postalCodeController, keyboardType: TextInputType.number),
              const SizedBox(height: 14),
              AppTextField(label: 'Alamat Lengkap', hint: 'Jl. Raya No. 1, RT 01/RW 02', controller: _addressController),
            ]),
            const SizedBox(height: 32),

            Consumer<StoreProvider>(
              builder: (_, sp, __) => sp.isLoading
                  ? const CircularProgressIndicator(color: AppColors.primary)
                  : PrimaryButton(text: 'Simpan Perubahan', onPressed: _save),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}
