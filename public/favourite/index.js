document.addEventListener('DOMContentLoaded', function () {
    const token = localStorage.getItem("token");
    const favouriteProductId = localStorage.getItem("favouriteProductId");
    const addForm = document.querySelector('form');
    addForm.querySelector('input[name=productId]').value = favouriteProductId;
    const productIdInput = document.getElementById('productId');
    const productTbody = document.getElementById('product-tbody');

    const fetchFavorites = function () {
        fetch('/favorites', {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        })
        .then(response => response.json())
        .then(body => {
            if (body.error) throw new Error(body.error);

            const favorites = body.reviews;
            productTbody.innerHTML = '';

            favorites.forEach(favorite => {
                const row = document.createElement("tr");

                const nameCell = document.createElement("td");
                const descriptionCell = document.createElement("td");
                const unitPriceCell = document.createElement("td");
                const productTypeCell = document.createElement("td");
                const imageUrlCell = document.createElement("td");
                const favoriteDateCell = document.createElement("td");
                const viewProductCell = document.createElement("td");
                const addToCartCell = document.createElement("td");
                const removeFavouriteCell = document.createElement("td");

                nameCell.textContent = favorite.productName;
                descriptionCell.textContent = favorite.description;
                unitPriceCell.textContent = favorite.unitPrice;
                productTypeCell.textContent = favorite.productType;
                imageUrlCell.innerHTML = `<img src="${favorite.imageUrl}" alt="${favorite.productName}" width="50" height="50">`;

                const favoriteDate = new Date(favorite.favoriteDate);
                favoriteDateCell.textContent = favoriteDate.toLocaleDateString('en-US', {
                    year: 'numeric',
                    month: '2-digit',
                    day: '2-digit'
                });

                const viewProductButton = document.createElement("button");
                viewProductButton.textContent = "View Product";
                viewProductButton.addEventListener('click', function () {
                    localStorage.setItem("productId", favorite.productId);
                    window.location.href = `/product/retrieve`;
                });
                viewProductCell.appendChild(viewProductButton);

                const addToCartButton = document.createElement("button");
                addToCartButton.textContent = "Add to Cart";
                addToCartButton.addEventListener('click', function () {
                    localStorage.setItem("cartProductId", favorite.productId);
                    window.location.href = `/cart/create`;
                });
                addToCartCell.appendChild(addToCartButton);

                const removeFavouriteButton = document.createElement("button");
                removeFavouriteButton.textContent = "Remove Favorite";
                removeFavouriteButton.addEventListener('click', function () {
                    removeFavorite(favorite.favoriteId);
                });
                removeFavouriteCell.appendChild(removeFavouriteButton);

                row.appendChild(nameCell);
                row.appendChild(descriptionCell);
                row.appendChild(unitPriceCell);
                row.appendChild(productTypeCell);
                row.appendChild(imageUrlCell);
                row.appendChild(favoriteDateCell);
                row.appendChild(viewProductCell);
                row.appendChild(addToCartCell);
                row.appendChild(removeFavouriteCell);

                productTbody.appendChild(row);
            });
        })
        .catch(error => {
            console.error('Error:', error.message);
            alert(`Fetch favorites failed: ${error.message}`);
        });
    };

    addForm.addEventListener('submit', function (event) {
        event.preventDefault();

        const productId = productIdInput.value.trim();
        if (!productId) {
            alert('Please enter a product ID');
            return;
        }

        fetch('/favorites/create', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${token}`
            },
            body: JSON.stringify({ product_id: productId })
        })
        .then(response => response.json())
        .then(body => {
            if (body.error) throw new Error(body.error);
            alert(body.message);
            fetchFavorites();
        })
        .catch(error => {
            console.error('Error:', error.message);
            alert(`Add favorite failed: ${error.message}`);
        });
    });

    window.removeFavorite = function (favoriteId) {
        fetch('/favorites/delete', {
            method: 'DELETE',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${token}`
            },
            body: JSON.stringify({ favorite_id: favoriteId })
        })
        .then(response => response.json())
        .then(body => {
            if (body.error) throw new Error(body.error);
            alert(body.message);
            fetchFavorites();
        })
        .catch(error => {
            console.error('Error:', error.message);
            alert(`Remove favorite failed: ${error.message}`);
        });
    };

    fetchFavorites();
});
