import { Hono } from 'hono';
import { query } from '../db.js';

const favorites = new Hono();

// GET /api/users/:userId/favorites — List favorite product IDs
favorites.get('/users/:userId/favorites', async (c) => {
  try {
    const userId = c.req.param('userId');
    const rows = await query(
      `SELECT f.product_id, p.name, p.seller, p.price, p.original_price,
              p.image_url, c.name AS category, p.unit,
              p.description, p.stock, p.location
       FROM favorites f
       LEFT JOIN products p ON f.product_id = p.id
       LEFT JOIN categories c ON p.category_id = c.id
       WHERE f.user_id = ?`,
      [userId]
    );
    return c.json({ success: true, data: rows });
  } catch (error) {
    return c.json({ success: false, message: error.message }, 500);
  }
});

// POST /api/users/:userId/favorites — Toggle favorite
favorites.post('/users/:userId/favorites', async (c) => {
  try {
    const userId = c.req.param('userId');
    const body = await c.req.json();
    const { product_id } = body;

    // Check if already favorited
    const existing = await query(
      'SELECT id FROM favorites WHERE user_id = ? AND product_id = ?',
      [userId, product_id]
    );

    if (existing.length > 0) {
      // Remove favorite
      await query('DELETE FROM favorites WHERE user_id = ? AND product_id = ?', [userId, product_id]);
      return c.json({ success: true, action: 'removed', message: 'Removed from favorites' });
    } else {
      // Add favorite
      await query(
        'INSERT INTO favorites (user_id, product_id) VALUES (?, ?)',
        [userId, product_id]
      );
      return c.json({ success: true, action: 'added', message: 'Added to favorites' }, 201);
    }
  } catch (error) {
    return c.json({ success: false, message: error.message }, 500);
  }
});

// DELETE /api/users/:userId/favorites/:productId — Remove favorite
favorites.delete('/users/:userId/favorites/:productId', async (c) => {
  try {
    const userId = c.req.param('userId');
    const productId = c.req.param('productId');
    await query('DELETE FROM favorites WHERE user_id = ? AND product_id = ?', [userId, productId]);
    return c.json({ success: true, message: 'Removed from favorites' });
  } catch (error) {
    return c.json({ success: false, message: error.message }, 500);
  }
});

export default favorites;
