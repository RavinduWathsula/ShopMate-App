import os

base_dir = r'e:\Projects\ShopMate\backend\app'
os.makedirs(os.path.join(base_dir, 'ai', 'vision'), exist_ok=True)
os.makedirs(os.path.join(base_dir, 'ai', 'models'), exist_ok=True)
os.makedirs(os.path.join(base_dir, 'ai', 'tests'), exist_ok=True)
os.makedirs(os.path.join(base_dir, 'routers'), exist_ok=True)

files = {
    'ai/vision/__init__.py': '',
    
    'ai/vision/preprocessing.py': '''import cv2
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
''',

    'ai/vision/detector.py': '''import numpy as np

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
''',

    'ai/vision/ocr.py': '''import cv2
import numpy as np

class OcrEngine:
    def __init__(self, use_mock=True):
        self.use_mock = use_mock
        if not self.use_mock:
            import easyocr
            self.reader = easyocr.Reader(['en'])

    def extract_text(self, cropped_image: np.ndarray) -> str:
        if self.use_mock:
            # Mock OCR return based on simple color or random logic 
            # to simulate reading 'Organic Bananas' or 'Milk'
            return 'Organic Bananas'
        else:
            result = self.reader.readtext(cropped_image)
            texts = [text for (bbox, text, prob) in result]
            return ' '.join(texts)
''',

    'ai/vision/product_matcher.py': '''from sqlalchemy.orm import Session
from app.models.models import Product
# Use fuzzywuzzy or thefuzz if installed, here we use simple substring matching for now
# from thefuzz import fuzz 

def match_product(extracted_text: str, db: Session):
    # In a real scenario, use fuzz.token_set_ratio against product names
    products = db.query(Product).all()
    best_match = None
    highest_score = 0
    
    extracted_lower = extracted_text.lower()
    
    for p in products:
        score = 0
        if p.product_name.lower() in extracted_lower or extracted_lower in p.product_name.lower():
            score = 80
        if p.brand and p.brand.lower() in extracted_lower:
            score += 20
            
        # Fallback to grab the first one if we are mocking and OCR returned a specific string
        if score > highest_score:
            highest_score = score
            best_match = p
            
    if best_match is None and products:
        # Fallback for mock pipeline to always return a product
        best_match = products[0]
        highest_score = 50
        
    return best_match, highest_score
''',

    'ai/vision/classifier.py': '''# Future stub for fine-grained feature classification (e.g., matching exact brand logo)
class FeatureClassifier:
    def __init__(self):
        pass
        
    def classify(self, cropped_image):
        return None
''',

    'routers/ai.py': '''from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from sqlalchemy.orm import Session
from app.database.database import get_db
from app.ai.vision.preprocessing import validate_image, process_image
from app.ai.vision.detector import YoloDetector
from app.ai.vision.ocr import OcrEngine
from app.ai.vision.product_matcher import match_product

router = APIRouter(prefix="/ai", tags=["AI Vision"])

detector = YoloDetector()
ocr = OcrEngine(use_mock=True) # Using mock OCR by default for speed in dev

@router.post("/recognize")
async def recognize_product(file: UploadFile = File(...), db: Session = Depends(get_db)):
    image_bytes = await file.read()
    
    # 2. Validate image
    if not validate_image(image_bytes):
        raise HTTPException(status_code=400, detail="Invalid image file")
        
    # 3-5. Preprocess (Resize, Normalize)
    image = process_image(image_bytes)
    
    # 6. Detect product using YOLO
    detections = detector.predict(image)
    if not detections:
        raise HTTPException(status_code=404, detail="No product detected in image")
        
    # Process the best detection
    best_detection = detections[0]
    bbox = best_detection['bbox']
    yolo_conf = best_detection['confidence']
    
    # 7. Crop detected product
    # Ensure bbox is within bounds
    h, w = image.shape[:2]
    x1, y1, x2, y2 = max(0, bbox[0]), max(0, bbox[1]), min(w, bbox[2]), min(h, bbox[3])
    cropped = image[y1:y2, x1:x2]
    
    if cropped.size == 0:
        cropped = image # fallback if crop fails
        
    # 8-9. Run OCR
    extracted_text = ocr.extract_text(cropped)
    
    # 10. Match detected information with MySQL products
    matched_product, match_score = match_product(extracted_text, db)
    
    if not matched_product:
        raise HTTPException(status_code=404, detail="Product could not be matched in database")
        
    # 11. Calculate confidence (simplified combined score)
    combined_confidence = (yolo_conf * 100 * 0.6) + (match_score * 0.4)
    
    # 12. Return best product matches
    return {
        "product_id": matched_product.product_id,
        "product_name": matched_product.product_name,
        "brand": matched_product.brand,
        "confidence": round(combined_confidence, 2),
        "price": float(matched_product.normal_price),
        "discount": bool(matched_product.discount_price),
        "discounted_price": float(matched_product.discount_price) if matched_product.discount_price else None,
        "category": matched_product.category_id
    }
'''
}

for path, content in files.items():
    full_path = os.path.join(base_dir, path.replace('/', os.sep))
    with open(full_path, 'w', encoding='utf-8') as f:
        f.write(content)
        
# Update main.py to include AI router
main_path = os.path.join(base_dir, 'main.py')
with open(main_path, 'r', encoding='utf-8') as f:
    main_content = f.read()

if 'routers import auth, products, shops, shopping, ai' not in main_content:
    main_content = main_content.replace(
        'from app.routers import auth, products, shops, shopping',
        'from app.routers import auth, products, shops, shopping, ai'
    )
    main_content = main_content.replace(
        'app.include_router(shopping.router)',
        'app.include_router(shopping.router)\napp.include_router(ai.router)'
    )
    with open(main_path, 'w', encoding='utf-8') as f:
        f.write(main_content)

print('AI Vision module generated and wired into main app.')
