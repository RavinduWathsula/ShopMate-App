import json
from backend.ai.navigation.store_router import calculate_optimal_route

def test_navigation():
    # Customer is at the entrance
    customer_location = "Entrance"
    
    # Needs Milk (Aisle 4), Bread (Aisle 1), and Apples (Aisle 5)
    products = [
        {"id": "p1", "name": "Bread", "location": "Aisle_1"},
        {"id": "p2", "name": "Milk", "location": "Aisle_4"},
        {"id": "p3", "name": "Apples", "location": "Aisle_5"}
    ]
    
    print("Testing store navigation route generation...\n")
    route_data = calculate_optimal_route(customer_location, products)
    
    print("Aisles to visit (Ordered):")
    for idx, aisle in enumerate(route_data["aisles"]):
        print(f"{idx + 1}. {aisle}")
        
    print(f"\nTotal Distance: {route_data['total_distance']} meters")
    print(f"Estimated Time: {route_data['estimated_walking_time_minutes']} minutes")
    print("\nDetailed Node Path:")
    print(" -> ".join(route_data["full_node_path"]))

if __name__ == "__main__":
    test_navigation()
