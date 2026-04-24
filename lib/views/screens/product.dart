class Product {
  final String id;
  final String name;
  final String seller;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final String category;
  final String unit;
  final double rating;
  final int reviewCount;
  final String description;
  final bool isOrganic;
  final bool isPremium;
  final int stock;

  const Product({
    required this.id,
    required this.name,
    required this.seller,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    required this.category,
    this.unit = 'kg',
    this.rating = 4.5,
    this.reviewCount = 0,
    this.description = '',
    this.isOrganic = false,
    this.isPremium = false,
    this.stock = 100,
  });
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.price * quantity;
}

class Order {
  final String id;
  final String date;
  final String status;
  final List<CartItem> items;
  final double totalPrice;
  final String buyerName;
  final String address;

  const Order({
    required this.id,
    required this.date,
    required this.status,
    required this.items,
    required this.totalPrice,
    required this.buyerName,
    required this.address,
  });
}

// Dummy data
class AppData {
  static const List<Product> products = [
    Product(
      id: '1',
      name: 'Tomat Organik',
      seller: 'AgriFresh Bandung',
      price: 20000,
      originalPrice: 25000,
      imageUrl: 'assets/images/tomato.jpg',
      category: 'Hasil Pertanian',
      unit: 'kg',
      rating: 4.8,
      reviewCount: 124,
      description:
          'Tomat cherry premium pilihan yang ditanam dengan metode hidroponik tanpa pestisida kimia. Memiliki rasa manis alami yang kuat dan tekstur segar.',
      isOrganic: true,
    ),
    Product(
      id: '2',
      name: 'Brokoli Segar',
      seller: 'Tani Maju',
      price: 15000,
      imageUrl: 'assets/images/broccoli.jpg',
      category: 'Sayuran',
      unit: 'kg',
      rating: 4.5,
      reviewCount: 89,
      isOrganic: true,
    ),
    Product(
      id: '3',
      name: 'Buncis Muda',
      seller: 'Kebun Sehat',
      price: 12000,
      imageUrl: 'assets/images/beans.jpg',
      category: 'Sayuran',
      unit: 'kg',
      rating: 4.3,
      reviewCount: 56,
    ),
    Product(
      id: '4',
      name: 'Wortel Organik',
      seller: 'AgriFresh Bandung',
      price: 8000,
      imageUrl: 'assets/images/carrot.jpg',
      category: 'Sayuran',
      unit: 'kg',
      rating: 4.6,
      reviewCount: 210,
      isOrganic: true,
      isPremium: true,
    ),
    Product(
      id: '5',
      name: 'Tomat Ceri',
      seller: 'Tani Maju',
      price: 18000,
      imageUrl: 'assets/images/cherry_tomato.jpg',
      category: 'Hasil Pertanian',
      unit: 'kg',
      rating: 4.7,
      reviewCount: 143,
    ),
    Product(
      id: '6',
      name: 'Madu Hutan Murni',
      seller: 'Lebah Alam',
      price: 85000,
      imageUrl: 'assets/images/honey.jpg',
      category: 'Produk Olahan',
      unit: 'botol',
      rating: 4.9,
      reviewCount: 312,
      isPremium: true,
    ),
    Product(
      id: '7',
      name: 'Pisang Cavendish',
      seller: 'Kebun Nusantara',
      price: 32000,
      imageUrl: 'assets/images/banana.jpg',
      category: 'Buah',
      unit: 'sisir',
      rating: 4.4,
      reviewCount: 78,
    ),
    Product(
      id: '8',
      name: 'Beras Merah Organik',
      seller: 'Sawah Organik',
      price: 45000,
      imageUrl: 'assets/images/rice.jpg',
      category: 'Beras & Biji',
      unit: 'kg',
      rating: 4.7,
      reviewCount: 267,
      isOrganic: true,
    ),
    Product(
      id: '9',
      name: 'Melon Super',
      seller: 'Kebun Makmur',
      price: 35000,
      imageUrl: 'assets/images/melon.jpg',
      category: 'Buah',
      unit: 'buah',
      rating: 4.5,
      reviewCount: 91,
    ),
    Product(
      id: '10',
      name: 'Ceri Organik',
      seller: 'AgriFresh Bandung',
      price: 25000,
      imageUrl: 'assets/images/cherry.jpg',
      category: 'Buah',
      unit: 'kg',
      rating: 4.6,
      reviewCount: 105,
      isOrganic: true,
    ),
  ];

  static const List<String> categories = [
    'Semua',
    'Hasil Pertanian',
    'Sayuran',
    'Buah',
    'Produk Olahan',
    'Beras & Biji',
    'Gas & Minyak',
  ];

  static const List<Map<String, dynamic>> orders = [
    {
      'id': '#INV-2024001',
      'date': '24 Okt 2024, 14:30',
      'status': 'Menunggu Pengiriman',
      'productName': 'Ceri Organik',
      'quantity': 1,
      'price': 25000,
      'buyerName': 'Julian Harvest',
    },
    {
      'id': '#INV-2024002',
      'date': '16 Okt 2024',
      'status': 'Menunggu Dikirim',
      'productName': 'Tomat Ceri',
      'quantity': 2,
      'price': 40000,
      'buyerName': 'Siti Agraria',
    },
    {
      'id': '#INV-2024005',
      'date': '12 Okt 2024',
      'status': 'Selesai',
      'productName': 'Ceri Organik',
      'quantity': 2,
      'price': 75000,
      'buyerName': 'Elna Roots',
    },
  ];
}