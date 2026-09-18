import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/theme_provider.dart';
import 'widgets/shopmate_app_bar.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notifications = true;
  bool _sound = true;
  bool _offlineMode = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const ShopMateAppBar(title: 'Settings', showBack: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              decoration: BoxDecoration(
                color: theme.cardTheme.color ?? theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  if (theme.brightness == Brightness.light)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                ],
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(
                      'Dark Mode',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 14.5,
                      ),
                    ),
                    subtitle: Text(
                      'Enable dark theme for the app',
                      style: theme.textTheme.bodyMedium,
                    ),
                    value: isDarkMode,
                    activeThumbColor: AppColors.primaryGreen,
                    activeTrackColor: AppColors.primaryGreenLight,
                    onChanged: (val) {
                      ref.read(themeModeProvider.notifier).state = val
                          ? ThemeMode.dark
                          : ThemeMode.light;
                    },
                  ),
                  const Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: AppColors.border,
                  ),
                  SwitchListTile(
                    title: Text(
                      'Push Notifications',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 14.5,
                      ),
                    ),
                    subtitle: Text(
                      'Receive deal alerts and shopping reminders',
                      style: theme.textTheme.bodyMedium,
                    ),
                    value: _notifications,
                    activeThumbColor: AppColors.primaryGreen,
                    activeTrackColor: AppColors.primaryGreenLight,
                    onChanged: (val) => setState(() => _notifications = val),
                  ),
                  const Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: AppColors.border,
                  ),
                  SwitchListTile(
                    title: Text(
                      'In-Store Beep Sound',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 14.5,
                      ),
                    ),
                    subtitle: Text(
                      'Play confirmation tone on barcode scan',
                      style: theme.textTheme.bodyMedium,
                    ),
                    value: _sound,
                    activeThumbColor: AppColors.primaryGreen,
                    activeTrackColor: AppColors.primaryGreenLight,
                    onChanged: (val) => setState(() => _sound = val),
                  ),
                  const Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: AppColors.border,
                  ),
                  SwitchListTile(
                    title: Text(
                      'Offline Basket Mode',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 14.5,
                      ),
                    ),
                    subtitle: Text(
                      'Cache product data for poor supermarket connectivity',
                      style: theme.textTheme.bodyMedium,
                    ),
                    value: _offlineMode,
                    activeThumbColor: AppColors.primaryGreen,
                    activeTrackColor: AppColors.primaryGreenLight,
                    onChanged: (val) => setState(() => _offlineMode = val),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
