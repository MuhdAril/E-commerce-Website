const pool = require('../database');
const { EMPTY_RESULT_ERROR, SQL_ERROR_CODE, UNIQUE_VIOLATION_ERROR } = require('../errors');

module.exports.createFavorite = (data, callback) => {
    const SQLSTATEMENT = 'call add_favorite ($1, $2)';
    const VALUES = [data.memberId, data.productId];
    pool.query(SQLSTATEMENT, VALUES, (err, result) => {
        if (err) {
            return callback(err, null);
        }
        return callback(null, result);
    })
};

module.exports.retrieveAll = (data, callback) => {
    const SQLSTATEMENT = `SELECT * FROM get_all_favorites($1)`;
    const VALUES = [data.memberId];
    pool.query(SQLSTATEMENT, VALUES, (err, result) => {
        if (err) {
            return callback(err, null);
        }
        return callback(null, result);
    });
};

module.exports.deleteFavorite = (data, callback) => {
    const SQLSTATEMENT = 'CALL remove_favorite_item($1, $2)';
    const VALUES = [data.favoriteId, data.memberId];
    pool.query(SQLSTATEMENT, VALUES, (err, result) => {
        if (err) {
            return callback(err, null);
        }
        return callback(null, result);
    })
};