import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';

class StoreMapScreen extends StatefulWidget {
  const StoreMapScreen({super.key});

  @override
  State<StoreMapScreen> createState() => _StoreMapScreenState();
}

class _StoreMapScreenState extends State<StoreMapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Optimized Route', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/homedashboard');
            }
          },
        ),
      ),
      body: Column(
        children: [
          _buildLegend(),
          Expanded(
            child: _buildMapArea(),
          ),
          _buildBottomPanel(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      color: Colors.white,
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: [
          _buildLegendItem(Icons.meeting_room, Colors.green, 'Entrance'),
          _buildLegendItem(Icons.my_location, Colors.blue, 'Your Location'),
          _buildLegendItem(Icons.shopping_basket, AppColors.primary, 'Products'),
          _buildLegendItem(Icons.point_of_sale, Colors.orange, 'Checkout'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(IconData icon, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildMapArea() {
    return Container(
      color: const Color(0xFFF0F4F8), // Light map background
      child: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(40),
        minScale: 0.5,
        maxScale: 3.0,
        child: Center(
          child: Container(
            width: 350,
            height: 480,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
              ],
            ),
            child: CustomPaint(
              size: const Size(350, 480),
              painter: SupermarketMapPainter(primaryColor: AppColors.primary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Distance', '320 m', Icons.route),
                Container(width: 1, height: 40, color: AppColors.border),
                _buildStat('Estimated Time', '5 min', Icons.timer_outlined),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.push('/shoppingsummary');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: AppColors.primary,
                elevation: 0,
              ),
              child: Text(
                'Start Navigation',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 22, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ],
        ),
        const SizedBox(height: 6),
        Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
      ],
    );
  }
}

class SupermarketMapPainter extends CustomPainter {
  final Color primaryColor;

  SupermarketMapPainter({required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFE2E8F0);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 1.5;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    void drawZone(Rect rect, String label, {Color? color}) {
      paint.color = color ?? const Color(0xFFF1F5F9);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), paint);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), borderPaint);

      textPainter.text = TextSpan(
        text: label,
        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF475569)),
      );
      textPainter.layout(minWidth: rect.width, maxWidth: rect.width);
      textPainter.paint(canvas, Offset(rect.left, rect.top + (rect.height - textPainter.height) / 2));
    }

    // Floor Plan Layout
    // Width: 350, Height: 480

    // Entrance
    drawZone(const Rect.fromLTWH(20, 420, 80, 40), 'Entrance', color: Colors.green.withValues(alpha: 0.15));
    
    // Checkout
    drawZone(const Rect.fromLTWH(220, 420, 110, 40), 'Checkout', color: Colors.orange.withValues(alpha: 0.15));

    // Aisles 1-5
    double aisleWidth = 32;
    double aisleHeight = 200;
    double startX = 60;
    double startY = 160;
    double spacing = 48;

    for (int i = 0; i < 5; i++) {
      drawZone(Rect.fromLTWH(startX + (i * spacing), startY, aisleWidth, aisleHeight), 'Aisle\n${i + 1}');
    }

    // Perimeter Zones
    // Top Zones
    drawZone(const Rect.fromLTWH(20, 20, 90, 50), 'Household', color: Colors.blue.withValues(alpha: 0.1));
    drawZone(const Rect.fromLTWH(130, 20, 90, 50), 'Dairy', color: Colors.blue.withValues(alpha: 0.1));
    drawZone(const Rect.fromLTWH(240, 20, 90, 50), 'Bakery', color: Colors.blue.withValues(alpha: 0.1));
    
    // Left Zone
    drawZone(const Rect.fromLTWH(10, 90, 30, 310), 'Drinks', color: Colors.blue.withValues(alpha: 0.1));
    
    // Right Zone
    drawZone(const Rect.fromLTWH(310, 90, 30, 310), 'Snacks', color: Colors.blue.withValues(alpha: 0.1));

    // Route (Mock Dijkstra Path)
    final path = Path();
    path.moveTo(60, 420); // Entrance
    path.lineTo(60, 380); // Move up
    path.lineTo(100, 380); // Aisle 1 entry
    path.lineTo(100, 260); // Product 1
    path.lineTo(100, 100); // Exit Aisle 1 top
    path.lineTo(175, 100); // Dairy
    path.lineTo(175, 140); // Aisle 3 entry top
    path.lineTo(175, 290); // Product 3
    path.lineTo(175, 380); // Exit Aisle 3 bottom
    path.lineTo(260, 380); // Move right to checkout
    path.lineTo(260, 420); // Checkout

    final routePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = primaryColor
      ..strokeWidth = 4
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    // Draw shadow for route line
    canvas.drawPath(path, Paint()
      ..style = PaintingStyle.stroke
      ..color = primaryColor.withValues(alpha: 0.2)
      ..strokeWidth = 10
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round);
      
    // Draw solid route line
    canvas.drawPath(path, routePaint);

    // Draw Your Location (Current)
    canvas.drawCircle(const Offset(60, 400), 8, Paint()..color = Colors.blue);
    canvas.drawCircle(const Offset(60, 400), 4, Paint()..color = Colors.white);

    // Draw Products
    final productPaint = Paint()..color = primaryColor;
    void drawProduct(Offset offset) {
      canvas.drawCircle(offset, 10, Paint()..color = Colors.white);
      canvas.drawCircle(offset, 8, productPaint);
      
      textPainter.text = TextSpan(
        text: '★',
        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(offset.dx - textPainter.width / 2, offset.dy - textPainter.height / 2));
    }

    drawProduct(const Offset(100, 260)); // Aisle 1
    drawProduct(const Offset(175, 100)); // Dairy
    drawProduct(const Offset(175, 290)); // Aisle 3

    // Draw End pin
    canvas.drawCircle(const Offset(260, 420), 8, Paint()..color = Colors.orange);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

