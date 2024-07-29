window.addEventListener('DOMContentLoaded', function () {
    const token = localStorage.getItem("token");

    fetch('/dashboard/members', {
        headers: {
            Authorization: `Bearer ${token}`
        }
    })
        .then(function (response) {
            return response.json();
        })
        .then(function (body) {
            if (body.error) throw new Error(body.error);
            const members = body.members;
            const tbody = document.querySelector("#member-tbody");
            members.forEach(function (member) {
                const row = document.createElement("tr");
                row.classList.add("member");
                const idCell = document.createElement("td");
                const usernameCell = document.createElement("td");
                const emailCell = document.createElement("td");
                const dobCell = document.createElement("td");
                const genderCell = document.createElement("td");
                const lastLoginOnCell = document.createElement("td");
                const clvCell = document.createElement("td");
                const runningTotalSpendingCell = document.createElement("td");
                
                idCell.textContent = member.id;
                usernameCell.textContent = member.username;
                emailCell.textContent = member.email;
                genderCell.textContent = member.gender;
                lastLoginOnCell.innerHTML = new Date(member.lastLoginOn).toLocaleString();
                if (member.clv == null) {
                    clvCell.textContent = "Not available.";
                } else {
                    clvCell.textContent = member.clv;
                }
                if (member.runningTotalSpending == null) {
                    runningTotalSpendingCell.textContent = "Not available.";
                } else {
                    runningTotalSpendingCell.textContent = member.runningTotalSpending;
                }
                const dob = new Date(member.dob);
                dobCell.textContent = dob.toLocaleDateString('en-US', {
                    year: 'numeric',
                    month: '2-digit',
                    day: '2-digit'
                });

                row.appendChild(idCell);
                row.appendChild(usernameCell);
                row.appendChild(emailCell);
                row.appendChild(dobCell);
                row.appendChild(genderCell);
                row.appendChild(lastLoginOnCell);
                row.appendChild(clvCell);
                row.appendChild(runningTotalSpendingCell);
                tbody.appendChild(row);
            });
        })
        .catch(function (error) {
            console.error(error);
        });
});
