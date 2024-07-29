function fetchUserReview(reviewId) {
	const token = localStorage.getItem("token");

	return fetch(`/reviews/search`, {
		method: "POST",
		headers: {
			'Content-Type': 'application/json',
			Authorization: `Bearer ${token}`
		},
		body: JSON.stringify({
			review_id: parseInt(reviewId)
		})
	})
		.then(function (response) {
			return response.json();
		})
		.then(function (body) {
			if (body.error) throw new Error(body.error);
			const reviews = body.reviews;
			const reviewContainerDiv = document.querySelector('#review-container');
			reviewContainerDiv.innerHTML = ''; // Clear previous reviews

			reviews.forEach(function (review) {
				const reviewDiv = document.createElement('div');
				reviewDiv.classList.add('review-row');

				let ratingStars = '';
				for (let i = 0; i < review.rating; i++) {
					ratingStars += '⭐';
				}

				reviewDiv.innerHTML = `
					<h3>Review ID: ${review.reviewId}</h3>
					<p>Product Name: ${review.productName}</p>
					<p>Rating: ${ratingStars}</p>
					<p>Review Text: ${review.reviewText}</p>
					<p>Review Date: ${review.reviewDate ? review.reviewDate.slice(0, 10) : ""}</p>
					<button class="update-button">Update</button>
					<button class="delete-button">Delete</button>
				`;

				reviewDiv.querySelector('.update-button').addEventListener('click', function () {
					localStorage.setItem("reviewId", review.reviewId);
					window.location.href = `/review/update`;
				});

				reviewDiv.querySelector('.delete-button').addEventListener('click', function () {
					localStorage.setItem("reviewId", review.reviewId);
					window.location.href = `/review/delete`;
				});

				reviewContainerDiv.appendChild(reviewDiv);
			});
		})
		.catch(function (error) {
			alert(error.message);
			console.error(error);
		});
}

document.addEventListener('DOMContentLoaded', function () {
    const reviewIdInput = document.getElementById('reviewIdInput');
    const fetchReviewButton = document.getElementById('fetchReviewButton');

    // Ensure only numeric input
    reviewIdInput.addEventListener('input', function () {
        reviewIdInput.value = reviewIdInput.value.replace(/\D/g, '');
    });

    fetchReviewButton.addEventListener('click', function () {
        const reviewId = reviewIdInput.value;
        if (reviewId) {
            fetchUserReview(reviewId).catch(function (error) {
                // Handle error
                console.error(error);
            });
        } else {
            alert('Please enter a Review ID');
        }
    });
});