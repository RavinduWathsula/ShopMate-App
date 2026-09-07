import 'package:flutter/material.dart';

class MobileAppShell extends StatelessWidget {
  final Widget child;

  const MobileAppShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // If the screen is wider than a typical phone, constrain it
        if (constraints.maxWidth > 600) {
          return Container(
            color: const Color(0xFF1E1E1E), // Dark neutral browser background
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 390,
                  maxHeight: 932, // iPhone 14 Pro Max height as a reasonable max
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                          size: Size(390, constraints.maxHeight > 932 ? 932 : constraints.maxHeight),
                          padding: const EdgeInsets.only(top: 48, bottom: 34), // Simulated safe area
                          viewInsets: EdgeInsets.zero,
                          viewPadding: const EdgeInsets.only(top: 48, bottom: 34),
                        ),
                        child: child,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        // Native mobile view - no wrapping needed
        return child;
      },
    );
  }
}
