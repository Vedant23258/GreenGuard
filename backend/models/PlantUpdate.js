const mongoose = require('mongoose');

const plantUpdateSchema = new mongoose.Schema(
  {
    plantId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Plant',
      required: true,
    },
    workerId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    photoUrl: {
      type: String,
    },
    status: {
      type: String,
      enum: ['Healthy', 'Needs Care', 'Dead'],
      required: true,
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
    timestamp: {
      type: Date,
      default: Date.now,
      required: true,
    },
  },
  {
    timestamps: true,
  },
);

plantUpdateSchema.index({ location: '2dsphere' });
plantUpdateSchema.index({ plantId: 1 });
plantUpdateSchema.index({ workerId: 1 });
plantUpdateSchema.index({ status: 1 });
plantUpdateSchema.index({ timestamp: -1 });

module.exports = mongoose.model('PlantUpdate', plantUpdateSchema);

