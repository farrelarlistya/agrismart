import { Hono } from 'hono';
import { query } from '../db.js';

const stores = new Hono();

// POST /api/stores/register - Register a new store
stores.post('/register', async (c) => {
  try {
    const body = await c.req.json();
    const { 
      user_id, name, phone, warehouse_name, pic_name, pic_phone, 
      province, city, district, postal_code, address, nik, logo_url
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
        id, user_id, name, phone, warehouse_name, pic_name, pic_phone,
        province, city, district, postal_code, address, nik, logo_url
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        storeId, user_id, name, phone, warehouse_name || '', pic_name || '', pic_phone || '',
        province || '', city || '', district || '', postal_code || '', address || '',
        nik || '', logo_url || null
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
      return c.json({ success: false, data: null }); // Returns null if no store
    }

    return c.json({ success: true, data: rows[0] });
  } catch (error) {
    return c.json({ success: false, message: error.message }, 500);
  }
});

export default stores;
