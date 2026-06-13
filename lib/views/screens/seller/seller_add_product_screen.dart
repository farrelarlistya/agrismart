import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/product.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/store_provider.dart';
import 'package:provider/provider.dart';

class SellerAddProductScreen extends StatefulWidget {
  final Product? productToEdit;
  const SellerAddProductScreen({super.key, this.productToEdit});

  @override
  State<SellerAddProductScreen> createState() => _SellerAddProductScreenState();
}

class _SellerAddProductScreenState extends State<SellerAddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final List<XFile> _images = [];
  XFile? _video;
  
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _unitCtrl = TextEditingController();
  
  String _selectedCategory = 'Hasil Pertanian';
  final List<String> _categories = ['Hasil Pertanian', 'Produk Olahan', 'Sarana Produksi', 'Alat & Mesin'];

  @override
  void initState() {
    super.initState();
    if (widget.productToEdit != null) {
      final p = widget.productToEdit!;
      _nameCtrl.text = p.name;
      _descCtrl.text = p.description;
      _priceCtrl.text = p.price.toStringAsFixed(0);
      _stockCtrl.text = p.stock.toString();
      _unitCtrl.text = p.unit;
      if (_categories.contains(p.category)) {
        _selectedCategory = p.category;
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _images.add(picked);
      });
    }
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final picked = await picker.pickVideo(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _video = picked;
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final storeProv = context.read<StoreProvider>();
      final store = storeProv.store;
      
      if (store == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Toko tidak ditemukan')),
        );
        return;
      }

      final productProv = context.read<ProductProvider>();
      String? finalImageUrl;

      if (_images.isNotEmpty) {
        final uploadedUrl = await productProv.uploadProductImage(_images.first.path);
        if (uploadedUrl != null) {
          finalImageUrl = uploadedUrl;
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal mengunggah foto produk')),
          );
          return;
        }
      }

      final isEditing = widget.productToEdit != null;

      // Create product json
      final productJson = {
        'name': _nameCtrl.text,
        'category_id': _categories.indexOf(_selectedCategory) + 1, // Assumes categories 1-4
        'description': _descCtrl.text,
        'price': double.tryParse(_priceCtrl.text) ?? 0,
        'stock': int.tryParse(_stockCtrl.text) ?? 0,
        'unit': _unitCtrl.text,
        'video_url': _video?.path ?? '',
        'seller': store.name,
        'seller_id': store.id,
      };

      if (finalImageUrl != null) {
        productJson['image_url'] = finalImageUrl;
        productJson['image_urls'] = _images.length > 1 ? _images.skip(1).map((e) => e.path).toList() : [];
      } else if (!isEditing) {
        productJson['image_url'] = '';
        productJson['image_urls'] = [];
      }

      bool success;
      if (isEditing) {
        success = await productProv.updateProduct(widget.productToEdit!.id, productJson);
      } else {
        success = await productProv.addProduct(productJson);
      }

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEditing ? 'Produk berhasil diperbarui' : 'Produk berhasil ditambahkan')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.read<ProductProvider>().error ?? (isEditing ? 'Gagal memperbarui produk' : 'Gagal menambahkan produk'))),
        );
      }
    }
  }

  void _deleteProduct() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: const Text('Apakah Anda yakin ingin menghapus produk ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<ProductProvider>().deleteProduct(widget.productToEdit!.id);
              if (!mounted) return;
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Produk berhasil dihapus')),
                );
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.read<ProductProvider>().error ?? 'Gagal menghapus produk')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildLabel(String label, {String? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (trailing != null)
            Text(
              trailing,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.greyLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Bidang ini wajib diisi';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.productToEdit != null ? 'Edit Produk' : 'Tambah Produk',
          style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (widget.productToEdit != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.red),
              onPressed: _deleteProduct,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Informasi Dasar
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Informasi Dasar'),
                    _buildLabel('FOTO PRODUK'),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (_images.isEmpty && widget.productToEdit != null && widget.productToEdit!.imageUrl.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: NetworkImage(widget.productToEdit!.imageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ..._images.map((img) => Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: FileImage(File(img.path)),
                                  fit: BoxFit.cover,
                                ),
                            ),
                          )),
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.greyLight.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.divider, style: BorderStyle.solid),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo, color: AppColors.primary),
                                  SizedBox(height: 4),
                                  Text('Tambah', style: TextStyle(fontSize: 10, color: AppColors.primary)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('NAMA PRODUK', trailing: 'Urungkan'),
                    _buildTextField(
                      controller: _nameCtrl,
                      hint: 'Contoh: Sayuran Organik',
                    ),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(top: 4.0),
                        child: Text('0/255', style: TextStyle(fontSize: 10, color: AppColors.grey)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.greyLight.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          isExpanded: true,
                          icon: const Icon(Icons.chevron_right),
                          items: _categories.map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c, style: const TextStyle(fontWeight: FontWeight.w600)),
                          )).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedCategory = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Detail Produk
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Detail Produk'),
                    _buildLabel('DESKRIPSI PRODUK'),
                    _buildTextField(
                      controller: _descCtrl,
                      maxLines: 4,
                      hint: 'Jelaskan produk Anda...',
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('VIDEO PRODUK'),
                    Row(
                      children: [
                        if (_video != null)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 120,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.black,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.play_circle_outline, color: AppColors.white, size: 32),
                          ),
                        GestureDetector(
                          onTap: _pickVideo,
                          child: Container(
                            width: 120,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.greyLight.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.videocam_outlined, color: AppColors.primary),
                                SizedBox(height: 4),
                                Text('Tambah', style: TextStyle(fontSize: 10, color: AppColors.primary)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Info Penjualan
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Info Penjualan'),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('HARGA SATUAN'),
                              _buildTextField(
                                controller: _priceCtrl,
                                keyboardType: TextInputType.number,
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.all(14.0),
                                  child: Text('Rp', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('STOK'),
                              _buildTextField(
                                controller: _stockCtrl,
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Pengiriman
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Pengiriman'),
                    _buildLabel('UNIT PENJUALAN'),
                    _buildTextField(
                      controller: _unitCtrl,
                      hint: 'Contoh: g, kg, ikat, pack',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100), // Space for bottom button
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: Consumer<ProductProvider>(
              builder: (context, productProv, child) {
                return ElevatedButton(
                  onPressed: productProv.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: productProv.isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(widget.productToEdit != null ? 'Simpan Perubahan' : 'Kirim untuk ditinjau...', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
