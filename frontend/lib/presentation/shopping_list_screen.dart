import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import 'widgets/shopmate_app_bar.dart';
import 'widgets/shopmate_bottom_nav.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final double _totalBudget = 4000.0;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<Map<String, dynamic>> _items = [
    {
      'id': '1',
      'name': 'Keeri Samba Rice 5kg',
      'category': 'Pantry',
      'price': 1350.0,
      'quantity': 1,
      'isChecked': true,
      'icon': Icons.grain_rounded,
    },
    {
      'id': '2',
      'name': 'Elephant House Fresh Milk 1L',
      'category': 'Dairy',
      'price': 450.0,
      'quantity': 2,
      'isChecked': true,
      'icon': Icons.local_drink_rounded,
    },
    {
      'id': '3',
      'name': 'Prima Sandwich Bread',
      'category': 'Bakery',
      'price': 190.0,
      'quantity': 1,
      'isChecked': false,
      'icon': Icons.bakery_dining_rounded,
    },
    {
      'id': '4',
      'name': 'Pasteurized Fresh Eggs (10s)',
      'category': 'Dairy',
      'price': 460.0,
      'quantity': 1,
      'isChecked': false,
      'icon': Icons.egg_rounded,
    },
    {
      'id': '5',
      'name': 'Fortune Sunflower Cooking Oil 1L',
      'category': 'Pantry',
      'price': 980.0,
      'quantity': 1,
      'isChecked': false,
      'icon': Icons.soup_kitchen_rounded,
    },
    {
      'id': '6',
      'name': 'Sunlight Lemon Soap 4-Pack',
      'category': 'Household',
      'price': 420.0,
      'quantity': 1,
      'isChecked': false,
      'icon': Icons.clean_hands_rounded,
    },
    {
      'id': '7',
      'name': 'Kellogg\'s Corn Flakes Cereal 300g',
      'category': 'Pantry',
      'price': 650.0,
      'quantity': 1,
      'isChecked': false,
      'icon': Icons.breakfast_dining_rounded,
    },
  ];

  final List<String> _categories = ['All', 'Dairy', 'Pantry', 'Bakery', 'Household', 'Snacks'];

  double get _estimatedTotal {
    return _items.fold(0.0, (sum, item) => sum + ((item['price'] as double) * (item['quantity'] as int)));
  }

  void _addNewItemDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    String category = 'Pantry';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            top: 24,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Item to Shopping List',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  hintText: 'e.g. Maliban Biscuits',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Estimated Price (Rs.)',
                  hintText: 'e.g. 250',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.trim().isNotEmpty) {
                    final price = double.tryParse(priceController.text) ?? 200.0;
                    setState(() {
                      _items.add({
                        'id': DateTime.now().millisecondsSinceEpoch.toString(),
                        'name': nameController.text.trim(),
                        'category': category,
                        'price': price,
                        'quantity': 1,
                        'isChecked': false,
                        'icon': Icons.shopping_basket_rounded,
                      });
                    });
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Add to List'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _items.where((item) {
      final matchesCat = _selectedCategory == 'All' || item['category'] == _selectedCategory;
      final matchesSearch = item['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();

    final remainingBudget = _totalBudget - _estimatedTotal;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ShopMateAppBar(
        title: 'Shopping List',
        showBack: false,
        actions: [
          IconButton(
            onPressed: _addNewItemDialog,
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
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
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search your shopping list...',
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
            // Category Horizontal Filters
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                    selectedColor: AppColors.primaryGreen,
                    backgroundColor: Colors.white,
                    labelStyle: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? AppColors.primaryGreen : AppColors.border,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            // Items List
            Expanded(
              child: filteredItems.isEmpty
                  ? Center(
                      child: Text(
                        'No items found',
                        style: GoogleFonts.inter(color: AppColors.textMuted),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: filteredItems.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        final isChecked = item['isChecked'] as bool;

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isChecked ? AppColors.primaryGreen.withValues(alpha: 0.3) : AppColors.border,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Checkbox
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    item['isChecked'] = !isChecked;
                                  });
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: isChecked ? AppColors.primaryGreen : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isChecked ? AppColors.primaryGreen : AppColors.border,
                                      width: 2,
                                    ),
                                  ),
                                  child: isChecked
                                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Product Icon
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  item['icon'] as IconData,
                                  color: AppColors.primaryGreenDark,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Title & Price
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'] as String,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: isChecked ? AppColors.textMuted : AppColors.textPrimary,
                                        decoration: isChecked ? TextDecoration.lineThrough : null,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Rs. ${(item['price'] as double).toStringAsFixed(0)} each',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Quantity Controls
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        if ((item['quantity'] as int) > 1) {
                                          item['quantity'] = (item['quantity'] as int) - 1;
                                        } else {
                                          _items.remove(item);
                                        }
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppColors.background,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.remove, size: 16, color: AppColors.textPrimary),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      '${item['quantity']}',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        item['quantity'] = (item['quantity'] as int) + 1;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppColors.background,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.add, size: 16, color: AppColors.textPrimary),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            // Bottom Summary Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_items.length} Items Total',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Rs. ${_estimatedTotal.toStringAsFixed(0)}',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryGreenDark,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Remaining Budget',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Rs. ${remainingBudget.toStringAsFixed(0)}',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: remainingBudget >= 0 ? AppColors.primaryGreen : AppColors.warningRed,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: () => context.push('/smartbasket'),
                    child: const Text('Start Shopping with Smart Basket'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const ShopMateBottomNav(currentIndex: 1),
    );
  }
}
