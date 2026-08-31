import json
from backend.ai.recommendation.knapsack_optimizer import optimize_basket

def test_optimization_engine():
    budget = 15.00
    
    # Original cart: total is $18.00 (Exceeds $15.00 budget)
    cart_products = [
        {"id": "c1", "name": "Premium Coffee", "category": "Beverage", "price": 10.00, "priority": 0.9},
        {"id": "c2", "name": "Luxury Chocolate", "category": "Snacks", "price": 5.00, "priority": 0.4},
        {"id": "c3", "name": "Almonds", "category": "Snacks", "price": 3.00, "priority": 0.6}
    ]
    
    # Alternatives available
    alternative_products = [
        {"id": "a1", "name": "Standard Coffee", "category": "Beverage", "price": 7.00, "priority": 0.7},
        {"id": "a2", "name": "Basic Chocolate", "category": "Snacks", "price": 2.00, "priority": 0.3}
    ]
    
    result = optimize_basket(budget, cart_products, alternative_products)
    
    print("--- ShopMate Basket Optimization ---")
    print(f"Original Total: ${result['original_total']}")
    print(f"Optimized Total: ${result['optimized_total']}")
    print(f"Total Saving: ${result['saving']} ({result['saving_percentage']}%)")
    
    print("\nProducts kept in basket:")
    for p in result['selected_products']:
        print(f" - {p['name']} (${p['price']})")
        
    print("\nSuggested Removals:")
    for r in result['removed_products']:
        print(f" - {r['explanation']['title']}: {r['explanation']['reasons'][0]}...")
        
    print("\nSuggested Replacements:")
    for rep in result['replacement_suggestions']:
        print(f" - {rep['explanation']['title']}: {rep['explanation']['reasons'][0]}...")
        
if __name__ == "__main__":
    test_optimization_engine()
