const mongoose = require('mongoose');

const offerSchema = new mongoose.Schema(
  {
    vendorUid: {
      type: String,
      index: true,
    },
    title: { type: String, required: true },
    discount: { type: String, default: '' },
    code: { type: String, default: '' },
    productName: { type: String, default: '' },
    isActive: { type: Boolean, default: true },
    expiresAt: { type: Date },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Offer', offerSchema);
