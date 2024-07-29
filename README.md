# DBS Practical

## Setup

1. Clone this repository

    - Open Visual Studio Code (VSCode) on your local machine.

    - Click on the "Source Control" icon in the left sidebar (the icon looks like a branch).

    - Click on the "Clone Repository" button.

    - In the repository URL input field, enter the github repository link: `https://github.com/soc-DBS/dbs-assignment-MuhdAril.git`

    - Choose a local directory where you want to clone the repository.

    - Click on the "Clone" button to start the cloning process.

2. Create a .env file with the following content

    ```
    DB_USER=<your_database_user>
    DB_PASSWORD=<your_database_password>
    DB_HOST=<your_database_host>
    DB_DATABASE=<your_database_name>
    DB_CONNECTION_LIMIT=1
    PORT=3000
    JWT_SECRET_KEY=your-secret-key
    JWT_EXPIRES_IN=1d
    JWT_ALGORITHM=HS256
    ```

3. Update the .env content with your database credentials accordingly.

4. Install dependencies by running `npm install`

5. Start the app by running `npm start`. Alternatively to use hot reload, start the app by running `npm run dev`.

6. You should see `App listening on port 3000`

7. (Optional) install the plugins recommended in `.vscode/extensions.json`

## Web Pages
Login

### Admin

Dashboard

Dashboard -> Age Group Spending

Dashboard -> Customer Lifetime Value

Dashboard -> All Favorites Data

Dashboard -> All Members

Sale Order

Sale Order -> Retrieve All Orders

Supplier

Supplier -> Retrieve All Suppliers

### Member

Product

Product -> Show All Products

Product -> Show All Products -> View Product

Product -> Show All Products -> Favourites (Standalone page to add favorites and view them)

Product -> Show All Products -> Add To Cart

Review

Review -> Create Review

Review -> Retrieve All (My) Reviews

Review -> Retrieve All (My) Reviews -> Update Review

Review -> Retrieve All (My) Reviews -> Delete Review

Review -> Retrieve (My) Review by ID

Favourites (Standalone page to add favorites and view them)

Cart

Cart -> Retrieve Cart



## Instructions

Open the page, `http://localhost:3000`, replace the port number accordingly if you app is not listening to port 3000

### Login

For admin,
    Username: `admin`
    Password: `password`

For normal member with seeded data (johndoe),
    Username: `johndoe`
    Password: `password`

For normal member no data (user),
    Username: `user`
    Password: `password`

### Test Reviews

#### Create Review

User: johndoe

Page: Review -> Create Review

Steps:
1. Choose a product in the list of completed order in the lower section.
2. Product Id textbox will be filled.
3. Rate the product from 1 - 5.
4. You can choose whether to type into the review text box or not.

Database Error Handling:
1. If the product in your sale order is not `COMPLETED`, an error will be shown
2. If the rating is less than 1 or more than 5, an error will be shown


#### Retrieve All (My) Reviews

User: johndoe

Page: Review -> Retrieve All (My) Reviews

Steps:
1. NIL.

Database Error Handling:
1. If member does not have any reviews, an error will be shown.

#### Update Review

User: johndoe

Page: Review -> Retrieve All (My) Reviews -> Update Review

Steps:
1. In the Retrieve All Reviews Page, choose the review you want to update.
2. Click the Update button.
3. You will be redirected to the Update Review Page.
4. The review Id textbox will automatically be filled with the ID of the chosen review from the previous page.
5. Choose the rating by selecting the dropdown menu and choosing the stars.
6. Review text can be empty.
7. Click on the Update button to update the chosen review with the new inputs.

Database Error Handling:
1. If the review ID is does not belong to the member, an error will be shown.
2. If the rating stars is not chosen, an error will be shown.

#### Delete Review

User: johndoe

Page: Review -> Retrieve All (My) Reviews -> Delete Review

Steps:
1. In the Retrieve All Reviews Page, choose the review you want to delete.
2. Click the Delete button.
3. You will be redirected to the Delete Review Page.
4. The review Id textbox will automatically be filled with the ID of the chosen review from the previous page.
5. Click on the Delete button to delete the chosen review.


Database Error Handling:
1. If the review ID is does not belong to the member, an error will be shown.

#### Retrieve (My) Review by ID

User: johndoe

Page: Review -> Retrieve (My) Review by ID

Steps:
1. Enter a review ID (Where the ID belongs to the member).
2. Details of the Review will be displayed.


Database Error Handling:
1. If the review ID is does not belong to the member, an error will be shown.

### Test CLV & Running Total Spending

#### Generate CLV

User: admin

Page: Dashboard -> Customer Lifetime Value

Steps:
1. Click on Generate.
2. It will compute the CLV (as well as the running total spending) of every member and store it in the database.


Database Error Handling:
1. A few members do not have available data for either/both of the computation because they do not meet the requirements. No error will be shown.

#### Retrieve All Members

User: admin

Page: Dashboard -> All Members

Steps:
1. It displays all available members with all their data (other than password).


Database Error Handling:
1. A few members do not have available data for either/both of the computation because they do not meet the requirements. No error will be shown.

### Test Favourites

#### Create Favourite

User: johndoe

Page: Favourites

Steps:
1. Enter the ID of the product you want to favourite OR You can go to the products page and click on the Add Favourite button.
2. Click the Add button

Database Error Handling:
1. If the product does not exist, an error will be shown.
2. If you have already favourited the product, an error will be shown.

#### Retrieve All (My) Favourites

User: johndoe

Page: Favourites

Steps:
1. The table will show all of the member's favourited products.
2. The membeer can view the product in more detail, and add it to cart.

Database Error Handling:
1. NIL.

#### Remove Favourite

User: johndoe

Page: Favourites

Steps:
1. Just click on the Remove Favorite button to remove the favorited product from the favourite list.

Database Error Handling:
1. NIL.

#### Favourite Insights for Members

User: johndoe

Page: Product -> Show All Products

Steps:
1. You can see the newly added Favorite Volume column the shows the number of favorites each product has, and the volume of the favorites compared to other products.

Database Error Handling:
1. NIL.

#### Favourite Data for Admin

User: admin

Page: Dashboard -> All Favorites Data

Steps:
1. It displays all products with the number of favorites each product has.
2. The admin can sort by ascending/descending number of favorites for easier reference to make better decisions for future sales.


Database Error Handling:
1. NIL.