const path = require('path');
const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const dotenv = require('dotenv');
const bcrypt = require('bcryptjs');

dotenv.config();

const connectDB = require('./config/db');
const authRoutes = require('./routes/authRoutes');
const plantRoutes = require('./routes/plantRoutes');
const { notFound, errorHandler } = require('./middleware/errorMiddleware');
const User = require('./models/User');

const app = express();

// Database
connectDB();

// Create default admin user if not exists
async function createDefaultAdmin() {
  try {
    const existing = await User.findOne({ username: 'admin' });

    if (!existing) {
      const hashed = await bcrypt.hash('123456', 10);
      
      await User.create({
        username: 'admin',
        password: hashed,
        role: 'officer'
      });
      
      console.log('✓ Default admin user created (username: admin, password: 123456)');
    } else {
      console.log('✓ Admin user already exists');
    }
  } catch (error) {
    console.error('Error creating default admin user:', error.message);
  }
}

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(morgan('dev'));

// Create admin user after database connection
createDefaultAdmin();

// Static folder for uploads
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/plants', plantRoutes);

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', service: 'greenguard-backend' });
});

// Error handlers
app.use(notFound);
app.use(errorHandler);

const PORT = process.env.PORT || 5000;
const BASE_URL = process.env.BASE_URL || `http://localhost:${PORT}`;

// Start server and listen on all network interfaces (0.0.0.0)
app.listen(PORT, "0.0.0.0", () => {
  // eslint-disable-next-line no-console
  console.log('');
  console.log('='.repeat(60));
  console.log('🚀 GreenGuard Backend Server Started Successfully!');
  console.log('='.repeat(60));
  console.log(`✓ Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`✓ Server running on port ${PORT}`);
  console.log(`✓ Accessible locally: http://localhost:${PORT}`);
  console.log(`✓ Accessible on network: ${BASE_URL}`);
  console.log(`✓ Health check: ${BASE_URL}/api/health`);
  console.log(`✓ Uploads URL: ${BASE_URL}/uploads/`);
  console.log('='.repeat(60));
  console.log('');
});

