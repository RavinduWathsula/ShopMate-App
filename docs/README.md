# ShopMate Dataset

This dataset is designed for the ShopMate AI-Based Smart Shopping and Budget Decision-Support System project.

## 1. Dataset Purpose
The dataset provides a complete, realistic, connected database for developing and testing the ShopMate application. It includes structured data for products, customers, store layout, inventory, and transactions. Furthermore, it supports computer vision AI features by providing image metadata and YOLO object detection configurations.

## 2. CSV Files Included
* **products.csv**: Core product catalog.
* **customers.csv**: Synthetic customer demographics.
* **transactions.csv**: Header records for purchases.
* **transaction_items.csv**: Line-items of transactions mapping to products.
* **discounts.csv**: Active and historical discounts.
* **shopping_history.csv**: Aggregated past purchases per customer.
* **product_images.csv**: Metadata and expected file paths for product images.
* **ai_product_labels.csv**: Stable mapping for AI classes for object detection.
* **inventory.csv**: Stock levels and restocking details.
* **store_locations.csv**: Shelf/Aisle grid layout of the store.
* **store_graph.csv**: Node connections in the store to calculate shortest path.
* **product_relationships.csv**: Co-purchase frequencies (Apriori pattern analysis).
* **cart_test_cases.csv**: Scenarios for UI/UX cart logic testing.

## 3. Database Relationships
* `transaction_items` references `transactions` and `products`.
* `transactions` references `customers`.
* `discounts`, `inventory`, `product_images`, and `ai_product_labels` reference `products`.
* `products` reference `store_locations`.

## 4. How to Generate the Dataset
Run the python script to regenerate the dataset from scratch:
```bash
python scripts/generate_dataset.py
```
This uses a fixed random seed (42) to ensure reproducibility. 

## 5. How to Validate the Dataset
Run the data validation script to ensure data integrity:
```bash
python scripts/validate_dataset.py
```

## 6. How to Import it into MySQL
1. Ensure MySQL is running on your system.
2. Open your MySQL client or terminal.
3. Source the SQL file generated:
   ```sql
   SOURCE database/shopmate.sql;
   ```
4. Then load the CSV data using `LOAD DATA INFILE` statements or a tool like MySQL Workbench/DBeaver. The tables strictly match the CSV column structure.

## 7. How the Dataset Supports AI
* The dataset simulates a small YOLO object detection task inside `dataset/ai_dataset_small/`.
* `ai_product_labels.csv` maps every `product_id` to an integer class used for ML training.
* The structure provides train/val/test splits in `product_images.csv`.

## 8. How the Image Recognition System Will Work
1. The user uses the Flutter App to take a photo of an item.
2. The image is passed to a FastAPI endpoint (e.g., `/api/ai/identify`).
3. The YOLO model returns an integer `class_id`.
4. FastAPI queries the database (mapping `class_id` to `product_id`).
5. FastAPI fetches the product details (price, stock, location).
6. FastAPI returns JSON to the Flutter App, which displays "Add to Cart" with exact pricing.

## 9. How Flutter Connects
Flutter acts as the presentation layer. It will use the `http` package in Dart to communicate with the FastAPI backend. FastAPI will manage MySQL queries using an ORM like SQLAlchemy, retrieving consistent dataset parameters based on this synthetic data structure.
