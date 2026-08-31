import json
from backend.ai.prediction.spending_model import spending_predictor

def test_spending_prediction():
    print("--- Training Models and Calculating Genuine Metrics ---")
    metrics = spending_predictor.train()
    
    print("\nModel Comparison (Test Set Metrics):")
    for model_name, model_metrics in metrics.items():
        if model_name != "Selected Model":
            print(f"\n{model_name}:")
            for metric, value in model_metrics.items():
                print(f"  - {metric}: {value}")
                
    print(f"\nModel Selected for Inference: {metrics['Selected Model']}")
    
    print("\n--- Running Risk Predictions ---")
    
    # Test Scenario 1: SAFE
    safe_features = {
        'budget': 200.0,
        'number_of_items': 5,
        'average_item_price': 10.0,
        'discount_amount': 5.0,
        'category_count': 2,
        'previous_average_spending': 50.0
    }
    
    # Test Scenario 2: OVER_BUDGET
    over_features = {
        'budget': 50.0,
        'number_of_items': 15,
        'average_item_price': 12.0,
        'discount_amount': 2.0,
        'category_count': 5,
        'previous_average_spending': 200.0
    }
    
    # Test Scenario 3: WARNING
    warning_features = {
        'budget': 100.0,
        'number_of_items': 10,
        'average_item_price': 8.5,
        'discount_amount': 5.0,
        'category_count': 3,
        'previous_average_spending': 95.0
    }
    
    scenarios = [
        ("Safe Scenario", safe_features),
        ("Over Budget Scenario", over_features),
        ("Warning Scenario", warning_features)
    ]
    
    for name, features in scenarios:
        print(f"\nTesting {name}:")
        print(f"  Budget: ${features['budget']}")
        result = spending_predictor.predict_spending_risk(features)
        print(f"  Predicted Total: ${result['predicted_total']}")
        print(f"  Remaining Budget: ${result['remaining_budget']}")
        print(f"  Risk Level: {result['risk_level']}")

if __name__ == "__main__":
    test_spending_prediction()
