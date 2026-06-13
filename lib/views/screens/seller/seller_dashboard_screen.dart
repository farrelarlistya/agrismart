import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/price_formatter.dart';
import '../../../providers/store_provider.dart';
import '../../../providers/order_provider.dart';
import '../../../providers/user_provider.dart';
import 'seller_profile_screen.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final storeProv = context.read<StoreProvider>();
    final orderProv = context.read<OrderProvider>();
    if (storeProv.store != null) {
      await orderProv.fetchSellerOrders(storeProv.store!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>().store;
    final orderProv = context.watch<OrderProvider>();
    final user = context.watch<UserProvider>().user;

    final needsShipping = orderProv.sellerOrders
        .where((o) => (o['status'] as String).contains('Pengiriman') || (o['status'] as String).contains('Dikirim'))
        .toList();
    final recentOrders = orderProv.sellerOrders.take(2).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(context, user.name, store),
                if (store != null) ...[
                  _buildStoreStatus(context, store),
                  _buildRevenueCard(store),
                  _buildNeedsShippingCard(needsShipping.length),
                ] else
                  _buildNoStoreState(),
                if (recentOrders.isNotEmpty)
                  _buildLatestOrders(context, recentOrders)
                else if (store != null)
                  _buildEmptyOrders(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, String userName, store) {
    final logoUrl = store?.logoUrl;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: store != null
                ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerProfileScreen()))
                : null,
            child: Stack(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.greenBadge,
                    border: Border.all(color: AppColors.primary, width: 1.5),
                    image: logoUrl != null
                        ? DecorationImage(
                            image: logoUrl.startsWith('/')
                                ? FileImage(File(logoUrl)) as ImageProvider
                                : NetworkImage(logoUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: logoUrl == null
                      ? const Icon(Icons.storefront, size: 24, color: AppColors.primary)
                      : null,
                ),
                if (store != null)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Icon(Icons.edit, size: 8, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Selamat Datang,', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              Text(
                'Halo, ${userName.isNotEmpty ? userName.split(' ').first : 'Penjual'}!',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: AppColors.primary, size: 22),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildStoreStatus(BuildContext context, store) {
    final logoUrl = store.logoUrl as String?;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerProfileScreen())),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.greenBadge,
                image: logoUrl != null
                    ? DecorationImage(
                        image: logoUrl.startsWith('/')
                            ? FileImage(File(logoUrl)) as ImageProvider
                            : NetworkImage(logoUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: logoUrl == null ? const Icon(Icons.storefront, color: AppColors.primary) : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(store.name as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(
                        color: (store.isActive as bool) ? AppColors.primary : AppColors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      (store.isActive as bool) ? 'Toko Aktif' : 'Toko Nonaktif',
                      style: TextStyle(fontSize: 12, color: (store.isActive as bool) ? AppColors.primary : AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Switch(
            value: store.isActive as bool,
            onChanged: (_) => context.read<StoreProvider>().toggleStoreActive(),
            activeColor: Colors.white,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueCard(store) {
    final balance = (store.balance as double?) ?? 0.0;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E8B4F), Color(0xFF2E7D32)],
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusXL),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pendapatan Bulan Ini', style: TextStyle(fontSize: 12, color: Colors.white70)),
          const SizedBox(height: 8),
          Text(
            balance > 0 ? formatPrice(balance) : 'Rp 0',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          if (balance > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.trending_up, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text('Saldo Terkini', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNeedsShippingCard(int count) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Perlu Dikirim', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              Icon(Icons.local_shipping_outlined, color: AppColors.orange),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$count', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text('Pesanan', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Proses Sekarang', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestOrders(BuildContext context, List<Map<String, dynamic>> orders) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Pesanan Masuk Terbaru', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const Spacer(),
              GestureDetector(onTap: () {}, child: const Text('Lihat Semua', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600))),
            ],
          ),
          const SizedBox(height: 12),
          ...orders.map((order) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _OrderCard(order: order),
          )),
        ],
      ),
    );
  }

  Widget _buildNoStoreState() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppDimens.radiusL)),
      child: const Column(
        children: [
          Icon(Icons.storefront_outlined, size: 60, color: AppColors.grey),
          SizedBox(height: 12),
          Text('Toko belum terdaftar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          SizedBox(height: 4),
          Text('Daftarkan tokomu untuk mulai berjualan', style: TextStyle(fontSize: 12, color: AppColors.textSecondary), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildEmptyOrders() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppDimens.radiusL)),
      child: const Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 50, color: AppColors.grey),
          SizedBox(height: 12),
          Text('Belum ada pesanan masuk', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final buyerName = order['buyer_name'] as String? ?? '-';
    final initials = buyerName.isNotEmpty ? buyerName.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase() : '?';
    final imageUrl = order['productImage'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(order['id'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
              const Spacer(),
              Text(order['date'] as String? ?? '', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: const Color(0xFFB05072),
                child: Text(initials, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              Text(buyerName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const Spacer(),
              _StatusBadge(status: order['status'] as String? ?? ''),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(AppDimens.radiusM)),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageUrl.isNotEmpty
                      ? Image.network(imageUrl, width: 48, height: 48, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 48, color: AppColors.grey))
                      : Container(width: 48, height: 48, color: AppColors.greyLight, child: const Icon(Icons.image, color: AppColors.grey)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order['productName'] as String? ?? '-', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('${order['quantity']} x ${formatPrice((order['price'] as int? ?? 0).toDouble())}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Pesanan', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text(formatPrice((order['price'] as int? ?? 0).toDouble()),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Input Resi', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg = const Color(0xFFFDF3E1);
    Color fg = const Color(0xFFB86614);
    if (status.contains('Selesai')) { bg = AppColors.greenBadge; fg = AppColors.primary; }
    if (status.contains('Dibatalkan')) { bg = const Color(0xFFFFEBEE); fg = AppColors.red; }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}
