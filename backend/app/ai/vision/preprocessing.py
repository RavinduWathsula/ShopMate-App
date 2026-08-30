import cv2
import numpy as np

def validate_image(image_bytes: bytes) -> bool:
    if not image_bytes:
        return False
    # Simple check if bytes can be decoded by opencv
    nparr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    return img is not None

def process_image(image_bytes: bytes) -> np.ndarray:
    nparr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    # Resize to standard YOLO input size
    img_resized = cv2.resize(img, (640, 640))
    # Normalize
    img_normalized = img_resized / 255.0
    # OpenCV operations can be added here
    return img_resized
