const express = require('express');
const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const app = express();
app.use(express.json({ limit: '5mb' }));
app.use(express.static('public'));

const JWT_SECRET = 'vcorner_super_secret_key_2026';

const pool = mysql.createPool({
  host: 'localhost',
  user: 'root',
  password: '',
  database: 'perfume_store',
  waitForConnections: true,
  connectionLimit: 10
});

function verifyToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'مطلوب تسجيل الدخول' });
  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ error: 'جلسة غير صالحة' });
    req.user = user;
    next();
  });
}

// API جلب المنتجات
app.get('/api/products', async (req, res) => {
  try {
    const [rows] = await pool.execute('SELECT * FROM products WHERE is_active = 1');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: 'خطأ في جلب المنتجات' });
  }
});

// API تسجيل الدخول
app.post('/api/auth/login', async (req, res) => {
  const { email, password } = req.body;
  try {
    const [rows] = await pool.execute('SELECT * FROM staff_users WHERE email = ?', [email]);
    if (rows.length === 0) return res.status(400).json({ error: 'البريد أو كلمة المرور غير صحيحة' });
    const user = rows[0];
    const match = await bcrypt.compare(password, user.password_hash);
    if (!match) return res.status(400).json({ error: 'البريد أو كلمة المرور غير صحيحة' });
    const token = jwt.sign({ email: user.email, role: user.role }, JWT_SECRET, { expiresIn: '8h' });
    res.json({ token, user: { email: user.email, role: user.role } });
  } catch (err) {
    res.status(500).json({ error: 'خطأ في الخادم' });
  }
});

// API جلب الطلبات
app.get('/api/orders', verifyToken, async (req, res) => {
  try {
    const [rows] = await pool.execute('SELECT * FROM orders ORDER BY ordered_at DESC');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: 'خطأ في جلب الطلبات' });
  }
});

const PORT = 3000;
app.listen(PORT, () => console.log(`✅ السيرفر يعمل بنجاح على المنفذ: ${PORT}`));