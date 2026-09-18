import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import 'widgets/shopmate_app_bar.dart';
import 'package:go_router/go_router.dart';

class DiscountsScreen extends StatelessWidget {
  const DiscountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ShopMateAppBar(title: "Today's Deals", showBack: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF9100), Color(0xFFFF3D00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Super Saver Weekend',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Up to 35% off on fresh produce and pantry staples.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Discounted Supermarket Items',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    _buildDealCard(
                      context,
                      'deal1',
                      'Kotmale Fresh Milk',
                      'Kotmale',
                      '1L',
                      450,
                      520,
                      '13% OFF',
                      'assets/images/products/fresh_milk_bottle_1789196429739.jpg',
                    ),
                    const SizedBox(height: 12),
                    _buildDealCard(
                      context,
                      'deal2',
                      'Real Strawberry Jam',
                      'Cargills Kist',
                      '300g',
                      380,
                      440,
                      '14% OFF',
                      'assets/images/products/strawberry_jam_jar_1789196446483.jpg',
                    ),
                    const SizedBox(height: 12),
                    _buildDealCard(
                      context,
                      'deal3',
                      'Super Cream Cracker',
                      'Munchee',
                      '500g',
                      360,
                      410,
                      '12% OFF',
                      'assets/images/products/cream_cracker_pack_1789196459599.jpg',
                    ),
                    const SizedBox(height: 12),
                    _buildDealCard(
                      context,
                      'deal4',
                      'Keeri Samba Rice',
                      'Araliya',
                      '5kg',
                      1350,
                      1550,
                      '13% OFF',
                      'assets/images/products/rice_bag_5kg_1789196473391.jpg',
                    ),
                    const SizedBox(height: 12),
                    _buildDealCard(
                      context,
                      'deal5',
                      'Sliced White Bread',
                      'Prima',
                      '400g',
                      190,
                      220,
                      '14% OFF',
                      'assets/images/products/sliced_bread_loaf_1789196500272.jpg',
                    ),
                    const SizedBox(height: 12),
                    _buildDealCard(
                      context,
                      'deal6',
                      'Fat Spread Butter',
                      'Astra',
                      '500g',
                      650,
                      720,
                      '10% OFF',
                      'assets/images/products/butter_block_500g_1789196640197.jpg',
                    ),
                    const SizedBox(height: 12),
                    _buildDealCard(
                      context,
                      'deal7',
                      'Ceylon Black Tea Bags',
                      'Dilmah',
                      '50s',
                      480,
                      550,
                      '13% OFF',
                      'assets/images/products/ceylon_tea_box_1789196653776.jpg',
                    ),
                    const SizedBox(height: 12),
                    _buildDealCard(
                      context,
                      'deal8',
                      'Refined White Sugar',
                      'Cargills',
                      '1kg',
                      290,
                      330,
                      '12% OFF',
                      'assets/images/products/sugar_bag_1kg_1789196668578.jpg',
                    ),
                    const SizedBox(height: 12),
                    _buildDealCard(
                      context,
                      'deal9',
                      'Classic Cola',
                      'Coca Cola',
                      '1.5L',
                      350,
                      400,
                      '12% OFF',
                      'assets/images/products/coca_cola_bottle_1789196700811.jpg',
                    ),
                    const SizedBox(height: 12),
                    _buildDealCard(
                      context,
                      'deal10',
                      'Rich Tomato Ketchup',
                      'Maggi',
                      '400g',
                      450,
                      510,
                      '12% OFF',
                      'assets/images/products/tomato_ketchup_bottle_1789196720511.jpg',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDealCard(
    BuildContext context,
    String id,
    String title,
    String brand,
    String size,
    double price,
    double originalPrice,
    String discountBadge,
    String imageUrl,
  ) {
    return InkWell(
      onTap: () {
        context.push(
          '/productdetails',
          extra: {
            'id': id,
            'name': title,
            'brand': brand,
            'size': size,
            'price': price,
            'originalPrice': originalPrice,
            'discountText': discountBadge,
            'location': 'Deals Section',
            'imageUrl': imageUrl,
            'category': 'General',
          },
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(imageUrl, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Rs. ${price.toStringAsFixed(0)}',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryGreenDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Rs. ${originalPrice.toStringAsFixed(0)}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                discountBadge,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.discount,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
