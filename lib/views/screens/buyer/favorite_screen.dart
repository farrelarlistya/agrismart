import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/favorite_provider.dart';
import '../../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import 'product_detail_screen.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(children: [
        Consumer2<FavoriteProvider, ProductProvider>(
          builder: (context, favProv, productProv, _) {
            final favorites = productProv.products.where((p) => favProv.isFavorite(p.id)).toList();
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
          child: Consumer2<FavoriteProvider, ProductProvider>(
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
}
