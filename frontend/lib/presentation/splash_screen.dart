import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) context.go('/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              AppConstants.primaryColor.withValues(alpha: 0.2),
              AppConstants.backgroundColor,
            ],
            center: Alignment.center,
            radius: 0.8,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Custom Icon Logo replacing image since we don't have assets yet
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shopping_cart,
                  size: 80,
                  color: AppConstants.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'ShopMate',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'AI Shopping Assistant',
                style: TextStyle(
                  fontSize: 14,
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              const Text(
                'Smart Shopping.\nSmarter You.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white70,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
