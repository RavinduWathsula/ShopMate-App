from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import auth, products, shops, shopping, ai

app = FastAPI(
    title="ShopMate API",
    description="Backend REST APIs for the ShopMate AI-assisted shopping application.",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(products.router)
app.include_router(shops.router)
app.include_router(shopping.router)
app.include_router(ai.router)

@app.get("/")
def root():
    return {"message": "Welcome to ShopMate API. Visit /docs for Swagger UI"}

