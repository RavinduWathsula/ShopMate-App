import 'package:flutter/material.dart';
import '../utils/constants.dart';

class BudgetSetupScreen extends StatelessWidget {
  const BudgetSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('My Budget'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Monthly Budget', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            const Text('\$200.00', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Spent: \$120.50', style: TextStyle(fontSize: 12, color: Colors.white70)),
                    Text('Warning: 51% hit', style: TextStyle(fontSize: 10, color: AppConstants.accentColor)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Remaining', style: TextStyle(fontSize: 12, color: Colors.white70)),
                    const Text('\$79.50', style: TextStyle(fontSize: 12, color: AppConstants.secondaryColor, fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: 0.6, // 120.50 / 200.00
                backgroundColor: Colors.white12,
                color: AppConstants.secondaryColor,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 48),
            const Text('Recent Transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildTransaction('Coca Cola 500ml', 'Today', 1.25, Icons.local_drink),
                  _buildTransaction('Bread', 'Yesterday', 2.10, Icons.bakery_dining),
                  _buildTransaction('Milk 1L', 'Yesterday', 1.80, Icons.egg),
                  _buildTransaction('Chips', '2 days ago', 2.50, Icons.fastfood),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('+ Set Budget'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTransaction(String name, String date, double amount, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppConstants.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppConstants.primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(date, style: const TextStyle(fontSize: 12, color: Colors.white54)),
              ],
            ),
          ),
          Text('\$${amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
