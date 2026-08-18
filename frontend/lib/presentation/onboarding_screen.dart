import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/constants.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingXLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Smart Shopping\nStarts Here!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 60),
              
              _buildFeatureRow(
                Icons.qr_code_scanner, 
                'Scan & Discover', 
                'Scan products to get prices, details and offers.'
              ),
              const SizedBox(height: 32),
              _buildFeatureRow(
                Icons.account_balance_wallet_outlined, 
                'Track Your Budget', 
                'Set a budget and get real-time alerts.'
              ),
              const SizedBox(height: 32),
              _buildFeatureRow(
                Icons.local_offer_outlined, 
                'Find Best Deals', 
                'Get the best discounts and save more.'
              ),
              
              const Spacer(),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/login'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Get Started', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Skip', style: TextStyle(color: Colors.white54)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppConstants.primaryColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(description, style: const TextStyle(fontSize: 13, color: Colors.white54, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}
