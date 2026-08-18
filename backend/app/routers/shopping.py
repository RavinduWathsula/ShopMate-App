from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.database.database import get_db
from app.models.models import ShoppingSession, ShoppingItem, ShoppingHistory, User
from app.schemas.schemas import ShoppingSessionCreate, ShoppingSessionResponse, ShoppingItemCreate, ShoppingItemResponse
from app.middleware.auth import get_current_user

router = APIRouter(tags=["Shopping"])

@router.post("/shopping-sessions", response_model=ShoppingSessionResponse)
def create_session(session: ShoppingSessionCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    db_session = ShoppingSession(user_id=current_user.id, shop_id=session.shop_id, budget_limit=session.budget_limit)
    db.add(db_session)
    db.commit()
    db.refresh(db_session)
    return db_session

@router.get("/shopping-sessions/{id}", response_model=ShoppingSessionResponse)
def get_session(id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    db_session = db.query(ShoppingSession).filter(ShoppingSession.id == id, ShoppingSession.user_id == current_user.id).first()
    if not db_session:
        raise HTTPException(status_code=404, detail="Session not found")
    return db_session

@router.post("/shopping-sessions/{id}/items", response_model=ShoppingItemResponse)
def add_item_to_session(id: int, item: ShoppingItemCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    db_session = db.query(ShoppingSession).filter(ShoppingSession.id == id, ShoppingSession.user_id == current_user.id).first()
    if not db_session:
        raise HTTPException(status_code=404, detail="Session not found")
    
    db_item = ShoppingItem(session_id=id, product_id=item.product_id, quantity=item.quantity, price_at_time=item.price_at_time)
    db.add(db_item)
    db.commit()
    db.refresh(db_item)
    return db_item

@router.delete("/shopping-sessions/{id}/items/{product_id}")
def remove_item(id: int, product_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    db_session = db.query(ShoppingSession).filter(ShoppingSession.id == id, ShoppingSession.user_id == current_user.id).first()
    if not db_session:
        raise HTTPException(status_code=404, detail="Session not found")
    
    db_item = db.query(ShoppingItem).filter(ShoppingItem.session_id == id, ShoppingItem.product_id == product_id).first()
    if not db_item:
        raise HTTPException(status_code=404, detail="Item not found")
    db.delete(db_item)
    db.commit()
    return {"detail": "Item removed"}

@router.put("/shopping-sessions/{id}/items/{product_id}", response_model=ShoppingItemResponse)
def update_item_quantity(id: int, product_id: int, quantity: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    db_session = db.query(ShoppingSession).filter(ShoppingSession.id == id, ShoppingSession.user_id == current_user.id).first()
    if not db_session:
        raise HTTPException(status_code=404, detail="Session not found")
    
    db_item = db.query(ShoppingItem).filter(ShoppingItem.session_id == id, ShoppingItem.product_id == product_id).first()
    if not db_item:
        raise HTTPException(status_code=404, detail="Item not found")
    
    db_item.quantity = quantity
    db.commit()
    db.refresh(db_item)
    return db_item

@router.get("/shopping-history", tags=["History"])
def get_shopping_history(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    history = db.query(ShoppingHistory).filter(ShoppingHistory.user_id == current_user.id).all()
    return history
