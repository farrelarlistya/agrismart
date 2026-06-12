import { Hono } from 'hono';
import { query } from '../db.js';

const products = new Hono();

// GET /api/products — List all products with optional filters
products.get('/', async (c) => {
  try {
    let sql = `
      SELECT p.*, c.name AS category
      FROM products p
      LEFT JOIN categories c ON p.category_id = c.id
      WHERE 1=1
    `;
    const params = [];

    // Filter by category
    const category = c.req.query('category');
    if (category && category !== 'Semua') {
      sql += ' AND c.name = ?';
      params.push(category);
    }

    // Search by name, seller, location
    const search = c.req.query('search');
    if (search) {
      sql += ' AND (p.name LIKE ? OR p.seller LIKE ? OR p.location LIKE ?)';
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
      `SELECT p.*, c.name AS category
       FROM products p
       LEFT JOIN categories c ON p.category_id = c.id
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

// POST /api/products — Create product
products.post('/', async (c) => {
  try {
    const body = await c.req.json();
    const {
      name, seller, price, original_price, image_url, category_id,
      unit, rating, review_count, description, is_organic, is_premium,
      stock, location
    } = body;

    const result = await query(
      `INSERT INTO products (name, seller, price, original_price, image_url, category_id,
        unit, rating, review_count, description, is_organic, is_premium, stock, location)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [name, seller, price, original_price || null, image_url, category_id || null,
       unit || 'kg', rating || 4.5, review_count || 0, description || '',
       is_organic || false, is_premium || false, stock || 100, location || '']
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
      'name', 'seller', 'price', 'original_price', 'image_url', 'category_id',
      'unit', 'rating', 'review_count', 'description', 'is_organic', 'is_premium',
      'stock', 'location'
    ];

    for (const field of allowedFields) {
      if (body[field] !== undefined) {
        fields.push(`${field} = ?`);
        params.push(body[field]);
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
