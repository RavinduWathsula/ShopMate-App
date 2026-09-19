import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'shopmate_product_card.dart';

class ShopMateFlashSaleSection extends StatefulWidget {
  final Function(String, String, double, String) onAddToCart;

  const ShopMateFlashSaleSection({
    super.key,
    required this.onAddToCart,
  });

  @override
  State<ShopMateFlashSaleSection> createState() =>
      _ShopMateFlashSaleSectionState();
}

class _ShopMateFlashSaleSectionState extends State<ShopMateFlashSaleSection> {
  late Timer _timer;
  Duration _duration = const Duration(hours: 2, minutes: 15, seconds: 30);

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_duration.inSeconds > 0) {
        setState(() {
          _duration -= const Duration(seconds: 1);
        });
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Flash Sale Header Banner
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE53935), Color(0xFFC62828)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFC62828).withValues(alpha: 0.28),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.flash_on_rounded,
                      color: Colors.amberAccent,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Flash Sale',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        color: Color(0xFFC62828),
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatDuration(_duration),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFC62828),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Horizontally scrolling high-value items
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              ShopMateProductCard(
                brand: "Cargills Finest",
                name: "Premium Chicken Breast",
                size: "500 g",
                price: 600,
                originalPrice: 1200,
                discountText: "50% OFF",
                productIcon: Icons.egg_alt_rounded,
                onAddToCart: () => widget.onAddToCart(
                  'flash1',
                  'Premium Chicken Breast',
                  600.0,
                  'Meat',
                ),
              ),
              const SizedBox(width: 16),
              ShopMateProductCard(
                brand: "Oster",
                name: "Digital Blender 600W",
                size: "1.5 L",
                price: 7500,
                originalPrice: 15000,
                discountText: "50% OFF",
                productIcon: Icons.blender_rounded,
                onAddToCart: () => widget.onAddToCart(
                  'flash2',
                  'Oster Digital Blender 600W',
                  7500.0,
                  'Electronics',
                ),
              ),
              const SizedBox(width: 16),
              ShopMateProductCard(
                brand: "Gold",
                name: "Pure Olive Oil",
                size: "1 L",
                price: 1800,
                originalPrice: 3000,
                discountText: "HOT DEAL",
                productIcon: Icons.liquor_rounded,
                onAddToCart: () => widget.onAddToCart(
                  'flash3',
                  'Gold Pure Olive Oil',
                  1800.0,
                  'Pantry',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
