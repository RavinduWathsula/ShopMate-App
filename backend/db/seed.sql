-- ShopMate Seed Data

USE shopmate_db;

-- Insert Shop
INSERT INTO shops (name, address) VALUES
('SuperMart Central', '123 Main Street, City Center');

-- Insert Categories
INSERT INTO categories (category_id, name, parent_category_id) VALUES
(1, 'Produce', NULL),
(2, 'Dairy', NULL),
(3, 'Bakery', NULL),
(4, 'Beverages', NULL),
(5, 'Snacks', NULL),
(6, 'Fruits', 1),
(7, 'Vegetables', 1);

-- Insert Products
INSERT INTO products (product_id, shop_id, category_id, product_name, brand, subcategory, weight, normal_price, discount_price, discount_percentage, stock_quantity, priority_score) VALUES
(1, 1, 6, 'Organic Bananas', 'Nature''s Best', 'Fresh Fruit', 500.00, 2.99, NULL, NULL, 150, 4.5),
(2, 1, 2, 'Whole Milk 2%', 'DairyPure', 'Milk', 1000.00, 3.50, 3.00, 14.29, 80, 5.0),
(3, 1, 3, 'Whole Wheat Bread', 'Wonder', 'Sliced Bread', 400.00, 2.50, NULL, NULL, 40, 3.8),
(4, 1, 4, 'Orange Juice 1L', 'Tropicana', 'Juice', 1000.00, 4.99, 4.50, 9.82, 60, 4.2),
(5, 1, 7, 'Fresh Carrots', 'FarmFresh', 'Root Vegetables', 1000.00, 1.99, NULL, NULL, 200, 3.5),
(6, 1, 5, 'Potato Chips', 'Lay''s', 'Salty Snacks', 200.00, 3.99, 2.99, 25.06, 120, 4.8);

-- Insert Product Images
INSERT INTO product_images (product_id, image_url, is_primary) VALUES
(1, 'https://example.com/images/bananas.jpg', TRUE),
(2, 'https://example.com/images/milk.jpg', TRUE),
(3, 'https://example.com/images/bread.jpg', TRUE),
(4, 'https://example.com/images/orange_juice.jpg', TRUE),
(5, 'https://example.com/images/carrots.jpg', TRUE),
(6, 'https://example.com/images/potato_chips.jpg', TRUE);

-- Insert Discounts
INSERT INTO discounts (product_id, description, start_date, end_date) VALUES
(2, 'Weekend Dairy Sale', '2026-08-01 00:00:00', '2026-08-31 23:59:59'),
(4, 'Summer Refreshment Promo', '2026-08-01 00:00:00', '2026-08-31 23:59:59'),
(6, 'Snack Fiesta', '2026-08-15 00:00:00', '2026-09-15 23:59:59');

-- Insert Inventory
INSERT INTO inventory (product_id, shop_id, stock_level, reorder_threshold) VALUES
(1, 1, 150, 50),
(2, 1, 80, 20),
(3, 1, 40, 10),
(4, 1, 60, 15),
(5, 1, 200, 50),
(6, 1, 120, 30);

-- Insert Product Locations
INSERT INTO product_locations (product_id, shop_id, aisle, section, shelf, x_position, y_position) VALUES
(1, 1, 'Aisle 1', 'Produce A', 'Shelf 2', 10.50, 20.00),
(5, 1, 'Aisle 1', 'Produce B', 'Shelf 1', 12.00, 20.00),
(2, 1, 'Aisle 8', 'Dairy', 'Refrigerated 3', 85.00, 15.50),
(4, 1, 'Aisle 8', 'Dairy', 'Refrigerated 4', 85.00, 18.00),
(3, 1, 'Aisle 3', 'Bakery', 'Shelf 4', 35.00, 40.00),
(6, 1, 'Aisle 5', 'Snacks', 'Shelf 2', 55.00, 60.00);
