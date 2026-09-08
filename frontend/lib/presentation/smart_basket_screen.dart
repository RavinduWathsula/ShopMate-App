import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

class SmartBasketScreen extends StatefulWidget {
  const SmartBasketScreen({super.key});

  @override
  State<SmartBasketScreen> createState() => _SmartBasketScreenState();
}

class _SmartBasketScreenState extends State<SmartBasketScreen> {
  bool _option1Selected = false;
  bool _option2Selected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Smart Basket Suggestions',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSummaryHeader(),
            const SizedBox(height: 24),
            _buildOption1(),
            const SizedBox(height: 16),
            _buildOption2(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButtons(),
    );
  }

  Widget _buildSummaryHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSummaryRow('Original Total:', 'Rs. 4,500', isTotal: false),
          const SizedBox(height: 12),
          _buildSummaryRow('Optimized Total:', 'Rs. 4,000', isTotal: false),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          _buildSummaryRow('You Save:', 'Rs. 500', isTotal: true, valueColor: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 20 : 16,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildOption1() {
    return _buildSuggestionCard(
      title: 'OPTION 1: Replace Product',
      icon: Icons.swap_horiz_rounded,
      isSelected: _option1Selected,
      onChanged: (val) => setState(() => _option1Selected = val ?? false),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.remove_circle_outline, color: AppColors.error, size: 20),
              const SizedBox(width: 8),
              Text('Brand A Cereal', style: GoogleFonts.inter(fontSize: 15, decoration: TextDecoration.lineThrough, color: AppColors.textSecondary)),
              const Spacer(),
              Text('Rs. 750', style: GoogleFonts.inter(fontSize: 15, decoration: TextDecoration.lineThrough, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('Brand B Cereal', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const Spacer(),
              Text('Rs. 600', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
            ],
          ),
          const SizedBox(height: 16),
          Text('Save: Rs. 150', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 4),
          Text('Reason: Similar product at a lower price.', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildOption2() {
    return _buildSuggestionCard(
      title: 'OPTION 2: Remove low-priority snack',
      icon: Icons.delete_outline_rounded,
      isSelected: _option2Selected,
      onChanged: (val) => setState(() => _option2Selected = val ?? false),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Save: Rs. 300', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 4),
          Text('Reason: Lower priority compared with your other items.', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required ValueChanged<bool?> onChanged,
    required Widget content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 2 : 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.background,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
              border: Border(bottom: BorderSide(color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : AppColors.border)),
            ),
            child: Row(
              children: [
                Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
                Checkbox(
                  value: isSelected,
                  onChanged: onChanged,
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: AppColors.primary,
                elevation: 0,
              ),
              child: Text(
                'Apply Changes',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: const BorderSide(color: AppColors.border, width: 2),
              ),
              child: Text(
                'Keep My Basket',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
