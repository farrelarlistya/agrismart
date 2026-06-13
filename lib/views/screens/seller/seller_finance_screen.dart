import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/price_formatter.dart';
import '../../../providers/store_provider.dart';
import '../../../providers/user_provider.dart';

class SellerFinanceScreen extends StatefulWidget {
  const SellerFinanceScreen({super.key});

  @override
  State<SellerFinanceScreen> createState() => _SellerFinanceScreenState();
}

class _SellerFinanceScreenState extends State<SellerFinanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoreProvider>().fetchFinance();
    });
  }

  void _showWithdrawDialog() {
    final amountCtrl = TextEditingController();
    final bankCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tarik Dana', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 20),
              const Text('Nama Bank', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: bankCtrl,
                decoration: InputDecoration(
                  hintText: 'Contoh: BCA, Mandiri',
                  filled: true, fillColor: AppColors.secondary,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimens.radiusM), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Jumlah Penarikan (Rp)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '100000',
                  filled: true, fillColor: AppColors.secondary,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimens.radiusM), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;
                    final bank = bankCtrl.text.trim();
                    if (amount <= 0 || bank.isEmpty) return;
                    Navigator.pop(ctx);
                    final success = await context.read<StoreProvider>().withdraw(amount: amount, bankName: bank);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(success ? 'Penarikan berhasil!' : 'Penarikan gagal'),
                        backgroundColor: success ? AppColors.primary : AppColors.red,
                      ));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusXL)),
                  ),
                  child: const Text('Konfirmasi Penarikan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storeProv = context.watch<StoreProvider>();
    final user = context.watch<UserProvider>().user;
    final store = storeProv.store;
    final balance = storeProv.balance;
    final transactions = storeProv.transactions;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => storeProv.fetchFinance(),
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildBalanceCard(balance, storeProv.isLoading),
                _buildTransactionHistory(transactions),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Keuangan', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        SizedBox(height: 4),
        Text('Kelola pendapatan dan transaksi Anda.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      ]),
    );
  }

  Widget _buildBalanceCard(double balance, bool isLoading) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
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
          const Text('SALDO TERSEDIA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white70)),
          const SizedBox(height: 8),
          isLoading
              ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
              : Text(formatPrice(balance), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: balance > 0 ? _showWithdrawDialog : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                disabledBackgroundColor: Colors.white.withOpacity(0.5),
                foregroundColor: AppColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text('Tarik Dana', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: balance > 0 ? AppColors.primary : AppColors.grey)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHistory(List<Map<String, dynamic>> transactions) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Riwayat Transaksi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          if (transactions.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              alignment: Alignment.center,
              child: const Column(children: [
                Icon(Icons.account_balance_wallet_outlined, size: 48, color: AppColors.grey),
                SizedBox(height: 12),
                Text('Belum ada transaksi', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ]),
            )
          else
            ...transactions.map((tx) {
              final isIncome = tx['type'] == 'income';
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppDimens.radiusL),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Row(children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: isIncome ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                          color: isIncome ? AppColors.primary : AppColors.red, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(tx['title'] as String? ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text(tx['date'] as String? ?? '', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ])),
                    Text(
                      '${isIncome ? '+' : '-'} ${formatPrice((tx['amount'] as num?)?.toDouble() ?? 0)}',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isIncome ? AppColors.primary : AppColors.textPrimary),
                    ),
                  ]),
                ),
              );
            }),
          if (transactions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Center(
              child: GestureDetector(
                onTap: () => context.read<StoreProvider>().fetchFinance(),
                child: const Text('Muat Ulang Transaksi', style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
