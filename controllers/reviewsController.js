const { EMPTY_RESULT_ERROR, UNIQUE_VIOLATION_ERROR, DUPLICATE_TABLE_ERROR } = require('../errors');
const reviewsModel = require('../models/reviews');

module.exports.createReview = function (req, res) {
    const data = {
        memberId: res.locals.member_id,
        productId: req.body.product_id,
        rating: req.body.rating,
        reviewText: req.body.review_text
    }

    reviewsModel.createReview(data, (err) => {
        if (err) {
            return res.status(500).json({
                success: false,
                message: 'Error creating review',
                error: err.message
            });
        }

        return res.status(201).json({
            success: true,
            message: 'You have succesfully created a review.'
        });
    });
};

module.exports.retrieveAll = (req, res) => {
    const data = {
        memberId: res.locals.member_id
    }


    reviewsModel.retrieveAll(data, (err, result) => {
        if (err) {
            return res.status(500).json({
                success: false,
                message: 'Error retrieving reviews',
                error: err.message
            });
        }

        return res.status(200).json({
            success: true,
            reviews: result.rows
        });
    });
};

module.exports.retrieveById = (req, res) => {
    
    const data = {
        reviewId: req.body.review_id,
        memberId: res.locals.member_id
    }


    reviewsModel.retrieveById(data, (err, result) => {
        if (err) {
            return res.status(500).json({
                success: false,
                message: 'Error retrieving reviews',
                error: err.message
            });
        }

        return res.status(200).json({
            success: true,
            reviews: result.rows
        });
    });
};

module.exports.deleteReview = function (req, res) {
    const data = {
        reviewId: req.body.review_id,
        memberId: res.locals.member_id
    }

    reviewsModel.deleteReview(data, (err) => {
        if (err) {
            return res.status(500).json({
                success: false,
                message: 'Error deleting review',
                error: err.message
            });
        }

        return res.status(200).json({
            success: true,
            message: 'You have succesfully deleted a review.'
        });
    });
};

module.exports.updateReview = function (req, res) {
    const data = {
        reviewId: req.body.review_id,
        memberId: res.locals.member_id,
        rating: req.body.rating,
        reviewText: req.body.review_text
    }

    reviewsModel.updateReview(data, (err) => {
        if (err) {
            return res.status(500).json({
                success: false,
                message: 'Error updating review',
                error: err.message
            });
        }

        return res.status(201).json({
            success: true,
            message: 'You have succesfully updated a review.'
        });
    });
};