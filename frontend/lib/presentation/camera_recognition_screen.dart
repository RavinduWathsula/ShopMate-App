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
    extends ConsumerState<CameraRecognitionScreen>
    with SingleTickerProviderStateMixin {
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
          if (((nameLower.contains('soap') || nameLower.contains('lifebuoy')) &&
                  (recNameLower.contains('soap') ||
                      recNameLower.contains('calin'))) ||
              ((nameLower.contains('meadowlea') ||
                      nameLower.contains('astra') ||
                      nameLower.contains('butter')) &&
                  (recNameLower.contains('meadowlea') ||
                      recNameLower.contains('astra') ||
                      recNameLower.contains('butter')))) {
            ref.read(shoppingListProvider.notifier).toggleCheck(item.id);
            break;
          }
        }
      }
    } catch (_) {}

    _showSuccess(name);
  }

  void _captureProduct() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      _showRedAlert('Camera is initializing. Please try again.');
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
        final pName = (result['product_name'] ?? '').toString().toLowerCase();

        // Strictly only Astra Cup and Calin Teen Soap
        final isAstra = pName.contains('astra') || pName.contains('meadowlea');
        final isSoap = pName.contains('soap') || pName.contains('calin');

        if (isAstra || isSoap) {
          _addItemToCartAndSyncList(
            id:
                result['product_id']?.toString() ??
                'scan_${DateTime.now().millisecondsSinceEpoch}',
            name: result['product_name'] ?? 'Product',
            category: result['category']?.toString() ?? 'General',
            price: (result['price'] as num?)?.toDouble() ?? 0.0,
          );
        } else {
          _showRedAlert(
            'Unrecognized item! Only Astra Cup and Calin Soap can be scanned.',
          );
        }
      } else {
        final errorMsg =
            response.errorMessage ??
            'Unrecognized item! Only Astra Cup and Calin Soap can be scanned.';
        _showRedAlert(errorMsg);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Hide loading
      debugPrint('Capture error: $e');
      _showRedAlert('Failed to capture image. Please try again.');
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
                              height:
                                  constraints.maxWidth *
                                  _cameraController!.value.aspectRatio,
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
                            size: Size(
                              constraints.maxWidth,
                              constraints.maxHeight,
                            ),
                            painter: ScannerBracketsPainter(
                              color: _scannerColor,
                            ),
                            child: AnimatedBuilder(
                              animation: _scannerAnimation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(
                                    0,
                                    _scannerAnimation.value *
                                        (constraints.maxHeight - 2),
                                  ),
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

            // Bottom Controls (Shopping List, Shutter Button, Cart)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
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
                child: Row(
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
                    _buildCircleButton(
                      Icons.shopping_cart_outlined,
                      () => context.push('/cart'),
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
  bool shouldRepaint(covariant ScannerBracketsPainter oldDelegate) =>
      oldDelegate.color != color;
}
