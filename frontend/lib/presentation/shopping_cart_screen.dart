import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../providers/basket_provider.dart';
import '../providers/budget_provider.dart';
import 'widgets/shopmate_app_bar.dart';
import 'widgets/shopmate_bottom_nav.dart';

class ShoppingCartScreen extends ConsumerWidget {
  const ShoppingCartScreen({super.key});

  String _formatCurrency(double amount) {
    String formatted = amount.abs().toStringAsFixed(0);
    final parts = formatted.split('.');
    final regExp = RegExp(r'\B(?=(\d{3})+(?!\d))');
    parts[0] = parts[0].replaceAll(regExp, ',');
    return '${amount < 0 ? '-' : ''}${parts[0]}';
  }

  void _confirmClearCart(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warningRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_sweep_rounded, color: AppColors.warningRed, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'Clear Cart',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to remove all items from your cart?',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(basketProvider.notifier).clear();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warningRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text('Clear All', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(basketProvider);
    final selectedTotal = ref.watch(basketTotalProvider);
    final budgetState = ref.watch(budgetProvider);
    final totalBudget = budgetState.budget > 0 ? budgetState.budget : 4000.0;

    final selectedItems = cartItems.where((item) => item.isSelected).toList();
    final isAllSelected = cartItems.isNotEmpty && cartItems.every((item) => item.isSelected);
    final remainingBudget = totalBudget - selectedTotal;
    final isOverBudget = selectedTotal > totalBudget;
    final budgetUsagePercent = totalBudget > 0 ? (selectedTotal / totalBudget).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ShopMateAppBar(
        title: 'My Cart (${cartItems.length})',
        showBack: true,
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.warningRed.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline_rounded, color: AppColors.warningRed, size: 20),
              ),
              tooltip: 'Clear Cart',
              onPressed: () => _confirmClearCart(context, ref),
            ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt_rounded, color: AppColors.primaryGreen, size: 20),
            ),
            tooltip: 'Scan Barcode',
            onPressed: () => context.push('/camerarecognition'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: cartItems.isEmpty
            ? _buildEmptyCart(context)
            : Column(
                children: [
                  // Store & Selection Control Header
                  _buildSelectAllHeader(context, ref, cartItems, selectedItems, isAllSelected),

                  // Cart Items List
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemCount: cartItems.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        return _buildCreativeCartCard(context, ref, item);
                      },
                    ),
                  ),

                  // Order Summary, Budget Tracker & Checkout
                  _buildOrderSummarySection(
                    context,
                    selectedTotal: selectedTotal,
                    selectedCount: selectedItems.length,
                    totalCount: cartItems.length,
                    totalBudget: totalBudget,
                    remainingBudget: remainingBudget,
                    isOverBudget: isOverBudget,
                    budgetUsagePercent: budgetUsagePercent,
                  ),
                ],
              ),
      ),
      bottomNavigationBar: const ShopMateBottomNav(currentIndex: 2),
    );
  }

  Widget _buildSelectAllHeader(
    BuildContext context,
    WidgetRef ref,
    List<BasketItem> cartItems,
    List<BasketItem> selectedItems,
    bool isAllSelected,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
          // Select All Checkbox
          InkWell(
            onTap: () {
              ref.read(basketProvider.notifier).toggleAllSelection(!isAllSelected);
            },
            borderRadius: BorderRadius.circular(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: isAllSelected,
                    activeColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    onChanged: (val) {
                      ref.read(basketProvider.notifier).toggleAllSelection(val ?? true);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Select All',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${selectedItems.length}/${cartItems.length} to buy',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryGreenDark,
              ),
            ),
          ),
          const Spacer(),
          // Store badge
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.storefront_rounded, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                'Cargills Food City',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCreativeCartCard(BuildContext context, WidgetRef ref, BasketItem item) {
    final itemTotal = item.price * item.quantity;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: item.isSelected
              ? AppColors.primaryGreen.withValues(alpha: 0.35)
              : AppColors.border,
          width: item.isSelected ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: item.isSelected
                ? AppColors.primaryGreen.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Checkbox to select what to buy
              SizedBox(
                width: 28,
                height: 28,
                child: Checkbox(
                  value: item.isSelected,
                  activeColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  onChanged: (val) {
                    ref.read(basketProvider.notifier).toggleSelection(item.id);
                  },
                ),
              ),
              const SizedBox(width: 8),

              // Product Image or Icon
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 62,
                  height: 62,
                  color: AppColors.inputBackground,
                  child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                      ? Image.network(
                          item.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => _buildFallbackIcon(item.category),
                        )
                      : _buildFallbackIcon(item.category),
                ),
              ),
              const SizedBox(width: 12),

              // Product Info & Price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.inputBackground,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.category.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () => ref.read(basketProvider.notifier).removeItem(item.id),
                          borderRadius: BorderRadius.circular(12),
                          child: const Padding(
                            padding: EdgeInsets.all(2),
                            child: Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: item.isSelected ? AppColors.textPrimary : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rs. ${_formatCurrency(item.price)} each',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              'Rs. ${_formatCurrency(itemTotal)}',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: item.isSelected ? AppColors.primaryGreenDark : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),

                        // Quantity Stepper
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.inputBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () {
                                  ref.read(basketProvider.notifier).updateQuantity(item.id, -1);
                                },
                                borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                  child: Icon(Icons.remove_rounded, size: 16, color: AppColors.textSecondary),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: Text(
                                  '${item.quantity}',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  ref.read(basketProvider.notifier).updateQuantity(item.id, 1);
                                },
                                borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                  child: Icon(Icons.add_rounded, size: 16, color: AppColors.primaryGreen),
                                ),
                              ),
                            ],
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
      ),
    );
  }

  Widget _buildFallbackIcon(String category) {
    IconData iconData;
    switch (category.toLowerCase()) {
      case 'dairy':
        iconData = Icons.local_drink_rounded;
        break;
      case 'bakery':
        iconData = Icons.bakery_dining_rounded;
        break;
      case 'snacks':
        iconData = Icons.cookie_outlined;
        break;
      case 'frozen':
        iconData = Icons.ac_unit_rounded;
        break;
      case 'beverages':
      case 'drinks':
        iconData = Icons.emoji_food_beverage_rounded;
        break;
      default:
        iconData = Icons.shopping_bag_outlined;
    }
    return Center(
      child: Icon(iconData, color: AppColors.primaryGreen, size: 28),
    );
  }

  Widget _buildOrderSummarySection(
    BuildContext context, {
    required double selectedTotal,
    required int selectedCount,
    required int totalCount,
    required double totalBudget,
    required double remainingBudget,
    required bool isOverBudget,
    required double budgetUsagePercent,
  }) {
    final int starPoints = (selectedTotal / 100).floor();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Live Budget Status Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isOverBudget
                  ? AppColors.warningRed.withValues(alpha: 0.08)
                  : AppColors.primaryGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isOverBudget
                    ? AppColors.warningRed.withValues(alpha: 0.25)
                    : AppColors.primaryGreen.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isOverBudget ? Icons.warning_amber_rounded : Icons.account_balance_wallet_outlined,
                          size: 16,
                          color: isOverBudget ? AppColors.warningRed : AppColors.primaryGreenDark,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isOverBudget ? 'Budget Exceeded' : 'Budget Tracker',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isOverBudget ? AppColors.warningRed : AppColors.primaryGreenDark,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      isOverBudget
                          ? 'Over by Rs. ${_formatCurrency(selectedTotal - totalBudget)}'
                          : 'Rs. ${_formatCurrency(remainingBudget)} left of Rs. ${_formatCurrency(totalBudget)}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isOverBudget ? AppColors.warningRed : AppColors.primaryGreenDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: budgetUsagePercent,
                    minHeight: 5,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isOverBudget ? AppColors.warningRed : AppColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Total & Star Points Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Total to Pay',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.dealYellow.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.stars_rounded, size: 12, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(
                              '+$starPoints Pts',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Rs. ${_formatCurrency(selectedTotal)}',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              // Smart suggestions link button
              TextButton.icon(
                onPressed: () => context.push('/smartbasket'),
                icon: const Icon(Icons.auto_awesome_rounded, size: 15, color: AppColors.aiPurple),
                label: Text(
                  'Smart Basket',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.aiPurple,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.aiPurple.withValues(alpha: 0.08),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Checkout Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: selectedCount > 0
                  ? () => context.push('/shoppingsummary')
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: selectedCount > 0 ? 3 : 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    selectedCount > 0
                        ? 'Proceed to Checkout ($selectedCount ${selectedCount == 1 ? 'item' : 'items'})'
                        : 'Select Items to Buy',
                    style: GoogleFonts.inter(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 50,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Your Cart is Empty',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scan products in Cargills Food City or add items to your cart to check out smoothly.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/camerarecognition'),
                icon: const Icon(Icons.camera_alt_rounded, size: 18, color: Colors.white),
                label: Text(
                  'Scan Products Now',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => context.push('/shoppinglist'),
                icon: const Icon(Icons.checklist_rounded, size: 18, color: AppColors.primaryGreen),
                label: Text(
                  'View Shopping List',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.primaryGreen,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryGreen),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
