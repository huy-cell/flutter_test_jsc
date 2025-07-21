const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const fs = require('fs-extra');
const path = require('path');
const multer = require('multer');

const app = express();
const PORT = 3000;

const DB_FILE = path.join(__dirname, 'db.json');
const UPLOAD_DIR = path.join(__dirname, 'uploads');

fs.ensureDirSync(UPLOAD_DIR);
app.use('/uploads', express.static(UPLOAD_DIR));
app.use(cors());
app.use(bodyParser.json());

// Load database
function loadDB() {
  try {
    return JSON.parse(fs.readFileSync(DB_FILE));
  } catch (err) {
    return { products: [], categories: [], _nextIds: { products: 1, categories: 1 } };
  }
}

function saveDB(db) {
  fs.writeFileSync(DB_FILE, JSON.stringify(db, null, 2));
}

function getNextId(db, type) {
  const current = db._nextIds?.[type] ?? 1;
  db._nextIds[type] = current + 1;
  return current;
}

// === MULTER (upload ảnh) ===
const storage = multer.diskStorage({
  destination: (_, __, cb) => cb(null, UPLOAD_DIR),
  filename: (_, file, cb) => {
    const ext = path.extname(file.originalname);
    const name = Date.now() + '-' + Math.round(Math.random() * 1e9) + ext;
    cb(null, name);
  }
});
const upload = multer({ storage });

// === ROUTES ===

// Root
app.get('/', (req, res) => {
  res.send('✅ Mock API đang chạy! Dùng /products hoặc /categories');
});

// GET /products
app.get('/products', (req, res) => {
  const db = loadDB();
  let products = db.products;
  const { q, categoryId } = req.query;

  if (q) {
    const qLower = q.toLowerCase();
    products = products.filter(p =>
      p.name.toLowerCase().includes(qLower) ||
      p.description.toLowerCase().includes(qLower)
    );
  }

  if (categoryId) {
    products = products.filter(p => p.categoryId == categoryId);
  }

  res.json(products);
});

// GET /products/:id
app.get('/products/:id', (req, res) => {
  const db = loadDB();
  const id = parseInt(req.params.id);
  const product = db.products.find(p => p.id === id);
  if (!product) return res.status(404).json({ error: 'Not found' });
  res.json(product);
});

// POST /products
app.post('/products', (req, res) => {
  const db = loadDB();
  const data = req.body;

  const newProduct = {
    id: getNextId(db, 'products'),
    name: data.name,
    description: data.description,
    price: data.price,
    stock: data.stock,
    categoryId: data.categoryId,
    images: data.images || []
  };

  db.products.push(newProduct);
  saveDB(db);
  res.status(201).json(newProduct);
});

// PUT /products/:id
app.put('/products/:id', (req, res) => {
  const db = loadDB();
  const id = parseInt(req.params.id);
  const index = db.products.findIndex(p => p.id === id);
  if (index === -1) return res.status(404).json({ error: 'Not found' });

  const updated = {
    ...db.products[index],
    ...req.body,
    id: id
  };

  db.products[index] = updated;
  saveDB(db);
  res.json(updated);
});

// DELETE /products/:id
app.delete('/products/:id', (req, res) => {
  const db = loadDB();
  const id = parseInt(req.params.id);
  const before = db.products.length;
  db.products = db.products.filter(p => p.id !== id);
  if (db.products.length === before) {
    return res.status(404).json({ error: 'Not found' });
  }
  saveDB(db);
  res.json({ message: 'Deleted' });
});

// POST /products/:id/images
app.post('/products/:id/images', upload.array('images', 5), (req, res) => {
  const db = loadDB();
  const id = parseInt(req.params.id);
  const product = db.products.find(p => p.id === id);
  if (!product) return res.status(404).json({ error: 'Product not found' });

  const files = req.files || [];
  const urls = files.map(f => `${req.protocol}://${req.get('host')}/uploads/${f.filename}`);

  product.images = [...product.images, ...urls].slice(0, 5);
  saveDB(db);
  res.json({ images: product.images });
});

// GET /categories
app.get('/categories', (req, res) => {
  const db = loadDB();
  res.json(db.categories);
});

// Start server
app.listen(PORT, () => {
  console.log(`API đang chạy tại: http://localhost:${PORT}`);
});
