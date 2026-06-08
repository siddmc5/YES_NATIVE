const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/auth');
const User = require('../models/User');

/**
 * GET /api/users/me
 *
 * Returns the authenticated user's profile.
 */
router.get('/me', authMiddleware, async (req, res) => {
  try {
    const user = await User.findOne({ uid: req.user.uid });
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    res.json(user);
  } catch (err) {
    console.error('❌ Get profile error:', err.message);
    res.status(500).json({ error: 'Server error' });
  }
});

/**
 * PUT /api/users/me
 *
 * Updates the authenticated user's profile.
 * Only the fields provided in the request body will be updated.
 */
router.put('/me', authMiddleware, async (req, res) => {
  try {
    const allowedFields = [
      'displayName',
      'photoUrl',
      'businessName',
      'phone',
      'address',
      'fcmToken',
    ];

    const updates = {};
    for (const field of allowedFields) {
      if (req.body[field] !== undefined) {
        updates[field] = req.body[field];
      }
    }

    const user = await User.findOneAndUpdate(
      { uid: req.user.uid },
      { $set: updates },
      { new: true }
    );

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json(user);
  } catch (err) {
    console.error('❌ Update profile error:', err.message);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;
