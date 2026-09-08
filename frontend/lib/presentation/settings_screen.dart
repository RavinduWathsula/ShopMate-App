import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import 'widgets/shopmate_app_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _sound = true;
  bool _offlineMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ShopMateAppBar(
        title: 'Settings',
        showBack: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
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
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('Push Notifications', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14.5)),
                    subtitle: Text('Receive deal alerts and shopping reminders', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                    value: _notifications,
                    activeThumbColor: AppColors.primaryGreen,
                    activeTrackColor: AppColors.primaryGreenLight,
                    onChanged: (val) => setState(() => _notifications = val),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.border),
                  SwitchListTile(
                    title: Text('In-Store Beep Sound', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14.5)),
                    subtitle: Text('Play confirmation tone on barcode scan', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                    value: _sound,
                    activeThumbColor: AppColors.primaryGreen,
                    activeTrackColor: AppColors.primaryGreenLight,
                    onChanged: (val) => setState(() => _sound = val),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.border),
                  SwitchListTile(
                    title: Text('Offline Basket Mode', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14.5)),
                    subtitle: Text('Cache product data for poor supermarket connectivity', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
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
