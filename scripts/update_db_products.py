import sqlite3

for p in ['backend/shopmate.db', 'shopmate.db']:
    conn = sqlite3.connect(p)
    c = conn.cursor()
    c.execute("UPDATE products SET product_name = 'Astra Fat Spread 250g', brand = 'Astra' WHERE product_id = 10000")
    c.execute("INSERT OR REPLACE INTO products (product_id, shop_id, category_id, subcategory_id, product_name, brand, weight, normal_price, discount_id, discount_price, discount_percentage, priority_score) VALUES (10002, 1, 1, NULL, 'Meadowlea Fat Spread 100g', 'Meadowlea', NULL, 220, NULL, NULL, NULL, 5)")
    conn.commit()
    c.execute('SELECT product_id, product_name, brand, normal_price FROM products WHERE product_id IN (9999, 10000, 10001, 10002)')
    print(p, c.fetchall())
print('Updated databases successfully!')
