import { Hono } from 'hono';
import { query } from '../db.js';

const cart = new Hono();

// GET /api/cart?user_id=...
cart.get('/', async (c) => {
  try {
    const userId = c.req.query('user_id');
    if (!userId) {
      return c.json({ success: false, message: 'user_id is required' }, 400);
    }

    const sql = `
      SELECT c.*, p.name as product_name, p.price, p.image_url, p.unit, p.stock,
             s.name as store_name
      FROM cart_items c
      JOIN products p ON c.product_id = p.id
      LEFT JOIN stores s ON p.seller_id = s.id
      WHERE c.user_id = ?
      ORDER BY c.created_at DESC
    `;
    const rows = await query(sql, [userId]);
    return c.json({ success: true, data: rows });
  } catch (error) {
    return c.json({ success: false, message: error.message }, 500);
  }
});

// POST /api/cart
// Body: { user_id, product_id, quantity }
cart.post('/', async (c) => {
  try {
    const body = await c.req.json();
    const { user_id, product_id, quantity } = body;

    if (!user_id || !product_id) {
      return c.json({ success: false, message: 'user_id and product_id required' }, 400);
    }

    // Check if item already exists
    const existing = await query(
      'SELECT * FROM cart_items WHERE user_id = ? AND product_id = ?',
      [user_id, product_id]
    );

    if (existing.length > 0) {
      // Update quantity
      const newQty = existing[0].quantity + (quantity || 1);
      await query(
        'UPDATE cart_items SET quantity = ? WHERE id = ?',
        [newQty, existing[0].id]
      );
      return c.json({ success: true, data: { id: existing[0].id, quantity: newQty } }, 200);
    } else {
      // Insert new
      const result = await query(
        'INSERT INTO cart_items (user_id, product_id, quantity) VALUES (?, ?, ?)',
        [user_id, product_id, quantity || 1]
      );
      return c.json({ success: true, data: { id: result.insertId, quantity: quantity || 1 } }, 201);
    }
  } catch (error) {
    return c.json({ success: false, message: error.message }, 500);
  }
});

// PUT /api/cart/:id
// Body: { quantity, selected }
cart.put('/:id', async (c) => {
  try {
    const id = c.req.param('id');
    const body = await c.req.json();
    const { quantity, selected } = body;

    let updates = [];
    let params = [];

    if (quantity !== undefined) {
      updates.push('quantity = ?');
      params.push(quantity);
    }
    if (selected !== undefined) {
      updates.push('selected = ?');
      params.push(selected ? 1 : 0);
    }

    if (updates.length > 0) {
      params.push(id);
      await query(`UPDATE cart_items SET ${updates.join(', ')} WHERE id = ?`, params);
    }

    return c.json({ success: true, message: 'Cart updated' });
  } catch (error) {
    return c.json({ success: false, message: error.message }, 500);
  }
});

// DELETE /api/cart/:id
cart.delete('/:id', async (c) => {
  try {
    const id = c.req.param('id');
    await query('DELETE FROM cart_items WHERE id = ?', [id]);
    return c.json({ success: true, message: 'Item removed from cart' });
  } catch (error) {
    return c.json({ success: false, message: error.message }, 500);
  }
});

// DELETE /api/cart/user/:userId
cart.delete('/user/:userId', async (c) => {
  try {
    const userId = c.req.param('userId');
    // Only delete selected items
    await query('DELETE FROM cart_items WHERE user_id = ? AND selected = 1', [userId]);
    return c.json({ success: true, message: 'Checkout successful, selected items removed' });
  } catch (error) {
    return c.json({ success: false, message: error.message }, 500);
  }
});

export default cart;
