import cv2
import os
import random

def collect_data():
    output_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'dataset', 'yolo'))
    images_dir = os.path.join(output_dir, 'images', 'train')
    labels_dir = os.path.join(output_dir, 'labels', 'train')
    
    os.makedirs(images_dir, exist_ok=True)
    os.makedirs(labels_dir, exist_ok=True)
    
    items = {
        ord('1'): (0, "Toothpaste"),
        ord('2'): (1, "Astra Cup"),
        ord('3'): (2, "Sprite Bottle Mini")
    }
    
    cap = cv2.VideoCapture(0)
    if not cap.isOpened():
        print("Error: Could not open webcam.")
        return
        
    print("--- SHOPMATE DATASET COLLECTOR ---")
    print("Position your physical item inside the GREEN BOX.")
    print("Press '1' to capture a picture of Toothpaste")
    print("Press '2' to capture a picture of Astra Cup")
    print("Press '3' to capture a picture of Sprite Bottle Mini")
    print("Press 'q' to quit when you have enough pictures (e.g., 10-20 per item).")
    
    count = {0: 0, 1: 0, 2: 0}
    
    while True:
        success, frame = cap.read()
        if not success: break
        
        # Draw a guide box in the center
        h, w = frame.shape[:2]
        box_size = int(min(h, w) * 0.5)
        x1 = int((w - box_size) / 2)
        y1 = int((h - box_size) / 2)
        x2 = x1 + box_size
        y2 = y1 + box_size
        
        display_frame = frame.copy()
        cv2.rectangle(display_frame, (x1, y1), (x2, y2), (0, 255, 0), 2)
        cv2.putText(display_frame, "Put item in this box", (x1, y1 - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 0), 2)
        
        cv2.imshow("Data Collector - Press 1, 2, or 3", display_frame)
        
        key = cv2.waitKey(1) & 0xFF
        if key == ord('q'):
            break
        elif key in items:
            class_id, name = items[key]
            
            # Randomly split 80% train, 20% val
            split = 'train' if random.random() < 0.8 else 'val'
            
            img_dir = os.path.join(output_dir, 'images', split)
            lbl_dir = os.path.join(output_dir, 'labels', split)
            os.makedirs(img_dir, exist_ok=True)
            os.makedirs(lbl_dir, exist_ok=True)
            
            # Save image
            img_id = random.randint(10000, 99999)
            filename = f"{name.replace(' ', '_')}_{img_id}"
            
            cv2.imwrite(os.path.join(img_dir, f"{filename}.jpg"), frame)
            
            # Save YOLO label (normalized cx, cy, w, h)
            # The bounding box is the guide box
            cx = (x1 + x2) / 2 / w
            cy = (y1 + y2) / 2 / h
            bw = box_size / w
            bh = box_size / h
            
            with open(os.path.join(lbl_dir, f"{filename}.txt"), 'w') as f:
                f.write(f"{class_id} {cx:.6f} {cy:.6f} {bw:.6f} {bh:.6f}\n")
                
            count[class_id] += 1
            print(f"Captured {name} into {split}! (Total for {name}: {count[class_id]})")

    cap.release()
    cv2.destroyAllWindows()
    print("Data collection finished! Now run scripts/train_yolo.py to train the AI.")

if __name__ == "__main__":
    collect_data()
