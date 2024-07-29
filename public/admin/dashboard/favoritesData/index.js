function fetchProducts(sort) {
    const token = localStorage.getItem("token");

    return fetch(`/dashboard/sort`, {
        method: "POST",
        headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${token}`
        },
        body: JSON.stringify({
            sortType: sort
        })
    })
        .then(function (response) {
            return response.json();
        })
        .then(function (body) {
            if (!body.success) throw new Error(body.error || 'Unknown error');
            const products = body.products;
            const tbody = document.querySelector("#product-tbody");
            tbody.innerHTML = '';
            products.forEach(function (product) {
                const row = document.createElement("tr");
                row.classList.add("product");
                const idCell = document.createElement("td");
                const nameCell = document.createElement("td");
                const unitPriceCell = document.createElement("td");
                const productTypeCell = document.createElement("td");
                const numOfFavoritesCell = document.createElement("td");

                idCell.textContent = product.productId;
                nameCell.textContent = product.productName;
                unitPriceCell.textContent = product.unitPrice;
                productTypeCell.textContent = product.productType;
                numOfFavoritesCell.textContent = product.numOfFavorites;

                row.appendChild(idCell);
                row.appendChild(nameCell);
                row.appendChild(unitPriceCell);
                row.appendChild(productTypeCell);
                row.appendChild(numOfFavoritesCell);
                tbody.appendChild(row);
            });
        })
        .catch(function (error) {
            alert(error.message);
            console.error(error);
        });
}

document.addEventListener('DOMContentLoaded', function () {
    const sortInput = document.getElementById('sortInput');
    const fetchProductsButton = document.getElementById('fetchProductsButton');

    fetchProductsButton.addEventListener('click', function () {
        const sort = sortInput.value;
        if (sort) {
            fetchProducts(sort).catch(function (error) {
                // Handle error
                console.error(error);
            });
        } else {
            alert('Please select a sort type.');
        }
    });
});