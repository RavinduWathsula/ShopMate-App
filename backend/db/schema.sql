CREATE DATABASE IF NOT EXISTS shopmate;
USE shopmate;

-- Core Tables
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    preferences_json JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE shops (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    parent_id INT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE SET NULL
);

CREATE TABLE discounts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    discount_type ENUM('percentage', 'fixed') NOT NULL,
    value DECIMAL(10,2) NOT NULL,
    valid_from DATETIME,
    valid_until DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Catalog Tables
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    shop_id INT NOT NULL,
    category_id INT,
    subcategory_id INT,
    product_name VARCHAR(255) NOT NULL,
    brand VARCHAR(100),
    weight DECIMAL(10,2),
    normal_price DECIMAL(10,2) NOT NULL,
    discount_id INT DEFAULT NULL,
    discount_price DECIMAL(10,2),
    discount_percentage DECIMAL(5,2),
    priority_score INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (shop_id) REFERENCES shops(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
    FOREIGN KEY (subcategory_id) REFERENCES categories(id) ON DELETE SET NULL,
    FOREIGN KEY (discount_id) REFERENCES discounts(id) ON DELETE SET NULL
);

CREATE INDEX idx_products_shop_id ON products(shop_id);
CREATE INDEX idx_products_category ON products(category_id);

CREATE TABLE product_images (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

CREATE TABLE inventory (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    shop_id INT NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    restock_date DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (shop_id) REFERENCES shops(id) ON DELETE CASCADE
);

CREATE TABLE product_locations (
    id INT AUTO_INCREMENT PRIMARY KEY,
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
    FOREIGN KEY (shop_id) REFERENCES shops(id) ON DELETE CASCADE
);

-- Shopping & Transactions
CREATE TABLE shopping_sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    shop_id INT NOT NULL,
    status ENUM('active', 'completed', 'cancelled') DEFAULT 'active',
    budget_limit DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (shop_id) REFERENCES shops(id) ON DELETE CASCADE
);

CREATE TABLE shopping_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    session_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    price_at_time DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES shopping_sessions(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

CREATE TABLE shopping_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    session_id INT NOT NULL,
    user_id INT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    completed_at DATETIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES shopping_sessions(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE recommendations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    score DECIMAL(5,2) NOT NULL,
    reason VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);
