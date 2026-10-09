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
    
    # Check for humans/faces before doing product detection
    try:
        gray = cv2.cvtColor(orig_image, cv2.COLOR_BGR2GRAY)
        
        # Keep basic haarcascades as a first-line defense but don't strictly rely on them
        face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')
        faces = face_cascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=4, minSize=(30, 30))
        if len(faces) > 0:
            print(f"[DEBUG AI] Frontal face detected in raw image")
    except Exception as e:
        print(f"[DEBUG AI] Face detection error: {e}")
        
    # 3-5. Preprocess (Resize, Normalize) for YOLO
    image = process_image(image_bytes)
    
    # 6. Detect product using YOLO
    detections = detector.predict(image)
    with open("backend_debug.txt", "a") as f:
        f.write(f"Detections: {detections}\n")
        
    print(f"[DEBUG AI] Detections from YOLO: {detections}")
    if not detections:
        print("[DEBUG AI] No detections found, returning 404")
        with open("backend_debug.txt", "a") as f:
            f.write("No detections found\n")
        raise HTTPException(status_code=404, detail="No product detected in image")
        
    # Process the best detection that meets a minimum confidence to filter background noise
    valid_detections = [d for d in detections if float(d['confidence']) >= 0.04]
    
    # Filter out detections that are actually just human skin (chest/face)
    final_detections = []
    for d in valid_detections:
        x1, y1, x2, y2 = d['bbox']
        # YOLO bounding boxes are based on the 640x640 processed image, so we must map them to orig_image
        h, w = orig_image.shape[:2]
        x1 = int(x1 * w / 640.0)
        x2 = int(x2 * w / 640.0)
        y1 = int(y1 * h / 640.0)
        y2 = int(y2 * h / 640.0)
        
        x1, y1 = max(0, x1), max(0, y1)
        x2, y2 = min(w, x2), min(h, y2)
        
        if x2 > x1 and y2 > y1:
            roi = orig_image[y1:y2, x1:x2]
            hsv = cv2.cvtColor(roi, cv2.COLOR_BGR2HSV)
            # Skin color range in HSV: Hue 0-20, Sat 20-150 (ignores bright red), Val 70-255
            lower_skin = np.array([0, 20, 70], dtype=np.uint8)
            upper_skin = np.array([20, 150, 255], dtype=np.uint8)
            mask = cv2.inRange(hsv, lower_skin, upper_skin)
            
            skin_ratio = np.sum(mask > 0) / (roi.shape[0] * roi.shape[1])
            print(f"[DEBUG AI] Box {d['class_name']} skin ratio: {skin_ratio}")
            with open("backend_debug.txt", "a") as f:
                f.write(f"Skin ratio for {d['class_name']}: {skin_ratio*100:.1f}%\n")
            
            # Use a very high skin threshold. If skin > 60%, it's mostly a face or chest.
            # If skin is 15-30%, it's probably just a hand holding the product. We MUST ACCEPT IT!
            if skin_ratio > 0.60:
                print(f"[DEBUG AI] Rejecting {d['class_name']} because it is {skin_ratio*100:.1f}% skin")
                continue
                
        final_detections.append(d)
        
    if not final_detections:
        print("[DEBUG AI] No valid detections found after skin filter, returning 404")
        with open("backend_debug.txt", "a") as f:
            f.write("No valid detections found\n")
        raise HTTPException(status_code=404, detail="Human detected, please scan a product")
        
    best_detection = final_detections[0]
    bbox = best_detection['bbox']
    yolo_conf = float(best_detection['confidence']) # type: ignore
    detected_class_name = str(best_detection.get('class_name', 'product'))
    
    # We remove the flawed shape heuristic. It was causing square-held Toothpastes 
    # to be flagged as Astra Cup, and hand-held Astra Cups to be flagged as Toothpaste.
    extracted_text = detected_class_name
    
    # 10. Match detected information with MySQL products
    matched_product, match_score = match_product(extracted_text, db)
    with open("backend_debug.txt", "a") as f:
        f.write(f"Extracted: {extracted_text}, Matched: {matched_product.product_name if matched_product else 'None'}, Score: {match_score}\n")
    
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
