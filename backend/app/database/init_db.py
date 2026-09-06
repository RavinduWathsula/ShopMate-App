import logging
from sqlalchemy.orm import Session
try:
    from app.database.database import engine, Base, SessionLocal
    from app.models.models import (
        User, Shop, Category, Discount, Product, Inventory,
        ProductLocation, ShoppingSession, ShoppingItem, Recommendation
    )
    from app.utils.security import get_password_hash
except ImportError:
    from backend.app.database.database import engine, Base, SessionLocal
    from backend.app.models.models import (
        User, Shop, Category, Discount, Product, Inventory,
        ProductLocation, ShoppingSession, ShoppingItem, Recommendation
    )
    from backend.app.utils.security import get_password_hash


logger = logging.getLogger("shopmate.init_db")

def init_db():
    Base.metadata.create_all(bind=engine)
    db: Session = SessionLocal()
    try:
        # Check if already seeded
        if db.query(Shop).first() is not None:
            return

        logger.info("Seeding initial data into database...")

        # 1. User
        user = User(
            email="testuser@shopmate.com",
            password_hash=get_password_hash("password123"),
            preferences_json={"dietary": ["vegan"], "max_budget_default": 100.00}
        )
        db.add(user)
        db.commit()
        db.refresh(user)

        # 2. Shop
        shop = Shop(
            name="FreshMart Downtown",
            address="123 Market St",
            city="Metropolis"
        )
        db.add(shop)
        db.commit()
        db.refresh(shop)

        # 3. Categories
        cat_produce = Category(id=1, name="Produce", parent_id=None)
        cat_fruits = Category(id=2, name="Fruits", parent_id=1)
        cat_vegetables = Category(id=3, name="Vegetables", parent_id=1)
        cat_dairy = Category(id=4, name="Dairy & Eggs", parent_id=None)
        cat_milk = Category(id=5, name="Milk", parent_id=4)
        cat_bakery = Category(id=6, name="Bakery", parent_id=None)
        cat_bread = Category(id=7, name="Bread", parent_id=6)

        db.add_all([cat_produce, cat_fruits, cat_vegetables, cat_dairy, cat_milk, cat_bakery, cat_bread])
        db.commit()

        # 4. Discounts
        d1 = Discount(id=1, name="10% Off Produce", discount_type="percentage", value=10.00)
        d2 = Discount(id=2, name="Weekly Bread Special", discount_type="fixed", value=0.50)
        db.add_all([d1, d2])
        db.commit()

        # 5. Products
        p1 = Product(
            product_id=1,
            shop_id=shop.id,
            category_id=1,
            subcategory_id=2,
            product_name="Organic Bananas",
            brand="Nature Farm",
            weight=1.0,
            normal_price=2.99,
            discount_id=None,
            discount_price=None,
            discount_percentage=None,
            priority_score=100
        )
        p2 = Product(
            product_id=2,
            shop_id=shop.id,
            category_id=4,
            subcategory_id=5,
            product_name="Whole Milk 1 Gallon",
            brand="DairyBest",
            weight=3.78,
            normal_price=3.50,
            discount_id=None,
            discount_price=None,
            discount_percentage=None,
            priority_score=90
        )
        p3 = Product(
            product_id=3,
            shop_id=shop.id,
            category_id=6,
            subcategory_id=7,
            product_name="Sourdough Loaf",
            brand="BakeryFresh",
            weight=0.5,
            normal_price=4.00,
            discount_id=2,
            discount_price=3.50,
            discount_percentage=None,
            priority_score=80
        )
        p4 = Product(
            product_id=4,
            shop_id=shop.id,
            category_id=1,
            subcategory_id=3,
            product_name="Avocado",
            brand="GreenLife",
            weight=0.2,
            normal_price=1.50,
            discount_id=1,
            discount_price=1.35,
            discount_percentage=10.00,
            priority_score=85
        )
        db.add_all([p1, p2, p3, p4])
        db.commit()

        # 6. Inventory
        inv1 = Inventory(product_id=1, shop_id=shop.id, stock_quantity=150)
        inv2 = Inventory(product_id=2, shop_id=shop.id, stock_quantity=40)
        inv3 = Inventory(product_id=3, shop_id=shop.id, stock_quantity=20)
        inv4 = Inventory(product_id=4, shop_id=shop.id, stock_quantity=80)
        db.add_all([inv1, inv2, inv3, inv4])

        # 7. Locations
        loc1 = ProductLocation(product_id=1, shop_id=shop.id, aisle="A1", section="Produce", shelf="Top", x_position=10.5, y_position=20.0)
        loc2 = ProductLocation(product_id=2, shop_id=shop.id, aisle="B3", section="Dairy", shelf="Bottom", x_position=30.0, y_position=45.5)
        loc3 = ProductLocation(product_id=3, shop_id=shop.id, aisle="C2", section="Bakery", shelf="Middle", x_position=15.0, y_position=60.2)
        loc4 = ProductLocation(product_id=4, shop_id=shop.id, aisle="A1", section="Produce", shelf="Middle", x_position=12.0, y_position=20.0)
        db.add_all([loc1, loc2, loc3, loc4])

        # 8. Shopping Session
        sess = ShoppingSession(user_id=user.id, shop_id=shop.id, status="active", budget_limit=50.00)
        db.add(sess)
        db.commit()
        db.refresh(sess)

        # 9. Shopping Items
        item1 = ShoppingItem(session_id=sess.id, product_id=1, quantity=2, price_at_time=2.99)
        item2 = ShoppingItem(session_id=sess.id, product_id=2, quantity=1, price_at_time=3.50)
        db.add_all([item1, item2])

        # 10. Recommendations
        rec1 = Recommendation(user_id=user.id, product_id=3, score=85.50, reason="Frequently bought with Milk")
        rec2 = Recommendation(user_id=user.id, product_id=4, score=92.00, reason="Matches Vegan preference and on sale")
        db.add_all([rec1, rec2])

        db.commit()
        logger.info("Seeding completed successfully.")
    except Exception as e:
        logger.error(f"Error seeding database: {e}")
        db.rollback()
    finally:
        db.close()
