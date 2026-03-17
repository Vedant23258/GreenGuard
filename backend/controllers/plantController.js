const Plant = require('../models/Plant');

const buildPhotoUrl = (req, file) => {
  if (!file) return null;
  const port = process.env.PORT || 5000;
  // Use environment-aware URL for production/deployment
  const baseUrl = process.env.BASE_URL || `http://localhost:${port}`;
  return `${baseUrl}/uploads/${file.filename}`;
};

const serializePlant = (plant) => {
  const doc = plant.toObject({ getters: true, virtuals: false });
  const coords = doc.location?.coordinates || [0, 0];
  const [lng, lat] = coords;

  return {
    id: doc._id.toString(),
    plantName: doc.plantName,
    status: doc.status,
    location: doc.location,
    latitude: lat,
    longitude: lng,
    photoUrl: doc.photoUrl || '',
    lastUpdated: doc.lastUpdated,
    createdAt: doc.createdAt,
    updatedAt: doc.updatedAt,
  };
};

// POST /api/plants
const createPlant = async (req, res, next) => {
  try {
    // Debug logging
    console.log("\n=== Plant Creation Request ===");
    console.log("Incoming plant request:", req.body);
    console.log("Uploaded file:", req.file);
    
    const { plantName, latitude, longitude, status, lastUpdated } = req.body;
    
    // Validation
    if (!plantName || !plantName.trim()) {
      console.log("Validation failed: plantName missing");
      return res.status(400).json({
        success: false,
        message: 'plantName is required',
      });
    }
    
    if (latitude === undefined || longitude === undefined || 
        latitude === '' || longitude === '') {
      console.log("Validation failed: coordinates missing");
      return res.status(400).json({
        success: false,
        message: 'latitude and longitude are required',
      });
    }

    const latNum = Number.parseFloat(latitude);
    const lngNum = Number.parseFloat(longitude);

    if (Number.isNaN(latNum) || Number.isNaN(lngNum)) {
      console.log("Validation failed: invalid coordinates");
      return res.status(400).json({
        success: false,
        message: 'latitude and longitude must be valid numbers',
      });
    }

    const photoUrl = buildPhotoUrl(req, req.file);
    console.log("Generated photoUrl:", photoUrl);

    // Development mode: use a default user ID if authentication is not enabled
    const userId = req.user?.id || '60d5ecb5c9f8a32e8c9b4567'; // Default dev user
    console.log("Using userId:", userId);

    const plantData = {
      plantName: plantName.trim(),
      location: {
        type: 'Point',
        coordinates: [lngNum, latNum],
      },
      status: status || 'Healthy',
      lastUpdated: lastUpdated ? new Date(lastUpdated) : new Date(),
      photoUrl,
      createdBy: userId,
    };
    
    console.log("Creating plant with data:", JSON.stringify(plantData, null, 2));

    const plant = await Plant.create(plantData);
    
    console.log("✓ Plant created successfully:", plant._id);
    console.log("============================\n");

    return res.status(201).json({
      success: true,
      plant: serializePlant(plant),
    });
  } catch (err) {
    console.error("❌ Error creating plant:", err.message);
    console.error("Stack trace:", err.stack);
    return next(err);
  }
};

// GET /api/plants
const getPlants = async (req, res, next) => {
  try {
    console.log("\n=== Fetching Plants ===");
    const plants = await Plant.find().sort({ createdAt: -1 }).populate({
      path: 'createdBy',
      select: 'username role',
    });
    console.log(`✓ Found ${plants.length} plants`);
    console.log("========================\n");
    return res.json({
      success: true,
      count: plants.length,
      plants: plants.map(serializePlant),
    });
  } catch (err) {
    console.error("❌ Error fetching plants:", err.message);
    return next(err);
  }
};

// PUT /api/plants/:id
const updatePlant = async (req, res, next) => {
  try {
    const { id } = req.params;
    const updates = { ...req.body };

    // Optional coordinate update
    if (updates.latitude !== undefined && updates.longitude !== undefined) {
      const latNum = Number.parseFloat(updates.latitude);
      const lngNum = Number.parseFloat(updates.longitude);

      if (Number.isNaN(latNum) || Number.isNaN(lngNum)) {
        return res.status(400).json({
          success: false,
          message: 'latitude and longitude must be valid numbers',
        });
      }

      updates.location = {
        type: 'Point',
        coordinates: [lngNum, latNum],
      };

      delete updates.latitude;
      delete updates.longitude;
    }

    if (req.file) {
      updates.photoUrl = buildPhotoUrl(req, req.file);
    }

    updates.lastUpdated = updates.lastUpdated
      ? new Date(updates.lastUpdated)
      : new Date();

    const plant = await Plant.findByIdAndUpdate(id, updates, {
      new: true,
      runValidators: true,
    });

    if (!plant) {
      return res.status(404).json({ 
        success: false,
        message: 'Plant not found' 
      });
    }

    return res.json({
      success: true,
      data: serializePlant(plant),
    });
  } catch (err) {
    return next(err);
  }
};

// DELETE /api/plants/:id
const deletePlant = async (req, res, next) => {
  try {
    const { id } = req.params;
    const plant = await Plant.findByIdAndDelete(id);
    if (!plant) {
      return res.status(404).json({ 
        success: false,
        message: 'Plant not found' 
      });
    }
    return res.json({ 
      success: true,
      message: 'Plant deleted' 
    });
  } catch (err) {
    return next(err);
  }
};

// GET /api/plants/overdue
const getOverduePlants = async (req, res, next) => {
  try {
    const cutoff = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
    const plants = await Plant.find({
      lastUpdated: { $lt: cutoff },
    })
      .sort({ lastUpdated: 1 })
      .populate({
        path: 'createdBy',
        select: 'username role',
      });

    return res.json({
      success: true,
      count: plants.length,
      data: plants.map(serializePlant),
    });
  } catch (err) {
    return next(err);
  }
};

// GET /api/plants/stats
const getPlantStats = async (req, res, next) => {
  try {
    const results = await Plant.aggregate([
      {
        $group: {
          _id: '$status',
          count: { $sum: 1 },
        },
      },
    ]);

    let totalPlants = 0;
    let healthyPlants = 0;
    let needsCarePlants = 0;
    let deadPlants = 0;

    results.forEach((r) => {
      totalPlants += r.count;
      if (r._id === 'Healthy') healthyPlants = r.count;
      if (r._id === 'Needs Care') needsCarePlants = r.count;
      if (r._id === 'Dead') deadPlants = r.count;
    });

    return res.json({
      success: true,
      data: {
        totalPlants,
        healthyPlants,
        needsCarePlants,
        deadPlants,
      },
    });
  } catch (err) {
    return next(err);
  }
};

module.exports = {
  createPlant,
  getPlants,
  updatePlant,
  deletePlant,
  getOverduePlants,
  getPlantStats,
};

