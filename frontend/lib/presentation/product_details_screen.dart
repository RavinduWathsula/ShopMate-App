import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/cart_provider.dart';
import '../providers/api_providers.dart';
import '../utils/constants.dart';

class ProductDetailsScreen extends ConsumerWidget {
  final String productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.pinkAccent),
            onPressed: () {},
          )
        ],
      ),
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
        data: (product) => Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image Hero
                    Container(
                      height: 350,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppConstants.cardColor,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Mocking the viewfinder bracket from the design
                            Container(
                              width: 250,
                              height: 250,
                              decoration: BoxDecoration(
                                border: Border.all(color: AppConstants.primaryColor.withValues(alpha: 0.3), width: 2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            Image.network(
                              product.imageUrl,
                              height: 220,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.local_drink, size: 100, color: Colors.white24),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.all(AppConstants.paddingLarge),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text(
                                '\$${product.finalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(width: 8),
                              if (product.discount > 0) ...[
                                Text(
                                  '\$${product.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white54,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppConstants.primaryColor.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${((product.discount / product.price) * 100).toInt()}% OFF',
                                    style: const TextStyle(color: AppConstants.primaryColor, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.star, color: AppConstants.accentColor, size: 16),
                              const SizedBox(width: 4),
                              const Text('4.5 (120)', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              const Spacer(),
                              const Icon(Icons.check_circle, color: AppConstants.secondaryColor, size: 16),
                              const SizedBox(width: 4),
                              const Text('In Stock', style: TextStyle(color: AppConstants.secondaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 32),
                          const Text('Product Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          const Text(
                            'Refreshing and original taste\nSoft drink\n500ml bottle\nCategory: Beverages',
                            style: TextStyle(color: Colors.white70, height: 1.6),
                          ),
                          const SizedBox(height: 32),
                          const Text('Best Price & Offers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          
                          // Offer Card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppConstants.cardColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Food City', style: TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text('17% OFF', style: TextStyle(color: AppConstants.secondaryColor, fontSize: 12)),
                                  ],
                                ),
                                const Spacer(),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('\$${product.finalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white30, fontSize: 12, decoration: TextDecoration.lineThrough)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom Add to Cart Button
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppConstants.backgroundColor,
                border: Border(top: BorderSide(color: Colors.white10)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(cartProvider.notifier).addItem(product, 1);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Added to Cart'),
                        backgroundColor: AppConstants.primaryColor,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Add to Cart', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
