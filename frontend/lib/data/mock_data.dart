import '../models/product.dart';
import '../models/store.dart';

class MockData {
  static const List<Store> stores = [
    Store(
      id: '1',
      name: 'FreshMart Downtown',
      address: '123 Main St, Cityville',
      imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=600&q=80',
    ),
    Store(
      id: '2',
      name: 'SuperFoods Westside',
      address: '456 West Ave, Cityville',
      imageUrl: 'https://images.unsplash.com/photo-1578916171728-46686eac8d58?auto=format&fit=crop&w=600&q=80',
    ),
  ];

  static const List<Product> products = [
    Product(
      id: 'p1',
      name: 'Fresh Milk 1L',
      brand: 'Highland',
      category: 'Dairy',
      price: 500.0,
      discount: 50.0,
      imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=300&q=80',
      locationNodeId: 'A1',
    ),
    Product(
      id: 'p2',
      name: 'Samba Rice 5kg',
      brand: 'Araliya',
      category: 'Grocery',
      price: 1250.0,
      discount: 0.0,
      imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&w=300&q=80',
      locationNodeId: 'B3',
    ),
    Product(
      id: 'p3',
      name: 'Sliced Bread',
      brand: 'Prima',
      category: 'Bakery',
      price: 300.0,
      discount: 20.0,
      imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=300&q=80',
      locationNodeId: 'C2',
    ),
    Product(
      id: 'p4',
      name: 'Free Range Eggs (10)',
      brand: 'HappyHens',
      category: 'Dairy',
      price: 650.0,
      discount: 0.0,
      imageUrl: 'https://images.unsplash.com/photo-1598965402089-897ce52e8355?auto=format&fit=crop&w=300&q=80',
      locationNodeId: 'B3',
    ),
    Product(
      id: 'p5',
      name: 'Lifebuoy Soap',
      brand: 'Unilever',
      category: 'Personal Care',
      price: 150.0,
      discount: 0.0,
      imageUrl: 'https://images.unsplash.com/photo-1600857062241-98e5dba7f214?auto=format&fit=crop&w=300&q=80',
      locationNodeId: 'A2',
    ),
  ];
}

