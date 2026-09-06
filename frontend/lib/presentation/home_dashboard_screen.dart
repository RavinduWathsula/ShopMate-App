import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import 'widgets/shopmate_bottom_nav.dart';
import 'widgets/shopmate_budget_card.dart';
import 'widgets/shopmate_ai_assistant_widget.dart';
import 'widgets/shopmate_product_card.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  String selectedStore = 'Food City Supermarket';
  double currentBudget = 4000.0;
  double currentSpent = 1650.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: Greeting & Notifications
              _buildTopBar(context),
              
              const SizedBox(height: 14),
              // Supermarket Store Selector Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildStoreSelector(context),
              ),

              const SizedBox(height: 20),
              // Large Purple/Green Budget Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ShopMateBudgetCard(
                  budget: currentBudget,
                  spent: currentSpent,
                  onEdit: () => context.push('/budgetsetup'),
                ),
              ),

              const SizedBox(height: 24),
              // Quick Actions Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildQuickActions(context),
              ),

              const SizedBox(height: 22),
              // Friendly ShopMate AI Assistant Insight Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ShopMateAiAssistantWidget(
                  message: "You're doing great! You can still add Rs. 2,350 worth of products.",
                  subtitle: "3 items from your shopping list are on discount today!",
                  actionLabel: "View Deals",
                  onTap: () => context.push('/discounts'),
                ),
              ),

              const SizedBox(height: 28),
              // Today's Deals Section
              _buildSectionHeader(
                context,
                title: "Today's Deals",
                badgeText: "HOT",
                onSeeAll: () => context.push('/discounts'),
              ),
              const SizedBox(height: 14),
              _buildDealsCarousel(context),

              const SizedBox(height: 28),
              // Recommended For You (AI-Powered)
              _buildSectionHeader(
                context,
                title: "Recommended For You",
                subtitle: "Based on your spending habits",
                onSeeAll: () => context.push('/recommendations'),
              ),
              const SizedBox(height: 14),
              _buildRecommendationsList(context),

              const SizedBox(height: 28),
              // Popular Supermarket Products
              _buildSectionHeader(
                context,
                title: "Popular in Food City",
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

  Widget _buildTopBar(BuildContext context) {
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
              Text(
                'Let\'s shop smart and save today',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          // Notification Icon with badge
          InkWell(
            onTap: () => context.push('/settings'),
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
                    size: 24,
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.discount,
                        shape: BoxShape.circle,
                      ),
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

  Widget _buildStoreSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.storefront_rounded,
              color: AppColors.primaryGreenDark,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURRENT SUPERMARKET',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  selectedStore,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.push('/supermarketselection'),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              foregroundColor: AppColors.primaryGreenDark,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Change',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionTile(
          context,
          icon: Icons.shopping_basket_rounded,
          title: 'Start\nShopping',
          bgColor: const Color(0xFFE8F8EE),
          iconColor: AppColors.primaryGreen,
          onTap: () => context.push('/smartbasket'),
        ),
        _buildActionTile(
          context,
          icon: Icons.document_scanner_rounded,
          title: 'Identify\nProduct',
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
          icon: Icons.auto_awesome_rounded,
          title: 'AI\nAssistant',
          bgColor: const Color(0xFFEFF6FF),
          iconColor: AppColors.electricBlue,
          onTap: () => context.push('/recommendations'),
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
        width: 76,
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
              child: Icon(icon, color: iconColor, size: 24),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (badgeText != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.discount,
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
      height: 220,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          ShopMateProductCard(
            brand: "Elephant House",
            name: "Fresh Milk 1L",
            size: "1000 ml",
            price: 450,
            originalPrice: 520,
            productIcon: Icons.local_drink_rounded,
            location: "Aisle 2",
            onTap: () => context.push('/productdetails'),
            onAddToCart: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added Fresh Milk to Smart Basket')),
              );
            },
          ),
          const SizedBox(width: 14),
          ShopMateProductCard(
            brand: "Lay's",
            name: "Classic Potato Chips",
            size: "120g",
            price: 288,
            originalPrice: 320,
            productIcon: Icons.lunch_dining_rounded,
            location: "Aisle 4",
            onTap: () => context.push('/productdetails'),
            onAddToCart: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Added Lay's Chips to Smart Basket")),
              );
            },
          ),
          const SizedBox(width: 14),
          ShopMateProductCard(
            brand: "Araliya",
            name: "Keeri Samba Rice 5kg",
            size: "5 kg",
            price: 1350,
            originalPrice: 1550,
            productIcon: Icons.grain_rounded,
            location: "Aisle 1",
            onTap: () => context.push('/productdetails'),
            onAddToCart: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added Keeri Samba Rice to Smart Basket')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsList(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          ShopMateProductCard(
            brand: "Prima",
            name: "Special Crust Bread",
            size: "450g",
            price: 190,
            productIcon: Icons.bakery_dining_rounded,
            location: "Bakery",
            onTap: () => context.push('/productdetails'),
            onAddToCart: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added Bread to Smart Basket')),
              );
            },
          ),
          const SizedBox(width: 14),
          ShopMateProductCard(
            brand: "Anchor",
            name: "Full Cream Milk Powder",
            size: "400g",
            price: 1080,
            originalPrice: 1150,
            productIcon: Icons.coffee_rounded,
            location: "Aisle 3",
            onTap: () => context.push('/productdetails'),
            onAddToCart: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added Milk Powder to Smart Basket')),
              );
            },
          ),
          const SizedBox(width: 14),
          ShopMateProductCard(
            brand: "Sunlight",
            name: "Lemon Soap 4-Pack",
            size: "400g",
            price: 420,
            productIcon: Icons.clean_hands_rounded,
            location: "Aisle 5",
            onTap: () => context.push('/productdetails'),
            onAddToCart: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added Sunlight Soap to Smart Basket')),
              );
            },
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
            onAddToCart: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added Cooking Oil to Smart Basket')),
              );
            },
          ),
          const SizedBox(height: 12),
          ShopMateProductCard(
            isCompact: true,
            brand: "Kotmale",
            name: "Pasteurized Fresh Eggs",
            size: "Pack of 10",
            price: 460,
            productIcon: Icons.egg_rounded,
            onTap: () => context.push('/productdetails'),
            onAddToCart: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added Fresh Eggs to Smart Basket')),
              );
            },
          ),
        ],
      ),
    );
  }
}
