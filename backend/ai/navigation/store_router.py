from typing import Dict, List, Any, Optional
from .dijkstra import compute_all_pairs_distances

# A mock configurable supermarket graph for demonstration.
# In a real scenario, this could be loaded from a database or JSON file.
# Nodes are locations in the store. Weights are physical distances in meters.
DEFAULT_SUPERMARKET_GRAPH = {
    "Entrance": {"Aisle_1": 5.0, "Aisle_2": 8.0, "Checkout": 20.0},
    "Aisle_1": {"Entrance": 5.0, "Aisle_2": 3.0, "Aisle_3": 5.0},
    "Aisle_2": {"Entrance": 8.0, "Aisle_1": 3.0, "Aisle_4": 6.0},
    "Aisle_3": {"Aisle_1": 5.0, "Aisle_4": 4.0, "Aisle_5": 7.0},
    "Aisle_4": {"Aisle_2": 6.0, "Aisle_3": 4.0, "Aisle_6": 5.0},
    "Aisle_5": {"Aisle_3": 7.0, "Aisle_6": 4.0},
    "Aisle_6": {"Aisle_4": 5.0, "Aisle_5": 4.0, "Checkout": 10.0},
    "Checkout": {"Entrance": 20.0, "Aisle_6": 10.0}
}

def calculate_optimal_route(
    customer_location: str,
    selected_products: List[Dict[str, Any]],
    store_graph: Optional[Dict[str, Dict[str, float]]] = None
) -> Dict[str, Any]:
    """
    Calculates the shortest route that visits all required product locations,
    starting from `customer_location` and optionally ending at "Checkout".
    Uses Nearest Neighbor TSP approximation on top of Dijkstra all-pairs shortest paths.
    """
    if store_graph is None:
        store_graph = DEFAULT_SUPERMARKET_GRAPH
        
    # Map products to their locations (aisles)
    # If a product doesn't specify a location, we skip routing for it
    product_locations = set()
    location_to_products = {}
    
    for product in selected_products:
        loc = product.get("location")
        if loc and loc in store_graph:
            product_locations.add(loc)
            if loc not in location_to_products:
                location_to_products[loc] = []
            location_to_products[loc].append(product)
            
    # Nodes we MUST visit
    target_nodes = list(product_locations)
    
    if not target_nodes:
        return {
            "ordered_locations": [customer_location],
            "aisles": [customer_location],
            "total_distance": 0.0,
            "estimated_walking_time": 0.0
        }
        
    # We also need to include the start location in our distance matrix computation
    nodes_to_compute = list(set(target_nodes + [customer_location]))
    
    # Pre-compute shortest paths between all target nodes + start node
    dist_matrix = compute_all_pairs_distances(store_graph, nodes_to_compute)
    
    # Greedy TSP (Nearest Neighbor)
    current_node = customer_location
    unvisited = set(target_nodes)
    if current_node in unvisited:
        unvisited.remove(current_node)
        
    ordered_aisles = [current_node]
    full_path = [current_node]
    total_distance = 0.0
    
    while unvisited:
        # Find nearest unvisited neighbor
        nearest_node = None
        min_dist = float('inf')
        
        for candidate in unvisited:
            _, dist = dist_matrix[current_node][candidate]
            if dist < min_dist:
                min_dist = dist
                nearest_node = candidate
                
        if nearest_node is None:
            break # Unreachable node
            
        # Update path and distance
        path_to_next, dist_to_next = dist_matrix[current_node][nearest_node]
        
        # path_to_next includes the current_node at index 0, so we slice from [1:] to avoid duplication
        if len(path_to_next) > 1:
            full_path.extend(path_to_next[1:])
            
        ordered_aisles.append(nearest_node)
        total_distance += dist_to_next
        
        unvisited.remove(nearest_node)
        current_node = nearest_node
        
    # Optionally, we could add routing to Checkout at the end
    if "Checkout" in store_graph and current_node != "Checkout":
        try:
            from .dijkstra import dijkstra_shortest_path
            checkout_path, checkout_dist = dijkstra_shortest_path(store_graph, current_node, "Checkout")
            if checkout_path:
                if len(checkout_path) > 1:
                    full_path.extend(checkout_path[1:])
                ordered_aisles.append("Checkout")
                total_distance += checkout_dist
        except Exception:
            pass

    # Assuming average walking speed of 1.4 meters per second
    # Time in seconds
    estimated_time_sec = total_distance / 1.4
    estimated_time_min = estimated_time_sec / 60.0
    
    # Format product info for each step
    ordered_product_locations = []
    for aisle in ordered_aisles:
        if aisle in location_to_products:
            ordered_product_locations.append({
                "aisle": aisle,
                "products": location_to_products[aisle]
            })
            
    return {
        "ordered_product_locations": ordered_product_locations,
        "full_node_path": full_path,
        "aisles": ordered_aisles,
        "total_distance": round(total_distance, 2), # in meters
        "estimated_walking_time_minutes": round(estimated_time_min, 1)
    }
