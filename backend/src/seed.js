import mysql from 'mysql2/promise';
import dotenv from 'dotenv';
import bcrypt from 'bcryptjs';

dotenv.config();

/**
 * Seed script: Creates database, tables, and inserts initial data
 * matching the dummy_data.dart from the Flutter app.
 */
async function seed() {
  // Connect without database first to create it
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '3306'),
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
  });

  const dbName = process.env.DB_NAME || 'agrismart';

  console.log('🌱 Starting database seed...\n');

  // Create database
  await connection.query(`CREATE DATABASE IF NOT EXISTS \`${dbName}\``);
  await connection.query(`USE \`${dbName}\``);
  console.log(`✅ Database "${dbName}" ready`);

  // Drop tables in reverse order (foreign key constraints)
  const dropTables = [
    'favorites', 'order_items', 'orders', 'stores', 'addresses', 'products', 'users', 'categories'
  ];
  for (const table of dropTables) {
    await connection.query(`DROP TABLE IF EXISTS \`${table}\``);
  }
  console.log('✅ Old tables dropped');

  // Create categories table
  await connection.query(`
    CREATE TABLE categories (
      id INT AUTO_INCREMENT PRIMARY KEY,
      name VARCHAR(100) NOT NULL UNIQUE
    )
  `);

  // Create products table
  await connection.query(`
    CREATE TABLE products (
      id INT AUTO_INCREMENT PRIMARY KEY,
      name VARCHAR(255) NOT NULL,
      seller VARCHAR(255) NOT NULL,
      seller_id VARCHAR(50) DEFAULT NULL,
      price DECIMAL(12,2) NOT NULL,
      original_price DECIMAL(12,2) DEFAULT NULL,
      image_url VARCHAR(500) NOT NULL,
      category_id INT,
      unit VARCHAR(50) DEFAULT 'kg',
      rating DECIMAL(3,2) DEFAULT 4.50,
      review_count INT DEFAULT 0,
      description TEXT,
      is_organic TINYINT(1) DEFAULT 0,
      is_premium TINYINT(1) DEFAULT 0,
      stock INT DEFAULT 100,
      location VARCHAR(255) DEFAULT '',
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (category_id) REFERENCES categories(id)
    )
  `);

  // Create users table
  await connection.query(`
    CREATE TABLE users (
      id VARCHAR(50) PRIMARY KEY,
      name VARCHAR(255) NOT NULL,
      email VARCHAR(255) NOT NULL,
      password VARCHAR(255) NOT NULL,
      phone VARCHAR(50),
      avatar_url VARCHAR(500) DEFAULT NULL
    )
  `);

  // Create addresses table
  await connection.query(`
    CREATE TABLE addresses (
      id INT AUTO_INCREMENT PRIMARY KEY,
      user_id VARCHAR(50) NOT NULL,
      recipient_name VARCHAR(255) NOT NULL,
      phone VARCHAR(50) NOT NULL,
      address TEXT NOT NULL,
      is_default TINYINT(1) DEFAULT 0,
      FOREIGN KEY (user_id) REFERENCES users(id)
    )
  `);

  // Create stores table
  await connection.query(`
    CREATE TABLE stores (
      id VARCHAR(50) PRIMARY KEY,
      user_id VARCHAR(50) NOT NULL UNIQUE,
      name VARCHAR(255) NOT NULL,
      phone VARCHAR(50) NOT NULL,
      warehouse_name VARCHAR(255),
      pic_name VARCHAR(255),
      pic_phone VARCHAR(50),
      province VARCHAR(100),
      city VARCHAR(100),
      district VARCHAR(100),
      postal_code VARCHAR(20),
      address TEXT,
      nik VARCHAR(50),
      logo_url VARCHAR(500) DEFAULT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES users(id)
    )
  `);

  // Create orders table
  await connection.query(`
    CREATE TABLE orders (
      id VARCHAR(50) PRIMARY KEY,
      user_id VARCHAR(50) NOT NULL,
      date VARCHAR(100) NOT NULL,
      status VARCHAR(100) NOT NULL,
      total_price DECIMAL(12,2) NOT NULL,
      buyer_name VARCHAR(255) NOT NULL,
      address TEXT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES users(id)
    )
  `);

  // Create order_items table
  await connection.query(`
    CREATE TABLE order_items (
      id INT AUTO_INCREMENT PRIMARY KEY,
      order_id VARCHAR(50) NOT NULL,
      product_id INT NOT NULL,
      quantity INT NOT NULL,
      price DECIMAL(12,2) NOT NULL,
      FOREIGN KEY (order_id) REFERENCES orders(id),
      FOREIGN KEY (product_id) REFERENCES products(id)
    )
  `);

  // Create favorites table
  await connection.query(`
    CREATE TABLE favorites (
      id INT AUTO_INCREMENT PRIMARY KEY,
      user_id VARCHAR(50) NOT NULL,
      product_id INT NOT NULL,
      UNIQUE KEY unique_fav (user_id, product_id),
      FOREIGN KEY (user_id) REFERENCES users(id),
      FOREIGN KEY (product_id) REFERENCES products(id)
    )
  `);

  console.log('✅ All tables created\n');

  // ========== SEED DATA ==========

  // 1. Categories (matching AppData.categories from dummy_data.dart)
  const categoriesData = ['Hasil Pertanian', 'Produk Olahan', 'Sarana Produksi', 'Alat & Mesin'];
  for (const name of categoriesData) {
    await connection.execute('INSERT INTO categories (name) VALUES (?)', [name]);
  }
  console.log(`✅ Inserted ${categoriesData.length} categories`);

  // Helper to get category ID
  const getCategoryId = async (name) => {
    const [rows] = await connection.execute('SELECT id FROM categories WHERE name = ?', [name]);
    return rows.length > 0 ? rows[0].id : null;
  };

  // 2. Products (matching AppData.products from dummy_data.dart)
  const productsData = [
    {
      name: 'Tomat Organik',
      seller: 'AgriFresh Bandung',
      price: 20000,
      original_price: 25000,
      image_url: 'assets/images/tomato.png',
      category: 'Hasil Pertanian',
      unit: 'kg',
      rating: 4.8,
      review_count: 124,
      description: 'Tomat cherry premium pilihan yang ditanam dengan metode hidroponik tanpa pestisida kimia. Memiliki rasa manis alami yang kuat dan tekstur segar.',
      is_organic: true,
      is_premium: false,
      location: 'Bandung, Jawa Barat',
    },
    {
      name: 'Brokoli Segar',
      seller: 'Tani Maju',
      price: 15000,
      original_price: null,
      image_url: 'assets/images/broccoli.png',
      category: 'Hasil Pertanian',
      unit: 'kg',
      rating: 4.5,
      review_count: 89,
      description: '',
      is_organic: true,
      is_premium: false,
      location: 'Lembang, Jawa Barat',
    },
    {
      name: 'Buncis Muda',
      seller: 'Kebun Sehat',
      price: 12000,
      original_price: null,
      image_url: 'assets/images/beans.png',
      category: 'Hasil Pertanian',
      unit: 'kg',
      rating: 4.3,
      review_count: 56,
      description: '',
      is_organic: false,
      is_premium: false,
      location: 'Garut, Jawa Barat',
    },
    {
      name: 'Wortel Organik',
      seller: 'AgriFresh Bandung',
      price: 8000,
      original_price: null,
      image_url: 'assets/images/carrot.png',
      category: 'Hasil Pertanian',
      unit: 'kg',
      rating: 4.6,
      review_count: 210,
      description: '',
      is_organic: true,
      is_premium: true,
      location: 'Bandung, Jawa Barat',
    },
    {
      name: 'Tomat Ceri',
      seller: 'Tani Maju',
      price: 18000,
      original_price: null,
      image_url: 'assets/images/cherry_tomato.png',
      category: 'Hasil Pertanian',
      unit: 'kg',
      rating: 4.7,
      review_count: 143,
      description: '',
      is_organic: false,
      is_premium: false,
      location: 'Cianjur, Jawa Barat',
    },
    {
      name: 'Madu Hutan Murni',
      seller: 'Lebah Alam',
      price: 85000,
      original_price: null,
      image_url: 'assets/images/honey.png',
      category: 'Produk Olahan',
      unit: 'botol',
      rating: 4.9,
      review_count: 312,
      description: '',
      is_organic: false,
      is_premium: true,
      location: 'Sumbawa, NTB',
    },
    {
      name: 'Pisang Cavendish',
      seller: 'Kebun Nusantara',
      price: 32000,
      original_price: null,
      image_url: 'assets/images/banana.png',
      category: 'Hasil Pertanian',
      unit: 'sisir',
      rating: 4.4,
      review_count: 78,
      description: '',
      is_organic: false,
      is_premium: false,
      location: 'Lampung, Sumatera',
    },
    {
      name: 'Beras Merah Organik',
      seller: 'Sawah Organik',
      price: 45000,
      original_price: null,
      image_url: 'assets/images/rice.png',
      category: 'Produk Olahan',
      unit: 'kg',
      rating: 4.7,
      review_count: 267,
      description: '',
      is_organic: true,
      is_premium: false,
      location: 'Subang, Jawa Barat',
    },
    {
      name: 'Melon Super',
      seller: 'Kebun Makmur',
      price: 35000,
      original_price: null,
      image_url: 'assets/images/melon.png',
      category: 'Hasil Pertanian',
      unit: 'buah',
      rating: 4.5,
      review_count: 91,
      description: '',
      is_organic: false,
      is_premium: false,
      location: 'Blitar, Jawa Timur',
    },
    {
      name: 'Ceri Organik',
      seller: 'AgriFresh Bandung',
      price: 25000,
      original_price: null,
      image_url: 'assets/images/cherry.png',
      category: 'Hasil Pertanian',
      unit: 'kg',
      rating: 4.6,
      review_count: 105,
      description: '',
      is_organic: true,
      is_premium: false,
      location: 'Bandung, Jawa Barat',
    },
  ];

  for (const p of productsData) {
    const categoryId = await getCategoryId(p.category);
    await connection.execute(
      `INSERT INTO products (name, seller, price, original_price, image_url, category_id,
        unit, rating, review_count, description, is_organic, is_premium, stock, location)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [p.name, p.seller, p.price, p.original_price, p.image_url, categoryId,
       p.unit, p.rating, p.review_count, p.description, p.is_organic ? 1 : 0,
       p.is_premium ? 1 : 0, 100, p.location]
    );
  }
  console.log(`✅ Inserted ${productsData.length} products`);

  // 3. Users
  const defaultPasswordHash = await bcrypt.hash('password123', 10);
  await connection.execute(
    `INSERT INTO users (id, name, email, password, phone) VALUES (?, ?, ?, ?, ?)`,
    ['user_001', 'Julian Harvest', 'julian.harvest@email.com', defaultPasswordHash, '0812-3456-7890']
  );
  console.log('✅ Inserted 1 user');

  // 4. Addresses (matching AddressProvider from address_provider.dart)
  const addressesData = [
    {
      user_id: 'user_001',
      recipient_name: 'Julian Harvest',
      phone: '0812-3456-7890',
      address: 'Jl. Raya Kebun Raya No. 58, Blok C2, Villa Agrikultura, Kecamatan Cisarua, Kabupaten Bogor, Jawa Barat, 16793',
      is_default: true,
    },
    {
      user_id: 'user_001',
      recipient_name: 'Julian Harvest (Warehouse)',
      phone: '0812-9382-7768',
      address: 'Kawasan Industri Sentral, Pergudangan AgriSmart Blok C-12, Cileungsi, Kabupaten Bogor, Jawa Barat, 16870',
      is_default: false,
    },
    {
      user_id: 'user_001',
      recipient_name: 'Bapak Harvest',
      phone: '0811-1111-2323',
      address: 'Desa Sukamakur, RT 05 RW 02, Kec. Sukamakmur, Kab. Bogor, Jawa Barat, 16810',
      is_default: false,
    },
  ];

  for (const a of addressesData) {
    await connection.execute(
      `INSERT INTO addresses (user_id, recipient_name, phone, address, is_default)
       VALUES (?, ?, ?, ?, ?)`,
      [a.user_id, a.recipient_name, a.phone, a.address, a.is_default ? 1 : 0]
    );
  }
  console.log(`✅ Inserted ${addressesData.length} addresses`);

  // 5. Orders (matching AppData.orders from dummy_data.dart)
  const ordersData = [
    {
      id: '#INV-2024001',
      user_id: 'user_001',
      date: '24 Okt 2024, 14:30',
      status: 'Menunggu Pengiriman',
      product_name: 'Ceri Organik',
      quantity: 1,
      price: 25000,
      buyer_name: 'Julian Harvest',
    },
    {
      id: '#INV-2024002',
      user_id: 'user_001',
      date: '16 Okt 2024',
      status: 'Menunggu Dikirim',
      product_name: 'Tomat Ceri',
      quantity: 2,
      price: 40000,
      buyer_name: 'Siti Agraria',
    },
    {
      id: '#INV-2024005',
      user_id: 'user_001',
      date: '12 Okt 2024',
      status: 'Selesai',
      product_name: 'Ceri Organik',
      quantity: 2,
      price: 75000,
      buyer_name: 'Elna Roots',
    },
  ];

  for (const o of ordersData) {
    await connection.execute(
      `INSERT INTO orders (id, user_id, date, status, total_price, buyer_name)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [o.id, o.user_id, o.date, o.status, o.price, o.buyer_name]
    );

    // Find the product ID by name to insert order item
    const [productRows] = await connection.execute(
      'SELECT id FROM products WHERE name = ? LIMIT 1',
      [o.product_name]
    );
    if (productRows.length > 0) {
      await connection.execute(
        `INSERT INTO order_items (order_id, product_id, quantity, price)
         VALUES (?, ?, ?, ?)`,
        [o.id, productRows[0].id, o.quantity, o.price]
      );
    }
  }
  console.log(`✅ Inserted ${ordersData.length} orders with items`);

  console.log('\n🎉 Database seeded successfully!');
  console.log(`   Database: ${dbName}`);
  console.log(`   Tables: categories, products, users, addresses, orders, order_items, favorites`);

  await connection.end();
  process.exit(0);
}

seed().catch((err) => {
  console.error('❌ Seed failed:', err.message);
  process.exit(1);
});
