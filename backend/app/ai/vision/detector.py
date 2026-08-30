import numpy as np

class YoloDetector:
    def __init__(self, model_path=None):
        self.model_path = model_path
        self.is_mock = model_path is None
        print(f'Initialized YoloDetector (Mock={self.is_mock})')

    def predict(self, image: np.ndarray):
        if self.is_mock:
            # Return a mock bounding box [x1, y1, x2, y2, confidence, class_id]
            # Assumes the product takes up the center of the image
            height, width = image.shape[:2]
            return [{
                'bbox': [int(width*0.2), int(height*0.2), int(width*0.8), int(height*0.8)],
                'confidence': 0.85,
                'class': 'product'
            }]
        else:
            raise NotImplementedError('Trained YOLO model not integrated yet.')
