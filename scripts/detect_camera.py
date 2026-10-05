import cv2
from ultralytics import YOLO
import os
import time

def main():
    # 1. Load the trained model
    weights_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'runs', 'detect', 'yolo_shopmate', 'weights', 'best.pt'))
    
    if not os.path.exists(weights_path):
        print(f"Error: Could not find the trained model at {weights_path}")
        print("Make sure you have run 'python scripts/train_yolo.py' first!")
        return
        
    print(f"Loading model from {weights_path}")
    model = YOLO(weights_path)
    
    # 2. Open the camera (0 is usually the default laptop webcam)
    print("Attempting to open webcam...")
    cap = cv2.VideoCapture(0)
    
    if not cap.isOpened():
        print("Error: Could not open the camera. Make sure no other apps are using it.")
        return
        
    print("Camera opened successfully.")
    print("Controls:")
    print("  'c' - Capture and identify items")
    print("  'q' - Quit")
    
    # Create a directory to save captured images
    captures_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'captures'))
    os.makedirs(captures_dir, exist_ok=True)
    
    while True:
        # Read a frame from the camera
        success, frame = cap.read()
        
        if not success:
            print("Failed to grab a frame from the camera")
            break
            
        # Run YOLO inference on the frame (only showing detections above 50% confidence)
        results = model.predict(frame, conf=0.5, verbose=False)
        
        # Convert results to a list to avoid iterator indexing issues
        results_list = list(results)
        result = results_list[0]
        
        # Visualize the results on the frame
        annotated_frame = result.plot() # type: ignore
        
        # Display the frame
        cv2.imshow("ShopMate Live YOLO Detection", annotated_frame)
        
        # Handle key presses
        key = cv2.waitKey(1) & 0xFF
        if key == ord('q'):
            break
        elif key == ord('c'):
            print("\n--- Capturing Image ---")
            
            # Analyze the results
            detected_items = []
            for r in results_list:
                for box in r.boxes: # type: ignore
                    class_id = int(box.cls[0])
                    conf = float(box.conf[0])
                    class_name = model.names[class_id]
                    detected_items.append((class_name, conf))
            
            if detected_items:
                print("Items identified in capture:")
                for item, conf in detected_items:
                    print(f" - {item} (Confidence: {conf:.2f})")
            else:
                print("No items detected in this capture. Please adjust the item and try again.")
            
            # Save the captured frame
            timestamp = time.strftime("%Y%m%d-%H%M%S")
            save_path = os.path.join(captures_dir, f"capture_{timestamp}.jpg")
            cv2.imwrite(save_path, annotated_frame)
            print(f"Saved annotated capture to: {save_path}")
            print("-----------------------\n")
            
    # Release the camera and close windows
    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    main()
