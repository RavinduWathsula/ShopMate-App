import os
import pandas as pd

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATASET_DIR = os.path.join(BASE_DIR, 'dataset')

def validate_dataset():
    print("## DATASET VALIDATION\n")
    
    # Load all CSVs
    try:
        df_products = pd.read_csv(os.path.join(DATASET_DIR, 'products.csv'))
        df_customers = pd.read_csv(os.path.join(DATASET_DIR, 'customers.csv'))
        df_transactions = pd.read_csv(os.path.join(DATASET_DIR, 'transactions.csv'))
        df_items = pd.read_csv(os.path.join(DATASET_DIR, 'transaction_items.csv'))
        df_discounts = pd.read_csv(os.path.join(DATASET_DIR, 'discounts.csv'))
        df_locations = pd.read_csv(os.path.join(DATASET_DIR, 'store_locations.csv'))
        df_inventory = pd.read_csv(os.path.join(DATASET_DIR, 'inventory.csv'))
        df_images = pd.read_csv(os.path.join(DATASET_DIR, 'product_images.csv'))
        df_labels = pd.read_csv(os.path.join(DATASET_DIR, 'ai_product_labels.csv'))
    except Exception as e:
        print(f"Error loading datasets: {e}")
        return

    # Basic counts
    print(f"Products: {len(df_products)} OK")
    print(f"Customers: {len(df_customers)} OK")
    print(f"Transactions: {len(df_transactions)} OK")
    print(f"Transaction Items: {len(df_items)} OK")
    print(f"Discounts: {len(df_discounts)} OK")

    # 1. Duplicate product IDs
    dup_products = df_products['product_id'].duplicated().sum()
    print(f"Duplicate Product IDs: {dup_products} {'OK' if dup_products == 0 else 'FAIL'}")

    # 2. Broken Foreign Keys - Transactions to Customers
    missing_customers = df_transactions[~df_transactions['customer_id'].isin(df_customers['customer_id'])]
    print(f"Broken Customer IDs in Transactions: {len(missing_customers)} {'OK' if len(missing_customers) == 0 else 'FAIL'}")

    # 3. Broken Foreign Keys - Items to Transactions
    missing_trans = df_items[~df_items['transaction_id'].isin(df_transactions['transaction_id'])]
    print(f"Broken Transaction IDs in Items: {len(missing_trans)} {'OK' if len(missing_trans) == 0 else 'FAIL'}")

    # 4. Broken Foreign Keys - Items to Products
    missing_prods = df_items[~df_items['product_id'].isin(df_products['product_id'])]
    print(f"Broken Product IDs in Items: {len(missing_prods)} {'OK' if len(missing_prods) == 0 else 'FAIL'}")

    # 5. Invalid Prices
    invalid_prices = df_products[df_products['price'] <= 0]
    print(f"Invalid Prices: {len(invalid_prices)} {'OK' if len(invalid_prices) == 0 else 'FAIL'}")

    # 6. Negative stock
    negative_stock = df_products[df_products['stock_quantity'] < 0]
    print(f"Negative Stock in Products: {len(negative_stock)} {'OK' if len(negative_stock) == 0 else 'FAIL'}")

    # 7. Discount calculations
    df_disc_check = df_discounts.copy()
    df_disc_check['calc_price'] = round(df_disc_check['original_price'] * (1 - df_disc_check['discount_percentage']/100), 2)
    invalid_discounts = df_disc_check[df_disc_check['calc_price'] != df_disc_check['discount_price']]
    print(f"Invalid Discount Calculations: {len(invalid_discounts)} {'OK' if len(invalid_discounts) == 0 else 'FAIL'}")

    # 8. Missing AI Classes
    missing_labels = df_products[~df_products['product_id'].isin(df_labels['product_id'])]
    print(f"Missing AI Classes for Products: {len(missing_labels)} {'OK' if len(missing_labels) == 0 else 'FAIL'}")

    # 9. Invalid Store Locations
    invalid_locations = df_products[~df_products['location_id'].isin(df_locations['location_id'])]
    print(f"Invalid Store Locations in Products: {len(invalid_locations)} {'OK' if len(invalid_locations) == 0 else 'FAIL'}")

    # 10. Missing Image Metadata
    missing_images = df_products[~df_products['product_id'].isin(df_images['product_id'])]
    print(f"Products Missing Image Metadata: {len(missing_images)} {'OK' if len(missing_images) == 0 else 'FAIL'}")

    print("\nValidation Complete.")

if __name__ == '__main__':
    validate_dataset()
