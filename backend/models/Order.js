const mongoose = require('mongoose');

const orderItemSchema = new mongoose.Schema(
  {
    productName: { type: String, required: true },
    quantity: { type: Number, required: true },
    price: { type: Number, required: true },
  },
  { _id: false }
);

const orderSchema = new mongoose.Schema(
  {
    orderId: {
      type: String,
      required: true,
      unique: true,
      index: true,
    },
    vendorUid: {
      type: String,
      index: true,
    },
    customerUid: {
      type: String,
      index: true,
    },
    customerName: { type: String, required: true },
    customerPhone: { type: String, default: '' },
    items: [orderItemSchema],
    total: { type: Number, required: true },
    status: {
      type: String,
      enum: [
        'pending',
        'confirmed',
        'processing',
        'shipped',
        'delivered',
        'cancelled',
        'completed',
      ],
      default: 'pending',
    },
    address: { type: String, default: '' },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Order', orderSchema);
