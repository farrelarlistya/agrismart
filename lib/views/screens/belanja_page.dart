import 'package:flutter/material.dart';
import '../widgets/product_card_widget.dart';
import 'login_page.dart';

class BelanjaPage extends StatefulWidget {
  const BelanjaPage({super.key});

  @override
  State<BelanjaPage> createState() => _BelanjaPageState();
}

class _BelanjaPageState extends State<BelanjaPage> {
  // Dummy product data
  final List<Map<String, dynamic>> _products = [
    {
      'farm': 'Petani Cabai Makmur',
      'name': 'Cabai Merah',
      'price': 'Rp 35.000/kg',
      'stock': 'Stok: 25 kg',
      'color': Colors.red,
      'icon': Icons.local_fire_department,
    },
    {
      'farm': 'Kebun Organik Ibu Sari',
      'name': 'Bayam Hijau',
      'price': 'Rp 5.000/ikat',
      'stock': 'Stok: 80 ikat',
      'color': Colors.green,
      'icon': Icons.eco,
    },
    {
      'farm': 'Tani Sejahtera',
      'name': 'Tomat Segar',
      'price': 'Rp 12.000/kg',
      'stock': 'Stok: 50 kg',
      'color': Colors.orange,
      'icon': Icons.circle,
    },
    {
      'farm': 'Petani Brokoli Lestari',
      'name': 'Brokoli',
      'price': 'Rp 18.000/kg',
      'stock': 'Stok: 30 kg',
      'color': Colors.teal,
      'icon': Icons.forest,
    },
  ];

  // Drawer categories
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Sayuran', 'icon': Icons.eco},
    {'name': 'Buah-buahan', 'icon': Icons.apple},
    {'name': 'Beras & Biji-bijian', 'icon': Icons.grain},
    {'name': 'Daging', 'icon': Icons.set_meal},
    {'name': 'Ikan & Seafood', 'icon': Icons.water},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      // ===== DRAWER =====
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User profile (belum login)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  children: [
                    // Avatar placeholder
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey.shade300,
                      child: Icon(
                        Icons.person_outline,
                        size: 50,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Hi, Budi!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'budi@example.com',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Daftar',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Category title
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Kategori Bahan Pangan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Category list
              ..._categories.map(
                (cat) => ListTile(
                  leading: Icon(cat['icon'], color: Colors.black87),
                  title: Text(cat['name']),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),

              const Spacer(),

              // Keluar
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Keluar'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),

      // ===== APP BAR =====
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        titleSpacing: 0,
        title: SizedBox(
          height: 37,
          child: TextField(
            maxLines: 1,
            decoration: InputDecoration(
              hintText: 'Cari bahan pangan...',
              hintStyle: const TextStyle(fontSize: 13),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
            ),
          ),
        ),
        actions: [
          // Favorit icon
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {},
          ),
          // Cart icon with badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {},
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Masuk button
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            child: const Text(
              'Masuk',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),

      // ===== BODY =====
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner "Spesial Hari Ini!"
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🌾 Spesial Hari Ini!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Dapatkan bahan pangan segar\nlangsung dari petani dengan harga\nterbaik!',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Section title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Produk Terbaru',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Product cards horizontal scroll
            SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final p = _products[index];
                  return ProductCardWidget(
                    farmName: p['farm'],
                    productName: p['name'],
                    price: p['price'],
                    stock: p['stock'],
                    imageColor: p['color'],
                    imageIcon: p['icon'],
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Section title 2
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Populer Minggu Ini',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Product cards horizontal scroll 2
            SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final p = _products[_products.length - 1 - index];
                  return ProductCardWidget(
                    farmName: p['farm'],
                    productName: p['name'],
                    price: p['price'],
                    stock: p['stock'],
                    imageColor: p['color'],
                    imageIcon: p['icon'],
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
