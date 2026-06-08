require('dotenv').config();

const express = require('express');
const cors = require('cors');
const connectDB = require('./config/db');
const { initFirebaseAdmin } = require('./config/firebase-admin');

// ── Route imports ───────────────────────────────────────────────────────
const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/users');
const productRoutes = require('./routes/products');
const orderRoutes = require('./routes/orders');
const offerRoutes = require('./routes/offers');

const app = express();
const PORT = process.env.PORT || 3000;

// ── CORS ────────────────────────────────────────────────────────────────
const allowedOrigins = (process.env.CORS_ORIGINS || '')
  .split(',')
  .map((s) => s.trim())
  .filter(Boolean);

function corsOrigin(requestOrigin, cb) {
  // Allow any localhost/127.0.0.1 origin (for Flutter web dev server)
  if (
    requestOrigin &&
    (requestOrigin.startsWith('http://localhost:') ||
      requestOrigin.startsWith('http://127.0.0.1:'))
  ) {
    return cb(null, requestOrigin);
  }
  // Use explicit list from .env, or allow any origin
  return cb(null, allowedOrigins.length > 0 ? allowedOrigins : true);
}

app.use(cors({ origin: corsOrigin, credentials: true }));

// ── Body parsing ────────────────────────────────────────────────────────
app.use(express.json({ limit: '10mb' }));

// ── Health check ────────────────────────────────────────────────────────
app.get('/api/health', (_req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// ── Routes ──────────────────────────────────────────────────────────────
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/products', productRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/offers', offerRoutes);

// ── Start server ────────────────────────────────────────────────────────
async function start() {
  // 1. Connect to MongoDB
  await connectDB();

  // 2. Init Firebase Admin SDK (optional — server runs without it for local dev)
  const firebase = initFirebaseAdmin();
  if (!firebase) {
    console.warn('⚠️  Firebase Auth disabled — API routes requiring auth will return 503.');
  }

  // 3. Setup Socket.io
  const http = require('http');
  const { Server } = require('socket.io');
  const server = http.createServer(app);
  
  const io = new Server(server, {
    cors: {
      origin: corsOrigin,
      methods: ["GET", "POST", "PUT", "PATCH", "DELETE"]
    }
  });

  io.on('connection', (socket) => {
    console.log(`🔌 Client connected: ${socket.id}`);
    
    // Clients can join rooms based on their user ID or vendor role to receive targeted updates
    socket.on('join_user_room', (userId) => {
      socket.join(`user_${userId}`);
      console.log(`User ${userId} joined room user_${userId}`);
    });
    
    socket.on('join_vendor_room', () => {
      socket.join('vendors');
      console.log('A vendor joined the vendors room');
    });

    socket.on('disconnect', () => {
      console.log(`🔌 Client disconnected: ${socket.id}`);
    });
  });

  // Make io accessible in our routes
  app.set('io', io);

  // 4. Start listening using the HTTP server instead of Express app
  server.listen(PORT, () => {
    console.log(`
╔══════════════════════════════════════════════════════╗
║  Yes Native Backend Server + WebSockets             ║
║  Running on http://localhost:${PORT.toString().padEnd(5)}              ║
║  Health: http://localhost:${PORT.toString().padEnd(5)}/api/health     ║
╚══════════════════════════════════════════════════════╝
    `);
  });
}

start().catch((err) => {
  console.error('❌ Failed to start server:', err);
  process.exit(1);
});
