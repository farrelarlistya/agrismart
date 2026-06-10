import { Hono } from 'hono';
import { query } from '../db.js';

const addresses = new Hono();

// GET /api/users/:userId/addresses — List addresses for user
addresses.get('/users/:userId/addresses', async (c) => {
  try {
    const userId = c.req.param('userId');
    const rows = await query(
      'SELECT * FROM addresses WHERE user_id = ? ORDER BY is_default DESC, id ASC',
      [userId]
    );
    return c.json({ success: true, data: rows });
  } catch (error) {
    return c.json({ success: false, message: error.message }, 500);
  }
});

// POST /api/users/:userId/addresses — Add address
addresses.post('/users/:userId/addresses', async (c) => {
  try {
    const userId = c.req.param('userId');
    const body = await c.req.json();
    const { recipient_name, phone, address, is_default } = body;

    // If setting as default, clear other defaults
    if (is_default) {
      await query('UPDATE addresses SET is_default = FALSE WHERE user_id = ?', [userId]);
    }

    const result = await query(
      `INSERT INTO addresses (user_id, recipient_name, phone, address, is_default)
       VALUES (?, ?, ?, ?, ?)`,
      [userId, recipient_name, phone, address, is_default || false]
    );

    return c.json({ success: true, data: { id: result.insertId } }, 201);
  } catch (error) {
    return c.json({ success: false, message: error.message }, 500);
  }
});

// PUT /api/addresses/:id — Update address
addresses.put('/addresses/:id', async (c) => {
  try {
    const id = c.req.param('id');
    const body = await c.req.json();
    const fields = [];
    const params = [];

    const allowedFields = ['recipient_name', 'phone', 'address'];
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
    await query(`UPDATE addresses SET ${fields.join(', ')} WHERE id = ?`, params);

    return c.json({ success: true, message: 'Address updated' });
  } catch (error) {
    return c.json({ success: false, message: error.message }, 500);
  }
});

// DELETE /api/addresses/:id — Delete address
addresses.delete('/addresses/:id', async (c) => {
  try {
    const id = c.req.param('id');

    // Check if it was default
    const rows = await query('SELECT * FROM addresses WHERE id = ?', [id]);
    const wasDefault = rows.length > 0 && rows[0].is_default;
    const userId = rows.length > 0 ? rows[0].user_id : null;

    await query('DELETE FROM addresses WHERE id = ?', [id]);

    // If deleted was default, set first remaining as default
    if (wasDefault && userId) {
      const remaining = await query(
        'SELECT id FROM addresses WHERE user_id = ? ORDER BY id LIMIT 1',
        [userId]
      );
      if (remaining.length > 0) {
        await query('UPDATE addresses SET is_default = TRUE WHERE id = ?', [remaining[0].id]);
      }
    }

    return c.json({ success: true, message: 'Address deleted' });
  } catch (error) {
    return c.json({ success: false, message: error.message }, 500);
  }
});

// PATCH /api/addresses/:id/default — Set as default
addresses.patch('/addresses/:id/default', async (c) => {
  try {
    const id = c.req.param('id');

    // Get user_id from this address
    const rows = await query('SELECT user_id FROM addresses WHERE id = ?', [id]);
    if (rows.length === 0) {
      return c.json({ success: false, message: 'Address not found' }, 404);
    }

    const userId = rows[0].user_id;

    // Clear all defaults for this user
    await query('UPDATE addresses SET is_default = FALSE WHERE user_id = ?', [userId]);
    // Set this one as default
    await query('UPDATE addresses SET is_default = TRUE WHERE id = ?', [id]);

    return c.json({ success: true, message: 'Default address updated' });
  } catch (error) {
    return c.json({ success: false, message: error.message }, 500);
  }
});

export default addresses;
