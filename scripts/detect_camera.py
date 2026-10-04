import cv2
from ultralytics import YOLO
import os

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
        
    print("Camera opened successfully. Position your Toothpaste, Astra Cup, or Sprite Bottle Mini in front of the camera!")
    print("Press 'q' to quit.")
    
    while True:
        # Read a frame from the camera
        success, frame = cap.read()
        
        if not success:
            print("Failed to grab a frame from the camera")
            break
            
        # Run YOLO inference on the frame (only showing detections above 50% confidence)
        results = model.predict(frame, conf=0.5, verbose=False)
        
        # Visualize the results on the frame
        annotated_frame = results[0].plot()
        
        # Display the frame
        cv2.imshow("ShopMate Live YOLO Detection", annotated_frame)
        
        # Press 'q' to quit
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break
            
    # Release the camera and close windows
    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    main()
