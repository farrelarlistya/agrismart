import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/price_formatter.dart';
import '../../../models/cart_item.dart';
import '../../../providers/cart_provider.dart';
import '../../widgets/agrismart_app_bar.dart';
import '../../widgets/primary_button.dart';
import '../../../core/utils/auth_guard.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AgriSmartAppBar(title: 'Keranjang Saya', showBack: true, actions: [
        Consumer<CartProvider>(
          builder: (context, cart, _) => TextButton(
            onPressed: cart.itemCount > 0 ? () => cart.clearCart() : null,
            child: const Text('Hapus', style: TextStyle(color: AppColors.red, fontSize: 13)),
          ),
        ),
      ]),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) => Column(children: [
          Expanded(
            child: cart.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : cart.items.isEmpty
                    ? _buildEmpty()
                    : _buildCartList(context, cart),
          ),
          _buildBottomBar(context, cart),
        ]),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.shopping_cart_outlined, size: 80, color: AppColors.grey.withOpacity(0.3)),
      const SizedBox(height: 16),
      const Text('Keranjang Kosong', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.grey)),
      const SizedBox(height: 8),
      const Text('Tambahkan produk ke keranjang', style: TextStyle(fontSize: 13, color: AppColors.grey)),
    ]));
  }

  Widget _buildCartList(BuildContext context, CartProvider cart) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      // Select all checkbox
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppDimens.radiusM)),
        child: Row(children: [
          SizedBox(width: 20, height: 20, child: Checkbox(
            value: cart.allSelected,
            onChanged: (v) => cart.selectAll(v ?? false),
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          )),
          const SizedBox(width: 10),
          const Text('Pilih Semua', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
        ]),
      ),
      const SizedBox(height: 12),
      // Cart items grouped
      Container(
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppDimens.radiusL), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Column(children: [
          Padding(padding: const EdgeInsets.all(14), child: Row(children: [
            const Icon(Icons.store, size: 16, color: AppColors.textPrimary), const SizedBox(width: 8),
            Expanded(child: Text(cart.items.isNotEmpty ? cart.items.first.product.seller : '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
          ])),
          const Divider(height: 1, color: AppColors.divider),
          ...cart.items.map((item) => _CartItemTile(
            item: item,
            onQuantityChanged: (q) => cart.updateQuantity(item.product.id, q),
            onSelectionChanged: (_) => cart.toggleSelection(item.product.id),
            onRemove: () => cart.removeFromCart(item.product.id),
          )),
        ]),
      ),
    ]);
  }

  Widget _buildBottomBar(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(color: AppColors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -4))]),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text('Total (${cart.selectedCount} item)', style: AppTextStyles.bodySmall),
          Text(formatPrice(cart.subtotal), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
        ]),
        const SizedBox(width: 16),
        Expanded(child: PrimaryButton(
          text: 'Checkout (${cart.selectedCount} item) →',
          onPressed: cart.selectedCount > 0 ? () => AuthGuard.run(context, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen()));
          }) : null,
          height: 46,
        )),
      ]),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final Function(int) onQuantityChanged;
  final Function(bool) onSelectionChanged;
  final VoidCallback onRemove;
  const _CartItemTile({required this.item, required this.onQuantityChanged, required this.onSelectionChanged, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    return Dismissible(
      key: Key(product.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(color: AppColors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
      child: Padding(padding: const EdgeInsets.all(14), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 20, height: 20, child: Checkbox(value: item.selected, onChanged: (v) => onSelectionChanged(v ?? false), activeColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)))),
        const SizedBox(width: 10),
        ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.asset(product.imageUrl, width: 64, height: 64, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 64, height: 64, decoration: BoxDecoration(color: AppColors.greenBadge, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.eco, color: AppColors.primary, size: 32)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(product.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          Text(product.seller, style: AppTextStyles.bodySmall),
          const SizedBox(height: 8),
          Row(children: [
            Text(formatPrice(product.price), style: AppTextStyles.priceSmall),
            const Spacer(),
            _QtyControl(quantity: item.quantity, onChanged: onQuantityChanged),
          ]),
        ])),
      ])),
    );
  }
}

class _QtyControl extends StatelessWidget {
  final int quantity;
  final Function(int) onChanged;
  const _QtyControl({required this.quantity, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: AppColors.divider), borderRadius: BorderRadius.circular(6)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        GestureDetector(onTap: () { if (quantity > 1) onChanged(quantity - 1); }, child: Container(width: 28, height: 28, alignment: Alignment.center, child: const Icon(Icons.remove, size: 14))),
        Container(width: 32, alignment: Alignment.center, child: Text('$quantity', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
        GestureDetector(onTap: () => onChanged(quantity + 1), child: Container(width: 28, height: 28, decoration: const BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.only(topRight: Radius.circular(5), bottomRight: Radius.circular(5))), alignment: Alignment.center, child: const Icon(Icons.add, size: 14, color: Colors.white))),
      ]),
    );
  }
}
