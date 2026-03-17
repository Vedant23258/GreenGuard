const express = require('express');
const {
  createPlant,
  getPlants,
  updatePlant,
  deletePlant,
  getOverduePlants,
  getPlantStats,
} = require('../controllers/plantController');
const upload = require('../middleware/uploadMiddleware');

const router = express.Router();

// Development mode: authentication temporarily disabled.
// Re-enable authMiddleware when real login is restored.
// const authMiddleware = require('../middleware/authMiddleware');
// if (process.env.NODE_ENV !== 'development') {
//   router.use(authMiddleware);
// }

router
  .route('/')
  .post(upload.single('photo'), createPlant)
  .get(getPlants);

router.get('/overdue', getOverduePlants);
router.get('/stats', getPlantStats);

router
  .route('/:id')
  .put(upload.single('photo'), updatePlant)
  .delete(deletePlant);

module.exports = router;

