import { Hono } from 'hono';
import { query } from '../db.js';
import fs from 'fs/promises';
import path from 'path';

const stores = new Hono();

// POST /api/stores/:id/logo — Upload store logo (multipart/form-data)
stores.post('/:id/logo', async (c) => {
  try {
    const id = c.req.param('id');
    const body = await c.req.parseBody();
    const image = body['image'];

    if (!image) {
      return c.json({ success: false, message: 'Data gambar tidak ditemukan' }, 400);
    }

    const buffer = await image.arrayBuffer();
    const extension = image.name.split('.').pop() || 'jpg';
    const fileName = `${id}-${Date.now()}.${extension}`;
    const uploadDir = path.join(process.cwd(), 'uploads', 'stores');

    // Ensure directory exists
    await fs.mkdir(uploadDir, { recursive: true });

    const filePath = path.join(uploadDir, fileName);
    await fs.writeFile(filePath, Buffer.from(buffer));

    // Store only the relative path
    const logoUrl = `/uploads/stores/${fileName}`;

    // Update database
    await query('UPDATE stores SET logo_url = ? WHERE id = ?', [logoUrl, id]);

    // Return updated store
    const rows = await query('SELECT * FROM stores WHERE id = ?', [id]);
    return c.json({ success: true, message: 'Logo toko berhasil diunggah', data: rows[0] });

  } catch (error) {
    console.error('Store logo upload error:', error);
    return c.json({ success: false, message: error.message }, 500);
  }
});

// POST /api/stores/register - Register a new store
stores.post('/register', async (c) => {
  try {
    const body = await c.req.json();
    const { 
      user_id, name, phone, pic_name, 
      province, city, postal_code, address, nik, logo_url, email, dob
    } = body;

    if (!user_id || !name || !phone) {
      return c.json({ success: false, message: 'User ID, Nama Toko, dan No HP wajib diisi' }, 400);
    }

    // Check if user already has a store
    const existing = await query('SELECT id FROM stores WHERE user_id = ?', [user_id]);
    if (existing.length > 0) {
      return c.json({ success: false, message: 'Pengguna sudah memiliki toko' }, 400);
    }

    const storeId = `store_${Date.now()}`;

    await query(
      `INSERT INTO stores (
        id, user_id, name, phone, pic_name,
        province, city, postal_code, address, nik, logo_url, email, dob
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        storeId, user_id, name, phone, pic_name || '',
        province || '', city || '', postal_code || '', address || '',
        nik || '', logo_url || null, email || null, dob || null
      ]
    );

    return c.json({
      success: true,
      message: 'Toko berhasil didaftarkan',
      data: { id: storeId, name, user_id }
    }, 201);

  } catch (error) {
    return c.json({ success: false, message: error.message }, 500);
  }
});

// GET /api/stores/me/:userId - Get store for a user
stores.get('/me/:userId', async (c) => {
  try {
    const userId = c.req.param('userId');
    const rows = await query('SELECT * FROM stores WHERE user_id = ?', [userId]);
    
    if (rows.length === 0) {
      return c.json({ success: false, data: null });
    }

    return c.json({ success: true, data: rows[0] });
  } catch (error) {
    return c.json({ success: false, message: error.message }, 500);
  }
});

// PUT /api/stores/:id - Update store details
stores.put('/:id', async (c) => {
  try {
    const id = c.req.param('id');
    const body = await c.req.json();
    const allowedFields = ['name', 'phone', 'pic_name', 'province', 'city', 'postal_code', 'address', 'logo_url', 'email', 'is_active'];
    const fields = [];
    const params = [];

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
    await query(`UPDATE stores SET ${fields.join(', ')} WHERE id = ?`, params);
    const rows = await query('SELECT * FROM stores WHERE id = ?', [id]);
    return c.json({ success: true, data: rows[0] });
  } catch (error) {
    return c.json({ success: false, message: error.message }, 500);
  }
});

// GET /api/stores/:id/finance - Get finance history (sales + withdrawals)
stores.get('/:id/finance', async (c) => {
  try {
    const storeId = c.req.param('id');

    // Get store balance
    const storeRows = await query('SELECT balance FROM stores WHERE id = ?', [storeId]);
    if (storeRows.length === 0) return c.json({ success: false, message: 'Store not found' }, 404);

    // Get order-based income (completed orders containing this store's products)
    const incomeRows = await query(`
      SELECT o.id, o.created_at, o.total_price,
             (SELECT p.name FROM order_items oi2 JOIN products p ON oi2.product_id = p.id WHERE oi2.order_id = o.id AND p.seller_id = ? LIMIT 1) AS product_name
      FROM orders o
      WHERE o.status = 'Selesai'
        AND o.id IN (SELECT oi.order_id FROM order_items oi JOIN products p ON oi.product_id = p.id WHERE p.seller_id = ?)
      ORDER BY o.created_at DESC LIMIT 20
    `, [storeId, storeId]);

    // Get withdrawal history
    const withdrawRows = await query(
      'SELECT * FROM withdrawals WHERE store_id = ? ORDER BY created_at DESC LIMIT 20',
      [storeId]
    );

    // Merge and sort
    const transactions = [
      ...incomeRows.map(r => ({
        type: 'income',
        title: `Penjualan ${r.product_name || 'Produk'}`,
        date: r.created_at,
        amount: parseFloat(r.total_price),
      })),
      ...withdrawRows.map(r => ({
        type: 'withdrawal',
        title: `Penarikan ke Bank ${r.bank_name}`,
        date: r.created_at,
        amount: parseFloat(r.amount),
      })),
    ].sort((a, b) => new Date(b.date) - new Date(a.date));

    return c.json({
      success: true,
      data: {
        balance: parseFloat(storeRows[0].balance),
        transactions,
      }
    });
  } catch (error) {
    return c.json({ success: false, message: error.message }, 500);
  }
});

// POST /api/stores/:id/withdraw - Request a withdrawal
stores.post('/:id/withdraw', async (c) => {
  try {
    const storeId = c.req.param('id');
    const { amount, bank_name } = await c.req.json();

    if (!amount || !bank_name) {
      return c.json({ success: false, message: 'Jumlah dan nama bank wajib diisi' }, 400);
    }

    const storeRows = await query('SELECT balance FROM stores WHERE id = ?', [storeId]);
    if (storeRows.length === 0) return c.json({ success: false, message: 'Store not found' }, 404);

    const balance = parseFloat(storeRows[0].balance);
    if (amount > balance) {
      return c.json({ success: false, message: 'Saldo tidak mencukupi' }, 400);
    }

    await query('UPDATE stores SET balance = balance - ? WHERE id = ?', [amount, storeId]);
    await query('INSERT INTO withdrawals (store_id, amount, bank_name, status) VALUES (?, ?, ?, ?)', [storeId, amount, bank_name, 'success']);

    return c.json({ success: true, message: 'Penarikan dana berhasil' });
  } catch (error) {
    return c.json({ success: false, message: error.message }, 500);
  }
});

export default stores;
