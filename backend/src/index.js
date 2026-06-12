import { Hono } from 'hono';
import { serve } from '@hono/node-server';
import { cors } from 'hono/cors';
import dotenv from 'dotenv';

import products from './routes/products.js';
import categories from './routes/categories.js';
import users from './routes/users.js';
import orders from './routes/orders.js';
import addresses from './routes/addresses.js';
import stores from './routes/stores.js';
import favorites from './routes/favorites.js';
import cart from './routes/cart.js';
import chats from './routes/chats.js';
dotenv.config();

import { serveStatic } from '@hono/node-server/serve-static';

const app = new Hono();

// Serve static files from uploads directory
app.use('/uploads/*', serveStatic({ root: './' }));

// Enable CORS for Flutter app
app.use('/*', cors({
  origin: '*',
  allowMethods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowHeaders: ['Content-Type', 'Authorization'],
}));

// Health check
app.get('/', (c) => {
  return c.json({
    message: 'AgriSmart API is running 🌱',
    version: '1.0.0',
    endpoints: [
      'GET  /api/products',
      'GET  /api/products/:id',
      'POST /api/products',
      'GET  /api/categories',
      'GET  /api/users/:id',
      'PUT  /api/users/:id',
      'GET  /api/users/:userId/addresses',
      'POST /api/users/:userId/addresses',
      'GET  /api/orders',
      'POST /api/orders',
      'GET  /api/users/:userId/favorites',
      'POST /api/users/:userId/favorites',
    ],
  });
});

// Register routes
app.route('/api/products', products);
app.route('/api/categories', categories);
app.route('/api/users', users);
app.route('/api', addresses);
app.route('/api/orders', orders);
app.route('/api/stores', stores);
app.route('/api', favorites);
app.route('/api/cart', cart);
app.route('/api/chats', chats);
// 404 handler
app.notFound((c) => {
  return c.json({ success: false, message: 'Route not found' }, 404);
});

// Error handler
app.onError((err, c) => {
  console.error('Server error:', err);
  return c.json({ success: false, message: 'Internal server error' }, 500);
});

const port = parseInt(process.env.PORT || '3000');

console.log(`🌱 AgriSmart API server starting on port ${port}...`);

serve({
  fetch: app.fetch,
  port,
}, (info) => {
  console.log(`✅ Server is running on http://localhost:${info.port}`);
});
