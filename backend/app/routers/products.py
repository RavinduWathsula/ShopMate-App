from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.database.database import get_db
from app.models.models import Product, ProductLocation
from app.schemas.schemas import ProductResponse, ProductLocationResponse

router = APIRouter(prefix="/products", tags=["Products"])

@router.get("", response_model=List[ProductResponse])
def get_products(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return db.query(Product).offset(skip).limit(limit).all()

@router.get("/{id}", response_model=ProductResponse)
def get_product(id: int, db: Session = Depends(get_db)):
    product = db.query(Product).filter(Product.product_id == id).first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    return product

@router.get("/{id}/location", response_model=List[ProductLocationResponse])
def get_product_location(id: int, db: Session = Depends(get_db)):
    locations = db.query(ProductLocation).filter(ProductLocation.product_id == id).all()
    return locations
