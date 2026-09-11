import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../providers/shopping_list_provider.dart';
import '../providers/basket_provider.dart';

class CameraRecognitionScreen extends ConsumerStatefulWidget {
  const CameraRecognitionScreen({super.key});

  @override
  ConsumerState<CameraRecognitionScreen> createState() => _CameraRecognitionScreenState();
}

class _CameraRecognitionScreenState extends ConsumerState<CameraRecognitionScreen> {
  bool _isFlashOn = false;

  final List<Map<String, dynamic>> _quickSampleProducts = [
    {
      'name': 'Kotmale Fresh Milk 1L',
      'category': 'Dairy',
      'price': 450.0,
      'icon': Icons.local_drink_rounded,
    },
    {
      'name': 'Prima Crust Bread',
      'category': 'Bakery',
      'price': 190.0,
      'icon': Icons.bakery_dining_rounded,
    },
    {
      'name': 'Munchee Cream Cracker',
      'category': 'Snacks',
      'price': 240.0,
      'icon': Icons.cookie_outlined,
    },
    {
      'name': 'Dilmah Premium Tea',
      'category': 'Drinks',
      'price': 620.0,
      'icon': Icons.emoji_food_beverage_rounded,
    },
  ];

  void _captureProduct([Map<String, dynamic>? product]) {
    final selected = product ?? _quickSampleProducts[0];

    // Automatically add to Cart in real time!
    final newItem = BasketItem(
      id: 'scan_${DateTime.now().millisecondsSinceEpoch}',
      name: selected['name'],
      category: selected['category'],
      price: selected['price'],
    );
    ref.read(basketProvider.notifier).addItem(newItem);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Auto-added "${selected['name']}" to Cart!',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryGreenDark,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1600),
      ),
    );

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) context.go('/cart');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera Background Preview
            Positioned.fill(
              child: Opacity(
                opacity: 0.65,
                child: Image.network(
                  'https://images.unsplash.com/photo-1578916171728-46686eac8d58?q=80&w=2874&auto=format&fit=crop',
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    color: const Color(0xFF1A1A1A),
                    child: const Center(
                      child: Icon(Icons.shelves, color: Colors.white24, size: 80),
                    ),
                  ),
                ),
              ),
            ),

            // Top Bar
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildIconButton(Icons.arrow_back_rounded, () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/homedashboard');
                    }
                  }),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome_rounded, color: Colors.amberAccent, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          'Cargills AI Scanner',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _buildIconButton(
                        _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                        () => setState(() => _isFlashOn = !_isFlashOn),
                      ),
                      const SizedBox(width: 12),
                      _buildIconButton(Icons.checklist_rounded, () {
                        context.push('/shoppinglist');
                      }),
                    ],
                  ),
                ],
              ),
            ),

            // Center Recognition Frame
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomPaint(
                    size: const Size(260, 260),
                    painter: ScannerBracketsPainter(),
                    child: Container(
                      width: 260,
                      height: 260,
                      alignment: Alignment.center,
                      child: Container(
                        height: 2,
                        width: 220,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGreen.withValues(alpha: 0.8),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt_rounded, color: AppColors.primaryGreenLight, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Capturing will auto-add to your Shopping List',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Quick Products & Shutter Button
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.85),
                      Colors.black,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Quick Scan Samples
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _quickSampleProducts.map((p) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ActionChip(
                              avatar: Icon(p['icon'], size: 16, color: AppColors.primaryGreen),
                              label: Text(p['name']),
                              backgroundColor: Colors.white.withValues(alpha: 0.18),
                              side: BorderSide.none,
                              labelStyle: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                              onPressed: () => _captureProduct(p),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Shutter Button Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildCircleButton(
                          Icons.checklist_rounded,
                          () => context.push('/shoppinglist'),
                        ),
                        // Main Shutter Button
                        GestureDetector(
                          onTap: () => _captureProduct(),
                          child: Container(
                            width: 78,
                            height: 78,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            child: Center(
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_rounded,
                                  color: Color(0xFFC62828),
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                        ),
                        _buildCircleButton(
                          Icons.image_rounded,
                          () {
                            _captureProduct();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

class ScannerBracketsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryGreen
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double length = 40;

    // Top-Left
    canvas.drawLine(const Offset(0, 0), const Offset(length, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, length), paint);

    // Top-Right
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - length, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, length), paint);

    // Bottom-Left
    canvas.drawLine(Offset(0, size.height), Offset(length, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - length), paint);

    // Bottom-Right
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - length, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - length), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
