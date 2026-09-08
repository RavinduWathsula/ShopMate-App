import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import 'widgets/shopmate_app_bar.dart';
import 'widgets/shopmate_bottom_nav.dart';
import '../providers/shopping_list_provider.dart';
import '../providers/budget_provider.dart';

class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ConsumerState<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends ConsumerState<ShoppingListScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Dairy',
    'Grains',
    'Bakery',
    'Drinks',
    'Snacks',
    'Household',
  ];

  final List<Map<String, dynamic>> _quickStaples = [
    {'name': 'Fresh Milk 1L', 'price': 450.0, 'category': 'Dairy', 'icon': Icons.local_drink_rounded},
    {'name': 'Prima Bread', 'price': 190.0, 'category': 'Bakery', 'icon': Icons.bakery_dining_rounded},
    {'name': 'Farm Eggs (6s)', 'price': 320.0, 'category': 'Dairy', 'icon': Icons.egg_rounded},
    {'name': 'Watawala Tea', 'price': 420.0, 'category': 'Drinks', 'icon': Icons.emoji_food_beverage_rounded},
    {'name': 'Munchee Cracker', 'price': 240.0, 'category': 'Snacks', 'icon': Icons.cookie_outlined},
  ];

  IconData _iconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'dairy':
        return Icons.local_drink_rounded;
      case 'grains':
        return Icons.grain_rounded;
      case 'bakery':
        return Icons.bakery_dining_rounded;
      case 'drinks':
        return Icons.local_bar_rounded;
      case 'snacks':
        return Icons.cookie_outlined;
      case 'household':
        return Icons.cleaning_services_rounded;
      default:
        return Icons.shopping_basket_rounded;
    }
  }

  void _addQuickStaple(Map<String, dynamic> staple) {
    final newItem = ShoppingListItem(
      id: 'item_${DateTime.now().millisecondsSinceEpoch}',
      name: staple['name'],
      category: staple['category'],
      price: staple['price'],
      quantity: 1,
      isChecked: false,
      icon: staple['icon'],
    );
    ref.read(shoppingListProvider.notifier).addItem(newItem);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('Added ${staple['name']} to list'),
          ],
        ),
        backgroundColor: AppColors.primaryGreenDark,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  void _addNewItemDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    String selectedCat = 'Dairy';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Add Product to List',
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Product Name',
                      hintText: 'e.g. Anchor Butter 227g',
                      prefixIcon: const Icon(Icons.edit_note_rounded),
                      filled: true,
                      fillColor: AppColors.inputBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Estimated Price (Rs.)',
                      hintText: 'e.g. 500',
                      prefixIcon: const Icon(Icons.payments_outlined),
                      filled: true,
                      fillColor: AppColors.inputBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Category',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['Dairy', 'Grains', 'Bakery', 'Drinks', 'Snacks', 'Household'].map((cat) {
                      final isSelected = selectedCat == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() => selectedCat = cat);
                          }
                        },
                        selectedColor: AppColors.primaryGreen,
                        labelStyle: GoogleFonts.inter(
                          fontSize: 12,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameController.text.trim().isNotEmpty) {
                          final price = double.tryParse(priceController.text.trim()) ?? 350.0;
                          final newItem = ShoppingListItem(
                            id: 'item_${DateTime.now().millisecondsSinceEpoch}',
                            name: nameController.text.trim(),
                            category: selectedCat,
                            price: price,
                            quantity: 1,
                            isChecked: false,
                            icon: _iconForCategory(selectedCat),
                          );

                          ref.read(shoppingListProvider.notifier).addItem(newItem);
                          
                          // Ensure new item is visible in current filter
                          setState(() {
                            _selectedCategory = 'All';
                          });

                          Navigator.pop(ctx);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added "${newItem.name}" to Shopping List'),
                              backgroundColor: AppColors.primaryGreenDark,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Add to Shopping List',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(shoppingListProvider);
    final budgetState = ref.watch(budgetProvider);

    final filteredItems = items.where((item) {
      final matchesCat = _selectedCategory == 'All' || item.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesSearch = item.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();

    final estimatedTotal = items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    final remainingBudget = budgetState.budget - estimatedTotal;
    final totalUnits = items.fold(0, (sum, item) => sum + item.quantity);
    final checkedCount = items.where((item) => item.isChecked).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ShopMateAppBar(
        title: 'Shopping List',
        showBack: true,
        actions: [
          IconButton(
            onPressed: () => context.push('/camerarecognition'),
            tooltip: 'Scan & Auto Add',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.aiPurple.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt_rounded, color: AppColors.aiPurple, size: 20),
            ),
          ),
          IconButton(
            onPressed: _addNewItemDialog,
            tooltip: 'Add item manually',
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
            // Search Bar & Scan Shortcut
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
                    hintText: 'Search products in your list...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
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

            // Quick Add Staples Bar
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _quickStaples.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final staple = _quickStaples[index];
                  return ActionChip(
                    avatar: const Icon(Icons.add_rounded, size: 16, color: AppColors.primaryGreenDark),
                    label: Text('+ ${staple['name']}'),
                    onPressed: () => _addQuickStaple(staple),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.border),
                    labelStyle: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // Category Horizontal Filters
            SizedBox(
              height: 40,
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

            const SizedBox(height: 8),

            // Items List
            Expanded(
              child: filteredItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_bag_outlined, size: 48, color: Colors.grey.shade300),
                          const SizedBox(height: 10),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'No items match "$_searchQuery"'
                                : 'Your shopping list is empty',
                            style: GoogleFonts.inter(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _addNewItemDialog,
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add an Item'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: Colors.white,
                              elevation: 0,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: filteredItems.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: item.isChecked
                                  ? AppColors.primaryGreen.withValues(alpha: 0.3)
                                  : AppColors.border,
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
                                  ref.read(shoppingListProvider.notifier).toggleCheck(item.id);
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: item.isChecked ? AppColors.primaryGreen : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: item.isChecked ? AppColors.primaryGreen : AppColors.border,
                                      width: 2,
                                    ),
                                  ),
                                  child: item.isChecked
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
                                  item.icon,
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
                                      item.name,
                                      style: GoogleFonts.inter(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: item.isChecked ? AppColors.textMuted : AppColors.textPrimary,
                                        decoration: item.isChecked ? TextDecoration.lineThrough : null,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Text(
                                          'Rs. ${item.price.toStringAsFixed(0)}',
                                          style: GoogleFonts.inter(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primaryGreenDark,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: AppColors.background,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            item.category,
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Quantity Controls & Delete
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      if (item.quantity > 1) {
                                        ref.read(shoppingListProvider.notifier).updateQuantity(item.id, -1);
                                      } else {
                                        ref.read(shoppingListProvider.notifier).removeItem(item.id);
                                      }
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
                                      '${item.quantity}',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      ref.read(shoppingListProvider.notifier).updateQuantity(item.id, 1);
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
                                  const SizedBox(width: 8),
                                  // Explicit Delete Button
                                  InkWell(
                                    onTap: () {
                                      ref.read(shoppingListProvider.notifier).removeItem(item.id);
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.warningRed),
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

            // Bottom Summary Bar with Live Real-time Recalculation
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
                            'Items: $totalUnits ($checkedCount checked)',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Estimated total: Rs. ${estimatedTotal.toStringAsFixed(0)}',
                            style: GoogleFonts.inter(
                              fontSize: 16,
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
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: remainingBudget >= 0 ? AppColors.primaryGreen : AppColors.warningRed,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/camerarecognition'),
                      icon: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                      label: Text(
                        'Start Shopping (Scan Items)',
                        style: GoogleFonts.inter(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
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
