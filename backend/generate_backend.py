import os

base_dir = r"e:\Projects\ShopMate\backend\app"

files = {
    "config/settings.py": '''from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    DB_URL: str = "mysql+pymysql://root:password@localhost/shopmate"
    JWT_SECRET: str = "supersecretkey"
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

    class Config:
        env_file = ".env"

settings = Settings()
''',

    "database/database.py": '''from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base
from app.config.settings import settings

engine = create_engine(settings.DB_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
''',

    "utils/security.py": '''from passlib.context import CryptContext
from datetime import datetime, timedelta
from jose import jwt
from app.config.settings import settings

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password):
    return pwd_context.hash(password)

def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, settings.JWT_SECRET, algorithm=settings.JWT_ALGORITHM)
    return encoded_jwt
''',

    "models/models.py": '''from sqlalchemy import Column, Integer, String, Float, Boolean, ForeignKey, DateTime, Enum, JSON, DECIMAL
from sqlalchemy.orm import relationship
from datetime import datetime
from app.database.database import Base

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(255), unique=True, index=True)
    password_hash = Column(String(255))
    preferences_json = Column(JSON, nullable=True)
    shopping_sessions = relationship("ShoppingSession", back_populates="user")
    recommendations = relationship("Recommendation", back_populates="user")

class Shop(Base):
    __tablename__ = "shops"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255))
    address = Column(String(255))
    city = Column(String(100))
    products = relationship("Product", back_populates="shop")

class Category(Base):
    __tablename__ = "categories"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100))
    parent_id = Column(Integer, ForeignKey("categories.id"), nullable=True)
    
class Discount(Base):
    __tablename__ = "discounts"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100))
    discount_type = Column(String(50))
    value = Column(DECIMAL(10,2))
    
class Product(Base):
    __tablename__ = "products"
    product_id = Column(Integer, primary_key=True, index=True)
    shop_id = Column(Integer, ForeignKey("shops.id"))
    category_id = Column(Integer, ForeignKey("categories.id"), nullable=True)
    subcategory_id = Column(Integer, ForeignKey("categories.id"), nullable=True)
    product_name = Column(String(255))
    brand = Column(String(100), nullable=True)
    weight = Column(DECIMAL(10,2), nullable=True)
    normal_price = Column(DECIMAL(10,2))
    discount_id = Column(Integer, ForeignKey("discounts.id"), nullable=True)
    discount_price = Column(DECIMAL(10,2), nullable=True)
    discount_percentage = Column(DECIMAL(5,2), nullable=True)
    priority_score = Column(Integer, default=0)
    
    shop = relationship("Shop", back_populates="products")
    images = relationship("ProductImage", back_populates="product")
    inventory = relationship("Inventory", back_populates="product")
    locations = relationship("ProductLocation", back_populates="product")

class ProductImage(Base):
    __tablename__ = "product_images"
    id = Column(Integer, primary_key=True, index=True)
    product_id = Column(Integer, ForeignKey("products.product_id"))
    image_url = Column(String(500))
    is_primary = Column(Boolean, default=False)
    product = relationship("Product", back_populates="images")

class Inventory(Base):
    __tablename__ = "inventory"
    id = Column(Integer, primary_key=True, index=True)
    product_id = Column(Integer, ForeignKey("products.product_id"))
    shop_id = Column(Integer, ForeignKey("shops.id"))
    stock_quantity = Column(Integer, default=0)
    product = relationship("Product", back_populates="inventory")

class ProductLocation(Base):
    __tablename__ = "product_locations"
    id = Column(Integer, primary_key=True, index=True)
    product_id = Column(Integer, ForeignKey("products.product_id"))
    shop_id = Column(Integer, ForeignKey("shops.id"))
    aisle = Column(String(50))
    section = Column(String(50))
    shelf = Column(String(50))
    x_position = Column(DECIMAL(10,2))
    y_position = Column(DECIMAL(10,2))
    product = relationship("Product", back_populates="locations")

class ShoppingSession(Base):
    __tablename__ = "shopping_sessions"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    shop_id = Column(Integer, ForeignKey("shops.id"))
    status = Column(String(50), default="active")
    budget_limit = Column(DECIMAL(10,2), nullable=True)
    user = relationship("User", back_populates="shopping_sessions")
    items = relationship("ShoppingItem", back_populates="session")
    history = relationship("ShoppingHistory", back_populates="session", uselist=False)

class ShoppingItem(Base):
    __tablename__ = "shopping_items"
    id = Column(Integer, primary_key=True, index=True)
    session_id = Column(Integer, ForeignKey("shopping_sessions.id"))
    product_id = Column(Integer, ForeignKey("products.product_id"))
    quantity = Column(Integer, default=1)
    price_at_time = Column(DECIMAL(10,2))
    session = relationship("ShoppingSession", back_populates="items")
    product = relationship("Product")

class ShoppingHistory(Base):
    __tablename__ = "shopping_history"
    id = Column(Integer, primary_key=True, index=True)
    session_id = Column(Integer, ForeignKey("shopping_sessions.id"))
    user_id = Column(Integer, ForeignKey("users.id"))
    total_amount = Column(DECIMAL(10,2))
    completed_at = Column(DateTime)
    session = relationship("ShoppingHistory", back_populates="history")

class Recommendation(Base):
    __tablename__ = "recommendations"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    product_id = Column(Integer, ForeignKey("products.product_id"))
    score = Column(DECIMAL(5,2))
    reason = Column(String(255))
    user = relationship("User", back_populates="recommendations")
    product = relationship("Product")
''',

    "schemas/schemas.py": '''from pydantic import BaseModel, EmailStr
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
''',

    "middleware/auth.py": '''from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from sqlalchemy.orm import Session
from app.config.settings import settings
from app.database.database import get_db
from app.models.models import User

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")

def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, settings.JWT_SECRET, algorithms=[settings.JWT_ALGORITHM])
        user_id: str = payload.get("sub")
        if user_id is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    user = db.query(User).filter(User.id == int(user_id)).first()
    if user is None:
        raise credentials_exception
    return user
''',

    "routers/auth.py": '''from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from app.database.database import get_db
from app.schemas.schemas import UserCreate, UserResponse, Token
from app.models.models import User
from app.utils.security import get_password_hash, verify_password, create_access_token

router = APIRouter(prefix="/auth", tags=["Authentication"])

@router.post("/register", response_model=UserResponse)
def register(user: UserCreate, db: Session = Depends(get_db)):
    db_user = db.query(User).filter(User.email == user.email).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    hashed_password = get_password_hash(user.password)
    new_user = User(email=user.email, password_hash=hashed_password)
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user

@router.post("/login", response_model=Token)
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == form_data.username).first()
    if not user or not verify_password(form_data.password, user.password_hash):
        raise HTTPException(status_code=400, detail="Incorrect email or password")
    
    access_token = create_access_token(data={"sub": str(user.id)})
    return {"access_token": access_token, "token_type": "bearer"}
''',

    "routers/products.py": '''from fastapi import APIRouter, Depends, HTTPException
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
''',

    "routers/shops.py": '''from fastapi import APIRouter, Depends
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
''',

    "routers/shopping.py": '''from fastapi import APIRouter, Depends, HTTPException
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

@router.get("/shopping-history", tags=["History"])
def get_shopping_history(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    history = db.query(ShoppingHistory).filter(ShoppingHistory.user_id == current_user.id).all()
    return history
''',

    "main.py": '''from fastapi import FastAPI
from app.routers import auth, products, shops, shopping

app = FastAPI(
    title="ShopMate API",
    description="Backend REST APIs for the ShopMate AI-assisted shopping application.",
    version="1.0.0"
)

app.include_router(auth.router)
app.include_router(products.router)
app.include_router(shops.router)
app.include_router(shopping.router)

@app.get("/")
def root():
    return {"message": "Welcome to ShopMate API. Visit /docs for Swagger UI"}
'''
}

for path, content in files.items():
    full_path = os.path.join(base_dir, path)
    os.makedirs(os.path.dirname(full_path), exist_ok=True)
    with open(full_path, "w", encoding="utf-8") as f:
        f.write(content)

print("Successfully generated FastAPI backend files.")
