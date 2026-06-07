const mongoose = require('mongoose');
const Product = require('./models/Product');
require('dotenv').config();

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb+srv://adornjim_db_user:orBjjQXfL0Fb2CN8@cluster0.s17pxfm.mongodb.net/yes_native?appName=Cluster0';

const products = [
  {
    vendorUid: 'DEFAULT_VENDOR',
    name: 'Black Rice Choco Drink Mix',
    price: 499,
    category: 'Family Health',
    rating: 4.8,
    reviews: 124,
    stock: 100,
    tags: ['Rich in Antioxidants', 'Kid-Friendly Taste', 'Immunity Boosting'],
    description: 'A delicious and highly nutritious drink mix made from traditional black rice. Perfect for the whole family, this choco-flavored drink offers the goodness of antioxidants and essential minerals while satisfying your chocolate cravings naturally.',
    imageUrl: 'assets/images/Black Rice Choco Drink Mix.jpeg',
    isActive: true,
  },
  {
    vendorUid: 'DEFAULT_VENDOR',
    name: 'Instant Millet Energy Drink Chocolate',
    price: 349,
    category: 'Daily Energy',
    rating: 4.9,
    reviews: 198,
    stock: 100,
    tags: ['Pre & Post Workout', 'No Caffeine Jitters', 'Complex Carbohydrates'],
    description: 'Recharge your day with our Instant Millet Energy Drink. Crafted with a premium blend of native millets and natural chocolate, it provides sustained energy without the sugar crash.',
    imageUrl: 'assets/images/Instant Millet Energy Drink Chocolate.jpeg',
    isActive: true,
  },
  {
    vendorUid: 'DEFAULT_VENDOR',
    name: 'Instant Millet Energy Drink Mix',
    price: 299,
    category: 'Daily Energy',
    rating: 4.6,
    reviews: 92,
    stock: 100,
    tags: ['Sustained Energy Release', 'High in Dietary Fiber', 'Easy to Digest'],
    description: 'The classic unflavored Instant Millet Energy Drink Mix. Packed with traditional grains, it is the perfect base for your morning smoothies or a quick wholesome drink to keep you active.',
    imageUrl: 'assets/images/Instant Millet Energy Drink Mix.jpeg',
    isActive: true,
  },
  {
    vendorUid: 'DEFAULT_VENDOR',
    name: 'Millet Energy Drink Red Banana',
    price: 399,
    category: 'Daily Energy',
    rating: 4.8,
    reviews: 156,
    stock: 100,
    tags: ['Potassium Rich', 'Natural Sweetness', 'Heart Health'],
    description: 'Experience the unique taste and health benefits of Red Banana paired with our signature millet blend. A naturally sweet, potassium-rich drink that fuels your body with pure goodness.',
    imageUrl: 'assets/images/Instant Millet Energy Drink Red Banana.jpeg',
    isActive: true,
  },
  {
    vendorUid: 'DEFAULT_VENDOR',
    name: 'Red Banana Enriched Drink',
    price: 449,
    category: 'Natural Nourishment',
    rating: 4.9,
    reviews: 143,
    stock: 100,
    tags: ['Enhanced Nutrient Profile', 'High Fiber', 'Muscle Recovery'],
    description: 'Our premium enriched version of the Red Banana Millet drink. Fortified with additional native grains and nuts to provide an extra boost of essential vitamins and minerals for optimal wellness.',
    imageUrl: 'assets/images/Instant Millet Energy Drink Red Banana Enriched.jpeg',
    isActive: true,
  },
  {
    vendorUid: 'DEFAULT_VENDOR',
    name: 'Pamcube Badam Drink Mix',
    price: 599,
    category: 'Natural Nourishment',
    rating: 4.7,
    reviews: 87,
    stock: 100,
    tags: ['Natural Sweetener', 'Rich in Vitamin E', 'Brain Health Support'],
    description: 'A luxurious Badam (Almond) drink mix sweetened naturally with Palm Sugar (Pamcube). This traditional recipe supports cognitive function and provides healthy fats in a comforting, warm beverage.',
    imageUrl: 'assets/images/Pamcube Badam Drink Mix.jpeg',
    isActive: true,
  },
  {
    vendorUid: 'DEFAULT_VENDOR',
    name: 'Sprouted Ragi Choco Malt',
    price: 549,
    category: 'Kids Nutrition',
    rating: 4.8,
    reviews: 134,
    stock: 100,
    tags: ['High Calcium Content', 'Easy Digestion', 'Growth & Development'],
    description: 'Specially crafted for growing children (and loved by adults!), this Sprouted Ragi Choco Malt is rich in calcium and iron. Sprouting enhances nutrient absorption, making it the perfect daily nutritional supplement.',
    imageUrl: 'assets/images/Sprouted Ragi Choco Malt.jpeg',
    isActive: true,
  },
  {
    vendorUid: 'DEFAULT_VENDOR',
    name: 'SlimSure Wellness Mix',
    price: 499,
    category: 'Weight Management',
    rating: 4.7,
    reviews: 76,
    stock: 100,
    tags: ['Weight Management', 'Zero Added Sugar', 'Slow Release Carbs'],
    description: 'Our special blend designed to support healthy weight management and stable blood sugar levels. Formulated with carefully selected complex carbohydrates and fiber.',
    imageUrl: 'assets/images/Instant Millet Energy Drink Mix.jpeg',
    isActive: true,
  },
];

async function seed() {
  try {
    await mongoose.connect(MONGODB_URI);
    console.log('Connected to DB');

    // Optional: Clear existing products for DEFAULT_VENDOR to avoid duplicates if run multiple times
    await Product.deleteMany({ vendorUid: 'DEFAULT_VENDOR' });
    console.log('Cleared existing products');

    await Product.insertMany(products);
    console.log('Products inserted successfully');

    process.exit(0);
  } catch (err) {
    console.error('Error seeding products:', err);
    process.exit(1);
  }
}

seed();
