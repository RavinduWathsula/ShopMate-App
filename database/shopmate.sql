-- ShopMate Database Schema
CREATE DATABASE IF NOT EXISTS shopmate;
USE shopmate;

CREATE TABLE customers (
    customer_id VARCHAR(10) PRIMARY KEY,
    customer_code VARCHAR(20) UNIQUE NOT NULL,
    age_group VARCHAR(10),
    city VARCHAR(50),
    preferred_category VARCHAR(50),
    average_monthly_budget DECIMAL(10,2),
    shopping_frequency VARCHAR(20),
    customer_segment VARCHAR(20)
);

CREATE TABLE store_locations (
    location_id VARCHAR(10) PRIMARY KEY,
    aisle_id VARCHAR(10),
    aisle_name VARCHAR(50),
    shelf_id VARCHAR(10),
    shelf_name VARCHAR(50),
    x_coordinate INT,
    y_coordinate INT,
    department VARCHAR(50),
    location_description VARCHAR(255)
);

CREATE TABLE products (
    product_id VARCHAR(10) PRIMARY KEY,
    sku VARCHAR(20) UNIQUE,
    product_name VARCHAR(100) NOT NULL,
    brand VARCHAR(50),
    category VARCHAR(50),
    subcategory VARCHAR(50),
    description TEXT,
    unit VARCHAR(10),
    weight_or_volume VARCHAR(20),
    price DECIMAL(10,2),
    cost_price DECIMAL(10,2),
    stock_quantity INT,
    minimum_stock INT,
    aisle_id VARCHAR(10),
    shelf_id VARCHAR(10),
    location_id VARCHAR(10),
    barcode VARCHAR(50),
    image_class VARCHAR(100),
    status VARCHAR(20),
    FOREIGN KEY (location_id) REFERENCES store_locations(location_id)
);

CREATE TABLE inventory (
    inventory_id VARCHAR(10) PRIMARY KEY,
    product_id VARCHAR(10),
    stock_quantity INT,
    reserved_quantity INT,
    reorder_level INT,
    stock_status VARCHAR(20),
    last_restock_date DATE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE discounts (
    discount_id VARCHAR(10) PRIMARY KEY,
    product_id VARCHAR(10),
    discount_type VARCHAR(20),
    discount_percentage DECIMAL(5,2),
    original_price DECIMAL(10,2),
    discount_price DECIMAL(10,2),
    start_date DATE,
    end_date DATE,
    campaign_name VARCHAR(100),
    active VARCHAR(10),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE transactions (
    transaction_id VARCHAR(15) PRIMARY KEY,
    customer_id VARCHAR(10),
    transaction_date DATETIME,
    subtotal DECIMAL(10,2),
    discount_amount DECIMAL(10,2),
    total_amount DECIMAL(10,2),
    payment_method VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE transaction_items (
    transaction_item_id VARCHAR(15) PRIMARY KEY,
    transaction_id VARCHAR(15),
    product_id VARCHAR(10),
    quantity INT,
    unit_price DECIMAL(10,2),
    discount_percentage DECIMAL(5,2),
    line_total DECIMAL(10,2),
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE product_images (
    image_id VARCHAR(15) PRIMARY KEY,
    product_id VARCHAR(10),
    image_class VARCHAR(100),
    image_filename VARCHAR(255),
    image_path VARCHAR(255),
    view_type VARCHAR(50),
    lighting VARCHAR(50),
    background VARCHAR(50),
    augmentation_type VARCHAR(50),
    split VARCHAR(10),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE ai_product_labels (
    label_id VARCHAR(10) PRIMARY KEY,
    product_id VARCHAR(10),
    class_id INT,
    class_name VARCHAR(100),
    display_name VARCHAR(100),
    confidence_threshold DECIMAL(3,2),
    image_folder VARCHAR(255),
    yolo_class_id INT,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE store_graph (
    node_id INT PRIMARY KEY,
    from_node VARCHAR(50),
    to_node VARCHAR(50),
    distance DECIMAL(5,2)
);

CREATE TABLE shopping_history (
    history_id VARCHAR(15) PRIMARY KEY,
    customer_id VARCHAR(10),
    product_id VARCHAR(10),
    purchase_count INT,
    last_purchase_date DATE,
    average_quantity DECIMAL(10,2),
    average_spending DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE product_relationships (
    relationship_id VARCHAR(15) PRIMARY KEY,
    product_a VARCHAR(10),
    product_b VARCHAR(10),
    co_purchase_count INT,
    support DECIMAL(10,4),
    confidence DECIMAL(10,4),
    lift DECIMAL(10,4),
    relationship_type VARCHAR(50),
    FOREIGN KEY (product_a) REFERENCES products(product_id),
    FOREIGN KEY (product_b) REFERENCES products(product_id)
);

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    customer_id VARCHAR(10),
    role VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
