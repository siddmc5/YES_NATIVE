const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/auth');
const Order = require('../models/Order');

// All order routes require authentication
router.use(authMiddleware);

/**
 * GET /api/orders
 *
 * Returns all orders for the authenticated vendor.
 */
router.get('/', async (req, res) => {
  try {
    const orders = await Order.find({ 
      $or: [{ vendorUid: req.user.uid }, { vendorUid: 'DEFAULT_VENDOR' }] 
    }).sort({ createdAt: -1 });
    res.json(orders);
  } catch (err) {
    console.error('❌ Get orders error:', err.message);
    res.status(500).json({ error: 'Server error' });
  }
});

/**
 * GET /api/orders/me
 *
 * Returns all orders for the authenticated customer.
 */
router.get('/me', async (req, res) => {
  try {
    const orders = await Order.find({ customerUid: req.user.uid }).sort({ createdAt: -1 });
    res.json(orders);
  } catch (err) {
    console.error('❌ Get customer orders error:', err.message);
    res.status(500).json({ error: 'Server error' });
  }
});

/**
 * GET /api/orders/status/:status
 *
 * Filter orders by status (e.g., /api/orders/status/pending).
 */
router.get('/status/:status', async (req, res) => {
  try {
    const validStatuses = [
      'pending', 'confirmed', 'processing', 'shipped',
      'delivered', 'cancelled', 'completed',
    ];
    const status = req.params.status;

    if (!validStatuses.includes(status)) {
      return res.status(400).json({ error: `Invalid status: ${status}` });
    }

    const orders = await Order.find({ 
      $or: [{ vendorUid: req.user.uid }, { vendorUid: 'DEFAULT_VENDOR' }],
      status 
    }).sort({ createdAt: -1 });
    res.json(orders);
  } catch (err) {
    console.error('❌ Get orders by status error:', err.message);
    res.status(500).json({ error: 'Server error' });
  }
});

/**
 * PUT /api/orders/:id
 *
 * Update an order's status.
 * Body: { "status": "processing" | "shipped" | "delivered" | "completed" | "cancelled" }
 */
router.put('/:id', async (req, res) => {
  try {
    const { status } = req.body;
    const validStatuses = [
      'pending', 'confirmed', 'processing', 'shipped',
      'delivered', 'cancelled', 'completed',
    ];

    if (!status || !validStatuses.includes(status)) {
      return res.status(400).json({ error: `Invalid status: ${status}` });
    }

    const order = await Order.findOneAndUpdate(
      { _id: req.params.id, $or: [{ vendorUid: req.user.uid }, { vendorUid: 'DEFAULT_VENDOR' }] },
      { $set: { status } },
      { new: true }
    );

    if (!order) {
      return res.status(404).json({ error: 'Order not found' });
    }

    res.json(order);
  } catch (err) {
    console.error('❌ Update order error:', err.message);
    res.status(500).json({ error: 'Server error' });
  }
});

/**
 * POST /api/orders
 *
 * Create a new order (called by customer app).
 * Requires auth. customerUid is taken from req.user.uid.
 */
router.post('/', async (req, res) => {
  try {
    const { items, total, address, customerName, customerPhone, vendorUid } = req.body;

    if (!items || !items.length || !total) {
      return res.status(400).json({ error: 'Missing required fields (items, total)' });
    }

    // Generate a unique order ID (e.g., ORD-timestamp-random)
    const orderId = `ORD-${Date.now()}-${Math.floor(Math.random() * 1000)}`;

    const order = await Order.create({
      orderId,
      customerUid: req.user.uid,
      customerName: customerName || req.user.name || 'Customer',
      customerPhone: customerPhone || '',
      vendorUid: vendorUid || 'DEFAULT_VENDOR', // This needs to be set properly when UI is connected
      items,
      total,
      address: address || '',
      status: 'pending',
    });

    res.status(201).json(order);
  } catch (err) {
    console.error('❌ Create order error:', err.message);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;
