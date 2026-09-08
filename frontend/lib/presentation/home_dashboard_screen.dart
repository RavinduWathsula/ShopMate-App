import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import 'widgets/shopmate_bottom_nav.dart';
import 'widgets/shopmate_budget_card.dart';
import 'widgets/shopmate_ai_assistant_widget.dart';
import 'widgets/shopmate_product_card.dart';
import '../providers/budget_provider.dart';
import '../providers/basket_provider.dart';

class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  ConsumerState<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen> {

  void _showNotificationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.notifications_active_rounded, color: Color(0xFFC62828), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Store Alerts & Updates',
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildNotificationItem(
              '🔥 Weekend Saver is Live!',
              'Extra 15% off on fresh produce and pantry staples at Cargills Food City.',
              '10 mins ago',
              Icons.local_offer_rounded,
              AppColors.discount,
            ),
            const SizedBox(height: 12),
            _buildNotificationItem(
              '📍 In-Store Fast Lane Ready',
              'You are in Cargills Union Place. Scan items directly to your smart basket.',
              '1 hour ago',
              Icons.storefront_rounded,
              AppColors.primaryGreen,
            ),
            const SizedBox(height: 12),
            _buildNotificationItem(
              '💡 Budget Advisory',
              'You have used 0% of your Rs. 4,000 budget. Keep it up!',
              '2 hours ago',
              Icons.savings_rounded,
              AppColors.aiPurple,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(String title, String desc, String time, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondary, height: 1.3),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addProductToCart(String id, String name, double price, String category) {
    ref.read(basketProvider.notifier).addItem(
      BasketItem(id: id, name: name, price: price, category: category),
    );
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Added $name to cart (Rs. ${price.toStringAsFixed(0)})',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryGreenDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'VIEW CART',
          textColor: Colors.amberAccent,
          onPressed: () => context.push('/cart'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final budgetState = ref.watch(budgetProvider);
    final spentTotal = ref.watch(basketTotalProvider);
    final cartItems = ref.watch(basketProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: Greeting & Notifications & Cart Shortcut
              _buildTopBar(context, cartItems.length),

              const SizedBox(height: 14),

              // Exclusive Cargills Food City Store Identity Banner (No generic switcher)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildCargillsStoreBanner(context),
              ),

              const SizedBox(height: 18),

              // Large Purple/Green Budget Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ShopMateBudgetCard(
                  budget: budgetState.budget,
                  spent: spentTotal,
                  onEdit: () => context.push('/budgetsetup'),
                ),
              ),

              const SizedBox(height: 22),

              // Quick Actions Grid (All working buttons)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildQuickActions(context),
              ),

              const SizedBox(height: 22),

              // Friendly ShopMate AI Assistant Insight Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ShopMateAiAssistantWidget(
                  message: spentTotal == 0
                      ? "Ready for shopping at Cargills! You have Rs. ${budgetState.budget.toStringAsFixed(2)} available."
                      : "You have Rs. ${(budgetState.budget - spentTotal).toStringAsFixed(2)} remaining within your budget.",
                  subtitle: "4 special weekly deals match your shopping list today!",
                  actionLabel: "View Deals",
                  onTap: () => context.push('/discounts'),
                ),
              ),

              const SizedBox(height: 28),

              // Today's Deals Section
              _buildSectionHeader(
                context,
                title: "Cargills Food City Deals",
                badgeText: "HOT SAVINGS",
                onSeeAll: () => context.push('/discounts'),
              ),
              const SizedBox(height: 14),
              _buildDealsCarousel(context),

              const SizedBox(height: 28),

              // Featured Pantry Picks (Cargills Best Sellers)
              _buildSectionHeader(
                context,
                title: "Featured Pantry Picks",
                subtitle: "Special offers and household favorites",
                onSeeAll: () => context.push('/discounts'),
              ),
              const SizedBox(height: 14),
              _buildRecommendationsList(context),

              const SizedBox(height: 28),

              // Popular Supermarket Products
              _buildSectionHeader(
                context,
                title: "Popular at Cargills Food City",
                subtitle: "Top-selling groceries this week",
                onSeeAll: () => context.push('/shoppinglist'),
              ),
              const SizedBox(height: 14),
              _buildPopularProductsList(context),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const ShopMateBottomNav(currentIndex: 0),
    );
  }

  Widget _buildTopBar(BuildContext context, int cartCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Hello, Ravindu',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text('👋', style: TextStyle(fontSize: 20)),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Smart shopping at Cargills Food City',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              // Notification Bell
              InkWell(
                onTap: () => _showNotificationSheet(context),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.notifications_none_rounded,
                        color: AppColors.textPrimary,
                        size: 22,
                      ),
                      Positioned(
                        top: -1,
                        right: -1,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFC62828),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Cart Shortcut
              InkWell(
                onTap: () => context.push('/cart'),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.shopping_bag_outlined,
                        color: AppColors.textPrimary,
                        size: 22,
                      ),
                      if (cartCount > 0)
                        Positioned(
                          top: -4,
                          right: -6,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryGreenDark,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$cartCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Exclusive Cargills Food City Store Identity Banner ---
  Widget _buildCargillsStoreBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFC62828), // Cargills Signature Red
            Color(0xFFD32F2F),
            Color(0xFFB71C1C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC62828).withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Cargills Emblem
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.storefront_rounded,
                    color: Color(0xFFC62828),
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Cargills Food City',
                          style: GoogleFonts.inter(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.verified_rounded,
                          color: Colors.amberAccent,
                          size: 16,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Union Place Flagship • Smart Assistant Active',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Interactive Action Pills on the Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.wifi_tethering_rounded, color: Colors.greenAccent, size: 15),
                    const SizedBox(width: 6),
                    Text(
                      'In-Store Connected',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                // Direct shortcut to Store Map
                InkWell(
                  onTap: () => context.push('/storemap'),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.map_rounded, color: Color(0xFFC62828), size: 14),
                        const SizedBox(width: 5),
                        Text(
                          'Aisle Map',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFC62828),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Quick Actions Grid (All 6 Working Buttons) ---
  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildActionTile(
              context,
              icon: Icons.shopping_basket_rounded,
              title: 'Smart\nBasket',
              bgColor: const Color(0xFFE8F8EE),
              iconColor: AppColors.primaryGreen,
              onTap: () => context.push('/smartbasket'),
            ),
            _buildActionTile(
              context,
              icon: Icons.qr_code_scanner_rounded,
              title: 'Scan &\nIdentify',
              bgColor: const Color(0xFFF3E8FF),
              iconColor: AppColors.aiPurple,
              onTap: () => context.push('/camerarecognition'),
            ),
            _buildActionTile(
              context,
              icon: Icons.checklist_rounded,
              title: 'Shopping\nList',
              bgColor: const Color(0xFFFFF7ED),
              iconColor: AppColors.dealOrange,
              onTap: () => context.push('/shoppinglist'),
            ),
            _buildActionTile(
              context,
              icon: Icons.local_offer_rounded,
              title: 'Weekly\nDeals',
              bgColor: const Color(0xFFFFF1F2),
              iconColor: const Color(0xFFC62828),
              onTap: () => context.push('/discounts'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildWideActionTile(
                context,
                icon: Icons.alt_route_rounded,
                title: 'Aisle Navigator',
                subtitle: 'Find items in Food City',
                color: const Color(0xFFC62828),
                onTap: () => context.push('/storemap'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildWideActionTile(
                context,
                icon: Icons.pie_chart_outline_rounded,
                title: 'Spending Insights',
                subtitle: 'Track monthly savings',
                color: AppColors.aiPurple,
                onTap: () => context.push('/spendinganalytics'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 78,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    String? subtitle,
    String? badgeText,
    VoidCallback? onSeeAll,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (badgeText != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC62828),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badgeText,
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: Text(
                'See all',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreenDark,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDealsCarousel(BuildContext context) {
    return SizedBox(
      height: 240,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          ShopMateProductCard(
            brand: "Kotmale",
            name: "Pasteurized Fresh Milk 1L",
            size: "1000 ml",
            price: 450,
            originalPrice: 520,
            productIcon: Icons.local_drink_rounded,
            location: "Aisle 2 • Dairy",
            onTap: () => context.push('/productdetails'),
            onAddToCart: () => _addProductToCart('deal1', 'Kotmale Fresh Milk 1L', 450, 'Dairy'),
          ),
          const SizedBox(width: 14),
          ShopMateProductCard(
            brand: "Cargills Kist",
            name: "Real Strawberry Jam",
            size: "300g",
            price: 380,
            originalPrice: 440,
            productIcon: Icons.breakfast_dining_rounded,
            location: "Aisle 3 • Spreads",
            onTap: () => context.push('/productdetails'),
            onAddToCart: () => _addProductToCart('deal2', 'Cargills Kist Strawberry Jam', 380, 'Pantry'),
          ),
          const SizedBox(width: 14),
          ShopMateProductCard(
            brand: "Munchee",
            name: "Super Cream Cracker",
            size: "500g",
            price: 360,
            originalPrice: 410,
            productIcon: Icons.cookie_outlined,
            location: "Aisle 4 • Biscuits",
            onTap: () => context.push('/productdetails'),
            onAddToCart: () => _addProductToCart('deal3', 'Munchee Cream Cracker', 360, 'Snacks'),
          ),
          const SizedBox(width: 14),
          ShopMateProductCard(
            brand: "Araliya",
            name: "Keeri Samba Rice 5kg",
            size: "5 kg",
            price: 1350,
            originalPrice: 1550,
            productIcon: Icons.grain_rounded,
            location: "Aisle 1 • Rice & Flour",
            onTap: () => context.push('/productdetails'),
            onAddToCart: () => _addProductToCart('deal4', 'Araliya Keeri Samba 5kg', 1350, 'Grains'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsList(BuildContext context) {
    return SizedBox(
      height: 240,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          ShopMateProductCard(
            brand: "Anchor",
            name: "Full Cream Milk Powder",
            size: "400g",
            price: 1080,
            originalPrice: 1150,
            productIcon: Icons.coffee_rounded,
            location: "Aisle 2 • Milk Powder",
            onTap: () => context.push('/productdetails'),
            onAddToCart: () => _addProductToCart('rec1', 'Anchor Milk Powder 400g', 1080, 'Dairy'),
          ),
          const SizedBox(width: 14),
          ShopMateProductCard(
            brand: "Elephant House",
            name: "Cream Soda 1.5L",
            size: "1500 ml",
            price: 390,
            originalPrice: 420,
            productIcon: Icons.local_bar_rounded,
            location: "Aisle 5 • Beverages",
            onTap: () => context.push('/productdetails'),
            onAddToCart: () => _addProductToCart('rec2', 'Cream Soda 1.5L', 390, 'Beverages'),
          ),
          const SizedBox(width: 14),
          ShopMateProductCard(
            brand: "Cargills Gold",
            name: "Pure Ghee 180ml",
            size: "180 ml",
            price: 790,
            productIcon: Icons.soup_kitchen_rounded,
            location: "Aisle 3 • Cooking",
            onTap: () => context.push('/productdetails'),
            onAddToCart: () => _addProductToCart('rec3', 'Cargills Gold Pure Ghee', 790, 'Cooking'),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularProductsList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          ShopMateProductCard(
            isCompact: true,
            brand: "Fortune",
            name: "Sunflower Cooking Oil 1L",
            size: "1000 ml",
            price: 980,
            originalPrice: 1100,
            productIcon: Icons.soup_kitchen_rounded,
            onTap: () => context.push('/productdetails'),
            onAddToCart: () => _addProductToCart('pop1', 'Fortune Sunflower Oil 1L', 980, 'Pantry'),
          ),
          const SizedBox(height: 12),
          ShopMateProductCard(
            isCompact: true,
            brand: "Kotmale",
            name: "Fresh Farm Eggs (Pack of 10)",
            size: "Pack of 10",
            price: 460,
            productIcon: Icons.egg_rounded,
            onTap: () => context.push('/productdetails'),
            onAddToCart: () => _addProductToCart('pop2', 'Kotmale Fresh Eggs (10s)', 460, 'Fresh'),
          ),
        ],
      ),
    );
  }
}
