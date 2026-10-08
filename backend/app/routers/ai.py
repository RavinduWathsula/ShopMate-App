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
    print(f"[DEBUG AI] Detections from YOLO: {detections}")
    if not detections:
        print("[DEBUG AI] No detections found, returning 404")
        raise HTTPException(status_code=404, detail="No product detected in image")
        
    # Process the best detection
    best_detection = detections[0]
    bbox = best_detection['bbox']
    yolo_conf = float(best_detection['confidence']) # type: ignore
    detected_class_name = str(best_detection.get('class_name', 'product'))
    
    # Skip OCR and just use the YOLO classification name directly
    extracted_text = detected_class_name
    
    # 10. Match detected information with MySQL products
    matched_product, match_score = match_product(extracted_text, db)
    print(f"[DEBUG AI] Extracted text: {extracted_text}")
    print(f"[DEBUG AI] Matched product: {matched_product.product_name if matched_product else 'None'} with score {match_score}")
    
    if not matched_product:
        raise HTTPException(status_code=404, detail="Product could not be matched in database")
        
    # 11. Calculate confidence (simplified combined score)
    combined_confidence = (yolo_conf * 100 * 0.8) + (match_score * 0.2)
    
    # 12. Return best product matches
    return {
        "product_id": matched_product.product_id,
        "product_name": matched_product.product_name,
        "brand": matched_product.brand,
        "confidence": round(combined_confidence, 2),
        "price": float(matched_product.normal_price) if hasattr(matched_product, 'normal_price') and matched_product.normal_price else 0.0, # type: ignore
        "discount": bool(matched_product.discount_price) if hasattr(matched_product, 'discount_price') else False,
        "discounted_price": float(matched_product.discount_price) if hasattr(matched_product, 'discount_price') and matched_product.discount_price else None, # type: ignore
        "category": matched_product.category_id if hasattr(matched_product, 'category_id') else "Uncategorized"
    }
