from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List
from app.database.database import get_db
from app.models.models import Shop, Discount
from app.schemas.schemas import ShopResponse, DiscountResponse

router = APIRouter(tags=["Shops & Discounts"])

@router.get("/shops", response_model=List[ShopResponse])
def get_shops(db: Session = Depends(get_db)):
    return db.query(Shop).all()

@router.get("/discounts", response_model=List[DiscountResponse])
def get_discounts(db: Session = Depends(get_db)):
    return db.query(Discount).all()
