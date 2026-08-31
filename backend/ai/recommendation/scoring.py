from typing import Dict, Any, Tuple

def get_recommendation_classification(score: float) -> str:
    """
    Classify the score into categories.
    80-100 = Highly Recommended
    60-79 = Recommended
    40-59 = Consider
    0-39 = Low Priority
    """
    if score >= 80:
        return "Highly Recommended"
    elif score >= 60:
        return "Recommended"
    elif score >= 40:
        return "Consider"
    else:
        return "Low Priority"

def generate_reason(factors: Dict[str, float], classification: str) -> str:
    """
    Generate a human-readable explanation based on the dominant factors.
    """
    reasons = []
    
    if factors.get("purchase_frequency", 0) > 0.6:
        reasons.append("you frequently purchase this category")
    elif factors.get("customer_preference", 0) > 0.6:
        reasons.append("it matches your known preferences")
        
    if factors.get("discount_benefit", 0) > 0.5:
        reasons.append("the product is currently discounted")
        
    if factors.get("current_basket_similarity", 0) > 0.5:
        reasons.append("it complements items in your current shopping basket")
        
    if factors.get("price_impact", 0) > 0.5:
        reasons.append("it fits well within your remaining budget")
    elif factors.get("price_impact", 0) < 0.2:
        reasons.append("it will consume a significant portion of your remaining budget")
        
    if not reasons:
        reasons.append("it is a popular item right now")
        
    reason_text = f"{classification} because "
    if len(reasons) == 1:
        reason_text += reasons[0] + "."
    elif len(reasons) == 2:
        reason_text += reasons[0] + " and " + reasons[1] + "."
    else:
        reason_text += ", ".join(reasons[:-1]) + ", and " + reasons[-1] + "."
        
    return reason_text

def compute_final_score(factors: Dict[str, float]) -> Tuple[int, str, str]:
    """
    Compute the final recommendation score from 0 to 100 based on the 7 factors.
    Returns (score, classification, reason).
    """
    # Factor weights
    weights = {
        "purchase_frequency": 0.20,
        "customer_preference": 0.15,
        "product_priority": 0.10,
        "discount_benefit": 0.20,
        "price_impact": 0.15,
        "current_basket_similarity": 0.10,
        "remaining_budget": 0.10
    }
    
    total_score = 0.0
    for key, weight in weights.items():
        total_score += factors.get(key, 0.0) * weight
        
    normalized_score = int(min(max(total_score * 100, 0), 100))
    classification = get_recommendation_classification(normalized_score)
    reason = generate_reason(factors, classification)
    
    return normalized_score, classification, reason
