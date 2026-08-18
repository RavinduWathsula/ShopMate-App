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
      name: 'Organic Bananas',
      brand: 'Nature Farm',
      category: 'Fruits',
      price: 2.99,
      discount: 0.0,
      imageUrl: 'https://images.unsplash.com/photo-1571501478200-85ba8161028e?auto=format&fit=crop&w=300&q=80',
      locationNodeId: 'A1',
    ),
    Product(
      id: 'p2',
      name: 'Whole Milk 1L',
      brand: 'DairyBest',
      category: 'Dairy',
      price: 1.50,
      discount: 0.10,
      imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=300&q=80',
      locationNodeId: 'B3',
    ),
    Product(
      id: 'p3',
      name: 'Whole Wheat Bread',
      brand: 'BakeryFresh',
      category: 'Bakery',
      price: 3.20,
      discount: 0.50,
      imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=300&q=80',
      locationNodeId: 'C2',
    ),
    Product(
      id: 'p4',
      name: 'Free Range Eggs (12)',
      brand: 'HappyHens',
      category: 'Dairy',
      price: 4.50,
      discount: 0.0,
      imageUrl: 'https://images.unsplash.com/photo-1598965402089-897ce52e8355?auto=format&fit=crop&w=300&q=80',
      locationNodeId: 'B3',
    ),
    Product(
      id: 'p5',
      name: 'Avocado',
      brand: 'GreenLife',
      category: 'Vegetables',
      price: 1.20,
      discount: 0.20,
      imageUrl: 'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?auto=format&fit=crop&w=300&q=80',
      locationNodeId: 'A2',
    ),
  ];
}
