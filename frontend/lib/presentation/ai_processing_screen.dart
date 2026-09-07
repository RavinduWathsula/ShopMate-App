import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

class AIProcessingScreen extends StatefulWidget {
  const AIProcessingScreen({super.key});

  @override
  State<AIProcessingScreen> createState() => _AIProcessingScreenState();
}

class _AIProcessingScreenState extends State<AIProcessingScreen> with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<String> _steps = [
    'Analyzing image...',
    'Detecting product...',
    'Reading product information...',
    'Matching products...',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startProcessing();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _startProcessing() async {
    for (int i = 0; i <= _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        setState(() {
          _currentStep = i;
        });
      }
    }
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      context.pushReplacement('/recognitionresult');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF091F13), // Deep dark green
              Colors.black,
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              
              // Glowing Robot Icon
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryGreenDark.withValues(alpha: 0.2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen.withValues(alpha: 0.3),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.smart_toy_rounded,
                        color: AppColors.primaryGreen,
                        size: 64,
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 48),
              
              Text(
                'ShopMate AI is analyzing your product...',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Steps List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(_steps.length, (index) {
                    final isCompleted = _currentStep > index;
                    final isActive = _currentStep == index;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        children: [
                          // Status Icon
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: isCompleted
                                ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen, size: 24)
                                : isActive
                                    ? const CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                                      )
                                    : Icon(Icons.radio_button_unchecked_rounded, color: Colors.white.withValues(alpha: 0.2), size: 24),
                          ),
                          const SizedBox(width: 16),
                          // Status Text
                          Expanded(
                            child: Text(
                              _steps[index],
                              style: GoogleFonts.inter(
                                color: isCompleted
                                    ? Colors.white
                                    : isActive
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.4),
                                fontSize: 14,
                                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              
              const Spacer(flex: 4),
              
              // Animated Dots at bottom
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAnimatedDot(0),
                  const SizedBox(width: 8),
                  _buildAnimatedDot(1),
                  const SizedBox(width: 8),
                  _buildAnimatedDot(2),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedDot(int index) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final double offset = (index * 0.3);
        final double value = ((_pulseController.value + offset) % 1.0);
        final double opacity = (0.3 + (0.7 * (1 - (value - 0.5).abs() * 2))).clamp(0.3, 1.0);
        
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withValues(alpha: opacity),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
