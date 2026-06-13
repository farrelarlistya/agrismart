import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/price_formatter.dart';
import '../../../models/product.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/address_provider.dart';
import '../../widgets/agrismart_app_bar.dart';
import '../../widgets/primary_button.dart';

class CheckoutScreen extends StatefulWidget {
  /// If set, this is a direct checkout (skip cart).
  final Product? directProduct;
  final int directQuantity;

  const CheckoutScreen({super.key, this.directProduct, this.directQuantity = 1});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedPayment = 0;
  bool _isLoading = false;
  final List<Map<String, dynamic>> _paymentMethods = [
    {'icon': Icons.account_balance, 'label': 'Transfer Bank', 'desc': 'BCA, BNI, BRI, Mandiri'},
    {'icon': Icons.account_balance_wallet, 'label': 'E-Wallet', 'desc': 'OVO, GoPay, Dana'},
    {'icon': Icons.qr_code, 'label': 'QRIS', 'desc': 'Scan kode QR'},
  ];

  bool get _isDirect => widget.directProduct != null;

  double get _subtotal {
    if (_isDirect) return widget.directProduct!.price * widget.directQuantity;
    return context.read<CartProvider>().subtotal;
  }

  double get _shipping => 15000;
  double get _total => _subtotal + _shipping;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AgriSmartAppBar(title: 'Checkout', showBack: true),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildAddressSection(),
        const SizedBox(height: 12),
        _buildOrderSection(),
        const SizedBox(height: 12),
        _buildShippingSection(),
        const SizedBox(height: 12),
        _buildPaymentSection(),
        const SizedBox(height: 12),
        _buildSummarySection(),
        const SizedBox(height: 12),
        _buildNoteField(),
        const SizedBox(height: 20),
        _buildCheckoutButton(),
        const SizedBox(height: 16),
      ])),
    );
  }

  Widget _buildAddressSection() {
    return Consumer<AddressProvider>(
      builder: (context, addrProv, _) {
        final addr = addrProv.defaultAddress;
        return _SectionCard(
          title: 'Alamat Pengiriman',
          trailing: TextButton(onPressed: () {}, child: const Text('Ubah', style: TextStyle(fontSize: 12, color: AppColors.primary))),
          child: addr != null
            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.location_on, color: AppColors.primary, size: 18),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(addr.recipientName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(addr.phone, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(addr.address, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5)),
                ])),
              ])
            : const Text('Belum ada alamat pengiriman', style: TextStyle(fontSize: 13, color: AppColors.grey)),
        );
      },
    );
  }

  Widget _buildOrderSection() {
    if (_isDirect) {
      final p = widget.directProduct!;
      return _SectionCard(
        title: 'Pesanan Anda',
        trailing: Text(p.seller, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        child: Row(children: [
          ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(p.imageUrl, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_, _, _) => Container(width: 50, height: 50, decoration: BoxDecoration(color: AppColors.greenBadge, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.eco, color: AppColors.primary, size: 26)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text('${widget.directQuantity} ${p.unit} · ${formatPrice(p.price)}', style: AppTextStyles.bodySmall),
          ])),
          Text(formatPrice(p.price * widget.directQuantity), style: AppTextStyles.priceSmall),
        ]),
      );
    }

    // Cart checkout
    final cartItems = context.read<CartProvider>().selectedItems;
    return _SectionCard(
      title: 'Pesanan Anda',
      trailing: Text('${cartItems.length} item', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      child: Column(
        children: cartItems.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(children: [
            ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset(item.product.imageUrl, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_, _, _) => Container(width: 50, height: 50, decoration: BoxDecoration(color: AppColors.greenBadge, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.eco, color: AppColors.primary, size: 26)))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.product.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              Text('${item.quantity} ${item.product.unit} · ${formatPrice(item.product.price)}', style: AppTextStyles.bodySmall),
            ])),
            Text(formatPrice(item.totalPrice), style: AppTextStyles.priceSmall),
          ]),
        )).toList(),
      ),
    );
  }

  Widget _buildShippingSection() {
    return _SectionCard(title: 'Pengiriman', child: Row(children: [
      const Icon(Icons.local_shipping_outlined, color: AppColors.primary, size: 18),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('AgrExpress (Same Day)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
        Text('Estimasi tiba dalam 1-2 jam', style: AppTextStyles.bodySmall),
      ])),
      Text(formatPrice(_shipping), style: AppTextStyles.priceSmall),
    ]));
  }

  Widget _buildPaymentSection() {
    return _SectionCard(title: 'Metode Pembayaran', child: Column(children: List.generate(_paymentMethods.length, (i) {
      final method = _paymentMethods[i];
      return GestureDetector(onTap: () => setState(() => _selectedPayment = i), child: Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: _selectedPayment == i ? AppColors.greenBadge : AppColors.secondary, borderRadius: BorderRadius.circular(8)), child: Icon(method['icon'] as IconData, color: _selectedPayment == i ? AppColors.primary : AppColors.grey, size: 18)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(method['label'] as String, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _selectedPayment == i ? AppColors.primary : AppColors.textPrimary)),
          Text(method['desc'] as String, style: AppTextStyles.caption),
        ])),
        Radio<int>(value: i, groupValue: _selectedPayment, onChanged: (v) => setState(() => _selectedPayment = v ?? 0), activeColor: AppColors.primary),
      ])));
    })));
  }

  Widget _buildSummarySection() {
    return _SectionCard(title: 'Ringkasan Pembayaran', child: Column(children: [
      _SummaryRow('Subtotal Harga', formatPrice(_subtotal)),
      const SizedBox(height: 8),
      _SummaryRow('Total Ongkos Kirim', formatPrice(_shipping)),
      const SizedBox(height: 12),
      const Divider(color: AppColors.divider),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Total Tagihan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        Text(formatPrice(_total), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.primary)),
      ]),
    ]));
  }

  Widget _buildNoteField() {
    return Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppDimens.radiusL)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Catatan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextField(maxLines: 2, style: const TextStyle(fontSize: 13), decoration: InputDecoration(hintText: 'Tambahkan catatan untuk penjual...', hintStyle: const TextStyle(fontSize: 12, color: AppColors.grey), filled: true, fillColor: AppColors.secondary, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none), contentPadding: const EdgeInsets.all(12))),
      ]));
  }

  Widget _buildCheckoutButton() {
    return Column(children: [
      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(10)),
        child: const Row(children: [Icon(Icons.info_outline, color: AppColors.orange, size: 16), SizedBox(width: 8),
          Expanded(child: Text('Saya menyetujui Syarat & Ketentuan yang berlaku di AgriSmart.', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.4)))])),
      const SizedBox(height: 12),
      PrimaryButton(text: 'BAYAR SEKARANG →', isLoading: _isLoading, onPressed: () async {
        setState(() => _isLoading = true);
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;
        setState(() => _isLoading = false);
        // Clear cart if checkout from cart
        if (!_isDirect) {
          context.read<CartProvider>().clearSelected();
        }
        _showSuccessDialog();
      }),
    ]);
  }

  void _showSuccessDialog() {
    showDialog(context: context, barrierDismissible: false, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusXL)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 70, height: 70, decoration: const BoxDecoration(color: AppColors.greenBadge, shape: BoxShape.circle), child: const Icon(Icons.check_circle, color: AppColors.primary, size: 40)),
        const SizedBox(height: 16),
        const Text('Pesanan Berhasil!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        const Text('Pesanan Anda sedang diproses oleh penjual.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 20),
        PrimaryButton(text: 'Kembali ke Beranda', onPressed: () {
          Navigator.pop(context); // close dialog
          Navigator.pop(context); // close checkout
          if (!_isDirect) Navigator.pop(context); // close cart if from cart
        }, height: 44),
      ]),
    ));
  }
}

class _SectionCard extends StatelessWidget {
  final String title; final Widget child; final Widget? trailing;
  const _SectionCard({required this.title, required this.child, this.trailing});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppDimens.radiusL), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)), const Spacer(), ?trailing]),
        const SizedBox(height: 12), child,
      ]));
  }
}

class _SummaryRow extends StatelessWidget {
  final String label; final String value;
  const _SummaryRow(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: AppTextStyles.bodySmall),
      Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
    ]);
  }
}
