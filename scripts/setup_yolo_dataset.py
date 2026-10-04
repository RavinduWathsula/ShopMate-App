import os
import pandas as pd
import numpy as np
from PIL import Image
import random
import shutil

def setup_yolo_dataset(csv_path="dataset/ai_product_labels.csv", output_dir="dataset/yolo"):
    # We no longer need the CSV, using custom items for the assignment
    # Create directories
    for split in ['train', 'val']:
        os.makedirs(os.path.join(output_dir, 'images', split), exist_ok=True)
        os.makedirs(os.path.join(output_dir, 'labels', split), exist_ok=True)
        
    # User requested specific items for their assignment
    target_items = [
        "Toothpaste",
        "Astra Cup",
        "Sprite Bottle Mini"
    ]
    
    # Create a custom dataframe for these 3 items
    df = pd.DataFrame({
        'display_name': target_items,
        'yolo_class_id': [0, 1, 2],
        'product_id': ['P_TOOTHPASTE', 'P_ASTRA', 'P_SPRITE']
    })
        
    print(f"Generating YOLO dataset for {len(df)} products (3 classes)...")
    
    # Generate 50 dummy images for each product to have enough data for a quick train
    for index, row in df.iterrows():
        yolo_class_id = row['yolo_class_id']
        product_id = row['product_id']
        
        for i in range(50):
            # 80% train, 20% val
            split = 'train' if random.random() < 0.8 else 'val'
            
            # Generate dummy image
            img = Image.new('RGB', (416, 416), color=(random.randint(0, 255), random.randint(0, 255), random.randint(0, 255)))
            img_filename = f"{product_id}_{i}.jpg"
            img_path = os.path.join(output_dir, 'images', split, img_filename)
            img.save(img_path)
            
            # Generate dummy YOLO label (class_id center_x center_y width height)
            label_filename = f"{product_id}_{i}.txt"
            label_path = os.path.join(output_dir, 'labels', split, label_filename)
            
            # Random bounding box
            w, h = random.uniform(0.1, 0.9), random.uniform(0.1, 0.9)
            cx, cy = random.uniform(w/2, 1-w/2), random.uniform(h/2, 1-h/2)
            
            with open(label_path, 'w') as f:
                f.write(f"{yolo_class_id} {cx:.4f} {cy:.4f} {w:.4f} {h:.4f}\n")
                
        print(f"Processed 50 images for {row['display_name']}")

    # Generate data.yaml for YOLO
    yaml_content = f"""path: {os.path.abspath(output_dir).replace('\\', '/')}
train: images/train
val: images/val
nc: 3
names: {target_items}
"""
    with open(os.path.join(output_dir, 'data.yaml'), 'w') as f:
        f.write(yaml_content)

    print(f"Dataset generated at {output_dir}")

if __name__ == "__main__":
    # Ensure run from root
    root_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    os.chdir(root_dir)
    setup_yolo_dataset()
