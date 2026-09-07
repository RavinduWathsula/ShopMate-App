import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Shop Smarter',
      'description': 'Build your shopping list and manage your spending with ease.',
    },
    {
      'title': 'AI Product Recognition',
      'description': 'Identify products using your camera in seconds.',
    },
    {
      'title': 'Stay Within Your Budget',
      'description': 'Get AI suggestions and optimize your basket.',
    },
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_onboarding', true);
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          // Custom Illustrations
                          _buildIllustration(index),
                          const SizedBox(height: 40),
                          Text(
                            _pages[index]['title']!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _pages[index]['description']!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      'Skip',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? AppColors.primaryGreen : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(120, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _completeOnboarding();
                      }
                    },
                    child: Text(
                      _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration(int index) {
    if (index == 1) {
      // AI Product Recognition Illustration
      return SizedBox(
        height: 250,
        width: 250,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.aiPurple.withValues(alpha: 0.1),
              ),
            ),
            Positioned(
              bottom: 40,
              child: Text(
                '🍎',
                style: TextStyle(fontSize: 80),
              ),
            ),
            Positioned(
              bottom: 30,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.aiPurple, width: 3),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            Positioned(
              top: 20,
              child: Container(
                width: 140,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black87, width: 6),
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.transparent,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: 40,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: Icon(Icons.auto_awesome, color: AppColors.aiPurple, size: 30),
            ),
            Positioned(
              bottom: 100,
              left: 10,
              child: Icon(Icons.auto_awesome, color: AppColors.dealOrange, size: 20),
            ),
          ],
        ),
      );
    } else if (index == 0) {
      // Screen 1 Illustration
      return Container(
        height: 250,
        width: 250,
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.shopping_cart_checkout,
            size: 100,
            color: AppColors.primaryGreen,
          ),
        ),
      );
    } else {
      // Screen 3 Illustration: Budget & Wallet
      return SizedBox(
        height: 250,
        width: 250,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Background purple gradient
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.aiPurple.withValues(alpha: 0.15),
                    AppColors.primaryGreen.withValues(alpha: 0.05),
                  ],
                ),
              ),
            ),
            // Wallet / Cards illustration
            Positioned(
              top: 60,
              left: 40,
              child: Transform.rotate(
                angle: -0.2,
                child: Container(
                  width: 120,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors.aiPurple,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(2, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 30, height: 8, color: Colors.white54),
                        const Spacer(),
                        Container(width: 80, height: 8, color: Colors.white54),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Shopping element (Basket emoji)
            Positioned(
              bottom: 40,
              right: 40,
              child: Text(
                '🛒',
                style: TextStyle(fontSize: 70),
              ),
            ),
            // Cash emoji
            Positioned(
              top: 50,
              right: 50,
              child: Text(
                '💵',
                style: TextStyle(fontSize: 40),
              ),
            ),
            // Green success icon
            Positioned(
              bottom: 80,
              left: 50,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 24),
              ),
            ),
            // AI Sparkles
            Positioned(
              top: 20,
              left: 80,
              child: Icon(Icons.auto_awesome, color: AppColors.dealOrange, size: 24),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: Icon(Icons.auto_awesome, color: AppColors.aiPurple, size: 30),
            ),
          ],
        ),
      );
    }
  }
}
