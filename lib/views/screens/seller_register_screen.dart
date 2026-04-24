import 'package:flutter/material.dart';
import '../screens/app_constants.dart';
import '../widgets/common_widgets.dart';
import 'seller_main_screen.dart';

class SellerRegisterScreen extends StatefulWidget {
  const SellerRegisterScreen({super.key});

  @override
  State<SellerRegisterScreen> createState() => _SellerRegisterScreenState();
}

class _SellerRegisterScreenState extends State<SellerRegisterScreen> {
  int _currentStep = 0;
  final _pageController = PageController();

  final _storeNameController = TextEditingController();
  final _storePhoneController = TextEditingController();
  final _warehouseNameController = TextEditingController();
  final _picNameController = TextEditingController();
  final _picPhoneController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _storeNameController.dispose();
    _storePhoneController.dispose();
    _warehouseNameController.dispose();
    _picNameController.dispose();
    _picPhoneController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SellerMainScreen()),
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: AppColors.textPrimary),
          onPressed: _prevStep,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Icon(Icons.eco, color: Colors.white, size: 14),
                ),
                const SizedBox(width: 6),
                const Text(
                  'AgriSmart Seller',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Langkah ${_currentStep + 1} dari 4',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _stepLabel(_currentStep),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: List.generate(4, (i) {
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                        decoration: BoxDecoration(
                          color: i <= _currentStep
                              ? AppColors.primary
                              : AppColors.greyLight,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _Step1Profile(
            storeNameController: _storeNameController,
            phoneController: _storePhoneController,
            onNext: _nextStep,
          ),
          _Step2Location(
            warehouseNameController: _warehouseNameController,
            picNameController: _picNameController,
            picPhoneController: _picPhoneController,
            onNext: _nextStep,
            onBack: _prevStep,
          ),
          _Step3Identity(onNext: _nextStep, onBack: _prevStep),
          _Step4Review(onSubmit: _nextStep, onBack: _prevStep),
        ],
      ),
    );
  }

  String _stepLabel(int step) {
    const labels = ['PROFIL TOKO', 'ALAMAT TOKO', 'IDENTITAS DIRI', 'TINJAU AKHIR'];
    return labels[step];
  }
}

// =====================
// STEP 1: PROFIL TOKO
// =====================
class _Step1Profile extends StatelessWidget {
  final TextEditingController storeNameController;
  final TextEditingController phoneController;
  final VoidCallback onNext;

  const _Step1Profile({
    required this.storeNameController,
    required this.phoneController,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Siapkan\nProfil Tokomu',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Mulai perjalanan bisnismu dengan melengkapi identitas dasar toko pertanianmu.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Logo Toko',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(AppDimens.radiusL),
                border: Border.all(
                    color: AppColors.divider, style: BorderStyle.solid),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt_outlined,
                      color: AppColors.grey, size: 28),
                  const SizedBox(height: 6),
                  const Text(
                    'Unggah logo untuk identitas tokomu.\nGunakan format JPG atau PNG, maksimal 2MB.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Pilih Gambar',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Nama Toko',
            hint: 'Contoh: Kebun Berkah Tani',
            controller: storeNameController,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Nomor HP Toko',
            hint: '812 3456 7890',
            controller: phoneController,
            prefixText: '+62 ',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          // Store photo placeholder
          Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(AppDimens.radiusL),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.add_photo_alternate_outlined,
                    color: AppColors.grey, size: 28),
                SizedBox(height: 6),
                Text(
                  'Tambah Foto Toko',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          PrimaryButton(text: 'Lanjut ke Alamat', onPressed: onNext),
        ],
      ),
    );
  }
}

// =====================
// STEP 2: LOKASI
// =====================
class _Step2Location extends StatelessWidget {
  final TextEditingController warehouseNameController;
  final TextEditingController picNameController;
  final TextEditingController picPhoneController;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _Step2Location({
    required this.warehouseNameController,
    required this.picNameController,
    required this.picPhoneController,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lokasi Toko',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tentukan titik simpul hasil tanimu ke seluruh penjuru Anda',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 20),
          AppTextField(
            label: 'Nama Gudang',
            hint: 'Contoh: Gudang Utama Ciwidey',
            controller: warehouseNameController,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Nama Penanggung Jawab',
            hint: 'Nama Lengkap Pengelola',
            controller: picNameController,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'No. Telepon / WhatsApp',
            hint: '812 3456 7890',
            controller: picPhoneController,
            prefixText: '+62 ',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          const Text(
            'Wilayah Operasional',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _DropdownField(label: 'Provinsi', value: 'Jawa Barat'),
          const SizedBox(height: 10),
          _DropdownField(label: 'Kota / Kabupaten', value: 'Kabupaten Bandung'),
          const SizedBox(height: 10),
          _DropdownField(label: 'Kecamatan', value: 'Ciwidey'),
          const SizedBox(height: 16),
          AppTextField(label: 'Kode Pos', hint: '40971'),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Alamat Lengkap',
            hint: 'Jl. Raya Ciwidey No. 123, RT 01/RW 04',
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onBack,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.grey),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusL),
                    ),
                  ),
                  child: const Text(
                    'Kembali',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: PrimaryButton(text: 'Lanjut ke Step 3', onPressed: onNext),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =====================
// STEP 3: IDENTITAS
// =====================
class _Step3Identity extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _Step3Identity({required this.onNext, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lengkapi\nIdentitas Diri',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pastikan foto KTP terlihat jelas dan data sesuai dengan dokumen resmi Anda.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          // KTP photo upload
          GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              height: 130,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(AppDimens.radiusL),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.camera_alt_outlined,
                      color: AppColors.grey, size: 32),
                  SizedBox(height: 8),
                  Text(
                    'Ambil Foto atau Pilih File',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Format JPG, PNG, atau PDF (maks. 5MB)',
                    style: TextStyle(fontSize: 11, color: AppColors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppTextField(label: 'NIK (16 Digit)', hint: '3270••••••••••••••'),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Nama Lengkap Sesuai KTP',
            hint: 'Contoh: Budi Setiawan',
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Tanggal Lahir',
            hint: 'mm/dd/yyyy',
            keyboardType: TextInputType.datetime,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'No. HP Aktif',
            hint: '+62 812••••••••',
            prefixText: '+62 ',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Alamat Email',
            hint: 'nama@email.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onBack,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.grey),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusL),
                    ),
                  ),
                  child: const Text(
                    'Kembali',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: PrimaryButton(text: 'Tinjau →', onPressed: onNext),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =====================
// STEP 4: REVIEW
// =====================
class _Step4Review extends StatelessWidget {
  final VoidCallback onSubmit;
  final VoidCallback onBack;

  const _Step4Review({required this.onSubmit, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Satu langkah lagi\nmenuju kesuksesan.',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Mohon tinjau kembali seluruh informasi yang telah Anda masukkan. Pastikan semua data sudah benar sebelum mengirimkan pendaftaran.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          _ReviewSection(
            title: 'Profil Toko',
            onEdit: () {},
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.greenBadge,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.eco,
                      color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'NAMA TOKO',
                      style: TextStyle(
                          fontSize: 10, color: AppColors.grey),
                    ),
                    Text(
                      'Tani Unggul Sejahtera',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Sayuran Organik',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _ReviewSection(
            title: 'Alamat Pengiriman',
            onEdit: () {},
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'LOKASI TOKO',
                  style: TextStyle(fontSize: 10, color: AppColors.grey),
                ),
                SizedBox(height: 4),
                Text(
                  'Gudang Utama - Lembang',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Jl. Maribaya No. 124, Desa Lembang, Kec. Lembang, Kabupaten Bandung Barat, Jawa Barat 40391',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '📍 PIN LOKASI TERPASANG',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _ReviewSection(
            title: 'Data Verifikasi',
            onEdit: () {},
            child: Column(
              children: [
                _VerifRow(
                  icon: Icons.credit_card,
                  label: 'NIK DIRI',
                  value: '3273••••••••••90',
                  verified: true,
                ),
                const SizedBox(height: 8),
                _VerifRow(
                  icon: Icons.account_balance,
                  label: 'REKENING BANK',
                  value: 'Bank Central Asia (BCA)',
                  verified: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(AppDimens.radiusL),
            ),
            child: const Text(
              'Dengan mengirimkan formulir ini, Anda menyetujui Syarat & Ketentuan Layanan AgriSmart Seller. Pastikan semua data benar dan valid sesuai ketentuan yang berlaku.',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onBack,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.grey),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusL),
                    ),
                  ),
                  child: const Text(
                    'Kembali',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: PrimaryButton(
                  text: 'Kirim Pendaftaran Toko →',
                  onPressed: onSubmit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewSection extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onEdit;

  const _ReviewSection({
    required this.title,
    required this.child,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
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
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onEdit,
                child: const Text(
                  'Ubah ✏',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _VerifRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool verified;

  const _VerifRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.verified,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.grey)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary)),
            ],
          ),
        ),
        if (verified)
          const Icon(Icons.check_circle, color: AppColors.primary, size: 18),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String value;

  const _DropdownField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Icon(Icons.keyboard_arrow_down,
              size: 20, color: AppColors.grey),
        ],
      ),
    );
  }
}
