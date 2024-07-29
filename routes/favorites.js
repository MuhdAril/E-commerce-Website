// See https://expressjs.com/en/guide/routing.html for routing

const express = require('express');
const favoritesController = require('../controllers/favoritesController');
const jwtMiddleware = require('../middleware/jwtMiddleware');

const router = express.Router();

// All routes in this file will use the jwtMiddleware to verify the token and check if the user is an admin.
// Here the jwtMiddleware is applied at the router level to apply to all routes in this file
// But you can also apply the jwtMiddleware to individual routes
// router.use(jwtMiddleware.verifyToken, jwtMiddleware.verifyIsAdmin);

router.use(jwtMiddleware.verifyToken);

router.post('/create', favoritesController.createFavorite);
router.get('/', favoritesController.retrieveAll);
router.delete('/delete', favoritesController.deleteFavorite);

module.exports = router;