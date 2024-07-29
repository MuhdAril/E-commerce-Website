const pool = require('../database');
const { EMPTY_RESULT_ERROR, SQL_ERROR_CODE, UNIQUE_VIOLATION_ERROR } = require('../errors');

module.exports.createReview = (data, callback) => {
    const SQLSTATEMENT = 'CALL create_review($1, $2, $3, $4)';
    const VALUES = [data.memberId, data.productId, data.rating, data.reviewText];
    pool.query(SQLSTATEMENT, VALUES, (err, result) => {
        if (err) {
            return callback(err, null);
        }
        return callback(null, result);
    })
};

module.exports.retrieveAll = (data, callback) => {
    const SQLSTATEMENT = `SELECT * FROM get_all_reviews($1)`;
    const VALUES = [data.memberId];
    pool.query(SQLSTATEMENT, VALUES, (err, result) => {
        if (err) {
            return callback(err, null);
        }
        return callback(null, result);
    });
};

module.exports.retrieveById = (data, callback) => {
    const SQLSTATEMENT = `SELECT * FROM get_review($1, $2)`;
    const VALUES = [data.reviewId, data.memberId];
    pool.query(SQLSTATEMENT, VALUES, (err, result) => {
        if (err) {
            return callback(err, null);
        }
        return callback(null, result);
    });
};

module.exports.deleteReview = (data, callback) => {
    const SQLSTATEMENT = 'CALL delete_review($1, $2)';
    const VALUES = [data.reviewId, data.memberId];
    pool.query(SQLSTATEMENT, VALUES, (err, result) => {
        if (err) {
            return callback(err, null);
        }
        return callback(null, result);
    })
};

module.exports.updateReview = (data, callback) => {
    const SQLSTATEMENT = 'CALL update_review($1, $2, $3, $4)';
    const VALUES = [data.reviewId, data.memberId, data.rating, data.reviewText];
    pool.query(SQLSTATEMENT, VALUES, (err, result) => {
        if (err) {
            return callback(err, null);
        }
        return callback(null, result);
    })
};