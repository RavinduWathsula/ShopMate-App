def calculate_discount_benefit(product: dict) -> float:
    """
    Calculate a normalized discount benefit score (0.0 to 1.0).
    Assumes product has 'price' and 'original_price' or 'discount_percentage'.
    """
    discount = product.get("discount_percentage", 0.0)
    if discount == 0.0:
        price = product.get("price", 0)
        original_price = product.get("original_price", price)
        if original_price > 0 and original_price > price:
            discount = ((original_price - price) / original_price) * 100
            
    # Normalize: e.g., 50% discount or more gives a score of 1.0
    benefit_score = min(discount / 50.0, 1.0)
    return benefit_score

def calculate_price_impact(product: dict, remaining_budget: float) -> float:
    """
    Calculate the price impact score (0.0 to 1.0).
    A score of 1.0 means it comfortably fits in the budget.
    A score of 0.0 means it exceeds the budget.
    """
    price = product.get("price", 0.0)
    if remaining_budget <= 0:
        return 0.0 if price > 0 else 1.0
        
    if price > remaining_budget:
        return 0.0
        
    # Example logic: if it consumes less than 20% of the budget, it has high impact score (1.0).
    # If it consumes the entire budget, score goes down to 0.5.
    ratio = price / remaining_budget
    impact_score = max(0.5, 1.0 - (ratio / 2))
    return impact_score
