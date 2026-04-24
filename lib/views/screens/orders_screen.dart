import 'package:flutter/material.dart';
import '../screens/app_constants.dart';
import '../widgets/common_widgets.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
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

  final List<Map<String, dynamic>> _orders = const [
    {
      'id': '#INV-2024001',
      'date': '24 Okt 2024',
      'status': 'Menunggu Pengiriman',
      'productName': 'Ceri Organik',
      'seller': 'AgriFresh Bandung',
      'quantity': 1,
      'price': 25000,
      'tab': 0,
    },
    {
      'id': '#INV-2024002',
      'date': '16 Okt 2024',
      'status': 'Dikirim',
      'productName': 'Tomat Ceri',
      'seller': 'AgriFresh Bandung',
      'quantity': 2,
      'price': 40000,
      'tab': 1,
    },
    {
      'id': '#INV-2024005',
      'date': '12 Okt 2024',
      'status': 'Selesai',
      'productName': 'Ceri Organik',
      'seller': 'AgriFresh Bandung',
      'quantity': 2,
      'price': 75000,
      'tab': 2,
    },
    {
      'id': '#INV-2024006',
      'date': '10 Okt 2024',
      'status': 'Selesai',
      'productName': 'Melon Super',
      'seller': 'Kebun Makmur',
      'quantity': 1,
      'price': 32500,
      'tab': 2,
    },
  ];

  List<Map<String, dynamic>> _getOrdersByTab(int tab) {
    if (tab == 0) {
      return _orders
          .where((o) =>
              o['status'] == 'Menunggu Pengiriman' ||
              o['status'] == 'Menunggu Dikirim')
          .toList();
    } else if (tab == 1) {
      return _orders.where((o) => o['status'] == 'Dikirim').toList();
    } else {
      return _orders.where((o) => o['status'] == 'Selesai').toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          _buildTabs(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(
                3,
                (i) => _buildOrderList(_getOrdersByTab(i)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Row(
        children: [
          const Text(
            'Pesanan Saya',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.greenBadge,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.filter_list,
                color: AppColors.primary, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: AppColors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.grey,
        indicatorColor: AppColors.primary,
        labelStyle:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        tabs: const [
          Tab(text: 'Semua'),
          Tab(text: 'Dikirim'),
          Tab(text: 'Selesai'),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<Map<String, dynamic>> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 64, color: AppColors.grey.withOpacity(0.4)),
            const SizedBox(height: 12),
            const Text(
              'Belum ada pesanan',
              style: TextStyle(color: AppColors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, i) => _OrderCard(order: orders[i]),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          // Header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Text(
                  order['id'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                StatusBadge(status: order['status'] as String),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          // Product info
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.greenBadge,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.eco,
                      color: AppColors.primary, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['productName'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order['seller'] as String,
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${order['quantity']} x ${formatPrice((order['price'] as int).toDouble())}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          // Footer
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Pesanan',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                    Text(
                      formatPrice((order['price'] as int).toDouble()),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (order['status'] == 'Selesai')
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Beli Lagi',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.primary),
                    ),
                  )
                else
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.grey),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Lacak Pesanan',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
