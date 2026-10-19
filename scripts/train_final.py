import os
import shutil
from ultralytics import YOLO

def main():
    root_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    os.chdir(root_dir)
    
    yaml_path = os.path.join(root_dir, 'dataset', 'yolo', 'data.yaml')
    print(f"Starting training with data: {yaml_path}")
    
    # Clean previous temp run if exists
    temp_dir = os.path.join(root_dir, 'runs', 'detect', 'train_temp')
    if os.path.exists(temp_dir):
        shutil.rmtree(temp_dir, ignore_errors=True)
        
    model = YOLO('yolov8n.pt')
    results = model.train(
        data=yaml_path,
        epochs=20,
        imgsz=416,
        batch=16,
        workers=2,
        project='runs/detect',
        name='train_temp',
        exist_ok=True,
        verbose=True
    )
    
    # Once complete, copy to final destination
    save_dir = str(results.save_dir) if hasattr(results, 'save_dir') else temp_dir
    best_weights = os.path.join(save_dir, 'weights', 'best.pt')
    final_dir = os.path.join(root_dir, 'runs', 'detect', 'yolo_shopmate', 'weights')
    os.makedirs(final_dir, exist_ok=True)
    final_weights = os.path.join(final_dir, 'best.pt')
    
    if os.path.exists(best_weights):
        shutil.copy2(best_weights, final_weights)
        print(f"SUCCESS: Copied final trained weights to {final_weights}")
    else:
        print(f"Warning: {best_weights} not found")
        
    # Clean temp run
    if os.path.exists(temp_dir):
        shutil.rmtree(temp_dir, ignore_errors=True)
        
    print("Training finished completely!")

if __name__ == '__main__':
    main()
