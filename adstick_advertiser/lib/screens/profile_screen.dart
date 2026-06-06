import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('👤 Profile')),
    body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
      Container(width: double.infinity, padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
        child: Column(children: [
          CircleAvatar(radius: 40, backgroundColor: AppTheme.brand.withOpacity(0.2),
              child: const Icon(Icons.business_rounded, color: AppTheme.brand, size: 40)),
          const SizedBox(height: 12),
          const Text('Ahmed Al-Rashid', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          const Text('MyBrand Co.', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
          const SizedBox(height: 8),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: AppTheme.brand.withOpacity(0.15), borderRadius: BorderRadius.circular(999)),
              child: const Text('Growth Plan · SAR 1,299/mo', style: TextStyle(color: AppTheme.brand, fontSize: 12, fontWeight: FontWeight.w700))),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: const [
            _PStat(label: 'Campaigns', value: '3'),
            _PStat(label: 'Total Spend', value: 'SAR 58K'),
            _PStat(label: 'Total Reach', value: '9.3M'),
          ]),
        ]),
      ),
      const SizedBox(height: 16),
      _item(Icons.person_outline_rounded, 'Account Details', () {}),
      _item(Icons.credit_card_rounded, 'Billing & Payment', () {}),
      _item(Icons.notifications_outlined, 'Notifications', () {}),
      _item(Icons.bar_chart_rounded, 'Spend Limits', () {}),
      _item(Icons.help_outline_rounded, 'Help & Support', () {}),
      const SizedBox(height: 8),
      SizedBox(width: double.infinity, child: OutlinedButton.icon(
        onPressed: () => context.go('/login'),
        icon: const Icon(Icons.logout_rounded, color: Colors.red),
        label: const Text('Sign Out', style: TextStyle(color: Colors.red)),
        style: OutlinedButton.styleFrom(side: const BorderSide(color: const Color(0x42EF4444)), padding: const EdgeInsets.symmetric(vertical: 14)),
      )),
    ])),
  );

  static Widget _item(IconData icon, String label, VoidCallback onTap) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      leading: Icon(icon, color: AppTheme.brand, size: 22),
      title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
      onTap: onTap,
    ),
  );
}

class _PStat extends StatelessWidget {
  final String label, value;
  const _PStat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
    Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
  ]);
}
