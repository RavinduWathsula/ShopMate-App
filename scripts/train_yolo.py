from ultralytics import YOLO
import os

def main():
    print("Initializing YOLOv8 training...")
    
    # Load a pretrained YOLOv8n model
    model = YOLO('yolov8n.pt')
    
    # Set the path to the generated data.yaml
    yaml_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'dataset', 'yolo', 'data.yaml'))
    
    if not os.path.exists(yaml_path):
        print(f"Error: {yaml_path} not found. Please run scripts/setup_yolo_dataset.py first.")
        return

    # Train the model
    # Note: Training parameters can be tuned as needed
    print(f"Training using dataset at: {yaml_path}")
    results = model.train(
        data=yaml_path,
        epochs=30,           # Increased training for actual accuracy
        imgsz=416,
        batch=16,
        project='runs/detect',
        name='yolo_shopmate',
        exist_ok=True
    )
    
    print("Training completed! The best weights should be located at runs/detect/yolo_shopmate/weights/best.pt")

if __name__ == '__main__':
    # Ensure run from root so relative paths work nicely
    root_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    os.chdir(root_dir)
    main()
