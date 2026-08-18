from fastapi import FastAPI
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
