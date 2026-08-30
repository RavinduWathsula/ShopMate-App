from sqlalchemy.orm import Session
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
