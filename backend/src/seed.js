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
    'withdrawals', 'messages', 'conversations', 'cart_items', 'favorites', 'order_items', 'orders', 'products', 'stores', 'addresses', 'users', 'categories'
  ];
  for (const table of dropTables) {
    await connection.query(`DROP TABLE IF EXISTS \`${table}\``);
  }
  console.log('✅ Old tables dropped');

  // Create users table
  await connection.query(`
    CREATE TABLE users (
      id VARCHAR(50) PRIMARY KEY,
      name VARCHAR(255) NOT NULL,
      email VARCHAR(255) NOT NULL UNIQUE,
      password VARCHAR(255) NOT NULL,
      phone VARCHAR(50) DEFAULT NULL,
      avatar_url VARCHAR(500) DEFAULT NULL,
      role ENUM('buyer', 'seller', 'admin') DEFAULT 'buyer',
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
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
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    )
  `);

  // Create categories table
  await connection.query(`
    CREATE TABLE categories (
      id INT AUTO_INCREMENT PRIMARY KEY,
      name VARCHAR(100) NOT NULL UNIQUE
    )
  `);

  // Create stores table
  await connection.query(`
    CREATE TABLE stores (
      id VARCHAR(50) PRIMARY KEY,
      user_id VARCHAR(50) NOT NULL UNIQUE,
      name VARCHAR(255) NOT NULL,
      phone VARCHAR(50) NOT NULL,
      pic_name VARCHAR(255) DEFAULT NULL,
      province VARCHAR(100) DEFAULT NULL,
      city VARCHAR(100) DEFAULT NULL,
      postal_code VARCHAR(20) DEFAULT NULL,
      address TEXT,
      nik VARCHAR(50) DEFAULT NULL,
      logo_url VARCHAR(500) DEFAULT NULL,
      email VARCHAR(255) DEFAULT NULL,
      dob VARCHAR(50) DEFAULT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      is_active TINYINT(1) DEFAULT 1,
      balance DECIMAL(12,2) DEFAULT 0.00,
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    )
  `);

  // Create withdrawals table
  await connection.query(`
    CREATE TABLE withdrawals (
      id INT AUTO_INCREMENT PRIMARY KEY,
      store_id VARCHAR(50) NOT NULL,
      amount DECIMAL(12,2) NOT NULL,
      bank_name VARCHAR(100) NOT NULL,
      status ENUM('pending', 'success', 'failed') DEFAULT 'pending',
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (store_id) REFERENCES stores(id) ON DELETE CASCADE
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
      category_id INT DEFAULT NULL,
      unit VARCHAR(50) DEFAULT 'kg',
      description TEXT,
      stock INT DEFAULT 100,
      location VARCHAR(255) DEFAULT '',
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      is_active TINYINT(1) DEFAULT 1,
      FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
      FOREIGN KEY (seller_id) REFERENCES stores(id) ON DELETE CASCADE
    )
  `);

  // Create favorites table
  await connection.query(`
    CREATE TABLE favorites (
      id INT AUTO_INCREMENT PRIMARY KEY,
      user_id VARCHAR(50) NOT NULL,
      product_id INT NOT NULL,
      UNIQUE KEY unique_fav (user_id, product_id),
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
      FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
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
      resi VARCHAR(100) DEFAULT NULL,
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
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
      FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
      FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
    )
  `);

  // Create cart_items table
  await connection.query(`
    CREATE TABLE cart_items (
      id INT AUTO_INCREMENT PRIMARY KEY,
      user_id VARCHAR(50) NOT NULL,
      product_id INT NOT NULL,
      quantity INT NOT NULL DEFAULT 1,
      selected TINYINT(1) DEFAULT 1,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      UNIQUE KEY unique_user_product_cart (user_id, product_id),
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
      FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
    )
  `);

  // Create conversations table
  await connection.query(`
    CREATE TABLE conversations (
      id VARCHAR(50) PRIMARY KEY,
      buyer_id VARCHAR(50) NOT NULL,
      seller_id VARCHAR(50) NOT NULL,
      product_id INT DEFAULT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (buyer_id) REFERENCES users(id) ON DELETE CASCADE,
      FOREIGN KEY (seller_id) REFERENCES stores(id) ON DELETE CASCADE,
      FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL
    )
  `);

  // Create messages table
  await connection.query(`
    CREATE TABLE messages (
      id VARCHAR(50) PRIMARY KEY,
      conversation_id VARCHAR(50) NOT NULL,
      sender_id VARCHAR(50) NOT NULL,
      text TEXT NOT NULL,
      status ENUM('sending', 'sent', 'delivered', 'read') DEFAULT 'sent',
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
      FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE
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

  console.log(`✅ Skipped products insertion (database is empty except categories)`);

  // 3. Users (Empty)
  console.log('✅ Skipped users insertion');

  // 4. Addresses (Empty)
  console.log(`✅ Skipped addresses insertion`);

  // 5. Orders (Empty)
  console.log(`✅ Skipped orders insertion`);

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
