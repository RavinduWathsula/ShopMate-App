import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routing/router.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: ShopMateApp(),
    ),
  );
}

class ShopMateApp extends StatelessWidget {
  const ShopMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ShopMate',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      builder: (context, child) {
        return Container(
          color: Colors.grey.shade900,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: ClipRect(child: child),
            ),
          ),
        );
      },
    );
  }
}
