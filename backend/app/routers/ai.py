from typing import Any
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from sqlalchemy.orm import Session
from app.database.database import get_db
from app.ai.vision.preprocessing import validate_image, process_image
from app.ai.vision.detector import YoloDetector
from app.ai.vision.ocr import OcrEngine
from app.ai.vision.product_matcher import match_product
import io
import cv2
import numpy as np
from PIL import Image, ImageOps

router = APIRouter(prefix="/ai", tags=["AI Vision"])

detector = YoloDetector()
ocr = OcrEngine(use_mock=True) # Using mock OCR by default for speed in dev

@router.post("/recognize")
async def recognize_product(file: UploadFile = File(...), db: Session = Depends(get_db)):
    image_bytes = await file.read()
    
    # 2. Validate image
    if not validate_image(image_bytes):
        raise HTTPException(status_code=400, detail="Invalid image file")

    # Save incoming image for debugging
    try:
        with open("last_scan.jpg", "wb") as f_save:
            f_save.write(image_bytes)
    except Exception:
        pass

    # Decode image with proper EXIF rotation handling (crucial for phone camera captures)
    try:
        pil_img = Image.open(io.BytesIO(image_bytes))
        pil_img = ImageOps.exif_transpose(pil_img)
        if pil_img.mode != 'RGB':
            pil_img = pil_img.convert('RGB')
        orig_image = cv2.cvtColor(np.array(pil_img), cv2.COLOR_RGB2BGR)
    except Exception:
        nparr = np.frombuffer(image_bytes, np.uint8)
        orig_image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

    if orig_image is None:
        raise HTTPException(status_code=400, detail="Could not decode image")
    
    # 3-5. Multi-view YOLO detection
    # A) Standard full image
    detections: list[dict[str, Any]] = detector.predict(orig_image)  # type: ignore

    # B) Center crop (corresponds to the camera scanner frame brackets)
    h, w = orig_image.shape[:2]
    crop_h, crop_w = int(h * 0.70), int(w * 0.70)
    y0, x0 = (h - crop_h) // 2, (w - crop_w) // 2
    if crop_h > 50 and crop_w > 50:
        center_crop = orig_image[y0:y0+crop_h, x0:x0+crop_w]
        crop_dets: list[dict[str, Any]] = detector.predict(center_crop)  # type: ignore
        for cd in crop_dets:
            cb = cd['bbox']
            cd_mapped = {
                'bbox': [cb[0] + x0, cb[1] + y0, cb[2] + x0, cb[3] + y0],
                'confidence': cd['confidence'],
                'class_name': cd['class_name'],
            }
            detections.append(cd_mapped)

    with open("backend_debug.txt", "a") as f:
        f.write(f"Detections: {detections}\n")
        
    print(f"[DEBUG AI] Combined detections from YOLO: {detections}")
    
    # Identify top confidence candidates per class
    astra_dets = [
        d for d in detections 
        if ('astra' in str(d.get('class_name', '')).lower() or 'meadow' in str(d.get('class_name', '')).lower())
    ]
    soap_dets = [
        d for d in detections 
        if ('soap' in str(d.get('class_name', '')).lower() or 'calin' in str(d.get('class_name', '')).lower())
    ]
    tp_dets = [
        d for d in detections 
        if ('toothpaste' in str(d.get('class_name', '')).lower() or 'signal' in str(d.get('class_name', '')).lower())
    ]
    
    top_astra = max(astra_dets, key=lambda x: float(x.get('confidence', 0.0)), default=None)
    top_soap = max(soap_dets, key=lambda x: float(x.get('confidence', 0.0)), default=None)
    top_tp = max(tp_dets, key=lambda x: float(x.get('confidence', 0.0)), default=None)
    
    astra_conf = float(top_astra.get('confidence', 0.0)) if top_astra else 0.0
    soap_conf = float(top_soap.get('confidence', 0.0)) if top_soap else 0.0
    tp_conf = float(top_tp.get('confidence', 0.0)) if top_tp else 0.0
    
    print(f"[DEBUG AI] Class confidences -> Astra: {astra_conf:.3f}, Soap: {soap_conf:.3f}, Toothpaste: {tp_conf:.3f}")

    best_detection = None
    
    # 1. If Toothpaste is the primary object detected, reject immediately (cannot add to cart)
    if tp_conf >= 0.15 and tp_conf >= soap_conf and tp_conf >= astra_conf:
        print("[DEBUG AI] Toothpaste detected as dominant object -> Rejecting")
        raise HTTPException(
            status_code=404,
            detail="Unrecognized item! Toothpaste cannot be added. Only Astra Cup and Soap are allowed."
        )
        
    # 2. Check if Soap meets the detection threshold and beats Toothpaste
    if top_soap and soap_conf >= 0.28 and soap_conf > tp_conf and soap_conf >= astra_conf:
        best_detection = top_soap
        
    # 3. Check if Astra Cup meets the detection threshold and beats Toothpaste
    elif top_astra and astra_conf >= 0.28 and astra_conf > tp_conf and astra_conf >= soap_conf:
        best_detection = top_astra
    
    if best_detection is None:
        print(f"[DEBUG AI] No valid product detected meeting threshold. Raw detections: {detections}")
        with open("backend_debug.txt", "a") as f:
            f.write(f"No valid product detected meeting threshold: {detections}\n")
            
        # Check if user was pointing camera at a human / face / body
        is_human = False
        
        # 1. Frontal face detection
        try:
            gray = cv2.cvtColor(orig_image, cv2.COLOR_BGR2GRAY)
            face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')
            faces = face_cascade.detectMultiScale(gray, scaleFactor=1.15, minNeighbors=5, minSize=(80, 80))
            if len(faces) > 0:
                is_human = True
                print("[DEBUG AI] Frontal face clearly detected")
        except Exception:
            pass
            
        # 2. Person detection via standard YOLO if available
        if not is_human:
            try:
                import os
                from ultralytics import YOLO
                coco_path = "yolov8n.pt"
                if os.path.exists(coco_path):
                    coco_model = YOLO(coco_path)
                    coco_results: list[Any] = list(coco_model.predict(orig_image, classes=[0], conf=0.60, verbose=False))  # type: ignore
                    if coco_results:
                        first_res: Any = coco_results[0]
                        boxes: Any = getattr(first_res, 'boxes', None)
                        if boxes is not None and len(boxes) > 0:
                            pbox = boxes[0].xyxy[0].tolist()
                            pw = abs(pbox[2] - pbox[0])
                            ph = abs(pbox[3] - pbox[1])
                            img_area = orig_image.shape[0] * orig_image.shape[1]
                            if (pw * ph) / max(1, img_area) > 0.30:
                                is_human = True
                                print("[DEBUG AI] Human body clearly detected")
            except Exception as e:
                print(f"[DEBUG AI] Error in COCO person check: {e}")
                
        if is_human:
            raise HTTPException(status_code=400, detail="Human detected! Please scan a product.")
        else:
            raise HTTPException(
                status_code=404, 
                detail="Unrecognized item! Only Astra Cup and Calin Soap can be scanned."
            )
        
    bbox = best_detection['bbox']
    yolo_conf = float(best_detection['confidence']) # type: ignore
    detected_class_name = str(best_detection.get('class_name', 'product'))
    extracted_text = detected_class_name
    
    # 10. Match detected information with products (strictly Astra Cup and Calin Soap)
    matched_product, match_score = match_product(extracted_text, db)
    with open("backend_debug.txt", "a") as f:
        f.write(f"Extracted: {extracted_text}, Matched: {matched_product.product_name if matched_product else 'None'}, Score: {match_score}\n")
    
    print(f"[DEBUG AI] Extracted text: {extracted_text}")
    print(f"[DEBUG AI] Matched product: {matched_product.product_name if matched_product else 'None'} with score {match_score}")
    
    if not matched_product:
        raise HTTPException(
            status_code=404, 
            detail="Unrecognized item! Only Astra Cup and Calin Soap can be scanned."
        )
        
    # 11. Calculate confidence (simplified combined score)
    combined_confidence = (yolo_conf * 100 * 0.8) + (match_score * 0.2)
    
    category_name = "Personal Care"
    p_name_lower = str(getattr(matched_product, 'product_name', '') or '').lower()
    if 'meadowlea' in p_name_lower or 'astra' in p_name_lower:
        category_name = "Dairy & Chilled"
    elif 'toothpaste' in p_name_lower or 'soap' in p_name_lower:
        category_name = "Personal Care"
    elif hasattr(matched_product, 'category_id') and matched_product.category_id:
        category_name = str(matched_product.category_id)

    return {
        "product_id": matched_product.product_id,
        "product_name": matched_product.product_name,
        "brand": matched_product.brand,
        "confidence": round(combined_confidence, 2),
        "price": float(matched_product.normal_price) if hasattr(matched_product, 'normal_price') and matched_product.normal_price else 0.0, # type: ignore
        "discount": bool(matched_product.discount_price) if hasattr(matched_product, 'discount_price') else False,
        "discounted_price": float(matched_product.discount_price) if hasattr(matched_product, 'discount_price') and matched_product.discount_price else None, # type: ignore
        "category": category_name
    }
