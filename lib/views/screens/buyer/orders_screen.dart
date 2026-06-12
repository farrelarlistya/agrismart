import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/price_formatter.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/order_provider.dart';
import '../../widgets/status_badge.dart';
import '../auth/login_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getOrdersByTab(List<Map<String, dynamic>> orders, int tab) {
    if (tab == 0) return orders.where((o) => o['status'] == 'Menunggu Pengiriman' || o['status'] == 'Menunggu Dikirim').toList();
    if (tab == 1) return orders.where((o) => o['status'] == 'Dikirim').toList();
    return orders.where((o) => o['status'] == 'Selesai').toList();
  }

  @override
  Widget build(BuildContext context) {
    final userProv = Provider.of<UserProvider>(context);
    final isGuest = userProv.user.id.isEmpty;
    final orderProv = Provider.of<OrderProvider>(context);

    if (!isGuest) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        orderProv.updateUserId(userProv.user.id);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(children: [
        _buildHeader(),
        if (isGuest)
          Expanded(child: _buildGuestPlaceholder())
        else ...[
          _buildTabs(),
          Expanded(
            child: orderProv.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : TabBarView(
                    controller: _tabController,
                    children: List.generate(3, (i) => _buildOrderList(_getOrdersByTab(orderProv.orders, i))),
                  ),
          ),
        ],
      ]),
    );
  }

  Widget _buildGuestPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.greenBadge,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: AppColors.primary,
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
              'Silakan masuk terlebih dahulu untuk melihat daftar pesanan Anda.',
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

  Widget _buildHeader() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: const Row(children: [
        Text('Pesanan Saya', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ]),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: AppColors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary, unselectedLabelColor: AppColors.grey, indicatorColor: AppColors.primary,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        tabs: const [Tab(text: 'Semua'), Tab(text: 'Dikirim'), Tab(text: 'Selesai')],
      ),
    );
  }

  Widget _buildOrderList(List<Map<String, dynamic>> orders) {
    if (orders.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.grey.withOpacity(0.4)),
        const SizedBox(height: 12),
        const Text('Belum ada pesanan', style: TextStyle(color: AppColors.grey, fontSize: 14)),
      ]));
    }
    return ListView.builder(padding: const EdgeInsets.all(16), itemCount: orders.length, itemBuilder: (context, i) => _OrderCard(order: orders[i]));
  }
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final String productImage = order['productImage'] as String? ?? '';
    final String unit = order['unit'] as String? ?? 'pcs';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppDimens.radiusL), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(children: [
        // Order header: invoice + status badge
        Padding(padding: const EdgeInsets.all(14), child: Row(children: [
          Text(order['id'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const Spacer(),
          StatusBadge(status: order['status'] as String),
        ])),
        const Divider(height: 1, color: AppColors.divider),
        // Product info with image
        Padding(padding: const EdgeInsets.all(14), child: Row(children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              productImage,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: AppColors.greenBadge, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary, size: 26),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Product name
            Text(order['productName'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            // Seller name
            Text(order['seller'] as String, style: AppTextStyles.bodySmall),
            const SizedBox(height: 2),
            // Quantity & unit
            Text('${order['quantity']} $unit × ${formatPrice((order['price'] as int).toDouble())}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ])),
        ])),
        const Divider(height: 1, color: AppColors.divider),
        // Footer: total + action button
        Padding(padding: const EdgeInsets.all(14), child: Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Total Pesanan', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            Text(formatPrice((order['price'] as int).toDouble()), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
          ]),
          const Spacer(),
          if (order['status'] == 'Selesai')
            OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primary), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), child: const Text('Beli Lagi', style: TextStyle(fontSize: 13, color: AppColors.primary)))
          else
            OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.grey), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), child: const Text('Lacak Pesanan', style: TextStyle(fontSize: 13, color: AppColors.textSecondary))),
        ])),
      ]),
    );
  }
}
