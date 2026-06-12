import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/favorite_provider.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/user_provider.dart';
import '../../widgets/product_card.dart';
import '../auth/login_screen.dart';
import 'product_detail_screen.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProv = Provider.of<UserProvider>(context);
    final isGuest = userProv.user.id.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(children: [
        Consumer2<FavoriteProvider, ProductProvider>(
          builder: (context, favProv, productProv, _) {
            final favorites = isGuest
                ? []
                : productProv.products.where((p) => favProv.isFavorite(p.id)).toList();
            return Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Row(children: [
                const Text('Favorit Saya', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const Spacer(),
                Text('${favorites.length} Produk', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ]),
            );
          },
        ),
        Expanded(
          child: isGuest
              ? _buildGuestPlaceholder(context)
              : Consumer2<FavoriteProvider, ProductProvider>(
                  builder: (context, favProv, productProv, _) {
                    final favorites = productProv.products.where((p) => favProv.isFavorite(p.id)).toList();
                    if (favorites.isEmpty) {
                      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.favorite_border, size: 60, color: AppColors.grey.withOpacity(0.5)),
                        const SizedBox(height: 12),
                        const Text('Belum ada produk favorit', style: TextStyle(color: AppColors.grey)),
                      ]));
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.72),
                      itemCount: favorites.length,
                      itemBuilder: (context, index) {
                        final product = favorites[index];
                        return ProductCard(
                          product: product,
                          isFavorite: true,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
                          onAddToCart: () {
                            context.read<CartProvider>().addToCart(product);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${product.name} ditambahkan ke keranjang'), backgroundColor: AppColors.primary, duration: const Duration(seconds: 1)));
                          },
                          onToggleFavorite: () => favProv.toggleFavorite(product.id),
                        );
                      },
                    );
                  },
                ),
        ),
      ]),
    );
  }

  Widget _buildGuestPlaceholder(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFFEEBEE), // Light red for heart badge
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_outline,
                size: 64,
                color: AppColors.red,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Belum Masuk Akun',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Silakan masuk terlebih dahulu untuk melihat produk favorit Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 160,
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Masuk Sekarang',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
