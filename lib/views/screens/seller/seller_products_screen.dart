import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/price_formatter.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/store_provider.dart';
import '../../../models/product.dart';

class SellerProductsScreen extends StatefulWidget {
  const SellerProductsScreen({super.key});

  @override
  State<SellerProductsScreen> createState() => _SellerProductsScreenState();
}

class _SellerProductsScreenState extends State<SellerProductsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProducts());
    _searchController.addListener(() => setState(() => _searchQuery = _searchController.text.trim().toLowerCase()));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    final store = context.read<StoreProvider>().store;
    if (store == null) return;
    // Force refresh to get seller-specific products
    final productProv = context.read<ProductProvider>();
    productProv.setSellerFilter(store.id);
    await productProv.fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    final productProv = context.watch<ProductProvider>();
    final allProducts = productProv.products;
    final filtered = _searchQuery.isEmpty
        ? allProducts
        : allProducts.where((p) => p.name.toLowerCase().contains(_searchQuery)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Kelola Produk', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: const Color(0xFFEBEBEB), borderRadius: BorderRadius.circular(20)),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                  hintText: 'Cari nama produk...',
                  hintStyle: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: productProv.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : filtered.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadProducts,
                        color: AppColors.primary,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (_, i) => _ProductCard(product: filtered[i]),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.grey),
          SizedBox(height: 16),
          Text('Belum ada produk', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          SizedBox(height: 4),
          Text('Tap tombol + untuk menambahkan produk pertama', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    // Default active unless stock is 0
    _isActive = (widget.product.stock ?? 0) > 0;
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final isOutOfStock = (product.stock ?? 0) == 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  product.imageUrl,
                  width: 80, height: 80, fit: BoxFit.cover,
                  color: isOutOfStock ? Colors.black.withOpacity(0.4) : null,
                  colorBlendMode: isOutOfStock ? BlendMode.darken : null,
                  errorBuilder: (_, __, ___) => Container(width: 80, height: 80, color: AppColors.greyLight, child: const Icon(Icons.image, color: AppColors.grey)),
                ),
              ),
              if (isOutOfStock)
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                      child: const Text('HABIS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isOutOfStock ? AppColors.textSecondary : AppColors.textPrimary),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Text(formatPrice(product.price),
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: isOutOfStock ? AppColors.textSecondary : AppColors.primary)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOutOfStock ? const Color(0xFFFBECEB) : const Color(0xFFEAEAEA),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('SISA ${product.stock ?? 0} ${product.unit}',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isOutOfStock ? AppColors.red : AppColors.textSecondary)),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary, size: 20),
                onPressed: () {},
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 24,
                child: Switch(
                  value: _isActive && !isOutOfStock,
                  onChanged: isOutOfStock ? null : (val) => setState(() => _isActive = val),
                  activeColor: Colors.white,
                  activeTrackColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
