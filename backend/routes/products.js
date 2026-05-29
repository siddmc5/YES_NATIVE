const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/auth');
const Product = require('../models/Product');

// All product routes require authentication
router.use(authMiddleware);

/**
 * GET /api/products
 *
 * Returns all products for the authenticated vendor.
 */
router.get('/', async (req, res) => {
  try {
    const products = await Product.find({ vendorUid: req.user.uid }).sort({ createdAt: -1 });
    res.json(products);
  } catch (err) {
    console.error('❌ Get products error:', err.message);
    res.status(500).json({ error: 'Server error' });
  }
});

/**
 * POST /api/products
 *
 * Create a new product.
 */
router.post('/', async (req, res) => {
  try {
    const product = await Product.create({
      ...req.body,
      vendorUid: req.user.uid,
    });
    res.status(201).json(product);
  } catch (err) {
    console.error('❌ Create product error:', err.message);
    res.status(500).json({ error: 'Server error' });
  }
});

/**
 * PUT /api/products/:id
 *
 * Update an existing product.
 */
router.put('/:id', async (req, res) => {
  try {
    const product = await Product.findOneAndUpdate(
      { _id: req.params.id, vendorUid: req.user.uid },
      { $set: req.body },
      { new: true }
    );
    if (!product) {
      return res.status(404).json({ error: 'Product not found' });
    }
    res.json(product);
  } catch (err) {
    console.error('❌ Update product error:', err.message);
    res.status(500).json({ error: 'Server error' });
  }
});

/**
 * DELETE /api/products/:id
 *
 * Delete a product.
 */
router.delete('/:id', async (req, res) => {
  try {
    const product = await Product.findOneAndDelete({
      _id: req.params.id,
      vendorUid: req.user.uid,
    });
    if (!product) {
      return res.status(404).json({ error: 'Product not found' });
    }
    res.json({ success: true, message: 'Product deleted' });
  } catch (err) {
    console.error('❌ Delete product error:', err.message);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;
