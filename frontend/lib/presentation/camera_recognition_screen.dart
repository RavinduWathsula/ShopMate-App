import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../providers/basket_provider.dart';
import '../providers/shopping_list_provider.dart';
import '../services/ai_service.dart';

class CameraRecognitionScreen extends ConsumerStatefulWidget {
  const CameraRecognitionScreen({super.key});

  @override
  ConsumerState<CameraRecognitionScreen> createState() =>
      _CameraRecognitionScreenState();
}

class _CameraRecognitionScreenState
    extends ConsumerState<CameraRecognitionScreen> with SingleTickerProviderStateMixin {
  bool _isFlashOn = false;
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  late AnimationController _scannerAnimation;
  Color _scannerColor = AppColors.primaryGreen;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _scannerAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.max,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _scannerAnimation.dispose();
    _cameraController?.dispose();
    super.dispose();
  }



  void _addItemToCartAndSyncList({
    required String id,
    required String name,
    required String category,
    required double price,
  }) {
    final newItem = BasketItem(
      id: id,
      name: name,
      category: category,
      price: price,
    );
    ref.read(basketProvider.notifier).addItem(newItem);

    // Auto-check matching item in shopping list if present
    try {
      final listItems = ref.read(shoppingListProvider);
      for (final item in listItems) {
        if (!item.isChecked) {
          final nameLower = item.name.toLowerCase();
          final recNameLower = name.toLowerCase();
          if ((nameLower.contains('toothpaste') && recNameLower.contains('toothpaste')) ||
              ((nameLower.contains('soap') || nameLower.contains('lifebuoy')) && (recNameLower.contains('soap') || recNameLower.contains('calin'))) ||
              ((nameLower.contains('meadowlea') || nameLower.contains('astra') || nameLower.contains('butter')) && 
               (recNameLower.contains('meadowlea') || recNameLower.contains('astra') || recNameLower.contains('butter')))) {
            ref.read(shoppingListProvider.notifier).toggleCheck(item.id);
            break;
          }
        }
      }
    } catch (_) {}

    _showSuccess(name);
  }

  void _captureProduct([Map<String, dynamic>? product]) async {
    if (product != null) {
      _addItemToCartAndSyncList(
        id: product['id']?.toString() ?? 'quick_${DateTime.now().millisecondsSinceEpoch}',
        name: product['name'] ?? 'Product',
        category: product['category'] ?? 'General',
        price: (product['price'] as num?)?.toDouble() ?? 0.0,
      );
      return;
    }

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      _showManualAddBottomSheet();
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
      );

      final XFile file = await _cameraController!.takePicture();
      final aiService = AiService();
      final response = await aiService.recognizeProduct(file);

      if (mounted) Navigator.pop(context); // Hide loading

      if (response.isSuccess && response.product != null) {
        final result = response.product!;
        _addItemToCartAndSyncList(
          id: result['product_id']?.toString() ?? 'scan_${DateTime.now().millisecondsSinceEpoch}',
          name: result['product_name'] ?? 'Unknown Product',
          category: result['category']?.toString() ?? 'Uncategorized',
          price: (result['price'] as num?)?.toDouble() ?? 0.0,
        );
      } else {
        final errorMsg = response.errorMessage ?? 'Could not recognize product. Please select or add item:';
        _showRedAlert(errorMsg);
        // Seamless fallback: open bottom sheet so user can add the item immediately
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 350), () {
            if (mounted) _showManualAddBottomSheet();
          });
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Hide loading
      debugPrint('Capture error: $e');
      _showRedAlert('Failed to capture image. Choose item below:');
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 350), () {
          if (mounted) _showManualAddBottomSheet();
        });
      }
    }
  }

  void _showRedAlert(String message) {
    if (!mounted) return;
    setState(() {
      _scannerColor = const Color(0xFFD32F2F);
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Item Not Added to Cart',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      fontSize: 12.5,
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFD32F2F), // Bright red alert
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(milliseconds: 3200),
      ),
    );

    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        setState(() {
          _scannerColor = AppColors.primaryGreen;
        });
      }
    });
  }

  void _showSuccess(String productName) {
    if (!mounted) return;
    setState(() {
      _scannerColor = const Color(0xFF2E7D32);
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Auto-added "$productName" to Cart!',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryGreenDark,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1600),
      ),
    );

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) context.go('/cart');
    });
  }

  void _toggleFlash() async {
    if (_cameraController == null) return;
    try {
      if (_isFlashOn) {
        await _cameraController!.setFlashMode(FlashMode.off);
      } else {
        await _cameraController!.setFlashMode(FlashMode.torch);
      }
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      debugPrint('Flash error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera Background Preview
            Positioned.fill(
              child:
                  (_cameraController != null &&
                      _cameraController!.value.isInitialized)
                  ? LayoutBuilder(
                      builder: (context, constraints) {
                        return SizedBox(
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          child: FittedBox(
                            fit: BoxFit.cover,
                            clipBehavior: Clip.hardEdge,
                            child: SizedBox(
                              width: constraints.maxWidth,
                              height: constraints.maxWidth * _cameraController!.value.aspectRatio,
                              child: CameraPreview(_cameraController!),
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                      ),
                    ),
            ),

            // Top Bar
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildIconButton(Icons.arrow_back_rounded, () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/homedashboard');
                    }
                  }),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.amberAccent,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Cargills AI Scanner',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _buildIconButton(
                        _isFlashOn
                            ? Icons.flash_on_rounded
                            : Icons.flash_off_rounded,
                        _toggleFlash,
                      ),
                      const SizedBox(width: 12),
                      _buildIconButton(Icons.checklist_rounded, () {
                        context.push('/shoppinglist');
                      }),
                    ],
                  ),
                ],
              ),
            ),



            // Full Screen Recognition Frame
            Positioned.fill(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 100, 24, 180),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: Size(constraints.maxWidth, constraints.maxHeight),
                            painter: ScannerBracketsPainter(color: _scannerColor),
                            child: AnimatedBuilder(
                              animation: _scannerAnimation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(0, _scannerAnimation.value * (constraints.maxHeight - 2)),
                                  child: child,
                                );
                              },
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  height: 2,
                                  width: constraints.maxWidth - 40,
                                  decoration: BoxDecoration(
                                    color: _scannerColor,
                                    boxShadow: [
                                      BoxShadow(
                                        color: _scannerColor.withValues(
                                          alpha: 0.8,
                                        ),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),

            // Bottom Quick Products & Shutter Button
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.85),
                      Colors.black,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Quick Action Chips for Fast Capture & Adding
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        children: [
                          _buildQuickProductChip(
                            icon: Icons.breakfast_dining_rounded,
                            label: 'Astra Cup (Rs. 220)',
                            product: {
                              'id': 'scan_10000',
                              'name': 'Astra Fat Spread 250g',
                              'category': 'Dairy & Chilled',
                              'price': 220.0,
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildQuickProductChip(
                            icon: Icons.wash_rounded,
                            label: 'Calin Soap (Rs. 110)',
                            product: {
                              'id': 'scan_10001',
                              'name': 'Calin Teen Soap 70g',
                              'category': 'Personal Care',
                              'price': 110.0,
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildQuickProductChip(
                            icon: Icons.cleaning_services_rounded,
                            label: 'Toothpaste (Rs. 135)',
                            product: {
                              'id': 'scan_9999',
                              'name': 'Signal Toothpaste 120g',
                              'category': 'Personal Care',
                              'price': 135.0,
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildQuickProductChip(
                            icon: Icons.playlist_add_rounded,
                            label: 'Manual Pick',
                            onTap: _showManualAddBottomSheet,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Shutter Button Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildCircleButton(
                          Icons.checklist_rounded,
                          () => context.push('/shoppinglist'),
                        ),
                        // Main Shutter Button
                        GestureDetector(
                          onTap: () => _captureProduct(),
                          child: Container(
                            width: 78,
                            height: 78,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            child: Center(
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_rounded,
                                  color: Color(0xFFC62828),
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                        ),
                        _buildCircleButton(Icons.add_shopping_cart_rounded, () {
                          _showManualAddBottomSheet();
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showManualAddBottomSheet() {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final unselectedShoppingList = ref
            .watch(shoppingListProvider)
            .where((item) => !item.isChecked)
            .toList();

        return Container(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_shopping_cart_rounded,
                        color: AppColors.primaryGreen,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Product to Cart',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Choose an item to capture and add to cart:',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'STORE ITEMS (FAST RECOGNITION)',
                  style: GoogleFonts.inter(
                    color: Colors.white38,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),
                _buildProductOptionTile(
                  icon: Icons.breakfast_dining_rounded,
                  iconColor: Colors.amberAccent,
                  name: 'Astra Fat Spread 250g (Astra Cup)',
                  category: 'Dairy & Chilled',
                  price: 220.0,
                  onTap: () {
                    Navigator.pop(ctx);
                    _addItemToCartAndSyncList(
                      id: 'scan_10000',
                      name: 'Astra Fat Spread 250g',
                      category: 'Dairy & Chilled',
                      price: 220.0,
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildProductOptionTile(
                  icon: Icons.wash_rounded,
                  iconColor: Colors.pinkAccent,
                  name: 'Calin Teen Soap 70g (Soap)',
                  category: 'Personal Care',
                  price: 110.0,
                  onTap: () {
                    Navigator.pop(ctx);
                    _addItemToCartAndSyncList(
                      id: 'scan_10001',
                      name: 'Calin Teen Soap 70g',
                      category: 'Personal Care',
                      price: 110.0,
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildProductOptionTile(
                  icon: Icons.cleaning_services_rounded,
                  iconColor: Colors.lightBlueAccent,
                  name: 'Signal Toothpaste 120g',
                  category: 'Personal Care',
                  price: 135.0,
                  onTap: () {
                    Navigator.pop(ctx);
                    _addItemToCartAndSyncList(
                      id: 'scan_9999',
                      name: 'Signal Toothpaste 120g',
                      category: 'Personal Care',
                      price: 135.0,
                    );
                  },
                ),
                if (unselectedShoppingList.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text(
                    'FROM YOUR SHOPPING LIST',
                    style: GoogleFonts.inter(
                      color: Colors.white38,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...unselectedShoppingList.take(3).map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: _buildProductOptionTile(
                        icon: item.icon,
                        iconColor: AppColors.primaryGreen,
                        name: item.name,
                        category: item.category,
                        price: item.price,
                        onTap: () {
                          Navigator.pop(ctx);
                          _addItemToCartAndSyncList(
                            id: item.id,
                            name: item.name,
                            category: item.category,
                            price: item.price,
                          );
                        },
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                InkWell(
                  onTap: () {
                    Navigator.pop(ctx);
                    _showCustomItemDialog();
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white24,
                        strokeAlign: BorderSide.strokeAlignCenter,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.edit_note_rounded,
                          color: Colors.white70,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Add Custom Item (Name & Price)',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCustomItemDialog() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF222222),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Add Scanned Item',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              autofocus: true,
              style: GoogleFonts.inter(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Product Name',
                labelStyle: GoogleFonts.inter(color: Colors.white60),
                hintText: 'e.g. Astra Cup, Soap, Biscuit',
                hintStyle: GoogleFonts.inter(color: Colors.white30),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryGreen),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: GoogleFonts.inter(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Price (Rs.)',
                labelStyle: GoogleFonts.inter(color: Colors.white60),
                hintText: 'e.g. 220',
                hintStyle: GoogleFonts.inter(color: Colors.white30),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryGreen),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: Colors.white60),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final name = nameCtrl.text.trim().isEmpty
                  ? 'Scanned Product'
                  : nameCtrl.text.trim();
              final price = double.tryParse(priceCtrl.text.trim()) ?? 150.0;
              Navigator.pop(ctx);
              _addItemToCartAndSyncList(
                id: 'scan_${DateTime.now().millisecondsSinceEpoch}',
                name: name,
                category: 'General',
                price: price,
              );
            },
            child: Text(
              'Add to Cart',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductOptionTile({
    required IconData icon,
    required Color iconColor,
    required String name,
    required String category,
    required double price,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    category,
                    style: GoogleFonts.inter(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Rs. ${price.toStringAsFixed(0)}',
                  style: GoogleFonts.inter(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+ Add',
                    style: GoogleFonts.inter(
                      color: AppColors.primaryGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickProductChip({
    required IconData icon,
    required String label,
    Map<String, dynamic>? product,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () => _captureProduct(product),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primaryGreen, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

class ScannerBracketsPainter extends CustomPainter {
  final Color color;
  ScannerBracketsPainter({this.color = AppColors.primaryGreen});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double length = 40;

    // Top-Left
    canvas.drawLine(const Offset(0, 0), const Offset(length, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, length), paint);

    // Top-Right
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width - length, 0),
      paint,
    );
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, length), paint);

    // Bottom-Left
    canvas.drawLine(Offset(0, size.height), Offset(length, size.height), paint);
    canvas.drawLine(
      Offset(0, size.height),
      Offset(0, size.height - length),
      paint,
    );

    // Bottom-Right
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width - length, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width, size.height - length),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant ScannerBracketsPainter oldDelegate) => oldDelegate.color != color;
}
