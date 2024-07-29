const { EMPTY_RESULT_ERROR, UNIQUE_VIOLATION_ERROR, DUPLICATE_TABLE_ERROR } = require('../errors');
const favoritesModel = require('../models/favorites');

module.exports.createFavorite = function (req, res) {
    const data = {
        memberId: res.locals.member_id,
        productId: req.body.product_id
    }

    favoritesModel.createFavorite(data, (err) => {
        if (err) {
            return res.status(500).json({
                success: false,
                message: 'Error favoriting a product',
                error: err.message
            });
        }

        return res.status(201).json({
            success: true,
            message: 'You have succesfully favorited a product.'
        });
    });
};

module.exports.retrieveAll = (req, res) => {
    const data = {
        memberId: res.locals.member_id
    }


    favoritesModel.retrieveAll(data, (err, result) => {
        if (err) {
            return res.status(500).json({
                success: false,
                message: 'Error retrieving favorite items',
                error: err.message
            });
        }

        return res.status(200).json({
            success: true,
            reviews: result.rows
        });
    });
};

module.exports.deleteFavorite = function (req, res) {
    const data = {
        favoriteId: req.body.favorite_id,
        memberId: res.locals.member_id
    }

    favoritesModel.deleteFavorite(data, (err) => {
        if (err) {
            return res.status(500).json({
                success: false,
                message: 'Error removing favorite item',
                error: err.message
            });
        }

        return res.status(200).json({
            success: true,
            message: 'You have succesfully removed a favorite item.'
        });
    });
};