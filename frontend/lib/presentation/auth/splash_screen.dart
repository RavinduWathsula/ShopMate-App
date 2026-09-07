import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _floatController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    // Main entrance animation
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Continuous floating animation
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _mainController.forward();
    _checkRouting();
  }

  Future<void> _checkRouting() async {
    // Wait for splash duration to finish
    await Future.delayed(const Duration(milliseconds: 3000));
    
    if (!mounted) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasCompletedOnboarding = prefs.getBool('has_completed_onboarding') ?? false;
      
      if (!mounted) return;

      if (hasCompletedOnboarding) {
        // Normally go to login or home depending on auth state
        context.go('/login');
      } else {
        context.go('/onboarding');
      }
    } catch (e) {
      // Fallback
      if (mounted) context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1714), // Premium dark supermarket background
      body: Stack(
        children: [
          // Background Gradient Lighting
          Positioned(
            top: -100,
            left: -100,
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryGreen.withValues(alpha: 0.15 * _glowAnimation.value),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              }
            ),
          ),
          Positioned(
            bottom: -50,
            right: -100,
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.aiPurple.withValues(alpha: 0.15 * (1.4 - _glowAnimation.value)),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              }
            ),
          ),
          
          // Floating Products
          _buildFloatingProduct(context, "🍎", -40, 120, 0.0, 34),
          _buildFloatingProduct(context, "🥦", 60, -140, 0.5, 38),
          _buildFloatingProduct(context, "🍞", 100, 130, 0.8, 42),
          _buildFloatingProduct(context, "🧀", -90, -90, 0.2, 36),
          _buildFloatingProduct(context, "🥩", -110, 30, 0.6, 40),
          _buildFloatingProduct(context, "🧴", 120, -20, 0.3, 35),

          // Main Content
          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glow behind logo
                          AnimatedBuilder(
                            animation: _glowAnimation,
                            builder: (context, child) {
                              return Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryGreen.withValues(alpha: 0.3 * _glowAnimation.value),
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                              );
                            }
                          ),
                          // Logo Container
                          Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primaryGreen,
                                  AppColors.primaryGreenDark,
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.shopping_bag_rounded,
                              size: 72,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.outfit(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: Colors.white,
                        ),
                        children: const [
                          TextSpan(text: 'Shop'),
                          TextSpan(
                            text: 'Mate',
                            style: TextStyle(color: AppColors.primaryGreen),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Smart Shopping.\nSmarter Spending.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const Spacer(),
                    
                    // Loading Section
                    Column(
                      children: [
                        SizedBox(
                          width: 200,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: const LinearProgressIndicator(
                              backgroundColor: Color(0xFF2A3631),
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                              minHeight: 4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading your smart experience...',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.white54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingProduct(BuildContext context, String emoji, double offsetX, double offsetY, double delay, double size) {
    return Align(
      alignment: Alignment.center,
      child: AnimatedBuilder(
        animation: _floatController,
        builder: (context, child) {
          // Calculate floating offset based on sine wave and delay
          final floatOffset = math.sin((_floatController.value * 2 * math.pi) + (delay * math.pi * 2)) * 15;
          return Transform.translate(
            offset: Offset(offsetX, offsetY + floatOffset),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Opacity(
                opacity: 0.8,
                child: Text(
                  emoji,
                  style: TextStyle(fontSize: size),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
