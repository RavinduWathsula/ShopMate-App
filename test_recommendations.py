import json
from backend.ai.recommendation.recommendation_engine import generate_recommendations

def test_recommendation_engine():
    # Mock data
    available_products = [
        {
            "id": "p1",
            "name": "Organic Bananas",
            "category": "Produce",
            "description": "Fresh organic bananas",
            "tags": ["fruit", "organic"],
            "price": 2.50,
            "original_price": 3.00,
            "discount_percentage": 16.67,
            "priority": 0.8
        },
        {
            "id": "p2",
            "name": "Whole Milk",
            "category": "Dairy",
            "description": "1 gallon whole milk",
            "tags": ["milk", "dairy"],
            "price": 4.00,
            "original_price": 4.00,
            "discount_percentage": 0.0,
            "priority": 0.5
        },
        {
            "id": "p3",
            "name": "Luxury Chocolate",
            "category": "Snacks",
            "description": "Imported dark chocolate",
            "tags": ["chocolate", "sweet"],
            "price": 15.00,
            "original_price": 15.00,
            "discount_percentage": 0.0,
            "priority": 0.3
        },
        {
            "id": "p4",
            "name": "Apples",
            "category": "Produce",
            "description": "Crisp red apples",
            "tags": ["fruit"],
            "price": 3.00,
            "original_price": 6.00,
            "discount_percentage": 50.0,
            "priority": 0.9
        }
    ]
    
    user_profile = {
        "preferences": ["Produce", "organic", "fruit"],
        "past_purchases": [
            {"id": "p1", "name": "Organic Bananas"}
        ]
    }
    
    current_basket = [
        {"id": "p1", "name": "Organic Bananas", "category": "Produce", "tags": ["fruit"]}
    ]
    
    remaining_budget = 10.00
    
    recommendations = generate_recommendations(
        available_products=available_products,
        user_profile=user_profile,
        current_basket=current_basket,
        remaining_budget=remaining_budget
    )
    
    for rec in recommendations:
        print(f"Product: {rec['product']['name']}")
        print(f"Score: {rec['recommendation_score']} - {rec['recommendation_level']}")
        print(f"Reason: {rec['reason']}")
        print(f"Price: {rec['price']} | Discount: {rec['discount']}%")
        print("-" * 40)

if __name__ == "__main__":
    test_recommendation_engine()
