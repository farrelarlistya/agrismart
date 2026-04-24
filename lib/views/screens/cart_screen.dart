import 'package:flutter/material.dart';
import '../screens/app_constants.dart';
import '../screens/product.dart';
import '../widgets/common_widgets.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _selectAll = true;

  final List<Map<String, dynamic>> _cartItems = [
    {
      'product': AppData.products[9], // Ceri Organik
      'quantity': 1,
      'selected': true,
    },
  ];

  double get _subtotal {
    double total = 0;
    for (final item in _cartItems) {
      if (item['selected'] == true) {
        final product = item['product'] as Product;
        total += product.price * (item['quantity'] as int);
      }
    }
    return total;
  }

  int get _selectedCount =>
      _cartItems.where((i) => i['selected'] == true).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AgriSmartAppBar(
        title: 'Keranjang Saya',
        showBack: true,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.red, fontSize: 13),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _cartItems.isEmpty
                ? _buildEmpty()
                : _buildCartList(),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 80, color: AppColors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text(
            'Keranjang Kosong',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tambahkan produk ke keranjang',
            style: TextStyle(fontSize: 13, color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Select all
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppDimens.radiusM),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: _selectAll,
                  onChanged: (v) {
                    setState(() {
                      _selectAll = v ?? false;
                      for (final item in _cartItems) {
                        item['selected'] = _selectAll;
                      }
                    });
                  },
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Pilih Semua',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Seller group
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppDimens.radiusL),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Seller header
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(Icons.store,
                        size: 16, color: AppColors.textPrimary),
                    const SizedBox(width: 8),
                    const Text(
                      'AgriFresh Bandung',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right,
                        size: 18, color: AppColors.grey),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.divider),
              // Cart items
              ..._cartItems.map((item) => _CartItemTile(
                    item: item,
                    onQuantityChanged: (q) {
                      setState(() => item['quantity'] = q);
                    },
                    onSelectionChanged: (v) {
                      setState(() {
                        item['selected'] = v;
                        _selectAll = _cartItems
                            .every((i) => i['selected'] == true);
                      });
                    },
                  )),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Delivery method
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppDimens.radiusL),
          ),
          child: Row(
            children: [
              const Icon(Icons.local_shipping_outlined,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AgrExpress (Same Day)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Text(
                    'Rp 15.000',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.chevron_right, size: 18, color: AppColors.grey),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total ($_selectedCount item)',
                style: AppTextStyles.bodySmall,
              ),
              Text(
                formatPrice(_subtotal),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: PrimaryButton(
              text: 'Checkout ($_selectedCount item) →',
              onPressed: _selectedCount > 0
                  ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CheckoutScreen()),
                      )
                  : null,
              height: 46,
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final Function(int) onQuantityChanged;
  final Function(bool) onSelectionChanged;

  const _CartItemTile({
    required this.item,
    required this.onQuantityChanged,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final product = item['product'] as Product;
    final qty = item['quantity'] as int;
    final selected = item['selected'] as bool;

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: selected,
              onChanged: (v) => onSelectionChanged(v ?? false),
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.greenBadge,
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                const Icon(Icons.eco, color: AppColors.primary, size: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(product.seller, style: AppTextStyles.bodySmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      formatPrice(product.price),
                      style: AppTextStyles.priceSmall,
                    ),
                    const Spacer(),
                    _QtyControl(
                      quantity: qty,
                      onChanged: onQuantityChanged,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              if (quantity > 1) onChanged(quantity - 1);
            },
            child: Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              child: const Icon(Icons.remove, size: 14),
            ),
          ),
          Container(
            width: 32,
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(quantity + 1),
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(5),
                  bottomRight: Radius.circular(5),
                ),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.add, size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
