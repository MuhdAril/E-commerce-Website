const { query } = require('../database');
const { EMPTY_RESULT_ERROR, SQL_ERROR_CODE, UNIQUE_VIOLATION_ERROR } = require('../errors');

module.exports.retrieveById = function retrieveById(productId) {
    const sql = `select * from get_product($1)`;
    return query(sql, [productId]).then(function (result) {
        const rows = result.rows;

        if (rows.length === 0) {
            throw new EMPTY_RESULT_ERROR(`Product ${productId} not found!`);
        }

        return rows[0];
    });
};

module.exports.retrieveAll = function retrieveAll() {
    const sql = `SELECT * FROM get_all_products()`;
    return query(sql).then(function (result) {
        return result.rows;
    });
};

module.exports.retrieveAllSorted = function retrieveAllSorted(sort) {
    const sql = `select * from get_products_by_favorites($1)`;
    return query(sql, [sort]).then(function (result) {
        const rows = result.rows;

        if (rows.length === 0) {
            throw new EMPTY_RESULT_ERROR(`No products found`);
        }

        return rows;
    });
};