import json
from backend.ai.recommendation.apriori import get_associations_for_product

def test_apriori():
    # Test data
    mock_transactions = [
        ["p1", "p2", "p3"],
        ["p1", "p2"],
        ["p2", "p3"],
        ["p1", "p2", "p4"],
        ["p1", "p4"],
    ]
    mock_catalog = {
        "p1": "Bread",
        "p2": "Butter",
        "p3": "Jam",
        "p4": "Milk"
    }
    
    # Test Bread (p1)
    print("Testing recommendations for Bread (p1):")
    bread_recs = get_associations_for_product(
        product_id="p1",
        transactions=mock_transactions,
        product_catalog=mock_catalog,
        min_support=0.1,
        min_confidence=0.1
    )
    
    for rec in bread_recs:
        print(f"- {rec['product_name']} (Support: {rec['support']}, Confidence: {rec['confidence']}, Lift: {rec['lift']})")
        print(f"  Explanation: {rec['explanation']}")

if __name__ == "__main__":
    test_apriori()
