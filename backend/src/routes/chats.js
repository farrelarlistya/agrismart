import { Hono } from 'hono';
import { query } from '../db.js';

const chats = new Hono();

// GET /api/chats/conversations?user_id=...
chats.get('/conversations', async (c) => {
  try {
    const userId = c.req.query('user_id');
    if (!userId) {
      return c.json({ success: false, message: 'user_id is required' }, 400);
    }

    // Check if user is a seller (has a store)
    const store = await query('SELECT id FROM stores WHERE user_id = ?', [userId]);
    const isSeller = store.length > 0;
    const storeId = isSeller ? store[0].id : null;

    let sql = '';
    let params = [];

    if (isSeller) {
      sql = `
        SELECT c.*, u.name as other_name, u.avatar_url as other_image,
               p.name as product_name, p.image_url as product_image,
               (SELECT text FROM messages m WHERE m.conversation_id = c.id ORDER BY m.created_at DESC LIMIT 1) as last_message,
               (SELECT created_at FROM messages m WHERE m.conversation_id = c.id ORDER BY m.created_at DESC LIMIT 1) as last_message_time
        FROM conversations c
        JOIN users u ON c.buyer_id = u.id
        LEFT JOIN products p ON c.product_id = p.id
        WHERE c.seller_id = ?
        ORDER BY last_message_time DESC
      `;
      params = [storeId];
    } else {
      sql = `
        SELECT c.*, s.name as other_name, s.logo_url as other_image,
               p.name as product_name, p.image_url as product_image,
               (SELECT text FROM messages m WHERE m.conversation_id = c.id ORDER BY m.created_at DESC LIMIT 1) as last_message,
               (SELECT created_at FROM messages m WHERE m.conversation_id = c.id ORDER BY m.created_at DESC LIMIT 1) as last_message_time
        FROM conversations c
        JOIN stores s ON c.seller_id = s.id
        LEFT JOIN products p ON c.product_id = p.id
        WHERE c.buyer_id = ?
        ORDER BY last_message_time DESC
      `;
      params = [userId];
    }

    const rows = await query(sql, params);
    return c.json({ success: true, data: rows });
  } catch (error) {
    return c.json({ success: false, message: error.message }, 500);
  }
});

// POST /api/chats/conversations
// Body: { buyer_id, seller_id, product_id }
chats.post('/conversations', async (c) => {
  try {
    const body = await c.req.json();
    const { buyer_id, seller_id, product_id } = body;

    if (!buyer_id || !seller_id) {
      return c.json({ success: false, message: 'buyer_id and seller_id required' }, 400);
    }

    // Check existing
    let querySql = 'SELECT * FROM conversations WHERE buyer_id = ? AND seller_id = ?';
    let queryParams = [buyer_id, seller_id];

    if (product_id) {
      querySql += ' AND product_id = ?';
      queryParams.push(product_id);
    } else {
      querySql += ' AND product_id IS NULL';
    }

    const existing = await query(querySql, queryParams);
    
    if (existing.length > 0) {
      return c.json({ success: true, data: existing[0] });
    }

    // Create new
    const conversationId = `conv_${Date.now()}`;
    await query(
      'INSERT INTO conversations (id, buyer_id, seller_id, product_id) VALUES (?, ?, ?, ?)',
      [conversationId, buyer_id, seller_id, product_id || null]
    );

    return c.json({ success: true, data: { id: conversationId, buyer_id, seller_id, product_id } }, 201);
  } catch (error) {
    return c.json({ success: false, message: error.message }, 500);
  }
});

// GET /api/chats/conversations/:id/messages
chats.get('/conversations/:id/messages', async (c) => {
  try {
    const id = c.req.param('id');
    const rows = await query(
      'SELECT * FROM messages WHERE conversation_id = ? ORDER BY created_at ASC',
      [id]
    );
    return c.json({ success: true, data: rows });
  } catch (error) {
    return c.json({ success: false, message: error.message }, 500);
  }
});

// POST /api/chats/messages
// Body: { conversation_id, sender_id, text }
chats.post('/messages', async (c) => {
  try {
    const body = await c.req.json();
    const { conversation_id, sender_id, text } = body;

    if (!conversation_id || !sender_id || !text) {
      return c.json({ success: false, message: 'Missing fields' }, 400);
    }

    const messageId = `msg_${Date.now()}`;
    await query(
      'INSERT INTO messages (id, conversation_id, sender_id, text) VALUES (?, ?, ?, ?)',
      [messageId, conversation_id, sender_id, text]
    );

    return c.json({ success: true, data: { id: messageId, conversation_id, sender_id, text, status: 'sent' } }, 201);
  } catch (error) {
    return c.json({ success: false, message: error.message }, 500);
  }
});

export default chats;
