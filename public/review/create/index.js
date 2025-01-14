window.addEventListener('DOMContentLoaded', function () {
    const token = localStorage.getItem("token");

    fetch('/saleOrders', {
        headers: {
            Authorization: `Bearer ${token}`
        }
    })
        .then(function (response) {
            return response.json();
        })
        .then(function (body) {
            if (body.error) throw new Error(body.error);
            const saleOrders = body.saleOrders;
            const tbody = document.querySelector("#product-tbody");
            saleOrders.forEach(function (saleOrder) {
                const row = document.createElement("tr");
                row.classList.add("product");
                const nameCell = document.createElement("td");
                const descriptionCell = document.createElement("td");
                const unitPriceCell = document.createElement("td");
                const quantityCell = document.createElement("td");
                const countryCell = document.createElement("td");
                const imageUrlCell = document.createElement("td");
                const orderId = document.createElement("td");
                const orderDatetimeCell = document.createElement("td");
                const statusCell = document.createElement("td");
                const createReviewCell = document.createElement("td");

                nameCell.textContent = saleOrder.name;
                descriptionCell.textContent = saleOrder.description;
                unitPriceCell.textContent = saleOrder.unitPrice;
                quantityCell.textContent = saleOrder.quantity;
                countryCell.textContent = saleOrder.country;
                imageUrlCell.innerHTML = `<img src="${saleOrder.imageUrl}" alt="Product Image">`;
                orderId.textContent = saleOrder.saleOrderId;
                orderDatetimeCell.textContent = new Date(saleOrder.orderDatetime).toLocaleString();
                statusCell.textContent = saleOrder.status;
                const viewProductButton = document.createElement("button");
                viewProductButton.textContent = "Create Review";
                viewProductButton.addEventListener('click', function () {
                    const reviewProductSpan = document.querySelector("#review-product-id");
                    reviewProductSpan.innerHTML = saleOrder.name;
                    const productIdInput = document.querySelector("input[name='productId']");
                    productIdInput.value = saleOrder.productId;
                });
                createReviewCell.appendChild(viewProductButton);

                row.appendChild(nameCell);
                row.appendChild(descriptionCell);
                row.appendChild(imageUrlCell);
                row.appendChild(unitPriceCell);
                row.appendChild(quantityCell);
                row.appendChild(countryCell);
                row.appendChild(orderId);
                row.appendChild(orderDatetimeCell);
                row.appendChild(statusCell);
                row.appendChild(createReviewCell);
                tbody.appendChild(row);
            });
        })
        .catch(function (error) {
            console.error(error);
        });

    const reviewForm = document.querySelector('form');
    reviewForm.addEventListener('submit', function (event) {
        event.preventDefault();

        const productId = parseInt(document.querySelector("#productId").value);
        const rating = parseInt(document.querySelector("#rating").value);
        const reviewText = document.querySelector("#reviewText").value;

        if (isNaN(productId) || isNaN(rating)) {
            alert('Product ID and Rating must be valid numbers');
            return;
        }

        const data = {
            product_id: productId,
            rating: rating,
            review_text: reviewText
        };

        fetch('/reviews/create', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                Authorization: `Bearer ${token}`
            },
            body: JSON.stringify(data)
        })
            .then(function (response) {
                return response.json().then(function (body) {
                    if (response.ok) {
                        reviewForm.reset();
                        alert('Review created successfully');
                    } else {
                        throw new Error(body.error || 'Failed to create review');
                    }
                });
            })
            .catch(function (error) {
                console.error('Error creating review:', error);
                alert('Failed to create review: ' + error.message);
            });
    });
});
