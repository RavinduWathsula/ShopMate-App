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
    
    # Ensure best weights are copied to the standard runs/detect/yolo_shopmate/weights location
    import shutil
    standard_weights_dir = os.path.abspath(os.path.join(root_dir, 'runs', 'detect', 'yolo_shopmate', 'weights'))
    os.makedirs(standard_weights_dir, exist_ok=True)
    trained_best = os.path.join(results.save_dir, 'weights', 'best.pt') if hasattr(results, 'save_dir') else None
    if trained_best and os.path.exists(trained_best):
        standard_best = os.path.join(standard_weights_dir, 'best.pt')
        shutil.copy2(trained_best, standard_best)
        print(f"Copied updated weights to: {standard_best}")
        
    print("Training completed! Model is ready for camera detection.")

if __name__ == '__main__':
    # Ensure run from root so relative paths work nicely
    root_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    os.chdir(root_dir)
    main()
