from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
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
