const { EMPTY_RESULT_ERROR, UNIQUE_VIOLATION_ERROR, DUPLICATE_TABLE_ERROR } = require('../errors');
const productsModel = require('../models/products');

module.exports.retrieveById = function (req, res) {
    const code = req.params.code;

    return productsModel
        .retrieveById(code)
        .then(function (product) {
            return res.json({ product: product });
        })
        .catch(function (error) {
            console.error(error);
            if (error instanceof EMPTY_RESULT_ERROR) {
                return res.status(404).json({ error: error.message });
            }
            return res.status(500).json({ error: error.message });
        });
}


module.exports.retrieveAll = function (req, res) {
    const memberId = res.locals.member_id;

    return productsModel
        .retrieveAll()
        .then(function (products) {
            return res.json({ products: products });
        })
        .catch(function (error) {
            console.error(error);
            return res.status(500).json({ error: error.message });
        });
}

module.exports.retrieveAllSorted = function (req, res) {
    const sort = req.body.sortType;

    productsModel.retrieveAllSorted(sort)
        .then(result => {
            return res.status(200).json({
                success: true,
                products: result
            });
        })
        .catch(err => {
            return res.status(500).json({
                success: false,
                message: 'Error retrieving products',
                error: err.message
            });
        });
};