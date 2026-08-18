import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(title: const Text('Profile & History')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppConstants.cardColor,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text('Ravindu Wathsula', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text('ravindu@example.com', style: TextStyle(color: Colors.white54)),
            const SizedBox(height: 32),
            _buildMenuItem(Icons.history, 'Order History'),
            _buildMenuItem(Icons.favorite_border, 'Saved Items'),
            _buildMenuItem(Icons.local_offer_outlined, 'My Coupons'),
            _buildMenuItem(Icons.payment, 'Payment Methods'),
            const SizedBox(height: 24),
            _buildMenuItem(Icons.settings_outlined, 'Settings'),
            _buildMenuItem(Icons.help_outline, 'Help & Support'),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white54),
              title: const Text('Logout', style: TextStyle(color: Colors.white54)),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      onTap: () {},
    );
  }
}
