import os
import random
import uuid
from datetime import datetime, timedelta
import pandas as pd
import numpy as np
from faker import Faker

# Setup Faker and Random Seed
Faker.seed(42)
random.seed(42)
np.random.seed(42)
fake = Faker()

# Configuration
NUM_PRODUCTS = 2000
NUM_CUSTOMERS = 500
NUM_TRANSACTIONS = 10000
NUM_DISCOUNTS = 4000

# Base Directories
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATASET_DIR = os.path.join(BASE_DIR, 'dataset')
DB_DIR = os.path.join(BASE_DIR, 'database')
IMAGES_DIR = os.path.join(DATASET_DIR, 'images')
AI_DATASET_SMALL_DIR = os.path.join(DATASET_DIR, 'ai_dataset_small')
SAMPLE_AI_TEST_DIR = os.path.join(DATASET_DIR, 'sample_ai_test_images')

os.makedirs(DATASET_DIR, exist_ok=True)
os.makedirs(DB_DIR, exist_ok=True)
os.makedirs(IMAGES_DIR, exist_ok=True)
os.makedirs(AI_DATASET_SMALL_DIR, exist_ok=True)
os.makedirs(SAMPLE_AI_TEST_DIR, exist_ok=True)

# 1. STORE LOCATIONS & STORE GRAPH
print("Generating Store Locations...")
departments = [
    'Dairy', 'Bakery', 'Beverages', 'Snacks', 'Rice & Grains', 'Pasta', 'Canned Food',
    'Frozen Food', 'Fruits', 'Vegetables', 'Meat', 'Seafood', 'Household', 'Personal Care',
    'Baby Products', 'Breakfast', 'Sauces', 'Spices', 'Cleaning', 'Stationery', 'Pet Food'
]

locations = []
aisles = [f"A{str(i).zfill(2)}" for i in range(1, 22)]
y_coord = 1
loc_idx = 1
for i, dept in enumerate(departments):
    aisle_id = aisles[i]
    for shelf_num in range(1, 6): # 5 shelves per aisle
        locations.append({
            'location_id': f"L{str(loc_idx).zfill(3)}",
            'aisle_id': aisle_id,
            'aisle_name': f"Aisle {aisle_id[1:]}",
            'shelf_id': f"S{str(shelf_num).zfill(2)}",
            'shelf_name': f"Shelf {shelf_num}",
            'x_coordinate': i + 1,
            'y_coordinate': y_coord + shelf_num,
            'department': dept,
            'location_description': f"{dept} section"
        })
        loc_idx += 1
df_locations = pd.DataFrame(locations)
df_locations.to_csv(os.path.join(DATASET_DIR, 'store_locations.csv'), index=False)

print("Generating Store Graph...")
# Connect locations
graph_edges = []
node_id = 1
for i in range(len(locations) - 1):
    # Connect adjacent shelves in the same aisle
    if locations[i]['aisle_id'] == locations[i+1]['aisle_id']:
        graph_edges.append({
            'node_id': node_id,
            'from_node': locations[i]['location_id'],
            'to_node': locations[i+1]['location_id'],
            'distance': 1.0
        })
        node_id += 1
    # Connect front of aisles
    if i % 5 == 0 and i + 5 < len(locations):
        graph_edges.append({
            'node_id': node_id,
            'from_node': locations[i]['location_id'],
            'to_node': locations[i+5]['location_id'],
            'distance': 5.0
        })
        node_id += 1

# Add Entrance and Checkout
graph_edges.append({'node_id': node_id, 'from_node': 'Entrance', 'to_node': 'L001', 'distance': 10.0}); node_id += 1
graph_edges.append({'node_id': node_id, 'from_node': 'L105', 'to_node': 'Checkout', 'distance': 10.0}); node_id += 1

df_graph = pd.DataFrame(graph_edges)
df_graph.to_csv(os.path.join(DATASET_DIR, 'store_graph.csv'), index=False)

# 2. PRODUCTS
print("Generating Products...")
# Define realistic product data generators based on departments
product_templates = {
    'Dairy': [('Milk', '1L', 350, 450), ('Butter', '200g', 600, 750), ('Cheese', '250g', 800, 1000), ('Yogurt', '80g', 50, 70)],
    'Bakery': [('Bread', '500g', 150, 200), ('Buns', '4pcs', 120, 160), ('Croissant', '2pcs', 200, 300), ('Cake', '1kg', 1200, 1600)],
    'Beverages': [('Soft Drink', '1.5L', 250, 350), ('Juice', '1L', 400, 500), ('Water', '1L', 60, 80), ('Energy Drink', '250ml', 300, 400)],
    'Snacks': [('Biscuits', '200g', 100, 150), ('Potato Chips', '50g', 150, 200), ('Chocolate', '100g', 250, 350), ('Nuts', '100g', 400, 600)],
    'Rice & Grains': [('Basmati Rice', '1kg', 600, 800), ('Red Rice', '1kg', 150, 220), ('White Rice', '1kg', 140, 200), ('Dhal', '1kg', 250, 350)],
    'Cleaning': [('Dishwashing Liquid', '500ml', 200, 280), ('Laundry Detergent', '1kg', 400, 600), ('Floor Cleaner', '1L', 300, 450)],
    'Personal Care': [('Shampoo', '200ml', 300, 450), ('Soap', '100g', 80, 120), ('Toothpaste', '120g', 150, 200), ('Deodorant', '150ml', 500, 700)],
    'Vegetables': [('Carrot', '500g', 100, 150), ('Potato', '1kg', 150, 200), ('Onion', '1kg', 200, 300), ('Tomato', '500g', 150, 250)],
    'Fruits': [('Apple', '1kg', 800, 1200), ('Banana', '1kg', 150, 200), ('Orange', '1kg', 700, 1000), ('Grapes', '500g', 600, 900)]
}

brands = ['BrandA', 'BrandB', 'BrandC', 'FreshFarms', 'PureLife', 'Glow', 'CleanPlus', 'DailyChoice', 'NatureBites', 'HealthyO']

products = []
product_categories = {}
product_id_to_price = {}

for i in range(1, NUM_PRODUCTS + 1):
    pid = f"P{str(i).zfill(4)}"
    dept = random.choice(departments)
    loc = random.choice([l for l in locations if l['department'] == dept])
    
    if dept in product_templates:
        base_name, weight, cost_base, price_base = random.choice(product_templates[dept])
        brand = random.choice(brands)
        name = f"{brand} {base_name} {weight} - Var {i}"
        cost = random.randint(cost_base, cost_base + 50)
        price = random.randint(price_base, price_base + 100)
    else:
        brand = random.choice(brands)
        name = f"{brand} {dept} Item {i}"
        weight = f"{random.choice([100, 200, 500])}{random.choice(['g', 'ml'])}"
        cost = random.randint(100, 500)
        price = cost + random.randint(50, 200)

    cat = dept
    subcat = f"Sub {dept}"
    
    products.append({
        'product_id': pid,
        'sku': f"SKU-{pid}",
        'product_name': name,
        'brand': brand,
        'category': cat,
        'subcategory': subcat,
        'description': f"High quality {name}",
        'unit': 'pcs',
        'weight_or_volume': weight,
        'price': price,
        'cost_price': cost,
        'stock_quantity': random.randint(10, 500),
        'minimum_stock': random.randint(5, 20),
        'aisle_id': loc['aisle_id'],
        'shelf_id': loc['shelf_id'],
        'location_id': loc['location_id'],
        'barcode': fake.ean13(),
        'image_class': name.lower().replace(' ', '_').replace('-', '').replace('__', '_'),
        'status': 'ACTIVE'
    })
    product_categories[pid] = cat
    product_id_to_price[pid] = price

df_products = pd.DataFrame(products)
df_products.to_csv(os.path.join(DATASET_DIR, 'products.csv'), index=False)

# 3. INVENTORY
print("Generating Inventory...")
inventory = []
for i, p in enumerate(products):
    inventory.append({
        'inventory_id': f"INV{str(i+1).zfill(4)}",
        'product_id': p['product_id'],
        'stock_quantity': p['stock_quantity'],
        'reserved_quantity': random.randint(0, 5),
        'reorder_level': p['minimum_stock'],
        'stock_status': 'IN_STOCK' if int(p['stock_quantity']) > 10 else ('LOW_STOCK' if int(p['stock_quantity']) > 0 else 'OUT_OF_STOCK'),
        'last_restock_date': fake.date_between(start_date='-30d', end_date='today').isoformat()
    })
df_inventory = pd.DataFrame(inventory)
df_inventory.to_csv(os.path.join(DATASET_DIR, 'inventory.csv'), index=False)

# 4. DISCOUNTS
print("Generating Discounts...")
discounts = []
for i in range(1, NUM_DISCOUNTS + 1):
    pid = random.choice(products)['product_id']
    orig_price = product_id_to_price[str(pid)]
    disc_pct = random.choice([5, 10, 15, 20, 25, 30])
    disc_price = round(orig_price * (1 - disc_pct / 100), 2)
    start_date = fake.date_between(start_date='-1y', end_date='today')
    end_date = start_date + timedelta(days=random.randint(7, 30))
    active = 'YES' if end_date >= datetime.now().date() else 'NO'
    
    discounts.append({
        'discount_id': f"D{str(i).zfill(5)}",
        'product_id': pid,
        'discount_type': 'PERCENTAGE',
        'discount_percentage': disc_pct,
        'original_price': orig_price,
        'discount_price': disc_price,
        'start_date': start_date.isoformat(),
        'end_date': end_date.isoformat(),
        'campaign_name': f"Promo {start_date.month}/{start_date.year}",
        'active': active
    })
df_discounts = pd.DataFrame(discounts)
df_discounts.to_csv(os.path.join(DATASET_DIR, 'discounts.csv'), index=False)

# 5. CUSTOMERS
print("Generating Customers...")
customers = []
segments = ['Budget', 'Premium', 'Regular', 'Occasional']
for i in range(1, NUM_CUSTOMERS + 1):
    customers.append({
        'customer_id': f"C{str(i).zfill(4)}",
        'customer_code': str(uuid.uuid4())[:8].upper(),
        'age_group': random.choice(['18-24', '25-34', '35-44', '45-54', '55+']),
        'city': random.choice(['Colombo', 'Kandy', 'Galle', 'Negombo', 'Moratuwa']),
        'preferred_category': random.choice(departments),
        'average_monthly_budget': random.randint(10000, 50000),
        'shopping_frequency': random.choice(['Weekly', 'Bi-Weekly', 'Monthly']),
        'customer_segment': random.choice(segments)
    })
df_customers = pd.DataFrame(customers)
df_customers.to_csv(os.path.join(DATASET_DIR, 'customers.csv'), index=False)

# 6. TRANSACTIONS & ITEMS
print("Generating Transactions and Items...")
transactions = []
transaction_items = []
t_item_id = 1

# Helper for bundle logic
bundles = {
    'Breakfast': [p for p in products if p['category'] in ['Bakery', 'Dairy', 'Breakfast']],
    'Cleaning': [p for p in products if p['category'] in ['Cleaning', 'Household']],
    'Snacks': [p for p in products if p['category'] in ['Snacks', 'Beverages']],
    'Cooking': [p for p in products if p['category'] in ['Rice & Grains', 'Spices', 'Sauces', 'Vegetables']]
}

for i in range(1, NUM_TRANSACTIONS + 1):
    tid = f"T{str(i).zfill(6)}"
    cid = random.choice(customers)['customer_id']
    t_date = fake.date_time_between(start_date='-1y', end_date='now')
    
    # Decide bundle type
    bundle_type = random.choice(list(bundles.keys()))
    pool = bundles[bundle_type]
    if not pool: pool = products
    
    num_items = random.randint(1, 10)
    selected_products = random.sample(pool, min(num_items, len(pool)))
    
    subtotal = 0
    t_discount = 0
    
    for sp in selected_products:
        pid = sp['product_id']
        qty = random.randint(1, 5)
        u_price = sp['price']
        
        # Check active discount
        active_discounts = [d for d in discounts if d['product_id'] == pid and d['active'] == 'YES']
        if active_discounts:
            disc_pct = active_discounts[0]['discount_percentage']
        else:
            disc_pct = 0
            
        line_tot = float(qty) * float(u_price)
        disc_amt = (line_tot * float(disc_pct)) / 100.0
        final_line_tot = line_tot - disc_amt
        
        subtotal += line_tot
        t_discount += disc_amt
        
        transaction_items.append({
            'transaction_item_id': f"TI{str(t_item_id).zfill(7)}",
            'transaction_id': tid,
            'product_id': pid,
            'quantity': qty,
            'unit_price': u_price,
            'discount_percentage': disc_pct,
            'line_total': round(final_line_tot, 2)
        })
        t_item_id += 1
        
    transactions.append({
        'transaction_id': tid,
        'customer_id': cid,
        'transaction_date': t_date.isoformat(),
        'subtotal': round(subtotal, 2),
        'discount_amount': round(t_discount, 2),
        'total_amount': round(subtotal - t_discount, 2),
        'payment_method': random.choice(['CARD', 'CASH', 'MOBILE_PAY'])
    })

df_trans = pd.DataFrame(transactions)
df_trans.to_csv(os.path.join(DATASET_DIR, 'transactions.csv'), index=False)

df_trans_items = pd.DataFrame(transaction_items)
df_trans_items.to_csv(os.path.join(DATASET_DIR, 'transaction_items.csv'), index=False)

# 7. PRODUCT IMAGES & DIRS
print("Generating Product Images...")
product_images = []
img_id = 1
view_types = ['front', 'back', 'left', 'right', 'angled']
lightings = ['normal', 'bright', 'dim']
backgrounds = ['store', 'white', 'shelf']

for p in products:
    pid = p['product_id']
    cls = p['image_class']
    
    # Create dir for this product
    prod_img_dir = os.path.join(IMAGES_DIR, str(pid))
    os.makedirs(prod_img_dir, exist_ok=True)
    
    num_imgs = random.randint(5, 10)
    for i in range(1, num_imgs + 1):
        v = random.choice(view_types)
        split = np.random.choice(['train', 'val', 'test'], p=[0.7, 0.2, 0.1])
        fname = f"{pid}_{v}_{str(i).zfill(3)}.jpg"
        
        product_images.append({
            'image_id': f"IMG{str(img_id).zfill(6)}",
            'product_id': pid,
            'image_class': cls,
            'image_filename': fname,
            'image_path': f"images/{pid}/{fname}",
            'view_type': v,
            'lighting': random.choice(lightings),
            'background': random.choice(backgrounds),
            'augmentation_type': 'none',
            'split': split
        })
        img_id += 1

df_images = pd.DataFrame(product_images)
df_images.to_csv(os.path.join(DATASET_DIR, 'product_images.csv'), index=False)

# 8. AI PRODUCT LABELS
print("Generating AI Labels...")
ai_labels = []
for idx, p in enumerate(products):
    ai_labels.append({
        'label_id': f"L{str(idx+1).zfill(4)}",
        'product_id': p['product_id'],
        'class_id': idx,
        'class_name': p['image_class'],
        'display_name': p['product_name'],
        'confidence_threshold': 0.70,
        'image_folder': f"images/{p['product_id']}",
        'yolo_class_id': idx
    })
df_labels = pd.DataFrame(ai_labels)
df_labels.to_csv(os.path.join(DATASET_DIR, 'ai_product_labels.csv'), index=False)

# Generate small dataset metadata
high_priority_products = products[:100]
print("Generating small AI dataset metadata...")
for p in high_priority_products:
    os.makedirs(os.path.join(AI_DATASET_SMALL_DIR, str(p['product_id'])), exist_ok=True)
    
# Generate YOLO yaml
yolo_yaml_content = f"""path: ../dataset/images
train: train
val: val
test: test
nc: {len(products)}
names: {df_labels['class_name'].tolist()}
"""
with open(os.path.join(DATASET_DIR, 'data.yaml'), 'w') as f:
    f.write(yolo_yaml_content)

with open(os.path.join(AI_DATASET_SMALL_DIR, 'README.md'), 'w') as f:
    f.write("# Small AI Dataset\n\nThis directory is intended for training a smaller YOLO model with ~100 classes. This is highly recommended for an initial student project to avoid the massive computational overhead of 2000 classes.")

# 9. SHOPPING HISTORY
print("Generating Shopping History...")
history = []
hist_id = 1
for cid in df_customers['customer_id']:
    # Get all transactions for customer
    c_trans = df_trans[df_trans['customer_id'] == cid]['transaction_id'].tolist()
    if c_trans:
        c_items = df_trans_items[df_trans_items['transaction_id'].isin(c_trans)]
        prod_counts = c_items.groupby('product_id').agg(
            purchase_count=('quantity', 'count'),
            average_quantity=('quantity', 'mean'),
            average_spending=('line_total', 'mean')
        ).reset_index()
        
        for _, row in prod_counts.iterrows():
            history.append({
                'history_id': f"H{str(hist_id).zfill(6)}",
                'customer_id': cid,
                'product_id': row['product_id'],
                'purchase_count': row['purchase_count'],
                'last_purchase_date': fake.date_between(start_date='-6m', end_date='today').isoformat(),
                'average_quantity': round(row['average_quantity'], 2),
                'average_spending': round(row['average_spending'], 2)
            })
            hist_id += 1

df_history = pd.DataFrame(history)
df_history.to_csv(os.path.join(DATASET_DIR, 'shopping_history.csv'), index=False)

# 10. PRODUCT RELATIONSHIPS
print("Generating Product Relationships...")
relationships = []
rel_id = 1
for b_name, b_items in bundles.items():
    if len(b_items) > 1:
        for i in range(min(50, len(b_items))):
            p_a = random.choice(b_items)
            p_b = random.choice(b_items)
            if p_a != p_b:
                relationships.append({
                    'relationship_id': f"R{str(rel_id).zfill(5)}",
                    'product_a': p_a['product_id'],
                    'product_b': p_b['product_id'],
                    'co_purchase_count': random.randint(10, 500),
                    'support': round(random.uniform(0.01, 0.1), 4),
                    'confidence': round(random.uniform(0.2, 0.8), 4),
                    'lift': round(random.uniform(1.1, 5.0), 2),
                    'relationship_type': 'CO_PURCHASE'
                })
                rel_id += 1
df_rels = pd.DataFrame(relationships)
df_rels.to_csv(os.path.join(DATASET_DIR, 'product_relationships.csv'), index=False)

# 11. CART TEST CASES
print("Generating Cart Test Cases...")
cart_tests = [
    {'test_case_id': 'TC_01', 'customer_id': 'C0001', 'budget': 5000, 'product_id': 'P0001', 'quantity': 2, 'expected_total': 0, 'expected_remaining_budget': 0, 'expected_status': 'NORMAL'},
    {'test_case_id': 'TC_02', 'customer_id': 'C0002', 'budget': 100, 'product_id': 'P0005', 'quantity': 10, 'expected_total': 0, 'expected_remaining_budget': 0, 'expected_status': 'EXCEEDED'},
    {'test_case_id': 'TC_03', 'customer_id': 'C0003', 'budget': 2000, 'product_id': 'P0010', 'quantity': 1, 'expected_total': 0, 'expected_remaining_budget': 0, 'expected_status': 'DISCOUNTED'},
    {'test_case_id': 'TC_04', 'customer_id': 'C0004', 'budget': 1000, 'product_id': 'P0020', 'quantity': 1, 'expected_total': 0, 'expected_remaining_budget': 0, 'expected_status': 'OUT_OF_STOCK'}
]
# We will just fill mock values for expected_total since it's a test data spec
for tc in cart_tests:
    pid = tc['product_id']
    if pid in product_id_to_price:
        p = product_id_to_price[pid]
        tc['expected_total'] = p * tc['quantity']
        tc['expected_remaining_budget'] = float(tc['budget']) - float(tc['expected_total']) # type: ignore
df_tests = pd.DataFrame(cart_tests)
df_tests.to_csv(os.path.join(DATASET_DIR, 'cart_test_cases.csv'), index=False)

# 12. SAMPLE AI TEST IMAGES
print("Generating Sample AI Test Images...")
for p in high_priority_products[:50]:
    pid = p['product_id']
    for i in range(1, 3):
        fname = f"{pid}_test_{str(i).zfill(2)}.jpg"
        # We don't create real images, just touch a metadata file or explain
        pass
with open(os.path.join(SAMPLE_AI_TEST_DIR, 'README.md'), 'w') as f:
    f.write("# Sample AI Test Images\nPlace your real test images here named like P0001_test_01.jpg")

# 13. GENERATE SQL DATABASE SCHEMA
print("Generating SQL Database Schema...")
sql_content = """-- ShopMate Database Schema
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
"""
with open(os.path.join(DB_DIR, 'shopmate.sql'), 'w') as f:
    f.write(sql_content)

print("Dataset generation completed successfully.")
