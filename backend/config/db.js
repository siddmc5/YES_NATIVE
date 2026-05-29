const mongoose = require('mongoose');

/**
 * Connect to MongoDB.
 *
 * Reads MONGODB_URI from environment variables (set in .env).
 * Ensure your MongoDB Atlas (or local) instance is running and the
 * connection string is correct.
 */
async function connectDB() {
  const uri = process.env.MONGODB_URI;

  if (!uri) {
    console.error('❌ MONGODB_URI is not set in environment variables.');
    console.error('   Copy .env.example to .env and fill in your MongoDB connection string.');
    process.exit(1);
  }

  try {
    await mongoose.connect(uri);
    console.log(`✅ Connected to MongoDB — ${mongoose.connection.host}`);
  } catch (err) {
    console.error('❌ MongoDB connection error:', err.message);
    process.exit(1);
  }
}

module.exports = connectDB;
