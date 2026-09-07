import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import 'widgets/shopmate_app_bar.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/shops_provider.dart';

class SupermarketSelectionScreen extends ConsumerStatefulWidget {
  const SupermarketSelectionScreen({super.key});

  @override
  ConsumerState<SupermarketSelectionScreen> createState() => _SupermarketSelectionScreenState();
}

class _SupermarketSelectionScreenState extends ConsumerState<SupermarketSelectionScreen> {
  final List<Map<String, dynamic>> _stores = [
    {
      'name': 'Food City',
      'branch': 'Main Branch',
      'distance': '1.2 km',
      'isOpen': true,
      'hasIndoorMap': true,
      'color': const Color(0xFFD32F2F),
      'icon': Icons.local_grocery_store_rounded,
    },
    {
      'name': 'Keells Super',
      'branch': 'Union Place',
      'distance': '1.5 km',
      'isOpen': true,
      'hasIndoorMap': true,
      'color': const Color(0xFF2E7D32),
      'icon': Icons.shopping_bag_rounded,
    },
    {
      'name': 'Arpico Supercentre',
      'branch': 'Nugegoda',
      'distance': '2.1 km',
      'isOpen': true,
      'hasIndoorMap': true,
      'color': const Color(0xFF1565C0),
      'icon': Icons.storefront_rounded,
    },
    {
      'name': 'Cargills Food City',
      'branch': 'Colombo',
      'distance': '2.3 km',
      'isOpen': true,
      'hasIndoorMap': false,
      'color': const Color(0xFFC62828),
      'icon': Icons.shopping_basket_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final selectedStoreName = ref.watch(selectedStoreProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ShopMateAppBar(title: 'Select Supermarket'),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Container(
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
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search stores...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
              ),
            ),
            // Supermarket List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _stores.length,
                separatorBuilder: (context, index) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final store = _stores[index];
                  final isSelected = selectedStoreName == store['name'];

                  return InkWell(
                    onTap: () {
                      // Update Riverpod state
                      ref.read(selectedStoreProvider.notifier).state = store['name'] as String;
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Switched to ${store['name']}'),
                          backgroundColor: AppColors.primaryGreenDark,
                        ),
                      );
                      // Return to Home
                      context.go('/homedashboard');
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryGreen : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? AppColors.primaryGreen.withValues(alpha: 0.12)
                                : Colors.black.withValues(alpha: 0.03),
                            blurRadius: isSelected ? 16 : 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: (store['color'] as Color).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              store['icon'] as IconData,
                              color: store['color'] as Color,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        store['name'] as String,
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        color: AppColors.primaryGreen,
                                        size: 22,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  store['branch'] as String,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    if (store['isOpen'] == true)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryGreen.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'Open',
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primaryGreenDark,
                                          ),
                                        ),
                                      ),
                                    if (store['isOpen'] == true)
                                      const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryLight,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        store['distance'] as String,
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryGreenDark,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
