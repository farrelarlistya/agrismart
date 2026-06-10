import { Hono } from 'hono';
import { query } from '../db.js';

const orders = new Hono();

// GET /api/orders — List all orders (optionally filter by user_id)
orders.get('/', async (c) => {
  try {
    let sql = 'SELECT * FROM orders';
    const params = [];

    const userId = c.req.query('user_id');
    if (userId) {
      sql += ' WHERE user_id = ?';
      params.push(userId);
    }

    sql += ' ORDER BY created_at DESC';
    const rows = await query(sql, params);
    return c.json({ success: true, data: rows });
  } catch (error) {
    return c.json({ success: false, message: error.message }, 500);
  }
});

// GET /api/orders/:id — Get order detail with items
orders.get('/:id', async (c) => {
  try {
    const id = c.req.param('id');
    const orderRows = await query('SELECT * FROM orders WHERE id = ?', [id]);
    if (orderRows.length === 0) {
      return c.json({ success: false, message: 'Order not found' }, 404);
    }

    const items = await query(
      `SELECT oi.*, p.name AS product_name, p.image_url, p.seller
       FROM order_items oi
       LEFT JOIN products p ON oi.product_id = p.id
       WHERE oi.order_id = ?`,
      [id]
    );

    return c.json({
      success: true,
      data: { ...orderRows[0], items },
    });
  } catch (error) {
    return c.json({ success: false, message: error.message }, 500);
  }
});

// POST /api/orders — Create a new order
orders.post('/', async (c) => {
  try {
    const body = await c.req.json();
    const { id, user_id, date, status, total_price, buyer_name, address, items } = body;

    // Generate order ID if not provided
    const orderId = id || `#INV-${Date.now()}`;

    await query(
      `INSERT INTO orders (id, user_id, date, status, total_price, buyer_name, address)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [orderId, user_id, date, status || 'Menunggu Pengiriman', total_price, buyer_name, address || '']
    );

    // Insert order items
    if (items && items.length > 0) {
      for (const item of items) {
        await query(
          `INSERT INTO order_items (order_id, product_id, quantity, price)
           VALUES (?, ?, ?, ?)`,
          [orderId, item.product_id, item.quantity, item.price]
        );
      }
    }

    return c.json({ success: true, data: { id: orderId } }, 201);
  } catch (error) {
    return c.json({ success: false, message: error.message }, 500);
  }
});

export default orders;
