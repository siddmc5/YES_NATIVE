const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/auth');
const Offer = require('../models/Offer');

// All offer routes require authentication
router.use(authMiddleware);

/**
 * GET /api/offers
 *
 * Returns all offers for the authenticated vendor.
 */
router.get('/', async (req, res) => {
  try {
    const offers = await Offer.find({ vendorUid: req.user.uid }).sort({ createdAt: -1 });
    res.json(offers);
  } catch (err) {
    console.error('❌ Get offers error:', err.message);
    res.status(500).json({ error: 'Server error' });
  }
});

/**
 * POST /api/offers
 *
 * Create a new offer.
 */
router.post('/', async (req, res) => {
  try {
    const offer = await Offer.create({
      ...req.body,
      vendorUid: req.user.uid,
    });
    res.status(201).json(offer);
  } catch (err) {
    console.error('❌ Create offer error:', err.message);
    res.status(500).json({ error: 'Server error' });
  }
});

/**
 * PUT /api/offers/:id
 *
 * Update an existing offer.
 */
router.put('/:id', async (req, res) => {
  try {
    const offer = await Offer.findOneAndUpdate(
      { _id: req.params.id, vendorUid: req.user.uid },
      { $set: req.body },
      { new: true }
    );
    if (!offer) {
      return res.status(404).json({ error: 'Offer not found' });
    }
    res.json(offer);
  } catch (err) {
    console.error('❌ Update offer error:', err.message);
    res.status(500).json({ error: 'Server error' });
  }
});

/**
 * DELETE /api/offers/:id
 *
 * Delete an offer.
 */
router.delete('/:id', async (req, res) => {
  try {
    const offer = await Offer.findOneAndDelete({
      _id: req.params.id,
      vendorUid: req.user.uid,
    });
    if (!offer) {
      return res.status(404).json({ error: 'Offer not found' });
    }
    res.json({ success: true, message: 'Offer deleted' });
  } catch (err) {
    console.error('❌ Delete offer error:', err.message);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;
