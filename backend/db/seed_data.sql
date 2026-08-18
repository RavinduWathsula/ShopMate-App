USE shopmate;

-- Seed Generic Test Users
INSERT INTO users (email, password_hash, preferences_json) VALUES
('testuser@shopmate.com', '$2b$12$e/jM/p.Z8n8gZ6P7.8G2rO.4.Z8n8gZ6P7.8G2rO.4.Z8n8gZ6P7', '{"dietary": ["vegan"], "max_budget_default": 100.00}');

-- Seed Shops
INSERT INTO shops (name, address, city) VALUES
('FreshMart Downtown', '123 Market St', 'Metropolis');

-- Seed Categories
INSERT INTO categories (id, name, parent_id) VALUES
(1, 'Produce', NULL),
(2, 'Fruits', 1),
(3, 'Vegetables', 1),
(4, 'Dairy & Eggs', NULL),
(5, 'Milk', 4),
(6, 'Bakery', NULL),
(7, 'Bread', 6);

-- Seed Discounts
INSERT INTO discounts (id, name, discount_type, value) VALUES
(1, '10% Off Produce', 'percentage', 10.00),
(2, 'Weekly Bread Special', 'fixed', 0.50);

-- Seed Products
INSERT INTO products (shop_id, category_id, subcategory_id, product_name, brand, weight, normal_price, discount_id, discount_price, discount_percentage, priority_score) VALUES
(1, 1, 2, 'Organic Bananas', 'Nature Farm', 1.0, 2.99, NULL, NULL, NULL, 100),
(1, 4, 5, 'Whole Milk 1 Gallon', 'DairyBest', 3.78, 3.50, NULL, NULL, NULL, 90),
(1, 6, 7, 'Sourdough Loaf', 'BakeryFresh', 0.5, 4.00, 2, 3.50, NULL, 80),
(1, 1, 3, 'Avocado', 'GreenLife', 0.2, 1.50, 1, 1.35, 10.00, 85);

-- Seed Inventory
INSERT INTO inventory (product_id, shop_id, stock_quantity) VALUES
(1, 1, 150),
(2, 1, 40),
(3, 1, 20),
(4, 1, 80);

-- Seed Product Locations
INSERT INTO product_locations (product_id, shop_id, aisle, section, shelf, x_position, y_position) VALUES
(1, 1, 'A1', 'Produce', 'Top', 10.5, 20.0),
(2, 1, 'B3', 'Dairy', 'Bottom', 30.0, 45.5),
(3, 1, 'C2', 'Bakery', 'Middle', 15.0, 60.2),
(4, 1, 'A1', 'Produce', 'Middle', 12.0, 20.0);

-- Seed Active Shopping Session
INSERT INTO shopping_sessions (user_id, shop_id, status, budget_limit) VALUES
(1, 1, 'active', 50.00);

-- Seed Shopping Items
INSERT INTO shopping_items (session_id, product_id, quantity, price_at_time) VALUES
(1, 1, 2, 2.99),
(1, 2, 1, 3.50);

-- Seed Recommendations
INSERT INTO recommendations (user_id, product_id, score, reason) VALUES
(1, 3, 85.50, 'Frequently bought with Milk'),
(1, 4, 92.00, 'Matches Vegan preference and on sale');
