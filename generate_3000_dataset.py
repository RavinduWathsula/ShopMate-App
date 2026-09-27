import os
import random
import string
from PIL import Image, ImageDraw

try:
    from backend.app.database.database import SessionLocal, engine
    from backend.app.models.models import Base, Product, Shop, Category
except ImportError:
    import sys
    sys.path.append(os.path.join(os.path.dirname(__file__), 'backend'))
    from app.database.database import SessionLocal, engine
    from app.models.models import Base, Product, Shop, Category

def generate_db_products(num_products=3000):
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    
    # Ensure there's a shop
    shop = db.query(Shop).first()
    if not shop:
        shop = Shop(name="SuperMart Mega", address="456 Main St", city="Metropolis")
        db.add(shop)
        db.commit()
        db.refresh(shop)
        
    # Categories
    categories = db.query(Category).all()
    if not categories:
        cat_names = ['Produce', 'Dairy', 'Bakery', 'Meat', 'Pantry', 'Frozen']
        categories = []
        for i, name in enumerate(cat_names, 1):
            cat = Category(name=name)
            db.add(cat)
            categories.append(cat)
        db.commit()
    
    brands = ['Nature Farm', 'BestChoice', 'ValuePlus', 'Premium', 'OrganicLife', 'DailyFresh']
    adjectives = ['Fresh', 'Organic', 'Tasty', 'Premium', 'Classic', 'Spicy', 'Sweet']
    nouns = ['Apples', 'Milk', 'Bread', 'Chicken', 'Rice', 'Pizza', 'Cheese', 'Juice']
    
    print(f"Generating {num_products} products in database...")
    existing_count = db.query(Product).count()
    
    products_to_add = []
    for i in range(existing_count + 1, existing_count + num_products + 1):
        cat = random.choice(categories)
        brand = random.choice(brands)
        name = f"{random.choice(adjectives)} {random.choice(nouns)} {i}"
        
        price = round(random.uniform(1.0, 50.0), 2)
        weight = round(random.uniform(0.1, 5.0), 2)
        
        p = Product(
            shop_id=shop.id,
            category_id=cat.id,
            product_name=name,
            brand=brand,
            weight=weight,
            normal_price=price,
            priority_score=random.randint(50, 100)
        )
        products_to_add.append(p)
        
        if len(products_to_add) >= 500:
            db.bulk_save_objects(products_to_add)
            db.commit()
            products_to_add = []
            
    if products_to_add:
        db.bulk_save_objects(products_to_add)
        db.commit()
        
    print(f"Successfully added products. Total products in DB: {db.query(Product).count()}")
    db.close()

def generate_image_dataset(num_products=3000):
    base_dir = "dataset"
    raw_dir = os.path.join(base_dir, "raw")
    os.makedirs(raw_dir, exist_ok=True)
    
    print(f"Generating image placeholders for {num_products} products (3 images each)...")
    
    # To save time, we will only create the directories and a simple text file or 1 small image, 
    # but the prompt asked for the dataset. We'll make tiny fast images.
    for i in range(1, num_products + 1):
        product_dir = os.path.join(raw_dir, f"product_{i:04d}")
        if not os.path.exists(product_dir):
            os.makedirs(product_dir)
            
            # Create just 1 small placeholder to save time, or 3 if really needed.
            # We'll create 3 very small ones to be fast
            for j in range(1, 4):
                placeholder_path = os.path.join(product_dir, f"image{j:03d}.jpg")
                img = Image.new('RGB', (100, 100), color = (random.randint(0,255), random.randint(0,255), random.randint(0,255)))
                img.save(placeholder_path)
                
        if i % 500 == 0:
            print(f"Generated images for {i} products...")
            
    print("Dataset directory structure with images created successfully.")

if __name__ == "__main__":
    generate_db_products(3000)
    generate_image_dataset(3000)
