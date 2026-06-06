import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('👤 Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Avatar
          Container(
            width: double.infinity, padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border)),
            child: Column(children: [
              CircleAvatar(radius: 40, backgroundColor: AppTheme.driverGreen.withOpacity(0.2),
                child: const Icon(Icons.directions_car_rounded, color: AppTheme.driverGreen, size: 40)),
              const SizedBox(height: 12),
              const Text('Ahmed Khalid', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFF78350F), borderRadius: BorderRadius.circular(999)),
                  child: const Text('🥇 Gold Driver', style: TextStyle(color: Color(0xFFFDE68A), fontSize: 12, fontWeight: FontWeight.w700))),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: const [
                _ProfileStat(label: 'Total KM', value: '12,440'),
                _ProfileStat(label: 'Campaigns', value: '8'),
                _ProfileStat(label: 'Rating', value: '4.8 ⭐'),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          _menuItem(Icons.person_outline_rounded, 'Personal Information', () {}),
          _menuItem(Icons.account_balance_rounded, 'Bank Account', () {}),
          _menuItem(Icons.directions_car_outlined, 'My Vehicle', () {}),
          _menuItem(Icons.notifications_outlined, 'Notifications', () {}),
          _menuItem(Icons.language_rounded, 'Language', () {}),
          _menuItem(Icons.help_outline_rounded, 'Help & Support', () {}),
          _menuItem(Icons.shield_outlined, 'Privacy Policy', () {}),
          const SizedBox(height: 8),
          SizedBox(width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.go('/login'),
              icon: const Icon(Icons.logout_rounded, color: Colors.red),
              label: const Text('Sign Out', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: const Color(0x42EF4444)),
                  padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, VoidCallback onTap) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      leading: Icon(icon, color: AppTheme.driverGreen, size: 22),
      title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
      onTap: onTap,
    ),
  );
}

class _ProfileStat extends StatelessWidget {
  final String label, value;
  const _ProfileStat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
    Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
  ]);
}
