import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/dummy_data.dart';
import '../../../models/product.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/favorite_provider.dart';
import '../../widgets/product_card.dart';
import 'product_detail_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});
  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String _selectedCategory = 'Semua';

  static const List<Map<String, dynamic>> _mainCategories = [
    {'icon': Icons.grass, 'label': 'Hasil Pertanian'},
    {'icon': Icons.eco, 'label': 'Produk Olahan'},
    {'icon': Icons.science_outlined, 'label': 'Sarana Produksi'},
    {'icon': Icons.agriculture, 'label': 'Alat & Mesin'},
  ];

  List<Product> get _filteredProducts {
    if (_selectedCategory == 'Semua') return AppData.products;
    return AppData.products.where((p) => p.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(children: [
        _buildHeader(),
        _buildCategoryTabs(),
        Expanded(child: _buildProductGrid()),
      ]),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Row(children: [
        const Text('Kategori', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: AppColors.greenBadge, borderRadius: BorderRadius.circular(20)),
          child: Text('${_filteredProducts.length} Produk', style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.search, color: AppColors.textPrimary, size: 22),
      ]),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      color: AppColors.white,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _mainCategories.map((cat) {
              final label = cat['label'] as String;
              final isSelected = _selectedCategory == label;
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedCategory = _selectedCategory == label ? 'Semua' : label;
                }),
                child: Column(children: [
                  Container(
                    width: 54, height: 54,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.greenBadge,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(cat['icon'] as IconData, color: isSelected ? Colors.white : AppColors.primary, size: 26),
                  ),
                  const SizedBox(height: 4),
                  Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? AppColors.primary : AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                ]),
              );
            }).toList(),
          ),
        ),
        const Divider(height: 1, color: AppColors.divider),
      ]),
    );
  }

  Widget _buildProductGrid() {
    final products = _filteredProducts;
    if (products.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.inventory_2_outlined, size: 60, color: AppColors.grey.withOpacity(0.4)),
        const SizedBox(height: 12),
        const Text('Belum ada produk\ndi kategori ini', textAlign: TextAlign.center, style: TextStyle(color: AppColors.grey, fontSize: 13)),
      ]));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.72),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Consumer<FavoriteProvider>(
          builder: (context, favProv, _) => ProductCard(
            product: product,
            isFavorite: favProv.isFavorite(product.id),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
            onAddToCart: () {
              context.read<CartProvider>().addToCart(product);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${product.name} ditambahkan ke keranjang'), backgroundColor: AppColors.primary, duration: const Duration(seconds: 1)));
            },
            onToggleFavorite: () => favProv.toggleFavorite(product.id),
          ),
        );
      },
    );
  }
}
