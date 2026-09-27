import os
import pandas as pd
import numpy as np
from PIL import Image
import random
import shutil

def setup_yolo_dataset(csv_path="dataset/ai_product_labels.csv", output_dir="dataset/yolo"):
    if not os.path.exists(csv_path):
        print(f"Error: {csv_path} not found.")
        return
        
    df = pd.read_csv(csv_path)
    
    # Create directories
    for split in ['train', 'val']:
        os.makedirs(os.path.join(output_dir, 'images', split), exist_ok=True)
        os.makedirs(os.path.join(output_dir, 'labels', split), exist_ok=True)
        
    print(f"Generating YOLO dataset for {len(df)} products...")
    
    # For each product, create a dummy image and label
    for index, row in df.iterrows():
        yolo_class_id = row['yolo_class_id']
        product_id = row['product_id']
        
        # 80% train, 20% val
        split = 'train' if random.random() < 0.8 else 'val'
        
        # Generate dummy image
        img = Image.new('RGB', (416, 416), color=(random.randint(0, 255), random.randint(0, 255), random.randint(0, 255)))
        img_filename = f"{product_id}_{index}.jpg"
        img_path = os.path.join(output_dir, 'images', split, img_filename)
        img.save(img_path)
        
        # Generate dummy YOLO label (class_id center_x center_y width height)
        label_filename = f"{product_id}_{index}.txt"
        label_path = os.path.join(output_dir, 'labels', split, label_filename)
        
        # Random bounding box
        w, h = random.uniform(0.1, 0.9), random.uniform(0.1, 0.9)
        cx, cy = random.uniform(w/2, 1-w/2), random.uniform(h/2, 1-h/2)
        
        with open(label_path, 'w') as f:
            f.write(f"{yolo_class_id} {cx:.4f} {cy:.4f} {w:.4f} {h:.4f}\n")
            
        if (index + 1) % 200 == 0:
            print(f"Processed {index + 1} / {len(df)} products")

    # Generate data.yaml for YOLO
    yaml_content = f"""path: {os.path.abspath(output_dir).replace('\\', '/')}
train: images/train
val: images/val
nc: {df['yolo_class_id'].nunique()}
names: {df['class_name'].tolist()}
"""
    with open(os.path.join(output_dir, 'data.yaml'), 'w') as f:
        f.write(yaml_content)

    print(f"Dataset generated at {output_dir}")

if __name__ == "__main__":
    # Ensure run from root
    root_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    os.chdir(root_dir)
    setup_yolo_dataset()
