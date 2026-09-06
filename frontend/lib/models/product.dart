class Product {
  final String id;
  final String name;
  final String brand;
  final String category;
  final double price;
  final double discount;
  final String imageUrl;
  final String locationNodeId;

  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.price,
    required this.discount,
    required this.imageUrl,
    required this.locationNodeId,
  });

  double get finalPrice => price - discount;
}

