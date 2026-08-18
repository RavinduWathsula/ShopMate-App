import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../utils/constants.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Hello, Ravindu 👋', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Good Morning!', style: TextStyle(fontSize: 12, color: AppConstants.textSecondary)),
              ],
            ),
            const Spacer(),
            const CircleAvatar(
              backgroundColor: AppConstants.cardColor,
              child: Icon(Icons.person, color: Colors.white),
            )
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: const Icon(Icons.tune, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 24),
              
              // Summer Mega Sale Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5F259F), Color(0xFFA644FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('SUMMER\nMEGA SALE', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, height: 1.1)),
                          const SizedBox(height: 8),
                          const Text('Up to 50% OFF', style: TextStyle(fontSize: 12, color: Colors.white70)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppConstants.primaryColor,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              minimumSize: Size.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: const Text('Shop Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          )
                        ],
                      ),
                    ),
                    const Icon(Icons.shopping_basket, size: 80, color: Colors.white54),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Quick Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuickAction(context, Icons.qr_code_scanner, 'Scan\nProduct', () => context.push('/camerarecognition')),
                  _buildQuickAction(context, Icons.account_balance_wallet_outlined, 'My\nBudget', () => context.push('/budgetsetup')),
                  _buildQuickAction(context, Icons.local_offer_outlined, 'Best\nDeals', () => context.push('/discounts')),
                  _buildQuickAction(context, Icons.search_outlined, 'Find\nItems', () => context.push('/supermarketselection')),
                ],
              ),
              const SizedBox(height: 32),
              
              // Today's Highlights
              const Text('Today\'s Highlights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildHighlightCard(const Color(0xFF9D84FF), '20%\nOFF', 'Dairy Products', Icons.icecream)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildHighlightCard(const Color(0xFFFF84B7), '15%\nOFF', 'Snacks', Icons.fastfood)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildHighlightCard(const Color(0xFFFFCA64), '25%\nOFF', 'Beverages', Icons.local_drink)),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) {
          if (index == 1) context.push('/budgetsetup');
          if (index == 2) context.push('/discounts');
          if (index == 3) context.push('/profile');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Budget'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'Deals'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppConstants.cardColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white10),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildHighlightCard(Color color, String discount, String category, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(discount, textAlign: TextAlign.center, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 18, height: 1.1)),
          const SizedBox(height: 8),
          Text(category, textAlign: TextAlign.center, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
