import { Hono } from 'hono';
import { query } from '../db.js';

const categories = new Hono();

// GET /api/categories — List all categories
categories.get('/', async (c) => {
  try {
    const rows = await query('SELECT * FROM categories ORDER BY id');
    return c.json({ success: true, data: rows });
  } catch (error) {
    return c.json({ success: false, message: error.message }, 500);
  }
});

export default categories;
