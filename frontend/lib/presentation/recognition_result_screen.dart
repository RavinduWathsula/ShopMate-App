import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import 'widgets/shopmate_app_bar.dart';
import '../providers/basket_provider.dart';
import '../providers/shopping_list_provider.dart';

class RecognitionResultScreen extends ConsumerStatefulWidget {
  const RecognitionResultScreen({super.key});

  @override
  ConsumerState<RecognitionResultScreen> createState() => _RecognitionResultScreenState();
}

class _RecognitionResultScreenState extends ConsumerState<RecognitionResultScreen> {
  final String _productName = 'Kotmale Fresh Milk 1L';
  final String _category = 'Dairy';
  final double _price = 450.0;
  final double _originalPrice = 520.0;

  @override
  void initState() {
    super.initState();
    // Ensure the recognized item is in the Shopping List
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(shoppingListProvider.notifier).addItem(
        ShoppingListItem(
          id: 'rec_${DateTime.now().millisecondsSinceEpoch}',
          name: _productName,
          category: _category,
          price: _price,
          quantity: 1,
          isChecked: false,
          icon: Icons.local_drink_rounded,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ShopMateAppBar(title: 'AI Product Recognition'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Auto-Add Success Banner
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE8F8EE), Color(0xFFD1F2DD)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryGreenDark,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Added to Your Shopping List!',
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryGreenDark,
                            ),
                          ),
                          Text(
                            'Item recognized and saved in real-time.',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Product Image & AI Badge
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    height: 240,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.local_drink_rounded,
                        size: 110,
                        color: AppColors.primaryGreen.withValues(alpha: 0.25),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.aiPurple, AppColors.aiPurpleDark],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.aiPurple.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome_rounded, color: Colors.amberAccent, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            '96% AI Match',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Product Details
              Text(
                _productName,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Cargills Food City • Aisle 2 (Dairy & Beverages)',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // Info Cards Grid
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      'Category',
                      _category,
                      Icons.category_rounded,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard(
                      'Deal',
                      '13% OFF',
                      Icons.local_offer_rounded,
                      AppColors.discount,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      'Regular Price',
                      'Rs. ${_originalPrice.toStringAsFixed(0)}',
                      Icons.money_off_rounded,
                      AppColors.textSecondary,
                      crossout: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard(
                      'Cargills Price',
                      'Rs. ${_price.toStringAsFixed(0)}',
                      Icons.check_circle_rounded,
                      AppColors.primaryGreenDark,
                      highlight: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Action Buttons
              // 1. View in Shopping List
              ElevatedButton.icon(
                onPressed: () => context.push('/shoppinglist'),
                icon: const Icon(Icons.checklist_rounded, color: Colors.white, size: 20),
                label: Text(
                  'View in Shopping List',
                  style: GoogleFonts.inter(fontSize: 15.5, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
              const SizedBox(height: 12),

              // 2. Add to Cart / Smart Basket
              OutlinedButton.icon(
                onPressed: () {
                  ref.read(basketProvider.notifier).addItem(
                    BasketItem(
                      id: 'milk_1l',
                      name: _productName,
                      price: _price,
                      category: _category,
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Added Fresh Milk 1L to Cart!'),
                      backgroundColor: AppColors.primaryGreenDark,
                    ),
                  );
                  context.push('/smartbasket');
                },
                icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.primaryGreenDark, size: 20),
                label: Text(
                  'Move to Smart Basket',
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primaryGreenDark),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 12),

              // 3. Scan Another Item
              TextButton.icon(
                onPressed: () => context.push('/camerarecognition'),
                icon: const Icon(Icons.camera_alt_outlined, color: AppColors.textSecondary, size: 18),
                label: Text(
                  'Scan Another Product',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color, {bool highlight = false, bool crossout = false}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlight ? color.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: highlight ? color.withValues(alpha: 0.3) : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: crossout ? AppColors.textMuted : AppColors.textPrimary,
              decoration: crossout ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }
}
