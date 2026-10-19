import cv2
import os
import random
import sys

def main():
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    my_pics_dir = os.path.join(base_dir, 'my_pictures', 'Calin Soap')
    yolo_dir = os.path.join(base_dir, 'dataset', 'yolo')
    
    os.makedirs(my_pics_dir, exist_ok=True)
    for split in ['train', 'val']:
        os.makedirs(os.path.join(yolo_dir, 'images', split), exist_ok=True)
        os.makedirs(os.path.join(yolo_dir, 'labels', split), exist_ok=True)

    class_id = 2
    class_name = "Calin Teen Soap"

    cap = cv2.VideoCapture(0)
    if not cap.isOpened():
        print("Error: Could not access webcam. Make sure no other application is using it.")
        return

    print("=" * 60)
    print("      SHOPMATE - CALIN TEEN SOAP CAMERA CAPTURE TOOL")
    print("=" * 60)
    print("Controls:")
    print("  [SPACE] or [C] : Snap a photo of Calin Teen Soap")
    print("  [Q] or [ESC]   : Finish and quit")
    print("=" * 60)

    count = 0

    while True:
        success, frame = cap.read()
        if not success:
            print("Failed to read frame from webcam.")
            break

        h, w = frame.shape[:2]
        
        # Guide box in center taking up ~60% of frame
        box_size = int(min(h, w) * 0.6)
        x1 = int((w - box_size) / 2)
        y1 = int((h - box_size) / 2)
        x2 = x1 + box_size
        y2 = y1 + box_size

        display = frame.copy()
        cv2.rectangle(display, (x1, y1), (x2, y2), (0, 255, 100), 2)
        cv2.putText(display, f"Hold {class_name} Inside Box", (x1, y1 - 12),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.65, (0, 255, 100), 2)
        
        # Info bar at top
        cv2.rectangle(display, (0, 0), (w, 40), (40, 40, 40), -1)
        cv2.putText(display, f"Photos Captured: {count} | Press SPACE to capture | Q to finish", 
                    (10, 26), cv2.FONT_HERSHEY_SIMPLEX, 0.55, (255, 255, 255), 1)

        cv2.imshow("ShopMate - Calin Teen Soap Collector", display)

        key = cv2.waitKey(1) & 0xFF
        if key in [ord('q'), 27]: # 'q' or ESC
            break
        elif key in [ord(' '), ord('c'), ord('C')]:
            # Save raw into my_pictures/Calin Soap
            img_id = random.randint(10000, 99999)
            raw_filename = f"calin_soap_{img_id}.jpg"
            cv2.imwrite(os.path.join(my_pics_dir, raw_filename), frame)

            # 80% train, 20% val
            split = 'train' if random.random() < 0.8 else 'val'
            img_dest = os.path.join(yolo_dir, 'images', split, raw_filename)
            lbl_dest = os.path.join(yolo_dir, 'labels', split, f"calin_soap_{img_id}.txt")

            cv2.imwrite(img_dest, frame)

            # Normalized YOLO coordinates (center_x, center_y, width, height)
            cx = (x1 + x2) / 2.0 / w
            cy = (y1 + y2) / 2.0 / h
            bw = float(box_size) / w
            bh = float(box_size) / h

            with open(lbl_dest, 'w') as f:
                f.write(f"{class_id} {cx:.6f} {cy:.6f} {bw:.6f} {bh:.6f}\n")

            count += 1
            print(f"[+Captured {count}] Saved to {split} ({raw_filename})")

    cap.release()
    cv2.destroyAllWindows()

    print("\nCapture session complete!")
    print(f"Total new photos saved: {count}")
    print("Run 'python scripts/train_yolo.py' to update the AI model weights.")

if __name__ == '__main__':
    main()
