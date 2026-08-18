from pydantic import BaseModel, EmailStr
from typing import List, Optional, Any
from datetime import datetime

class UserCreate(BaseModel):
    email: EmailStr
    password: str

class UserResponse(BaseModel):
    id: int
    email: EmailStr
    preferences_json: Optional[Any] = None
    
    class Config:
        from_attributes = True

class Token(BaseModel):
    access_token: str
    token_type: str

class ProductResponse(BaseModel):
    product_id: int
    product_name: str
    brand: Optional[str] = None
    normal_price: float
    discount_price: Optional[float] = None
    shop_id: int

    class Config:
        from_attributes = True

class ProductLocationResponse(BaseModel):
    aisle: Optional[str] = None
    section: Optional[str] = None
    x_position: Optional[float] = None
    y_position: Optional[float] = None

    class Config:
        from_attributes = True

class ShopResponse(BaseModel):
    id: int
    name: str
    address: str

    class Config:
        from_attributes = True

class DiscountResponse(BaseModel):
    id: int
    name: str
    discount_type: str
    value: float

    class Config:
        from_attributes = True

class ShoppingSessionCreate(BaseModel):
    shop_id: int
    budget_limit: Optional[float] = None

class ShoppingSessionResponse(BaseModel):
    id: int
    user_id: int
    shop_id: int
    status: str
    budget_limit: Optional[float] = None

    class Config:
        from_attributes = True

class ShoppingItemCreate(BaseModel):
    product_id: int
    quantity: int
    price_at_time: float

class ShoppingItemResponse(BaseModel):
    id: int
    product_id: int
    quantity: int
    price_at_time: float

    class Config:
        from_attributes = True
