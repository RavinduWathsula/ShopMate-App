-- ShopMate Full Database Setup for XAMPP
-- This file contains the complete schema and seed data.

CREATE DATABASE IF NOT EXISTS shopmate_db;
USE shopmate_db;

-- ---------------------------------------------------------
-- SCHEMA DEFINITIONS
-- ---------------------------------------------------------

-- Users Table
CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    preferences JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Shops Table
CREATE TABLE IF NOT EXISTS shops (
    shop_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Categories Table
CREATE TABLE IF NOT EXISTS categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    parent_category_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Products Table
CREATE TABLE IF NOT EXISTS products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    shop_id INT NOT NULL,
    category_id INT NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    brand VARCHAR(150),
    subcategory VARCHAR(100),
    weight DECIMAL(10,2),
    normal_price DECIMAL(10,2) NOT NULL,
    discount_price DECIMAL(10,2) NULL,
    discount_percentage DECIMAL(5,2) NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    priority_score DECIMAL(5,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (shop_id) REFERENCES shops(shop_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE RESTRICT,
    INDEX idx_shop_category (shop_id, category_id)
) ENGINE=InnoDB;

-- Product Images Table
CREATE TABLE IF NOT EXISTS product_images (
    image_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    image_url VARCHAR(255) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Discounts Table
CREATE TABLE IF NOT EXISTS discounts (
    discount_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    description VARCHAR(255),
    start_date DATETIME NOT NULL,
    end_date DATETIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Inventory Table
CREATE TABLE IF NOT EXISTS inventory (
    inventory_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    shop_id INT NOT NULL,
    stock_level INT NOT NULL DEFAULT 0,
    reorder_threshold INT NOT NULL DEFAULT 10,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (shop_id) REFERENCES shops(shop_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Product Locations Table
CREATE TABLE IF NOT EXISTS product_locations (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    shop_id INT NOT NULL,
    aisle VARCHAR(50),
    section VARCHAR(50),
    shelf VARCHAR(50),
    x_position DECIMAL(10,2),
    y_position DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (shop_id) REFERENCES shops(shop_id) ON DELETE CASCADE,
    INDEX idx_product_location (shop_id, product_id)
) ENGINE=InnoDB;

-- Shopping Sessions Table
CREATE TABLE IF NOT EXISTS shopping_sessions (
    session_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    shop_id INT NOT NULL,
    budget DECIMAL(10,2),
    status ENUM('active', 'completed', 'abandoned') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (shop_id) REFERENCES shops(shop_id) ON DELETE RESTRICT,
    INDEX idx_user_session (user_id, status)
) ENGINE=InnoDB;

-- Shopping Items Table
CREATE TABLE IF NOT EXISTS shopping_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    session_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    price_at_time DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES shopping_sessions(session_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Shopping History Table
CREATE TABLE IF NOT EXISTS shopping_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    session_id INT NOT NULL UNIQUE,
    user_id INT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    checkout_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES shopping_sessions(session_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Recommendations Table
CREATE TABLE IF NOT EXISTS recommendations (
    recommendation_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    score DECIMAL(5,2) NOT NULL,
    reason VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
) ENGINE=InnoDB;


-- ---------------------------------------------------------
-- SEED DATA
-- ---------------------------------------------------------

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
