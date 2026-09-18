import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopmate/presentation/product_details_screen.dart';

void main() {
  testWidgets('ProductDetailsScreen layout test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ProductDetailsScreen(
              productData: {
                'id': 'fresh_milk',
                'name': 'Pasteurized Fresh Milk 1L',
                'brand': 'Kotmale',
                'size': '1000 ml',
                'price': 450,
                'originalPrice': 520,
                'discountText': '13% OFF',
                'location': 'Aisle 2 • Dairy',
                'imageUrl': 'assets/images/products/fresh_milk_bottle_1789196429739.jpg',
                'category': 'General',
              },
            ),
          ),
        ),
      ),
    );
    
    // Wait for animations/images
    await tester.pumpAndSettle();
    
    expect(find.byType(ProductDetailsScreen), findsOneWidget);
  });
}
