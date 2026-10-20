from sqlalchemy.orm import Session
from app.models.models import Product
# Use fuzzywuzzy or thefuzz if installed, here we use simple substring matching for now
# from thefuzz import fuzz 

def match_product(extracted_text: str, db: Session):
    products = db.query(Product).all()
    extracted_lower = extracted_text.lower()
    
    # Strictly allow ONLY 2 items:
    # 1. Astra Cup
    if 'astra' in extracted_lower:
        match = next((p for p in products if 'astra' in str(getattr(p, 'product_name', '') or '').lower()), None)
        if not match:
            match = next((p for p in products if getattr(p, 'product_id', None) == 10000), None)
        if match:
            return match, 100

    if 'meadowlea' in extracted_lower:
        match = next((p for p in products if 'meadowlea' in str(getattr(p, 'product_name', '') or '').lower()), None)
        if not match:
            match = next((p for p in products if getattr(p, 'product_id', None) == 10002), None)
        if not match:
            match = next((p for p in products if getattr(p, 'product_id', None) == 10000), None)
        if match:
            return match, 100
            
    # 2. Calin Teen Soap
    if 'calin' in extracted_lower or 'soap' in extracted_lower:
        match = next(
            (p for p in products if 'calin' in str(getattr(p, 'product_name', '') or '').lower() 
             or 'calin' in str(getattr(p, 'brand', '') or '').lower()), 
            None
        )
        if not match:
            match = next((p for p in products if 'soap' in str(getattr(p, 'product_name', '') or '').lower()), None)
        if not match:
            match = next((p for p in products if getattr(p, 'product_id', None) == 10001), None)
        if match:
            return match, 100
            
    # All other items (toothpaste, non-store items, etc.) are NOT allowed
    return None, 0

