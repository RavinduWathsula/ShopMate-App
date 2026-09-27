# ShopMate Backend API Requirements

This document outlines the required endpoints for the ShopMate FastAPI backend. These endpoints interact with the generated MySQL database to serve the Flutter frontend.

## Authentication & User Management
* `POST /api/auth/login`: Authenticate a user and return a JWT token.
* `POST /api/auth/register`: Create a new user account linked to a `customer_id`.

## Product Catalog & Search
* `GET /api/products`: Retrieve a paginated list of products.
* `GET /api/products/{product_id}`: Retrieve detailed information about a specific product.
* `GET /api/products/search?q={query}`: Search products by name, brand, or category.

## Product Pricing & Location
* `GET /api/products/{product_id}/price`: Get the current base price.
* `GET /api/products/{product_id}/discount`: Check for active discounts on a product.
* `GET /api/products/{product_id}/location`: Get the specific `aisle_id` and `shelf_id` for navigation.

## AI & Image Recognition
* `POST /api/ai/identify`: 
  * **Payload**: Image file (multipart/form-data)
  * **Process**: Runs YOLO model inference. Matches bounding boxes to `ai_product_labels` class IDs.
  * **Response**: `{ "product_id": "P0001", "product_name": "Anchor Milk 1L", "confidence": 0.94 }`

## Shopping Cart & Budget
* `POST /api/cart`: Add or update a product in the user's cart.
* `GET /api/cart/{customer_id}`: Retrieve the current cart items, total value, and check against the budget.

## Recommendations
* `GET /api/recommendations/{customer_id}`: Retrieve personalized recommendations based on `shopping_history`.
* `GET /api/recommendations/product/{product_id}`: Retrieve related items (frequent co-purchases) based on `product_relationships`.

## Algorithms & Advanced Features
* `POST /api/budget/optimize`: Submit a shopping list. The backend suggests alternatives or removals if the list exceeds the given budget.
* `POST /api/route/calculate`: 
  * **Payload**: List of `product_id` in the cart.
  * **Process**: Uses Dijkstra's algorithm on the `store_graph` combining with `store_locations` to find the shortest shopping path from Entrance -> Aisles -> Checkout.
  * **Response**: Ordered list of navigational steps.
