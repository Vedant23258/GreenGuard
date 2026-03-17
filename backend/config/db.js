const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    const uri = process.env.MONGO_URI;
    if (!uri) {
      throw new Error('MONGO_URI is not set in environment');
    }

    const conn = await mongoose.connect(uri, {
      // MongoDB Atlas specific options
      serverSelectionTimeoutMS: 5000,
      socketTimeoutMS: 45000,
      maxPoolSize: 10,
    });
    
    // eslint-disable-next-line no-console
    console.log('='.repeat(60));
    console.log('✓ MongoDB Atlas Connected Successfully!');
    console.log(`✓ Database: ${conn.connection.name}`);
    console.log(`✓ Host: ${conn.connection.host}`);
    console.log('='.repeat(60));
  } catch (err) {
    // eslint-disable-next-line no-console
    console.error('MongoDB Atlas connection error:', err.message);
    console.error('Error code:', err.code);
    process.exit(1);
  }
};

module.exports = connectDB;

