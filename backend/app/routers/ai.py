from typing import Any
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from sqlalchemy.orm import Session
from app.database.database import get_db
from app.ai.vision.preprocessing import validate_image, process_image
from app.ai.vision.detector import YoloDetector
from app.ai.vision.ocr import OcrEngine
from app.ai.vision.product_matcher import match_product
import cv2
import numpy as np

router = APIRouter(prefix="/ai", tags=["AI Vision"])

detector = YoloDetector()
ocr = OcrEngine(use_mock=True) # Using mock OCR by default for speed in dev

@router.post("/recognize")
async def recognize_product(file: UploadFile = File(...), db: Session = Depends(get_db)):
    image_bytes = await file.read()
    
    # 2. Validate image
    if not validate_image(image_bytes):
        raise HTTPException(status_code=400, detail="Invalid image file")
        # Decode image for face detection (before any resizing distorts the face shape)
    nparr = np.frombuffer(image_bytes, np.uint8)
    orig_image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    if orig_image is None:
        raise HTTPException(status_code=400, detail="Could not decode image")
    
    # 3-5. Preprocess (Resize, Normalize) for YOLO
    image = process_image(image_bytes)
    
    detections: list[dict[str, Any]] = detector.predict(image)  # type: ignore
    with open("backend_debug.txt", "a") as f:
        f.write(f"Detections: {detections}\n")
        
    print(f"[DEBUG AI] Detections from YOLO: {detections}")
    
    # Process detections that meet minimum confidence (0.20) to capture all 3 products reliably
    valid_detections: list[dict[str, Any]] = [d for d in detections if float(d['confidence']) >= 0.20]
    
    if not valid_detections:
        print("[DEBUG AI] No valid product detected with >= 0.20 confidence")
        with open("backend_debug.txt", "a") as f:
            f.write("No valid product detected\n")
            
        # Check if user was pointing camera at a human / face / body
        is_human = False
        
        # 1. Skin detection in HSV space
        hsv_full = cv2.cvtColor(orig_image, cv2.COLOR_BGR2HSV)
        lower_skin = np.array([0, 40, 60], dtype=np.uint8)
        upper_skin = np.array([20, 170, 255], dtype=np.uint8)
        skin_mask = cv2.inRange(hsv_full, lower_skin, upper_skin)
        h, w = orig_image.shape[:2]
        center_skin = np.sum(skin_mask[h//4:3*h//4, w//4:3*w//4] > 0) / max(1, (h//2)*(w//2))
        total_skin = np.sum(skin_mask > 0) / max(1, (h * w))
        
        if center_skin > 0.22 or total_skin > 0.20:
            is_human = True
            print(f"[DEBUG AI] Human detected via skin tone (center={center_skin:.2f}, total={total_skin:.2f})")
            
        # 2. Person detection via standard YOLO if available
        if not is_human:
            try:
                import os
                from ultralytics import YOLO
                coco_path = "yolov8n.pt"
                if os.path.exists(coco_path):
                    coco_model = YOLO(coco_path)
                    coco_results: list[Any] = list(coco_model.predict(orig_image, classes=[0], conf=0.35, verbose=False))  # type: ignore
                    if coco_results:
                        first_res: Any = coco_results[0]
                        boxes: Any = getattr(first_res, 'boxes', None)
                        if boxes is not None and len(boxes) > 0:
                            is_human = True
                            print("[DEBUG AI] Human detected via COCO person model")
            except Exception as e:
                print(f"[DEBUG AI] Error in COCO person check: {e}")
                
        if is_human:
            raise HTTPException(status_code=400, detail="Human detected! Please scan a product.")
        else:
            raise HTTPException(
                status_code=404, 
                detail="Unrecognized item! Only Closeup Toothpaste, Meadowlea, and Calin Teen Soap can be scanned."
            )
        
    best_detection = valid_detections[0]
    bbox = best_detection['bbox']
    yolo_conf = float(best_detection['confidence']) # type: ignore
    detected_class_name = str(best_detection.get('class_name', 'product'))
    extracted_text = detected_class_name
    
    # 10. Match detected information with products (strictly 3 allowed items)
    matched_product, match_score = match_product(extracted_text, db)
    with open("backend_debug.txt", "a") as f:
        f.write(f"Extracted: {extracted_text}, Matched: {matched_product.product_name if matched_product else 'None'}, Score: {match_score}\n")
    
    print(f"[DEBUG AI] Extracted text: {extracted_text}")
    print(f"[DEBUG AI] Matched product: {matched_product.product_name if matched_product else 'None'} with score {match_score}")
    
    if not matched_product:
        raise HTTPException(
            status_code=404, 
            detail="Unrecognized item! Only Closeup Toothpaste, Meadowlea, and Calin Teen Soap can be scanned."
        )
        
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
