import { Hono } from 'hono';
import bcrypt from 'bcryptjs';
import { query } from '../db.js';

import fs from 'fs/promises';
import path from 'path';

const users = new Hono();

// POST /api/users/:id/avatar — Upload avatar
users.post('/:id/avatar', async (c) => {
  try {
    const id = c.req.param('id');
    const body = await c.req.parseBody();
    const avatar = body['avatar'];

    if (!avatar || typeof avatar === 'string') {
      return c.json({ success: false, message: 'File avatar tidak ditemukan' }, 400);
    }

    // Ensure the file is an image
    if (!avatar.type.startsWith('image/')) {
      return c.json({ success: false, message: 'File harus berupa gambar' }, 400);
    }

    // Read the file as an array buffer and convert to a Node Buffer
    const buffer = Buffer.from(await avatar.arrayBuffer());

    // Construct file name and save path
    const extension = avatar.name.split('.').pop() || 'png';
    const fileName = `${id}-${Date.now()}.${extension}`;
    const uploadDir = path.join(process.cwd(), 'uploads', 'avatars');
    
    // Ensure directory exists
    await fs.mkdir(uploadDir, { recursive: true });

    const filePath = path.join(uploadDir, fileName);
    await fs.writeFile(filePath, buffer);

    // Generate public URL (assuming server runs on http://localhost:3000)
    const avatarUrl = `http://10.0.2.2:3000/uploads/avatars/${fileName}`;

    // Update database
    await query('UPDATE users SET avatar_url = ? WHERE id = ?', [avatarUrl, id]);

    // Return updated user
    const rows = await query('SELECT id, name, email, phone, avatar_url FROM users WHERE id = ?', [id]);
    return c.json({ success: true, message: 'Avatar berhasil diunggah', data: rows[0] });

  } catch (error) {
    return c.json({ success: false, message: error.message }, 500);
  }
});

// POST /api/users/register — Register new user
users.post('/register', async (c) => {
  try {
    const { name, email, password, phone } = await c.req.json();

    if (!name || !email || !password) {
      return c.json({ success: false, message: 'Nama, email, dan kata sandi wajib diisi' }, 400);
    }

    // Check if email already exists
    const existingUsers = await query('SELECT * FROM users WHERE email = ?', [email]);
    if (existingUsers.length > 0) {
      return c.json({ success: false, message: 'Email sudah terdaftar' }, 400);
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Generate user ID
    const id = `user_${Date.now()}`;

    // Save to database
    await query(
      'INSERT INTO users (id, name, email, password, phone) VALUES (?, ?, ?, ?, ?)',
      [id, name, email, hashedPassword, phone || '']
    );

    // Return created user (excluding password)
    return c.json({
      success: true,
      message: 'Registrasi berhasil',
      data: { id, name, email, phone: phone || '', avatar_url: null }
    }, 201);
  } catch (error) {
    return c.json({ success: false, message: error.message }, 500);
  }
});

// POST /api/users/login — Login user
users.post('/login', async (c) => {
  try {
    const { email, password } = await c.req.json();

    if (!email || !password) {
      return c.json({ success: false, message: 'Email dan kata sandi wajib diisi' }, 400);
    }

    // Find user by email
    const rows = await query('SELECT * FROM users WHERE email = ?', [email]);
    if (rows.length === 0) {
      return c.json({ success: false, message: 'Email atau kata sandi salah' }, 401);
    }

    const user = rows[0];

    // Verify password
    const passwordMatch = await bcrypt.compare(password, user.password);
    if (!passwordMatch) {
      return c.json({ success: false, message: 'Email atau kata sandi salah' }, 401);
    }

    // Return user profile
    return c.json({
      success: true,
      message: 'Login berhasil',
      data: {
        id: user.id,
        name: user.name,
        email: user.email,
        phone: user.phone || '',
        avatar_url: user.avatar_url
      }
    });
  } catch (error) {
    return c.json({ success: false, message: error.message }, 500);
  }
});

// GET /api/users/:id — Get user profile
users.get('/:id', async (c) => {
  try {
    const id = c.req.param('id');
    const rows = await query('SELECT id, name, email, phone, avatar_url FROM users WHERE id = ?', [id]);
    if (rows.length === 0) {
      return c.json({ success: false, message: 'User not found' }, 404);
    }
    return c.json({ success: true, data: rows[0] });
  } catch (error) {
    return c.json({ success: false, message: error.message }, 500);
  }
});

// PUT /api/users/:id — Update user profile
users.put('/:id', async (c) => {
  try {
    const id = c.req.param('id');
    const body = await c.req.json();
    const fields = [];
    const params = [];

    const allowedFields = ['name', 'email', 'phone', 'avatar_url'];
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
    await query(`UPDATE users SET ${fields.join(', ')} WHERE id = ?`, params);

    // Return updated user
    const rows = await query('SELECT id, name, email, phone, avatar_url FROM users WHERE id = ?', [id]);
    return c.json({ success: true, data: rows[0] });
  } catch (error) {
    return c.json({ success: false, message: error.message }, 500);
  }
});

export default users;
