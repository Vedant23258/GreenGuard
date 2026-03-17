const mongoose = require('mongoose');

const plantSchema = new mongoose.Schema(
  {
    plantName: {
      type: String,
      required: true,
      trim: true,
    },
    location: {
      type: {
        type: String,
        enum: ['Point'],
        default: 'Point',
      },
      coordinates: {
        type: [Number], // [longitude, latitude]
        required: true,
      },
    },
    photoUrl: {
      type: String,
    },
    status: {
      type: String,
      enum: ['Healthy', 'Needs Care', 'Dead'],
      default: 'Healthy',
    },
    lastUpdated: {
      type: Date,
      default: Date.now,
    },
    createdBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: false, // Made optional for development mode
      default: null,
    },
  },
  {
    timestamps: true,
  },
);

plantSchema.index({ location: '2dsphere' });
plantSchema.index({ createdBy: 1 });
plantSchema.index({ status: 1 });
plantSchema.index({ createdAt: -1 });

module.exports = mongoose.model('Plant', plantSchema);

