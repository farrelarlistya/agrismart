import { Hono } from 'hono';
import { query } from '../db.js';
import fs from 'fs/promises';
import path from 'path';

const products = new Hono();

// GET /api/products — List all products with optional filters
products.get('/', async (c) => {
  try {
    let sql = `
      SELECT p.*, c.name AS category, CONCAT_WS(', ', s.city, s.province) AS location
      FROM products p
      LEFT JOIN categories c ON p.category_id = c.id
      LEFT JOIN stores s ON p.seller_id = s.id
      WHERE 1=1
    `;
    const params = [];

    // Filter by category
    const category = c.req.query('category');
    if (category && category !== 'Semua') {
      sql += ' AND c.name = ?';
      params.push(category);
    }

    // Filter by seller_id
    const sellerId = c.req.query('seller_id');
    if (sellerId) {
      sql += ' AND p.seller_id = ?';
      params.push(sellerId);
    }

    // Search by name, seller, location
    const search = c.req.query('search');
    if (search) {
      sql += ' AND (p.name LIKE ? OR p.seller LIKE ? OR CONCAT_WS(\', \', s.city, s.province) LIKE ?)';
      const like = `%${search}%`;
      params.push(like, like, like);
    }

    // Limit
    const limit = c.req.query('limit');
    if (limit) {
      sql += ' LIMIT ?';
      params.push(parseInt(limit));
    }

    sql += ' ORDER BY p.created_at DESC';

    const rows = await query(sql, params);
    return c.json({ success: true, data: rows });
  } catch (error) {
    return c.json({ success: false, message: error.message }, 500);
  }
});

// GET /api/products/:id — Get product detail
products.get('/:id', async (c) => {
  try {
    const id = c.req.param('id');
    const rows = await query(
      `SELECT p.*, c.name AS category, CONCAT_WS(', ', s.city, s.province) AS location
       FROM products p
       LEFT JOIN categories c ON p.category_id = c.id
       LEFT JOIN stores s ON p.seller_id = s.id
       WHERE p.id = ?`,
      [id]
    );
    if (rows.length === 0) {
      return c.json({ success: false, message: 'Product not found' }, 404);
    }
    return c.json({ success: true, data: rows[0] });
  } catch (error) {
    return c.json({ success: false, message: error.message }, 500);
  }
});

// POST /api/products/upload — Upload product image
products.post('/upload', async (c) => {
  try {
    const body = await c.req.parseBody();
    const image = body['image'];

    if (!image) {
      return c.json({ success: false, message: 'No image uploaded' }, 400);
    }

    const buffer = await image.arrayBuffer();
    const extension = image.name.split('.').pop() || 'jpg';
    const fileName = `product-${Date.now()}.${extension}`;
    const uploadDir = path.join(process.cwd(), 'uploads', 'products');

    await fs.mkdir(uploadDir, { recursive: true });
    const filePath = path.join(uploadDir, fileName);
    await fs.writeFile(filePath, Buffer.from(buffer));

    const host = c.req.header('host') || 'localhost:3000';
    const imageUrl = `http://${host}/uploads/products/${fileName}`;

    return c.json({ success: true, url: imageUrl });
  } catch (error) {
    console.error('Product upload error:', error);
    return c.json({ success: false, message: error.message }, 500);
  }
});

// POST /api/products — Create product
products.post('/', async (c) => {
  try {
    const body = await c.req.json();
    const {
      name, seller, seller_id, price, original_price, image_url, image_urls, video_url, category_id,
      unit, description, stock
    } = body;

    let imageUrlsStr = null;
    if (Array.isArray(image_urls)) {
      imageUrlsStr = JSON.stringify(image_urls);
    } else if (typeof image_urls === 'string') {
      imageUrlsStr = image_urls;
    }

    const result = await query(
      `INSERT INTO products (name, seller, seller_id, price, original_price, image_url, image_urls, video_url, category_id,
        unit, description, stock)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [name, seller, seller_id || null, price, original_price || null, image_url, imageUrlsStr, video_url || null, category_id || null,
       unit || 'kg', description || '', stock || 100]
    );

    return c.json({ success: true, data: { id: result.insertId } }, 201);
  } catch (error) {
    return c.json({ success: false, message: error.message }, 500);
  }
});

// PUT /api/products/:id — Update product
products.put('/:id', async (c) => {
  try {
    const id = c.req.param('id');
    const body = await c.req.json();
    const fields = [];
    const params = [];

    const allowedFields = [
      'name', 'seller', 'price', 'original_price', 'image_url', 'image_urls', 'video_url', 'category_id',
      'unit', 'description', 'stock'
    ];

    for (const field of allowedFields) {
      if (body[field] !== undefined) {
        fields.push(`${field} = ?`);
        let val = body[field];
        if (field === 'image_urls' && Array.isArray(val)) {
          val = JSON.stringify(val);
        }
        params.push(val);
      }
    }

    if (fields.length === 0) {
      return c.json({ success: false, message: 'No fields to update' }, 400);
    }

    params.push(id);
    await query(`UPDATE products SET ${fields.join(', ')} WHERE id = ?`, params);

    return c.json({ success: true, message: 'Product updated' });
  } catch (error) {
    return c.json({ success: false, message: error.message }, 500);
  }
});

// DELETE /api/products/:id — Delete product
products.delete('/:id', async (c) => {
  try {
    const id = c.req.param('id');
    await query('DELETE FROM products WHERE id = ?', [id]);
    return c.json({ success: true, message: 'Product deleted' });
  } catch (error) {
    return c.json({ success: false, message: error.message }, 500);
  }
});

export default products;
