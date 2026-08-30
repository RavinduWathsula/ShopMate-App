-- ShopMate Database Schema

CREATE DATABASE IF NOT EXISTS shopmate_db;
USE shopmate_db;

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
