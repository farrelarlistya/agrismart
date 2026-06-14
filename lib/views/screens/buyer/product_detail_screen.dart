import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/price_formatter.dart';
import '../../../models/product.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/favorite_provider.dart';
import '../../../providers/product_provider.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/product_card.dart';
import '../../../core/utils/auth_guard.dart';
import 'chat_detail_screen.dart';
import 'checkout_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> with SingleTickerProviderStateMixin {
  int _quantity = 1;
  late TabController _tabController;

  // Image carousel state
  late PageController _imagePageController;
  Timer? _autoScrollTimer;
  int _currentImagePage = 0;
  List<String> _allImages = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _imagePageController = PageController();

    // Combine main image + additional images
    _allImages = [widget.product.imageUrl, ...widget.product.imageUrls];
    _allImages.removeWhere((url) => url.isEmpty);
    if (_allImages.isEmpty) _allImages = [''];

    // Start auto-scroll if multiple images
    if (_allImages.length > 1) {
      _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
        if (_imagePageController.hasClients) {
          _currentImagePage = (_currentImagePage + 1) % _allImages.length;
          _imagePageController.animateToPage(
            _currentImagePage,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _autoScrollTimer?.cancel();
    _imagePageController.dispose();
    super.dispose();
  }

  List<Product> get _relatedProducts {
    return context.read<ProductProvider>().getRelated(widget.product);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Scaffold(backgroundColor: AppColors.background, body: Stack(children: [
      CustomScrollView(slivers: [
        _buildSliverAppBar(p),
        SliverToBoxAdapter(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildProductInfo(p),
          _buildSellerInfo(p),
          _buildQuantitySelector(),
          _buildTabSection(p),
          _buildRelatedProducts(),
          const SizedBox(height: 100),
        ])),
      ]),
      _buildBottomBar(p),
    ]));
  }

  Widget _buildSliverAppBar(Product p) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.white,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
          ),
          child: const Icon(Icons.arrow_back_ios_new, size: 16, color: AppColors.textPrimary),
        ),
      ),
      actions: [
        Consumer<FavoriteProvider>(
          builder: (context, favProv, _) {
            final isFav = favProv.isFavorite(p.id);
            return GestureDetector(
              onTap: () => AuthGuard.run(context, () => favProv.toggleFavorite(p.id)),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? AppColors.red : AppColors.grey, size: 20),
                ),
              ),
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Image carousel
            PageView.builder(
              controller: _imagePageController,
              onPageChanged: (index) {
                setState(() => _currentImagePage = index);
                // Reset auto-scroll timer on manual swipe
                _autoScrollTimer?.cancel();
                if (_allImages.length > 1) {
                  _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
                    if (_imagePageController.hasClients) {
                      _currentImagePage = (_currentImagePage + 1) % _allImages.length;
                      _imagePageController.animateToPage(
                        _currentImagePage,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    }
                  });
                }
              },
              itemCount: _allImages.length,
              itemBuilder: (context, index) {
                final url = _allImages[index];
                if (url.isEmpty) {
                  return Container(
                    color: AppColors.greyLight,
                    child: Icon(Icons.eco, size: 100, color: AppColors.primary.withOpacity(0.2)),
                  );
                }
                return Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.greyLight,
                    child: Icon(Icons.eco, size: 100, color: AppColors.primary.withOpacity(0.2)),
                  ),
                );
              },
            ),

            // Dot indicators + counter badge
            if (_allImages.length > 1)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Counter badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_currentImagePage + 1} / ${_allImages.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Dot indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_allImages.length, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          height: 6,
                          width: _currentImagePage == index ? 20 : 6,
                          decoration: BoxDecoration(
                            color: _currentImagePage == index
                                ? AppColors.primary
                                : Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo(Product p) {
    return Container(color: AppColors.white, padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(p.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 8),
      Row(children: [
        Text(formatPrice(p.price), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary)),
        Text('/${p.unit}', style: const TextStyle(fontSize: 14, color: AppColors.grey)),
        if (p.originalPrice != null) ...[const SizedBox(width: 8), Text(formatPrice(p.originalPrice!), style: AppTextStyles.priceCrossed.copyWith(fontSize: 14))],
      ]),
      const SizedBox(height: 8),
      Text('Stok: ${p.stock} ${p.unit}', style: AppTextStyles.bodySmall),
    ]));
  }

  Widget _buildSellerInfo(Product p) {
    return Container(color: AppColors.white, margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.all(16), child: Row(children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.greenBadge, shape: BoxShape.circle), child: const Icon(Icons.store, color: AppColors.primary, size: 20)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(p.seller, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        Row(children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: p.storeIsActive ? AppColors.primary : AppColors.grey, shape: BoxShape.circle)), 
          const SizedBox(width: 4), 
          Text(p.storeIsActive ? 'Penjual Aktif' : 'Toko Libur', style: TextStyle(fontSize: 12, color: p.storeIsActive ? AppColors.primary : AppColors.grey))
        ]),
        if (p.location.isNotEmpty)
          Padding(padding: const EdgeInsets.only(top: 2), child: Row(children: [
            const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textSecondary),
            const SizedBox(width: 3),
            Text(p.location, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ])),
      ])),
      OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primary), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), child: const Text('Kunjungi', style: TextStyle(fontSize: 12, color: AppColors.primary))),
    ]));
  }

  Widget _buildQuantitySelector() {
    return Container(color: AppColors.white, margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Row(children: [
      const Text('Pilih Jumlah', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      const Spacer(),
      Container(decoration: BoxDecoration(border: Border.all(color: AppColors.divider), borderRadius: BorderRadius.circular(8)), child: Row(children: [
        _QtyButton(icon: Icons.remove, onTap: () { if (_quantity > 1) setState(() => _quantity--); }),
        Container(width: 40, alignment: Alignment.center, child: Text('$_quantity', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
        _QtyButton(icon: Icons.add, onTap: () => setState(() => _quantity++), isAdd: true),
      ])),
      const SizedBox(width: 8),
      Text(widget.product.unit, style: AppTextStyles.bodySmall),
    ]));
  }

  Widget _buildTabSection(Product p) {
    return Container(color: AppColors.white, margin: const EdgeInsets.only(top: 8), child: Column(children: [
      TabBar(controller: _tabController, labelColor: AppColors.primary, unselectedLabelColor: AppColors.grey, indicatorColor: AppColors.primary, labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), tabs: const [Tab(text: 'Deskripsi'), Tab(text: 'Info Produk')]),
      SizedBox(height: 160, child: TabBarView(controller: _tabController, children: [
        Padding(padding: const EdgeInsets.all(16), child: Text(p.description.isNotEmpty ? p.description : 'Produk segar berkualitas tinggi langsung dari petani lokal.', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.6))),
        Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _InfoRow('Kategori', p.category), _InfoRow('Satuan', p.unit), _InfoRow('Stok', '${p.stock} ${p.unit}'),
          if (p.location.isNotEmpty) _InfoRow('Lokasi', p.location),
        ])),
      ])),
    ]));
  }

  Widget _buildRelatedProducts() {
    final related = _relatedProducts;
    if (related.isEmpty) return const SizedBox.shrink();
    return Container(
      color: AppColors.white, margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Produk Terkait', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
        const SizedBox(height: 12),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: related.length,
            itemBuilder: (context, index) {
              final product = related[index];
              return Container(
                width: 150, margin: const EdgeInsets.only(right: 12),
                child: Consumer<FavoriteProvider>(
                  builder: (context, favProv, _) => ProductCard(
                    product: product,
                    isFavorite: favProv.isFavorite(product.id),
                    onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
                    onAddToCart: () {
                      context.read<CartProvider>().addToCart(product);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${product.name} ditambahkan ke keranjang'), backgroundColor: AppColors.primary, duration: const Duration(seconds: 1)));
                    },
                    onToggleFavorite: () => favProv.toggleFavorite(product.id),
                  ),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _buildBottomBar(Product p) {
    return Positioned(bottom: 0, left: 0, right: 0, child: Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(color: AppColors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -4))]),
      child: Row(children: [
        // Chat Toko
        GestureDetector(
          onTap: () => AuthGuard.run(context, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ChatDetailScreen(
              sellerName: p.seller, sellerAvatar: p.seller.isNotEmpty ? p.seller[0] : 'T', isOnline: true,
              productName: p.name, productImage: p.imageUrl, productPrice: p.price, productUnit: p.unit,
            )));
          }),
          child: Container(width: 48, height: 48, decoration: BoxDecoration(border: Border.all(color: AppColors.primary), borderRadius: BorderRadius.circular(AppDimens.radiusL)),
            child: const Icon(Icons.chat_bubble_outline, color: AppColors.primary, size: 22)),
        ),
        const SizedBox(width: 10),
        // Tambah ke Keranjang
        Expanded(
          child: OutlinedButton(
            onPressed: p.storeIsActive ? () {
              context.read<CartProvider>().addToCart(p, quantity: _quantity);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${p.name} (×$_quantity) ditambahkan ke keranjang'), backgroundColor: AppColors.primary, duration: const Duration(seconds: 1)));
            } : () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Toko sedang libur/offline')));
            },
            style: OutlinedButton.styleFrom(side: BorderSide(color: p.storeIsActive ? AppColors.primary : AppColors.grey), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusL))),
            child: Text('Keranjang', style: TextStyle(color: p.storeIsActive ? AppColors.primary : AppColors.grey, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(width: 10),
        // Beli Sekarang → Direct Checkout
        Expanded(
          flex: 2,
          child: PrimaryButton(
            text: 'Beli Sekarang →',
            backgroundColor: p.storeIsActive ? AppColors.primary : AppColors.grey,
            onPressed: p.storeIsActive ? () => AuthGuard.run(context, () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => CheckoutScreen(directProduct: p, directQuantity: _quantity),
              ));
            }) : () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Toko sedang libur/offline')));
            },
          ),
        ),
      ]),
    ));
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon; final VoidCallback onTap; final bool isAdd;
  const _QtyButton({required this.icon, required this.onTap, this.isAdd = false});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: Container(width: 34, height: 34, decoration: BoxDecoration(color: isAdd ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(6)), child: Icon(icon, size: 16, color: isAdd ? Colors.white : AppColors.textPrimary)));
  }
}

class _InfoRow extends StatelessWidget {
  final String label; final String value;
  const _InfoRow(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
      SizedBox(width: 80, child: Text(label, style: AppTextStyles.bodySmall)),
      const Text(': ', style: TextStyle(color: AppColors.grey)),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500))),
    ]));
  }
}
