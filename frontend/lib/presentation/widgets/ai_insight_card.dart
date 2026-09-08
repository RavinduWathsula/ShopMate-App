import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

enum AIInsightState {
  success,
  warning,
  saving,
  recommendation,
  information
}

class AIInsightCard extends StatefulWidget {
  final String message;
  final AIInsightState state;
  final String? customTitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const AIInsightCard({
    super.key,
    required this.message,
    this.state = AIInsightState.information,
    this.customTitle,
    this.trailing,
    this.onTap,
  });

  @override
  State<AIInsightCard> createState() => _AIInsightCardState();
}

class _AIInsightCardState extends State<AIInsightCard> with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.1, end: 0.5).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  String get _title {
    if (widget.customTitle != null) return widget.customTitle!;
    switch (widget.state) {
      case AIInsightState.success:
        return 'Great Choice';
      case AIInsightState.warning:
        return 'Budget Alert';
      case AIInsightState.saving:
        return 'Savings Found';
      case AIInsightState.recommendation:
        return 'Recommendation';
      case AIInsightState.information:
        return 'AI Insight';
    }
  }

  Color get _stateColor {
    switch (widget.state) {
      case AIInsightState.success:
        return Colors.green;
      case AIInsightState.warning:
        return AppColors.error;
      case AIInsightState.saving:
      case AIInsightState.recommendation:
      case AIInsightState.information:
        return AppColors.aiPurple;
    }
  }

  IconData get _stateIcon {
    switch (widget.state) {
      case AIInsightState.success:
        return Icons.check_circle;
      case AIInsightState.warning:
        return Icons.warning_amber_rounded;
      case AIInsightState.saving:
        return Icons.savings_rounded;
      case AIInsightState.recommendation:
        return Icons.star_rounded;
      case AIInsightState.information:
        return Icons.auto_awesome;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _stateColor.withValues(alpha: _glowAnimation.value),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _stateColor.withValues(alpha: _glowAnimation.value * 0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 5),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.aiPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('🤖', style: TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(_stateIcon, color: _stateColor, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _title,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _stateColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.message,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.trailing != null) ...[
                  const SizedBox(width: 12),
                  widget.trailing!,
                ]
              ],
            ),
          ),
        );
      }
    );
  }
}
