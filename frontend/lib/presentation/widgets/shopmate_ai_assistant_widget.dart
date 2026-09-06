import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class ShopMateAiAssistantWidget extends StatefulWidget {
  final String message;
  final String? subtitle;
  final VoidCallback? onTap;
  final String? actionLabel;
  final bool compact;

  const ShopMateAiAssistantWidget({
    super.key,
    required this.message,
    this.subtitle,
    this.onTap,
    this.actionLabel,
    this.compact = false,
  });

  @override
  State<ShopMateAiAssistantWidget> createState() => _ShopMateAiAssistantWidgetState();
}

class _ShopMateAiAssistantWidgetState extends State<ShopMateAiAssistantWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glowValue = _glowController.value;
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF2E1065), // Deep AI purple
                Color(0xFF4C1D95), // Vibrant AI violet
                Color(0xFF1E1B4B), // Indigo edge
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.aiPurple.withValues(alpha: 0.25 + (glowValue * 0.15)),
                blurRadius: 16 + (glowValue * 8),
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: AppColors.aiPurpleLight.withValues(alpha: 0.4 + (glowValue * 0.2)),
              width: 1.2,
            ),
          ),
          padding: EdgeInsets.all(widget.compact ? 12.0 : 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Friendly AI Robot Avatar with glowing ring
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: widget.compact ? 42 : 52,
                    height: widget.compact ? 42 : 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFA78BFA).withValues(alpha: 0.5),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.smart_toy_rounded,
                        color: Colors.white,
                        size: widget.compact ? 22 : 28,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              // Speech bubble text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.aiPurpleLight.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'SHOPMATE AI INSIGHT',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFE9D5FF),
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.message,
                      style: GoogleFonts.inter(
                        fontSize: widget.compact ? 13 : 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFFCBD5E1),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.actionLabel != null && widget.onTap != null) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: widget.onTap,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.actionLabel!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
