import os
import shutil
import cv2
import random

def import_images():
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    input_dir = os.path.join(base_dir, 'my_pictures')
    
    output_dir = os.path.join(base_dir, 'dataset', 'yolo')
    images_dir = os.path.join(output_dir, 'images')
    labels_dir = os.path.join(output_dir, 'labels')
    
    # Class mapping matching our YOLO dataset
    # Maps lowercase folder keywords to (class_id, class_name)
    class_rules = [
        (["toothpaste"], 0, "toothpaste"),
        (["astra"], 1, "astra"),
        (["sprite"], 2, "sprite"),
        (["calin", "soap"], 3, "calin_soap"),
    ]
    
    # Standard subdirectories in my_pictures
    subdirs = ["toothpaste", "astra", "sprite", "Calin Soap"]
    
    # If the folder doesn't exist, create it and tell the user
    if not os.path.exists(input_dir):
        os.makedirs(input_dir)
        for s in subdirs:
            os.makedirs(os.path.join(input_dir, s), exist_ok=True)
        print(f"\n[SETUP] I just created a new folder called 'my_pictures' in your project root!")
        print("1. Open the 'my_pictures' folder.")
        print("2. Copy your photos of toothpaste into the 'toothpaste' folder.")
        print("3. Copy your photos of Astra into the 'astra' folder.")
        print("4. Copy your photos of Sprite into the 'sprite' folder.")
        print("5. Copy your photos of Calin Teen Soap into the 'Calin Soap' folder.")
        print("6. Run this script again when you are done!\n")
        return
    else:
        for s in subdirs:
            os.makedirs(os.path.join(input_dir, s), exist_ok=True)

    # Process the images if they exist
    processed = 0
    for entry in os.listdir(input_dir):
        folder_path = os.path.join(input_dir, entry)
        if not os.path.isdir(folder_path):
            continue
        
        folder_lower = entry.lower()
        matched_class = None
        for keywords, cid, cname in class_rules:
            if any(k in folder_lower for k in keywords):
                matched_class = (cid, cname)
                break
                
        if not matched_class:
            print(f"Skipping unknown folder: {entry}")
            continue
            
        class_id, class_name = matched_class
        
        for file in os.listdir(folder_path):
            if file.lower().endswith(('.png', '.jpg', '.jpeg', '.webp')):
                img_path = os.path.join(folder_path, file)
                
                # Split into train/val
                split = 'train' if random.random() < 0.8 else 'val'
                os.makedirs(os.path.join(images_dir, split), exist_ok=True)
                os.makedirs(os.path.join(labels_dir, split), exist_ok=True)
                
                # Read image to verify and get dimensions
                img = cv2.imread(img_path)
                if img is None: continue
                
                # New standardized filename
                img_id = random.randint(10000, 99999)
                new_name = f"{class_name}_{img_id}"
                
                # Copy the image to the YOLO dataset folder
                shutil.copy(img_path, os.path.join(images_dir, split, f"{new_name}.jpg"))
                
                # Auto-generate a YOLO label!
                # We assume the item is in the center taking up about 60% of the image.
                cx, cy, bw, bh = 0.5, 0.5, 0.6, 0.6
                
                with open(os.path.join(labels_dir, split, f"{new_name}.txt"), 'w') as f:
                    f.write(f"{class_id} {cx:.6f} {cy:.6f} {bw:.6f} {bh:.6f}\n")
                
                processed += 1
                print(f"Imported {file} from '{entry}' as class {class_id} ({class_name}) into {split}")
                
    if processed > 0:
        print(f"\nSUCCESS! Automatically imported and labeled {processed} images!")
        print("You can now train your AI by running: python scripts/train_yolo.py")
    else:
        print("\nNo images found. Please put your .jpg or .png files into the subfolders inside 'my_pictures'!")

if __name__ == "__main__":
    import_images()
