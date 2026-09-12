from typing import List, Dict, Any, cast
from .deal_score import calculate_discount_benefit, calculate_price_impact
from .similarity import calculate_product_similarity
from .scoring import compute_final_score

def generate_recommendations(
    available_products: List[Dict[str, Any]],
    user_profile: Dict[str, Any],
    current_basket: List[Dict[str, Any]],
    remaining_budget: float
) -> List[Dict[str, Any]]:
    """
    Generate product recommendations based on a hybrid system.
    Returns a list of recommended products with their scores, classification, and reason.
    """
    recommendations = []
    
    past_purchases = user_profile.get("past_purchases", [])
    user_preferences = user_profile.get("preferences", [])
    
    for product in available_products:
        # Avoid recommending items already in the basket
        if any(item.get("id") == product.get("id") for item in current_basket):
            continue
            
        factors = {}
        
        # 1. Purchase frequency (based on past purchases similarity or ID match)
        purchase_count = sum(1 for p in past_purchases if p.get("id") == product.get("id"))
        factors["purchase_frequency"] = min(purchase_count / 5.0, 1.0)
        
        # 2. Customer preference (matching tags/categories)
        if product.get("category") in user_preferences or any(tag in user_preferences for tag in product.get("tags", [])):
            factors["customer_preference"] = 1.0
        else:
            factors["customer_preference"] = 0.0
            
        # 3. Product priority (can be a system-level priority flag, 0.0 to 1.0)
        factors["product_priority"] = product.get("priority", 0.5)
        
        # 4. Discount benefit
        factors["discount_benefit"] = calculate_discount_benefit(product)
        
        # 5. Price impact
        factors["price_impact"] = calculate_price_impact(product, remaining_budget)
        
        # 6. Current shopping basket (similarity)
        factors["current_basket_similarity"] = calculate_product_similarity(product, current_basket)
        
        # 7. Remaining budget (general budget health indicator)
        factors["remaining_budget"] = 1.0 if remaining_budget > 0 else 0.0
        
        # Compute normalized score and classification
        score, level, reason = compute_final_score(factors)
        
        recommendations.append({
            "product": product,
            "recommendation_score": score,
            "recommendation_level": level,
            "reason": reason,
            "price": product.get("price"),
            "discount": product.get("discount_percentage", 0.0),
            "budget_impact": product.get("price", 0.0)
        })
        
    # Sort by recommendation score descending
    recommendations.sort(key=lambda x: cast(float, x["recommendation_score"]), reverse=True)
    
    return recommendations
