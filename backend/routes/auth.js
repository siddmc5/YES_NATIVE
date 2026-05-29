const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/auth');
const User = require('../models/User');

/**
 * POST /api/auth/login
 *
 * Verifies the Firebase ID token and returns the user from MongoDB.
 * If the user does not exist yet, they are automatically created
 * (first-time sign-up). This works for both vendor and customer roles.
 *
 * Request body (optional):
 *   { "role": "vendor" | "customer" }   — defaults to "vendor"
 *
 * Both the vendor and customer apps call this endpoint after a
 * successful Firebase Google Sign-In.
 */
router.post('/login', authMiddleware, async (req, res) => {
  try {
    const { uid, email, name, picture } = req.user;
    const role = req.body.role || 'vendor';

    let user = await User.findOne({ uid });

    if (!user) {
      // First-time sign-up — create a new user document
      user = await User.create({
        uid,
        displayName: name || '',
        email: email || '',
        photoUrl: picture || '',
        role,
      });
      console.log(`🆕 New ${role} created: ${email} (${uid})`);
    } else if (role !== user.role) {
      // Allow updating role if this is the first time logging in from a different app
      user.role = role;
      await user.save();
    }

    res.json({ success: true, user });
  } catch (err) {
    console.error('❌ Auth login error:', err.message);
    res.status(500).json({ error: 'Server error during login' });
  }
});

module.exports = router;
