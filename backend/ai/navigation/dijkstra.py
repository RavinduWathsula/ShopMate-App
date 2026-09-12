import heapq
from typing import Dict, List, Tuple

def dijkstra_shortest_path(graph: Dict[str, Dict[str, float]], start: str, end: str) -> Tuple[List[str], float]:
    """
    Computes the shortest path between `start` and `end` in a weighted `graph` using Dijkstra's algorithm.
    The graph is represented as an adjacency list: {node: {neighbor: weight}}.
    
    Returns a tuple: (list of nodes in the shortest path, total distance).
    If no path exists, returns ([], float('inf')).
    """
    if start not in graph:
        return [], float('inf')
        
    distances = {node: float('inf') for node in graph}
    distances[start] = 0
    previous: Dict[str, str] = {}
    
    # Priority queue: (distance, node)
    pq: List[Tuple[float, str]] = [(0.0, start)]
    
    while pq:
        current_distance, current_node = heapq.heappop(pq)
        
        # If we reached the target, we can stop early
        if current_node == end:
            break
            
        # Optimization: skip if we found a shorter path already
        if current_distance > distances[current_node]:
            continue
            
        for neighbor, weight in graph[current_node].items():
            distance = current_distance + weight
            
            # Only consider this new path if it's better
            if distance < distances.get(neighbor, float('inf')):
                distances[neighbor] = distance
                previous[neighbor] = current_node
                heapq.heappush(pq, (distance, neighbor))
                
    # Reconstruct path
    path = []
    current = end
    
    if distances.get(end, float('inf')) == float('inf'):
        return [], float('inf')
        
    while current is not None:
        path.append(current)
        current = previous.get(current)
        
    path.reverse()
    return path, distances[end]

def compute_all_pairs_distances(graph: Dict[str, Dict[str, float]], nodes: List[str]) -> Dict[str, Dict[str, Tuple[List[str], float]]]:
    """
    Computes the shortest path and distance between all pairs in the given `nodes` list.
    Returns a nested dictionary: distances[u][v] = (path_from_u_to_v, distance).
    """
    result = {node: {} for node in nodes}
    for i in range(len(nodes)):
        for j in range(i + 1, len(nodes)):
            u = nodes[i]
            v = nodes[j]
            path, dist = dijkstra_shortest_path(graph, u, v)
            
            result[u][v] = (path, dist)
            
            # Graph is assumed to be undirected for supermarket navigation
            # but we reverse the path for v -> u
            rev_path = list(reversed(path)) if path else []
            result[v][u] = (rev_path, dist)
            
    for node in nodes:
        result[node][node] = ([node], 0.0)
        
    return result
