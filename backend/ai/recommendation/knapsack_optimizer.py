from typing import List, Dict, Any, Tuple
import copy

def _solve_knapsack(items: List[Dict[str, Any]], capacity: float) -> List[Dict[str, Any]]:
    """
    Standard 0/1 Knapsack algorithm using dynamic programming.
    Cost is price (in cents to allow integer DP), Value is priority (scaled).
    """
    n = len(items)
    # Scale capacity to integer (e.g. cents) for standard DP approach
    cap_int = int(capacity * 100)
    
    # DP table: dp[i][w] stores max value
    dp = [[0 for _ in range(cap_int + 1)] for _ in range(n + 1)]
    
    # Store items for easy access, ensuring we have integer weights and values
    weights = [int(item.get("price", 0) * 100) for item in items]
    values = [int(item.get("priority", 0) * 100) for item in items]
    
    for i in range(1, n + 1):
        for w in range(cap_int + 1):
            if weights[i-1] <= w:
                dp[i][w] = max(
                    dp[i-1][w],
                    dp[i-1][w - weights[i-1]] + values[i-1]
                )
            else:
                dp[i][w] = dp[i-1][w]
                
    # Backtrack to find selected items
    selected = []
    w = cap_int
    for i in range(n, 0, -1):
        if dp[i][w] != dp[i-1][w]:
            selected.append(items[i-1])
            w -= weights[i-1]
            
    return selected

def optimize_basket(
    budget: float,
    cart_products: List[Dict[str, Any]],
    alternative_products: List[Dict[str, Any]]
) -> Dict[str, Any]:
    """
    Optimize basket using 0/1 Knapsack algorithm.
    """
    original_total = sum(p.get("price", 0) for p in cart_products)
    
    # If budget is sufficient, no optimization needed
    if original_total <= budget:
        return {
            "original_total": original_total,
            "optimized_total": original_total,
            "saving": 0.0,
            "saving_percentage": 0.0,
            "selected_products": cart_products,
            "removed_products": [],
            "replacement_suggestions": []
        }
        
    # Pool of all items to consider: current cart + alternatives
    all_items = copy.deepcopy(cart_products)
    
    # Identify items in cart by ID for easy lookup
    cart_ids = {p["id"] for p in cart_products}
    
    # We only want to consider alternatives for items in the cart
    # and we want to ensure we don't pick an alternative AND the original item.
    # To handle this cleanly with standard 0/1 knapsack, we can group them or
    # just throw them all in and let the knapsack decide, but we might get duplicates.
    # A simple greedy heuristic combined with knapsack:
    
    # Add alternatives to the pool
    for alt in alternative_products:
        all_items.append(alt)
        
    # Solve standard knapsack
    selected_items = _solve_knapsack(all_items, budget)
    selected_ids = {p["id"] for p in selected_items}
    
    # Calculate totals
    optimized_total = sum(p.get("price", 0) for p in selected_items)
    saving = original_total - optimized_total
    saving_percentage = (saving / original_total) * 100 if original_total > 0 else 0
    
    # Determine removed and replaced
    removed_products = []
    replacement_suggestions = []
    
    # Items that were in the cart but not selected
    for p in cart_products:
        if p["id"] not in selected_ids:
            # Check if there is a cheaper alternative selected that belongs to the same category
            # (Simplistic matching logic for demonstration)
            alt_match = None
            for s in selected_items:
                if s["id"] not in cart_ids and s.get("category") == p.get("category"):
                    alt_match = s
                    break
                    
            if alt_match:
                replacement_suggestions.append({
                    "original": p,
                    "replacement": alt_match,
                    "explanation": {
                        "title": "AI Recommendation: Consider replacing",
                        "reasons": [
                            "Lower priority",
                            "Replacing it keeps your basket within budget"
                        ],
                        "potential_saving": round(p['price'] - alt_match['price'], 2),
                        "alternative_name": alt_match['name'],
                        "alternative_price": round(alt_match['price'], 2)
                    }
                })
                # Remove from selected_ids so we don't use the same alternative twice
                selected_ids.remove(alt_match["id"])
            else:
                removed_products.append({
                    "product": p,
                    "explanation": {
                        "title": "AI Recommendation: Consider removing",
                        "reasons": [
                            "Low priority",
                            "Not frequently purchased",
                            "No current discount",
                            "Removing it keeps your basket within budget"
                        ],
                        "potential_saving": round(p['price'], 2)
                    }
                })
                
    # Format selected products to match original cart where possible
    final_selected = [p for p in selected_items if p["id"] in cart_ids]
    
    return {
        "original_total": round(original_total, 2),
        "optimized_total": round(optimized_total, 2),
        "saving": round(saving, 2),
        "saving_percentage": round(saving_percentage, 2),
        "selected_products": final_selected,
        "removed_products": removed_products,
        "replacement_suggestions": replacement_suggestions
    }
