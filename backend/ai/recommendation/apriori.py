from typing import List, Dict, Any, Set, Tuple
from collections import defaultdict

def calculate_apriori_metrics(
    transactions: List[List[str]],
    min_support: float = 0.1
) -> Dict[Tuple[str, str], Dict[str, float]]:
    """
    Given a list of transactions (each is a list of product IDs),
    calculate support, confidence, and lift for item pairs (A -> B).
    Returns a dictionary mapping (A, B) to their metrics.
    """
    total_transactions = len(transactions)
    if total_transactions == 0:
        return {}
        
    # Calculate support for individual items
    item_counts = defaultdict(int)
    for transaction in transactions:
        for item in set(transaction):
            item_counts[item] += 1
            
    # Filter items by min_support
    frequent_items = {
        item for item, count in item_counts.items() 
        if count / total_transactions >= min_support
    }
    
    # Calculate support for pairs
    pair_counts = defaultdict(int)
    for transaction in transactions:
        items = list(set(transaction))
        for i in range(len(items)):
            for j in range(i + 1, len(items)):
                a, b = items[i], items[j]
                if a in frequent_items and b in frequent_items:
                    pair_counts[(a, b)] += 1
                    pair_counts[(b, a)] += 1
                    
    # Calculate metrics for pairs
    rules = {}
    for (a, b), count in pair_counts.items():
        support_a = item_counts[a] / total_transactions
        support_b = item_counts[b] / total_transactions
        support_ab = count / total_transactions
        
        confidence = support_ab / support_a if support_a > 0 else 0
        lift = confidence / support_b if support_b > 0 else 0
        
        rules[(a, b)] = {
            "support": round(support_ab, 4),
            "confidence": round(confidence, 4),
            "lift": round(lift, 4)
        }
        
    return rules

def get_associations_for_product(
    product_id: str,
    transactions: List[List[str]],
    product_catalog: Dict[str, str],
    min_support: float = 0.1,
    min_confidence: float = 0.2
) -> List[Dict[str, Any]]:
    """
    Get formatted recommendations for a specific product based on Apriori metrics.
    """
    rules = calculate_apriori_metrics(transactions, min_support)
    
    recommendations = []
    
    for (a, b), metrics in rules.items():
        if a == product_id and metrics["confidence"] >= min_confidence:
            # We found a rule A -> B
            b_name = product_catalog.get(b, f"Product {b}")
            a_name = product_catalog.get(a, f"Product {a}")
            
            explanation = f"Frequently purchased together with {a_name}."
            
            recommendations.append({
                "product_id": b,
                "product_name": b_name,
                "support": metrics["support"],
                "confidence": metrics["confidence"],
                "lift": metrics["lift"],
                "explanation": explanation
            })
            
    # Sort by lift, then confidence
    recommendations.sort(key=lambda x: (x["lift"], x["confidence"]), reverse=True)
    
    return recommendations
