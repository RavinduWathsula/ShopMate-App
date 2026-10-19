import numpy as np
import os
from ultralytics import YOLO

class YoloDetector:
    def __init__(self, model_path=None):
        if model_path is None:
            # Look for the trained model in the runs folder
            current_dir = os.path.dirname(os.path.abspath(__file__))
            root_dir = os.path.abspath(os.path.join(current_dir, '..', '..', '..', '..'))
            standard_path = os.path.join(root_dir, 'runs', 'detect', 'yolo_shopmate', 'weights', 'best.pt')
            if os.path.exists(standard_path):
                model_path = standard_path
                print(f"Using latest model weights at: {model_path}")
                
        self.model_path = model_path
        self.is_mock = model_path is None
        self._last_mtime = 0
        
        if not self.is_mock and self.model_path is not None:
            self._last_mtime = os.path.getmtime(self.model_path)
            self.model = YOLO(self.model_path)
            
        print(f'Initialized YoloDetector (Mock={self.is_mock})')

    def check_reload(self):
        if self.model_path and os.path.exists(self.model_path):
            latest_mtime = os.path.getmtime(self.model_path)
            if latest_mtime > self._last_mtime:
                print(f"[YoloDetector] Reloading updated weights from {self.model_path}")
                self.model = YOLO(self.model_path)
                self.is_mock = False
                self._last_mtime = latest_mtime

    def predict(self, image: np.ndarray):
        self.check_reload()
        
        if self.is_mock:
            # Mock bounding box
            height, width = image.shape[:2]
            return [{
                'bbox': [int(width*0.2), int(height*0.2), int(width*0.8), int(height*0.8)],
                'confidence': 0.85,
                'class_name': 'product'
            }]
        else:
            # Run inference
            results = self.model.predict(image, conf=0.01, verbose=False)
            detections = []
            
            # Convert to list to satisfy type checker
            results_list = list(results)
            
            for r in results_list:
                for box in r.boxes: # type: ignore
                    x1, y1, x2, y2 = box.xyxy[0].tolist()
                    conf = float(box.conf[0])
                    class_id = int(box.cls[0])
                    class_name = self.model.names[class_id]
                    
                    detections.append({
                        'bbox': [int(x1), int(y1), int(x2), int(y2)],
                        'confidence': conf,
                        'class_name': class_name
                    })
                    
            # Sort by highest confidence
            detections.sort(key=lambda x: x['confidence'], reverse=True)
            return detections
