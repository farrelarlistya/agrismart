import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/price_formatter.dart';
import '../../../providers/order_provider.dart';
import '../../../providers/store_provider.dart';

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Semua', 'Perlu Dikirim', 'Dikirim', 'Selesai'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final store = context.read<StoreProvider>().store;
      if (store != null) {
        context.read<OrderProvider>().fetchSellerOrders(store.id);
      }
    });
  }

  List<Map<String, dynamic>> _filteredOrders(List<Map<String, dynamic>> all) {
    if (_selectedTabIndex == 0) return all;
    final filterMap = ['', 'Menunggu', 'Dikirim', 'Selesai'];
    final keyword = filterMap[_selectedTabIndex];
    return all.where((o) => (o['status'] as String).contains(keyword)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final orderProv = context.watch<OrderProvider>();
    final filtered = _filteredOrders(orderProv.sellerOrders);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Pesanan Saya', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      ),
      body: Column(
        children: [
          _buildTabs(),
          Expanded(
            child: orderProv.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : filtered.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () {
                          final store = context.read<StoreProvider>().store;
                          if (store != null) return context.read<OrderProvider>().refreshSellerOrders(store.id);
                          return Future.value();
                        },
                        color: AppColors.primary,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (_, i) => _OrderCard(order: filtered[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedTabIndex = index),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.secondary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(_tabs[index],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  )),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.grey),
          const SizedBox(height: 16),
          const Text('Tidak ada pesanan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(
            _selectedTabIndex == 0 ? 'Belum ada pesanan yang masuk' : 'Tidak ada pesanan dengan status ini',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
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
    final initials = buyerName.isNotEmpty
        ? buyerName.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : '?';
    final imageUrl = order['productImage'] as String? ?? '';
    final status = order['status'] as String? ?? '';

    Color statusBg = const Color(0xFFFDF3E1);
    Color statusFg = const Color(0xFFB86614);
    if (status.contains('Selesai')) { statusBg = AppColors.greenBadge; statusFg = AppColors.primary; }
    if (status.contains('Dibatalkan')) { statusBg = const Color(0xFFFFEBEE); statusFg = AppColors.red; }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(order['id'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
            const Spacer(),
            Text(order['date'] as String? ?? '', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFFB05072),
              child: Text(initials, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 10),
            Text(buyerName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(12)),
              child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: statusFg)),
            ),
          ]),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(AppDimens.radiusM)),
            child: Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl.isNotEmpty
                    ? Image.network(imageUrl, width: 48, height: 48, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(width: 48, height: 48, color: AppColors.greyLight, child: const Icon(Icons.image, color: AppColors.grey)))
                    : Container(width: 48, height: 48, color: AppColors.greyLight, child: const Icon(Icons.image, color: AppColors.grey)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(order['productName'] as String? ?? '-', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('${order['quantity']} x ${formatPrice((order['price'] as int? ?? 0).toDouble())}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ])),
            ]),
          ),
          const SizedBox(height: 16),
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Total Pesanan', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 2),
              Text(formatPrice((order['price'] as int? ?? 0).toDouble()),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            ]),
            const Spacer(),
            ElevatedButton(
              onPressed: status.contains('Pengiriman') ? () {} : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.greyLight,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(
                status.contains('Pengiriman') ? 'Input Resi' : (status.contains('Selesai') ? 'Selesai ✓' : 'Lihat Detail'),
                style: TextStyle(color: status.contains('Pengiriman') ? Colors.white : AppColors.grey, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
