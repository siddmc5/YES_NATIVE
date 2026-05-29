/**
 * Database setup script.
 * Creates the yes_native database and required collections (users, products, orders, offers).
 * Collections are automatically created by Mongoose when data is first inserted,
 * but this script ensures they exist explicitly for setup purposes.
 */
require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });
const mongoose = require('mongoose');

async function setupDB() {
  const uri = process.env.MONGODB_URI;
  if (!uri) {
    console.error('❌ MONGODB_URI not set in .env');
    process.exit(1);
  }

  await mongoose.connect(uri);
  const db = mongoose.connection.db;
  console.log(`✅ Connected to database: ${db.databaseName}`);

  // List all databases
  const dbs = await db.admin().listDatabases();
  console.log('📊 Existing databases:', dbs.databases.map(d => d.name).join(', '));

  // Check and create collections
  const existing = await db.listCollections().toArray();
  const existingNames = existing.map(c => c.name);

  const needed = ['users', 'products', 'orders', 'offers'];
  for (const col of needed) {
    if (existingNames.includes(col)) {
      console.log(`✓ Collection "${col}" already exists`);
    } else {
      await db.createCollection(col);
      console.log(`+ Created collection "${col}"`);
    }
  }

  console.log('\n✅ Database setup complete!');
  await mongoose.disconnect();
}

setupDB().catch(err => {
  console.error('❌ Setup failed:', err.message);
  process.exit(1);
});
