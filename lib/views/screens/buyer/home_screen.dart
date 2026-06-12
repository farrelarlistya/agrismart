import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/product.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/favorite_provider.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/search_provider.dart';
import '../../../core/utils/auth_guard.dart';
import '../../widgets/product_card.dart';
import '../../widgets/section_header.dart';
import 'product_detail_screen.dart';
import 'category_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  final List<Map<String, dynamic>> _categoryItems = const [
    {'icon': Icons.grass, 'label': 'Hasil\nPertanian'},
    {'icon': Icons.eco, 'label': 'Produk\nOlahan'},
    {'icon': Icons.science_outlined, 'label': 'Sarana\nProduksi'},
    {'icon': Icons.agriculture, 'label': 'Alat &\nMesin'},
  ];

  @override
  void initState() {
    super.initState();
    // Fetch products from API when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
      context.read<FavoriteProvider>().fetchFavorites();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchProvider>();
    final productProvider = context.watch<ProductProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(searchProvider),
            // Show search results or normal content
            if (searchProvider.query.isNotEmpty)
              _buildSearchResults(searchProvider)
            else if (productProvider.isLoading)
              const Padding(
                padding: EdgeInsets.all(60),
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              )
            else ...[
              _buildBanner(),
              _buildCategories(),
              _buildBestSellers(productProvider),
              _buildRecommendations(productProvider),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(SearchProvider searchProvider) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(fontSize: 14),
        onChanged: (value) => searchProvider.search(value),
        decoration: InputDecoration(
          hintText: 'Cari hasil tani segar...',
          hintStyle: const TextStyle(fontSize: 13, color: AppColors.grey),
          prefixIcon: const Icon(Icons.search, color: AppColors.grey, size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18, color: AppColors.grey),
                  onPressed: () {
                    _searchController.clear();
                    searchProvider.clearSearch();
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.secondary,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusM),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildSearchResults(SearchProvider searchProvider) {
    if (searchProvider.isSearching) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }
    if (searchProvider.results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.search_off, size: 60, color: AppColors.grey.withOpacity(0.4)),
              const SizedBox(height: 12),
              Text(
                'Tidak ditemukan produk untuk\n"${searchProvider.query}"',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${searchProvider.results.length} hasil untuk "${searchProvider.query}"',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.7,
            ),
            itemCount: searchProvider.results.length,
            itemBuilder: (context, index) {
              final product = searchProvider.results[index];
              return Consumer<FavoriteProvider>(
                builder: (context, favProv, _) => ProductCard(
                  product: product,
                  isFavorite: favProv.isFavorite(product.id),
                  onTap: () => _openProduct(product),
                  onAddToCart: () => _addToCart(product),
                  onToggleFavorite: () => AuthGuard.run(context, () => favProv.toggleFavorite(product.id)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/hero_bg.png', fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1E8B4F), Color(0xFF2ECC71)])),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Colors.black.withOpacity(0.55), Colors.black.withOpacity(0.1)]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('Panen Raya Serentak', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 4),
                const Text('Diskon produk segar hingga 30%', style: TextStyle(fontSize: 13, color: Colors.white70)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: const Text('Belanja Sekarang', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionHeader(title: 'Kategori Utama'),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _categoryItems.map((c) {
            final rawLabel = c['label'] as String;
            final filterLabel = rawLabel.replaceAll('\n', ' ');
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Scaffold(
                      appBar: AppBar(
                        title: Text(filterLabel),
                        surfaceTintColor: Colors.transparent,
                        backgroundColor: AppColors.white,
                      ),
                      body: CategoryScreen(initialCategory: filterLabel),
                    ),
                  ),
                );
              },
              child: _CategoryChip(icon: c['icon'] as IconData, label: rawLabel),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ]),
    );
  }

  Widget _buildBestSellers(ProductProvider productProvider) {
    final allProducts = productProvider.products;
    final displayCount = allProducts.length > 5 ? 5 : allProducts.length;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SectionHeader(title: 'Produk Terlaris Minggu Ini', actionLabel: 'Lihat Semua', onAction: () {}),
      ),
      const SizedBox(height: 12),
      SizedBox(
        height: 260,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: displayCount,
          itemBuilder: (context, index) {
            final product = allProducts[index];
            return Container(
              width: 150,
              margin: const EdgeInsets.only(right: 12),
              child: Consumer<FavoriteProvider>(
                builder: (context, favProv, _) => ProductCard(
                  product: product,
                  isFavorite: favProv.isFavorite(product.id),
                  onTap: () => _openProduct(product),
                  onAddToCart: () => _addToCart(product),
                  onToggleFavorite: () => AuthGuard.run(context, () => favProv.toggleFavorite(product.id)),
                ),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 20),
    ]);
  }

  Widget _buildRecommendations(ProductProvider productProvider) {
    final allProducts = productProvider.products;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionHeader(title: 'Rekomendasi Untukmu', actionLabel: 'Lihat Semua', onAction: () {}),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.7,
          ),
          itemCount: allProducts.length,
          itemBuilder: (context, index) {
            final product = allProducts[index];
            return Consumer<FavoriteProvider>(
              builder: (context, favProv, _) => ProductCard(
                product: product,
                isFavorite: favProv.isFavorite(product.id),
                onTap: () => _openProduct(product),
                onAddToCart: () => _addToCart(product),
                onToggleFavorite: () => AuthGuard.run(context, () => favProv.toggleFavorite(product.id)),
              ),
            );
          },
        ),
      ]),
    );
  }

  void _openProduct(Product product) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)));
  }

  void _addToCart(Product product) {
    context.read<CartProvider>().addToCart(product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} ditambahkan ke keranjang'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _CategoryChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        width: 64, height: 64,
        decoration: BoxDecoration(color: AppColors.greenBadge, borderRadius: BorderRadius.circular(14)),
        child: Icon(icon, color: AppColors.primary, size: 30),
      ),
      const SizedBox(height: 6),
      Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textPrimary, height: 1.3)),
    ]);
  }
}
