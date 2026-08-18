import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';
import '../utils/constants.dart';

class SmartBasketScreen extends ConsumerWidget {
  const SmartBasketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final notifier = ref.read(cartProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Smart Basket')),
      body: cart.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_basket_outlined, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Your basket is empty',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 18),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppConstants.padding),
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final item = cart[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
                  child: ListTile(
                    leading: Image.network(
                      item.product.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.image),
                    ),
                    title: Text(item.product.name),
                    subtitle: Text('Qty: ${item.quantity}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '\$${item.totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => notifier.removeItem(item.product.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(AppConstants.padding),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: \$${notifier.totalAmount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                onPressed: cart.isEmpty ? null : () {},
                child: const Text('Checkout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
