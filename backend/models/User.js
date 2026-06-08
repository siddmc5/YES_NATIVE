const mongoose = require('mongoose');

/**
 * User schema shared by both vendor and customer apps.
 *
 * The `role` field distinguishes between:
 *   - "vendor"   → vendor-side app
 *   - "customer" → customer/user-side app
 *
 * Both apps authenticate via the same Firebase Auth project but are
 * stored together in this collection so data can be linked (e.g., an
 * order ties vendor → customer).
 */
const userSchema = new mongoose.Schema(
  {
    // Firebase Auth UID (unique identifier shared across apps)
    uid: {
      type: String,
      required: true,
      unique: true,
      index: true,
    },
    displayName: { type: String, default: '' },
    email: { type: String, default: '' },
    photoUrl: { type: String, default: '' },
    role: {
      type: String,
      enum: ['vendor', 'customer'],
      default: 'vendor',
      index: true,
    },
    // Vendor-specific fields
    businessName: { type: String, default: '' },
    phone: { type: String, default: '' },
    address: { type: String, default: '' },
    // Customer-specific fields (used by the user-side app)
    phoneNumber: { type: String, default: '' },
    shippingAddresses: [
      {
        label: { type: String },
        address: { type: String },
        isDefault: { type: Boolean, default: false },
      },
    ],
    // For push notifications
    fcmToken: { type: String, default: '' },
  },
  { timestamps: true } // adds createdAt, updatedAt
);

module.exports = mongoose.model('User', userSchema);
