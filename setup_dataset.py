import os

base_dir = "dataset"
subdirs = ["raw", "processed", "train", "validation", "test"]

from PIL import Image, ImageDraw, ImageFont

# Create main directories
for subdir in subdirs:
    os.makedirs(os.path.join(base_dir, subdir), exist_ok=True)

# Create 30 product folders in 'raw' with valid .jpg placeholder images
raw_dir = os.path.join(base_dir, "raw")
for i in range(1, 31):
    product_dir = os.path.join(raw_dir, f"product_{i:03d}")
    os.makedirs(product_dir, exist_ok=True)
    
    # Create valid placeholder .jpg files
    for j in range(1, 4):
        placeholder_path = os.path.join(product_dir, f"image{j:03d}.jpg")
        
        # Create a simple image with a solid color and text
        img = Image.new('RGB', (400, 400), color = (73, 109, 137))
        d = ImageDraw.Draw(img)
        d.text((50, 180), f"Product {i:03d}\nImage {j:03d}", fill=(255, 255, 0))
        img.save(placeholder_path)

print("Dataset directory structure and 30 folders with actual .jpg placeholder images created successfully.")
