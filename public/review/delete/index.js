window.addEventListener('DOMContentLoaded', function () {

    const token = localStorage.getItem('token');
    const reviewId = localStorage.getItem('reviewId');


    const form = document.querySelector('form'); // Only have 1 form in this HTML
    form.querySelector('input[name=reviewId]').value = reviewId;
    form.onsubmit = function (e) {
        e.preventDefault(); // prevent using the default submit behavior

        const reviewId = parseInt(document.querySelector("input[name='reviewId']").value);

        fetch(`/reviews/delete`, {
            method: "DELETE",
            headers: {
                Authorization: `Bearer ${token}`,
                "Content-Type": "application/json",
            },
            body: JSON.stringify({
                review_id: reviewId
            }),
        })
            .then(function (response) {
                if (response.ok) {
                    alert(`Review deleted!`);
                    
                } else {
                    // If fail, show the error message
                    response.json().then(function (data) {
                        alert(data.error);
                    });
                }
            })
            .catch(function (error) {
                alert(`Error deleting review`);
            });
    };
});
