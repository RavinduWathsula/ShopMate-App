import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import 'widgets/shopmate_bottom_nav.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Mock interactive preference toggles
  bool _autoSubstitutions = true;
  bool _dealAlerts = true;
  bool _expiryTracking = true;
  bool _biometricAuth = true;
  bool _darkMode = false;

  final List<String> _selectedPreferences = [
    '🌱 Organic Priority',
    '⚡ Auto Price-Match',
    '🏷️ Deal Hunter',
  ];

  final List<String> _availablePreferences = [
    '🌱 Organic Priority',
    '⚡ Auto Price-Match',
    '🏷️ Deal Hunter',
    '🌾 Gluten Free',
    '🥗 High Protein',
    '📉 Strict Budget Cap',
    '🥛 Lactose Free',
  ];

  void _showLoyaltyCardModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'ShopMate Supermarket Pass',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Scan this barcode at any partner checkout lane',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            // Simulated Barcode Widget
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(42, (i) {
                      final isThick = (i % 3 == 0) || (i % 7 == 0);
                      final isSpace = (i % 5 == 0);
                      if (isSpace) return const SizedBox(width: 3);
                      return Container(
                        width: isThick ? 4 : 2,
                        height: 70,
                        margin: const EdgeInsets.symmetric(horizontal: 1.2),
                        color: Colors.black87,
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'SM - 9482 - 0184 - 2026',
                    style: GoogleFonts.sourceCodePro(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildModalStat('Loyalty Points', '2,850 pts', AppColors.primaryGreenDark),
                Container(width: 1, height: 32, color: AppColors.border),
                _buildModalStat('Cashback Value', 'Rs. 2,850', AppColors.aiPurple),
                Container(width: 1, height: 32, color: AppColors.border),
                _buildModalStat('Partner Tier', 'VIP Gold', AppColors.dealOrange),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Done',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildModalStat(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Log Out of ShopMate?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Your active shopping list, saved preferences, and budget targets will stay safe.',
          style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14),
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
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warningRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(
              'Log Out',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const ShopMateBottomNav(currentIndex: 3),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Dynamic Creative Sliver App Bar
          _buildSliverHeader(context),

          // Body Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 18),

                  // AI Shopper Stats Ribbon
                  _buildStatsRibbon(),

                  const SizedBox(height: 20),

                  // Digital Loyalty Pass (Apple/Google Wallet look)
                  _buildDigitalLoyaltyCard(context),

                  const SizedBox(height: 22),

                  // ShopMate AI Insights Card
                  _buildAiInsightCard(),

                  const SizedBox(height: 24),

                  // Dietary & Shopping Preferences Section
                  _buildSectionHeader('Smart Shopping Preferences', 'Personalize AI recommendations'),
                  const SizedBox(height: 12),
                  _buildPreferencesChips(),

                  const SizedBox(height: 26),

                  // Quick Shortcuts Section (Budget, Analytics, Cart)
                  _buildSectionHeader('Finance & Analytics', 'Manage spending goals'),
                  const SizedBox(height: 12),
                  _buildFinanceShortcuts(context),

                  const SizedBox(height: 26),

                  // AI Automation & Smart Features Toggles
                  _buildSectionHeader('AI Automation', 'Smart assistant behavior'),
                  const SizedBox(height: 12),
                  _buildAutomationCard(),

                  const SizedBox(height: 26),

                  // App Settings & Preferences
                  _buildSectionHeader('Account & Preferences', 'Security, alerts and display'),
                  const SizedBox(height: 12),
                  _buildAccountSettingsCard(),

                  const SizedBox(height: 26),

                  // Log Out Button
                  _buildLogoutButton(context),

                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Sliver App Bar Header ---
  Widget _buildSliverHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220.0,
      pinned: true,
      backgroundColor: AppColors.primaryGreen,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.25),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16,
            color: Colors.white,
          ),
        ),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/homedashboard');
          }
        },
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF00C853),
                Color(0xFF009624),
                Color(0xFF651FFF),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Subtle background decorative circles
              Positioned(
                top: -30,
                right: -20,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: -40,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),
              // User Info Content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          // Avatar with Pro Badge
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 78,
                                height: 78,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.18),
                                      blurRadius: 14,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  border: Border.all(color: Colors.white, width: 3),
                                ),
                                child: ClipOval(
                                  child: Container(
                                    color: AppColors.aiPurpleSoft,
                                    child: Center(
                                      child: Text(
                                        'RW',
                                        style: GoogleFonts.outfit(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.aiPurple,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: AppColors.dealOrange,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: const Icon(
                                    Icons.edit_rounded,
                                    size: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 18),
                          // Name & Badges
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'Ravindu Wathsula',
                                        style: GoogleFonts.inter(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: -0.3,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Icons.verified_rounded,
                                      color: Colors.amberAccent,
                                      size: 18,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'ravindu.wathsula@shopmate.ai',
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5,
                                    color: Colors.white.withValues(alpha: 0.88),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                // Pro Badge Pill
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.22),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.35),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.auto_awesome_rounded,
                                        color: Colors.amberAccent,
                                        size: 13,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        'PRO AI SHOPPER',
                                        style: GoogleFonts.inter(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: 0.6,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      title: Text(
        'My Profile',
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
          tooltip: 'Loyalty Pass Barcode',
          onPressed: () => _showLoyaltyCardModal(context),
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          tooltip: 'Quick Settings',
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Preferences are managed below in this screen.'),
              duration: Duration(seconds: 2),
            ),
          ),
        ),
      ],
    );
  }

  // --- Stats Ribbon ---
  Widget _buildStatsRibbon() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetricItem(
            icon: Icons.savings_outlined,
            iconColor: AppColors.primaryGreen,
            value: 'Rs. 14.8k',
            label: 'Total Saved',
            badge: '+18% mo',
            badgeColor: AppColors.primaryGreenDark,
          ),
          Container(width: 1, height: 42, color: AppColors.border),
          _buildMetricItem(
            icon: Icons.auto_awesome_rounded,
            iconColor: AppColors.aiPurple,
            value: '96/100',
            label: 'AI Smart Score',
            badge: 'Top 5%',
            badgeColor: AppColors.aiPurple,
          ),
          Container(width: 1, height: 42, color: AppColors.border),
          _buildMetricItem(
            icon: Icons.shopping_bag_outlined,
            iconColor: AppColors.dealOrange,
            value: '28',
            label: 'Trips Tracked',
            badge: '0 Overbudget',
            badgeColor: AppColors.dealOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required String badge,
    required Color badgeColor,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            badge,
            style: GoogleFonts.inter(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: badgeColor,
            ),
          ),
        ),
      ],
    );
  }

  // --- Digital Loyalty Card (NFC / Wallet Style) ---
  Widget _buildDigitalLoyaltyCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLoyaltyCardModal(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF1E293B),
              Color(0xFF0F172A),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: AppColors.primaryGreenLight,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ShopMate Smart Pass',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Supermarket Partner Card',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Icon(
                  Icons.contactless_rounded,
                  color: Colors.white70,
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AVAILABLE BALANCE',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white54,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '2,850 Points',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.amberAccent,
                      ),
                    ),
                    Text(
                      '≈ Rs. 2,850.00 discount ready',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.qr_code_rounded, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'TAP BARCODE',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
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
    );
  }

  // --- AI Insight Card ---
  Widget _buildAiInsightCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.aiPurpleSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.aiPurple.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.aiPurple,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ShopMate AI Shopper Insight',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.aiPurpleDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'By switching to store-brand dairy & catching 3 weekly deals, you reduced your average cart total by 19.4% this month!',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: AppColors.textPrimary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Section Header Helper ---
  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // --- Preferences Filter Chips ---
  Widget _buildPreferencesChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _availablePreferences.map((pref) {
        final isSelected = _selectedPreferences.contains(pref);
        return FilterChip(
          label: Text(
            pref,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedPreferences.add(pref);
              } else {
                _selectedPreferences.remove(pref);
              }
            });
          },
          selectedColor: AppColors.primaryGreenDark,
          backgroundColor: Colors.white,
          checkmarkColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? AppColors.primaryGreenDark : AppColors.border,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        );
      }).toList(),
    );
  }

  // --- Finance & Analytics Shortcuts ---
  Widget _buildFinanceShortcuts(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildNavigationTile(
            icon: Icons.account_balance_wallet_outlined,
            iconColor: AppColors.primaryGreen,
            title: 'Monthly Budget & Limits',
            subtitle: 'Target: Rs. 40,000 / month',
            onTap: () => context.push('/budgetsetup'),
          ),
          const Divider(height: 1, indent: 64, color: AppColors.border),
          _buildNavigationTile(
            icon: Icons.pie_chart_outline_rounded,
            iconColor: AppColors.aiPurple,
            title: 'Spending Analytics',
            subtitle: 'Category breakdowns & projections',
            onTap: () => context.push('/spendinganalytics'),
          ),
          const Divider(height: 1, indent: 64, color: AppColors.border),
          _buildNavigationTile(
            icon: Icons.checklist_rounded,
            iconColor: AppColors.dealOrange,
            title: 'My Shopping Lists',
            subtitle: 'Manage regular pantry replenishment',
            onTap: () => context.push('/shoppinglist'),
          ),
        ],
      ),
    );
  }

  // --- AI Automation Card ---
  Widget _buildAutomationCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.swap_horizontal_circle_outlined,
            iconColor: AppColors.aiPurple,
            title: 'Smart Brand Substitution',
            subtitle: 'Suggest cheaper alternative if out of stock',
            value: _autoSubstitutions,
            onChanged: (val) => setState(() => _autoSubstitutions = val),
          ),
          const Divider(height: 1, indent: 64, color: AppColors.border),
          _buildSwitchTile(
            icon: Icons.notifications_active_outlined,
            iconColor: AppColors.dealOrange,
            title: 'Real-Time Deal Push Alerts',
            subtitle: 'Alert when favorite items drop in price',
            value: _dealAlerts,
            onChanged: (val) => setState(() => _dealAlerts = val),
          ),
          const Divider(height: 1, indent: 64, color: AppColors.border),
          _buildSwitchTile(
            icon: Icons.timelapse_rounded,
            iconColor: AppColors.primaryGreen,
            title: 'Pantry Expiry Tracking',
            subtitle: 'Notify before perishable items expire',
            value: _expiryTracking,
            onChanged: (val) => setState(() => _expiryTracking = val),
          ),
        ],
      ),
    );
  }

  // --- Account Settings Card ---
  Widget _buildAccountSettingsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.fingerprint_rounded,
            iconColor: AppColors.electricBlue,
            title: 'Biometric Login',
            subtitle: 'Fingerprint / Face ID for faster checkout',
            value: _biometricAuth,
            onChanged: (val) => setState(() => _biometricAuth = val),
          ),
          const Divider(height: 1, indent: 64, color: AppColors.border),
          _buildSwitchTile(
            icon: Icons.dark_mode_outlined,
            iconColor: Colors.purple.shade400,
            title: 'Dark Theme Preview',
            subtitle: 'High contrast shopping experience',
            value: _darkMode,
            onChanged: (val) => setState(() => _darkMode = val),
          ),
          const Divider(height: 1, indent: 64, color: AppColors.border),
          _buildNavigationTile(
            icon: Icons.help_outline_rounded,
            iconColor: AppColors.textSecondary,
            title: 'Help Center & AI FAQ',
            subtitle: 'Guides on barcode scanner and smart basket',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ShopMate AI Help Center is active 24/7.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textMuted,
        size: 20,
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primaryGreen,
        activeTrackColor: AppColors.primaryGreenLight,
      ),
    );
  }

  // --- Logout Button ---
  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () => _showLogoutDialog(context),
        icon: const Icon(Icons.logout_rounded, color: AppColors.warningRed, size: 20),
        label: Text(
          'Log Out of Account',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.warningRed,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFFFCDD2), width: 1.5),
          backgroundColor: const Color(0xFFFFEBEE),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
