from sqlalchemy import Column, Integer, String, Float, Boolean, ForeignKey, DateTime, Enum, JSON, DECIMAL
from sqlalchemy.orm import relationship
from datetime import datetime
try:
    from app.database.database import Base
except ImportError:
    from backend.app.database.database import Base


class User(Base):
    __tablename__ = "users"
    id = Column("user_id", Integer, primary_key=True, index=True)
    email = Column(String(255), unique=True, index=True)
    password_hash = Column(String(255))
    preferences_json = Column("preferences", JSON, nullable=True)
    shopping_sessions = relationship("ShoppingSession", back_populates="user")
    recommendations = relationship("Recommendation", back_populates="user")

class Shop(Base):
    __tablename__ = "shops"
    id = Column("shop_id", Integer, primary_key=True, index=True)
    name = Column(String(255))
    address = Column(String(255))
    city = Column(String(100))
    products = relationship("Product", back_populates="shop")

class Category(Base):
    __tablename__ = "categories"
    id = Column("category_id", Integer, primary_key=True, index=True)
    name = Column(String(100))
    parent_id = Column(Integer, ForeignKey("categories.category_id"), nullable=True)
    
class Discount(Base):
    __tablename__ = "discounts"
    id = Column("discount_id", Integer, primary_key=True, index=True)
    name = Column(String(100))
    discount_type = Column(String(50))
    value = Column(DECIMAL(10,2))
    
class Product(Base):
    __tablename__ = "products"
    product_id = Column(Integer, primary_key=True, index=True)
    shop_id = Column(Integer, ForeignKey("shops.shop_id"))
    category_id = Column(Integer, ForeignKey("categories.category_id"), nullable=True)
    subcategory_id = Column(Integer, ForeignKey("categories.category_id"), nullable=True)
    product_name = Column(String(255))
    brand = Column(String(100), nullable=True)
    weight = Column(DECIMAL(10,2), nullable=True)
    normal_price = Column(DECIMAL(10,2))
    discount_id = Column(Integer, ForeignKey("discounts.discount_id"), nullable=True)
    discount_price = Column(DECIMAL(10,2), nullable=True)
    discount_percentage = Column(DECIMAL(5,2), nullable=True)
    priority_score = Column(Integer, default=0)
    
    shop = relationship("Shop", back_populates="products")
    images = relationship("ProductImage", back_populates="product")
    inventory = relationship("Inventory", back_populates="product")
    locations = relationship("ProductLocation", back_populates="product")

class ProductImage(Base):
    __tablename__ = "product_images"
    id = Column("image_id", Integer, primary_key=True, index=True)
    product_id = Column(Integer, ForeignKey("products.product_id"))
    image_url = Column(String(500))
    is_primary = Column(Boolean, default=False)
    product = relationship("Product", back_populates="images")

class Inventory(Base):
    __tablename__ = "inventory"
    id = Column("inventory_id", Integer, primary_key=True, index=True)
    product_id = Column(Integer, ForeignKey("products.product_id"))
    shop_id = Column(Integer, ForeignKey("shops.shop_id"))
    stock_quantity = Column(Integer, default=0)
    product = relationship("Product", back_populates="inventory")

class ProductLocation(Base):
    __tablename__ = "product_locations"
    id = Column("location_id", Integer, primary_key=True, index=True)
    product_id = Column(Integer, ForeignKey("products.product_id"))
    shop_id = Column(Integer, ForeignKey("shops.shop_id"))
    aisle = Column(String(50))
    section = Column(String(50))
    shelf = Column(String(50))
    x_position = Column(DECIMAL(10,2))
    y_position = Column(DECIMAL(10,2))
    product = relationship("Product", back_populates="locations")

class ShoppingSession(Base):
    __tablename__ = "shopping_sessions"
    id = Column("session_id", Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id"))
    shop_id = Column(Integer, ForeignKey("shops.shop_id"))
    status = Column(String(50), default="active")
    budget_limit = Column(DECIMAL(10,2), nullable=True)
    user = relationship("User", back_populates="shopping_sessions")
    items = relationship("ShoppingItem", back_populates="session")
    history = relationship("ShoppingHistory", back_populates="session", uselist=False)

class ShoppingItem(Base):
    __tablename__ = "shopping_items"
    id = Column("item_id", Integer, primary_key=True, index=True)
    session_id = Column(Integer, ForeignKey("shopping_sessions.session_id"))
    product_id = Column(Integer, ForeignKey("products.product_id"))
    quantity = Column(Integer, default=1)
    price_at_time = Column(DECIMAL(10,2))
    session = relationship("ShoppingSession", back_populates="items")
    product = relationship("Product")

class ShoppingHistory(Base):
    __tablename__ = "shopping_history"
    id = Column("history_id", Integer, primary_key=True, index=True)
    session_id = Column(Integer, ForeignKey("shopping_sessions.session_id"))
    user_id = Column(Integer, ForeignKey("users.user_id"))
    total_amount = Column(DECIMAL(10,2))
    completed_at = Column(DateTime)
    session = relationship("ShoppingSession", back_populates="history")

class Recommendation(Base):
    __tablename__ = "recommendations"
    id = Column("recommendation_id", Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id"))
    product_id = Column(Integer, ForeignKey("products.product_id"))
    score = Column(DECIMAL(5,2))
    reason = Column(String(255))
    user = relationship("User", back_populates="recommendations")
    product = relationship("Product")
