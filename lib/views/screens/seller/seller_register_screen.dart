import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/store_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';
import 'seller_main_screen.dart';

class SellerRegisterScreen extends StatefulWidget {
  const SellerRegisterScreen({super.key});
  @override
  State<SellerRegisterScreen> createState() => _SellerRegisterScreenState();
}

class _SellerRegisterScreenState extends State<SellerRegisterScreen> {
  int _currentStep = 0;
  final _pageController = PageController();
  
  // Step 1 Controllers (Profil Toko)
  final _storeNameController = TextEditingController();
  final _provinceController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _addressController = TextEditingController();
  String? _logoPath;
  
  // Step 2 Controllers (Identitas Pemilik)
  final _nikController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() { 
    _pageController.dispose(); 
    _storeNameController.dispose(); 
    _provinceController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _addressController.dispose(); 
    _nikController.dispose();
    _ownerNameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose(); 
  }

  Future<void> _pickLogo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      setState(() {
        _logoPath = image.path;
      });
    }
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 17, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  bool _validateStep1() {
    if (_storeNameController.text.trim().isEmpty || 
        _provinceController.text.trim().isEmpty || 
        _cityController.text.trim().isEmpty || 
        _postalCodeController.text.trim().isEmpty || 
        _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua field lokasi dan nama wajib diisi')));
      return false;
    }
    if (_logoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logo Toko wajib diunggah')));
      return false;
    }
    return true;
  }

  bool _validateStep2() {
    if (_nikController.text.trim().isEmpty || _ownerNameController.text.trim().isEmpty || 
        _dobController.text.trim().isEmpty || _phoneController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua field Identitas Pemilik wajib diisi')));
      return false;
    }
    
    if (_nikController.text.trim().length != 16) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('NIK harus 16 digit')));
      return false;
    }

    String phone = _phoneController.text.trim();
    if (!phone.startsWith('8')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nomor HP harus diawali angka 8 (setelah +62)')));
      return false;
    }

    try {
      List<String> parts = _dobController.text.trim().split('/');
      if (parts.length != 3) parts = _dobController.text.trim().split('-');
      if (parts.length == 3) {
        int year = int.parse(parts[2].length == 4 ? parts[2] : parts[0]);
        int month = int.parse(parts[1]);
        int day = int.parse(parts[2].length == 4 ? parts[0] : parts[2]);
        DateTime dob = DateTime(year, month, day);
        DateTime now = DateTime.now();
        int age = now.year - dob.year;
        if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
          age--;
        }
        if (age < 17) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Umur pemilik minimal harus 17 tahun')));
          return false;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Format tanggal lahir salah (Gunakan DD/MM/YYYY)')));
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Format tanggal lahir tidak valid (Gunakan DD/MM/YYYY)')));
      return false;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Format email tidak valid')));
      return false;
    }

    return true;
  }

  Future<void> _nextStep() async {
    if (_currentStep == 0 && !_validateStep1()) return;
    if (_currentStep == 1 && !_validateStep2()) return;

    if (_currentStep < 2) { 
      setState(() => _currentStep++); 
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut); 
    } else { 
      final userId = context.read<UserProvider>().user.id;
      final storeProv = context.read<StoreProvider>();
      
      final data = {
        'user_id': userId,
        'name': _storeNameController.text.trim(),
        'phone': '62${_phoneController.text.trim()}',
        'pic_name': _ownerNameController.text.trim(),
        'province': _provinceController.text.trim(),
        'city': _cityController.text.trim(),
        'postal_code': _postalCodeController.text.trim(),
        'address': _addressController.text.trim(),
        'nik': _nikController.text.trim(),
        'logo_url': _logoPath ?? '',
        'email': _emailController.text.trim(),
        'dob': _dobController.text.trim(),
      };

      final success = await storeProv.registerStore(data);
      if (success && mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SellerMainScreen())); 
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mendaftar toko')));
      }
    }
  }

  void _prevStep() {
    if (_currentStep > 0) { 
      setState(() => _currentStep--); 
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut); 
    } else { 
      Navigator.pop(context); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: AppColors.white,
      appBar: AppBar(backgroundColor: AppColors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textPrimary), onPressed: _prevStep),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Container(width: 22, height: 22, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(5)), child: const Icon(Icons.eco, color: Colors.white, size: 14)), const SizedBox(width: 6),
            const Text('AgriSmart Seller', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary))]),
        ]),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(50), child: Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12), child: Column(children: [
          Row(children: [Text('Langkah ${_currentStep + 1} dari 3', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)), const Spacer(), Text(_stepLabel(_currentStep), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary))]),
          const SizedBox(height: 6),
          Row(children: List.generate(3, (i) => Expanded(child: Container(height: 4, margin: EdgeInsets.only(right: i < 2 ? 4 : 0), decoration: BoxDecoration(color: i <= _currentStep ? AppColors.primary : AppColors.greyLight, borderRadius: BorderRadius.circular(2)))))),
        ]))),
      ),
      body: PageView(controller: _pageController, physics: const NeverScrollableScrollPhysics(), children: [
        _Step1Profile(
          storeNameController: _storeNameController, 
          provinceController: _provinceController,
          cityController: _cityController,
          postalCodeController: _postalCodeController,
          addressController: _addressController,
          logoPath: _logoPath,
          onPickLogo: _pickLogo,
          onNext: _nextStep
        ),
        _Step2Identity(
          nikController: _nikController,
          ownerNameController: _ownerNameController,
          dobController: _dobController,
          phoneController: _phoneController,
          emailController: _emailController,
          onPickDob: _pickDob,
          onNext: _nextStep, 
          onBack: _prevStep
        ),
        _Step3Review(
          storeName: _storeNameController.text,
          address: _addressController.text,
          nik: _nikController.text,
          ownerName: _ownerNameController.text,
          onSubmit: _nextStep, 
          onBack: _prevStep
        ),
      ]),
    );
  }

  String _stepLabel(int step) { const labels = ['PROFIL TOKO', 'IDENTITAS PEMILIK', 'TINJAU AKHIR']; return labels[step]; }
}

class _Step1Profile extends StatelessWidget {
  final TextEditingController storeNameController; 
  final TextEditingController provinceController;
  final TextEditingController cityController;
  final TextEditingController postalCodeController;
  final TextEditingController addressController; 
  final String? logoPath;
  final VoidCallback onPickLogo;
  final VoidCallback onNext;

  const _Step1Profile({
    required this.storeNameController, 
    required this.provinceController,
    required this.cityController,
    required this.postalCodeController,
    required this.addressController, 
    this.logoPath,
    required this.onPickLogo,
    required this.onNext
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Siapkan\nProfil Tokomu', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1.2)),
      const SizedBox(height: 8), const Text('Lengkapi identitas dasar toko pertanianmu.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
      const SizedBox(height: 24), const Text('Logo Toko', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)), const SizedBox(height: 8),
      
      GestureDetector(onTap: onPickLogo, child: Container(width: double.infinity, height: 120, decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(AppDimens.radiusL), border: Border.all(color: AppColors.divider)),
        child: logoPath != null 
          ? ClipRRect(borderRadius: BorderRadius.circular(AppDimens.radiusL), child: Image.file(File(logoPath!), fit: BoxFit.cover, width: double.infinity, height: 120))
          : Column(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.camera_alt_outlined, color: AppColors.grey, size: 28), SizedBox(height: 6), Text('Unggah logo untuk identitas tokomu.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.4)), SizedBox(height: 6), Text('Pilih Gambar', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600))]))),
      
      const SizedBox(height: 16), AppTextField(label: 'Nama Toko', hint: 'Contoh: Kebun Berkah Tani', controller: storeNameController),
      const SizedBox(height: 16), AppTextField(label: 'Provinsi', hint: 'Jawa Barat', controller: provinceController),
      const SizedBox(height: 16), AppTextField(label: 'Kota / Kabupaten', hint: 'Kabupaten Bandung', controller: cityController),
      const SizedBox(height: 16), AppTextField(label: 'Kode Pos', hint: '40971', controller: postalCodeController),
      const SizedBox(height: 16), AppTextField(label: 'Alamat Lengkap Toko', hint: 'Jl. Raya Ciwidey No. 123, RT 01/RW 04', controller: addressController),
      const SizedBox(height: 32), PrimaryButton(text: 'Lanjut ke Identitas', onPressed: onNext),
    ]));
  }
}

class _Step2Identity extends StatelessWidget {
  final TextEditingController nikController;
  final TextEditingController ownerNameController;
  final TextEditingController dobController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final VoidCallback onPickDob;
  final VoidCallback onNext; 
  final VoidCallback onBack;

  const _Step2Identity({
    required this.nikController, 
    required this.ownerNameController,
    required this.dobController,
    required this.phoneController,
    required this.emailController,
    required this.onPickDob,
    required this.onNext, 
    required this.onBack
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Lengkapi\nIdentitas Diri', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1.2)), const SizedBox(height: 8),
      const Text('Pastikan data sesuai dengan dokumen resmi Anda.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)), const SizedBox(height: 20),
      
      AppTextField(label: 'NIK (16 Digit)', hint: '3270••••••••••••••', controller: nikController, keyboardType: TextInputType.number), const SizedBox(height: 16),
      AppTextField(label: 'Nama Lengkap Sesuai KTP', hint: 'Contoh: Budi Setiawan', controller: ownerNameController), const SizedBox(height: 16),
      AppTextField(label: 'Tanggal Lahir', hint: 'DD/MM/YYYY', controller: dobController, readOnly: true, onTap: onPickDob), const SizedBox(height: 16),
      AppTextField(label: 'No. HP Aktif', hint: '81234567890', prefixText: '+62 ', controller: phoneController, keyboardType: TextInputType.phone), const SizedBox(height: 16),
      AppTextField(label: 'Alamat Email', hint: 'nama@email.com', controller: emailController, keyboardType: TextInputType.emailAddress), const SizedBox(height: 32),
      
      Row(children: [
        Expanded(child: OutlinedButton(onPressed: onBack, style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.grey), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusL))), child: const Text('Kembali', style: TextStyle(color: AppColors.textSecondary)))),
        const SizedBox(width: 12), Expanded(flex: 2, child: PrimaryButton(text: 'Tinjau →', onPressed: onNext)),
      ]),
    ]));
  }
}

class _Step3Review extends StatelessWidget {
  final String storeName;
  final String address;
  final String nik;
  final String ownerName;
  final VoidCallback onSubmit; 
  final VoidCallback onBack;

  const _Step3Review({
    required this.storeName,
    required this.address,
    required this.nik,
    required this.ownerName,
    required this.onSubmit, 
    required this.onBack
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Satu langkah lagi\nmenuju kesuksesan.', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1.3)), const SizedBox(height: 8),
      const Text('Mohon tinjau kembali seluruh informasi yang telah Anda masukkan.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5)), const SizedBox(height: 20),
      
      _ReviewSection(title: 'Profil Toko', onEdit: () {}, child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.greenBadge, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.eco, color: AppColors.primary, size: 24)), const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('NAMA TOKO', style: TextStyle(fontSize: 10, color: AppColors.grey)), Text(storeName.isNotEmpty ? storeName : '-', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)), const SizedBox(height: 2), Text(address.isNotEmpty ? address : '-', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis)]))])),
      const SizedBox(height: 12),
      
      _ReviewSection(title: 'Data Verifikasi Pemilik', onEdit: () {}, child: Column(children: [
        _VerifRow(icon: Icons.person, label: 'NAMA LENGKAP', value: ownerName.isNotEmpty ? ownerName : '-', verified: true), const SizedBox(height: 8),
        _VerifRow(icon: Icons.credit_card, label: 'NIK DIRI', value: nik.isNotEmpty ? nik : '-', verified: true)])),
      const SizedBox(height: 16),
      
      Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(AppDimens.radiusL)),
        child: const Text('Dengan mengirimkan formulir ini, Anda menyetujui Syarat & Ketentuan Layanan AgriSmart Seller.', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.5))),
      const SizedBox(height: 24),
      
      Row(children: [
        Expanded(child: OutlinedButton(onPressed: onBack, style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.grey), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusL))), child: const Text('Kembali', style: TextStyle(color: AppColors.textSecondary)))),
        const SizedBox(width: 12), Expanded(flex: 2, child: PrimaryButton(text: 'Kirim Pendaftaran Toko →', onPressed: onSubmit)),
      ]),
    ]));
  }
}

class _ReviewSection extends StatelessWidget {
  final String title; final Widget child; final VoidCallback onEdit;
  const _ReviewSection({required this.title, required this.child, required this.onEdit});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppDimens.radiusL), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)), const Spacer(), GestureDetector(onTap: onEdit, child: const Text('Ubah ✏', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500)))]),
        const SizedBox(height: 10), child]));
  }
}

class _VerifRow extends StatelessWidget {
  final IconData icon; final String label; final String value; final bool verified;
  const _VerifRow({required this.icon, required this.label, required this.value, required this.verified});
  @override
  Widget build(BuildContext context) {
    return Row(children: [Icon(icon, size: 18, color: AppColors.textSecondary), const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 10, color: AppColors.grey)), Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary))])),
      if (verified) const Icon(Icons.check_circle, color: AppColors.primary, size: 18)]);
  }
}
