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
    const orders = await Order.find({ vendorUid: req.user.uid }).sort({ createdAt: -1 });
    res.json(orders);
  } catch (err) {
    console.error('❌ Get orders error:', err.message);
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

    const orders = await Order.find({ vendorUid: req.user.uid, status }).sort({ createdAt: -1 });
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
      { _id: req.params.id, vendorUid: req.user.uid },
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

module.exports = router;
