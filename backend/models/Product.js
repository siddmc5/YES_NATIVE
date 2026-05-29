const mongoose = require('mongoose');

const productSchema = new mongoose.Schema(
  {
    vendorUid: {
      type: String,
      required: true,
      index: true,
    },
    name: { type: String, required: true },
    category: { type: String, default: '' },
    price: { type: Number, required: true },
    stock: { type: Number, default: 0 },
    rating: { type: Number, default: 0 },
    reviews: { type: Number, default: 0 },
    tags: [String],
    isActive: { type: Boolean, default: true },
    imageUrl: { type: String, default: '' },
    description: { type: String, default: '' },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Product', productSchema);
