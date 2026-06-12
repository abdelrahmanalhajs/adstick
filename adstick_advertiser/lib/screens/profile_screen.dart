import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/models.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = authService.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: const Text('👤 Company Profile')),
      body: StreamBuilder<AdvertiserProfile>(
        stream: fsService.advertiserProfileStream(uid),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.brand));
          }
          final profile = snap.data;
          if (profile == null) {
            return const Center(
              child: Text('Profile not found',
                  style: TextStyle(color: AppTheme.textMuted)),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

              // ── Avatar + company ──────────────────────────────
              Center(
                child: Column(children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor:
                        AppTheme.brand.withValues(alpha: 0.15),
                    child: Text(
                      profile.companyName.isNotEmpty
                          ? profile.companyName[0].toUpperCase()
                          : 'A',
                      style: const TextStyle(
                          color: AppTheme.brand,
                          fontSize: 36,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(profile.companyName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(profile.email,
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 13)),
                  const SizedBox(height: 8),
                  _PlanBadge(plan: profile.plan),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showEditDialog(context, uid, profile),
                    icon: const Icon(Icons.edit_rounded, size: 16),
                    label: const Text('Edit Profile'),
                  ),
                ]),
              ),
              const SizedBox(height: 24),

              // ── Account details ───────────────────────────────
              const Text('Account Details',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
              const SizedBox(height: 12),
              Card(
                child: Column(children: [
                  _DetailRow(Icons.business_rounded,
                      'Company Name', profile.companyName),
                  const Divider(color: AppTheme.border, height: 1,
                      indent: 52),
                  _DetailRow(Icons.person_rounded,
                      'Contact Name', profile.name),
                  const Divider(color: AppTheme.border, height: 1,
                      indent: 52),
                  _DetailRow(Icons.email_rounded,
                      'Email', profile.email),
                  const Divider(color: AppTheme.border, height: 1,
                      indent: 52),
                  _DetailRow(Icons.phone_rounded,
                      'Phone',
                      profile.phone.isNotEmpty ? profile.phone : '—'),
                  const Divider(color: AppTheme.border, height: 1,
                      indent: 52),
                  _DetailRow(Icons.location_city_rounded,
                      'City',
                      profile.city.isNotEmpty ? profile.city : '—'),
                ]),
              ),
              const SizedBox(height: 24),

              // ── Billing stats ─────────────────────────────────
              const Text('Billing Overview',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: _StatBox(
                  label: 'Total Spent',
                  value: 'SAR ${profile.totalSpent.toStringAsFixed(0)}',
                  color: AppTheme.blue,
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: _StatBox(
                  label: 'Total Campaigns',
                  value: '${profile.totalCampaigns}',
                  color: AppTheme.brand,
                )),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: _StatBox(
                  label: 'Total Impressions',
                  value: _fmtN(profile.totalImpressions),
                  color: AppTheme.green,
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: _StatBox(
                  label: 'Avg ROI',
                  value: profile.totalSpent > 0
                      ? '${(profile.totalImpressions * 0.004 / profile.totalSpent).toStringAsFixed(1)}×'
                      : '—',
                  color: AppTheme.yellow,
                )),
              ]),
              const SizedBox(height: 24),

              // ── Account ID ────────────────────────────────────
              Card(
                child: ListTile(
                  leading: const Icon(Icons.fingerprint_rounded,
                      color: AppTheme.textMuted, size: 20),
                  title: const Text('Account ID',
                      style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12)),
                  subtitle: Text(uid,
                      style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          fontFamily: 'monospace')),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy_rounded,
                        color: AppTheme.brand, size: 16),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: uid));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied!')),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Danger zone ───────────────────────────────────
              const Text('Account',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textMuted)),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.logout_rounded,
                      color: Colors.red, size: 20),
                  title: const Text('Sign Out',
                      style: TextStyle(color: Colors.red, fontSize: 14)),
                  onTap: () async {
                    await authService.signOut();
                    if (context.mounted) context.go('/login');
                  },
                ),
              ),
              const SizedBox(height: 80),
            ]),
          );
        },
      ),
    );
  }

  void _showEditDialog(
      BuildContext context, String uid, AdvertiserProfile profile) {
    final nameCtrl = TextEditingController(text: profile.name);
    final compCtrl = TextEditingController(text: profile.companyName);
    final phoneCtrl = TextEditingController(text: profile.phone);
    final cityCtrl = TextEditingController(text: profile.city);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.dark2,
        title: const Text('Edit Profile',
            style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _field(nameCtrl, 'Contact Name', Icons.person_rounded),
            const SizedBox(height: 12),
            _field(compCtrl, 'Company Name', Icons.business_rounded),
            const SizedBox(height: 12),
            _field(phoneCtrl, 'Phone', Icons.phone_rounded,
                type: TextInputType.phone),
            const SizedBox(height: 12),
            _field(cityCtrl, 'City', Icons.location_city_rounded),
          ]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              await fsService.updateAdvertiserProfile(uid, {
                'name': nameCtrl.text.trim(),
                'companyName': compCtrl.text.trim(),
                'phone': phoneCtrl.text.trim(),
                'city': cityCtrl.text.trim(),
              });
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, IconData icon,
      {TextInputType? type}) =>
      TextField(
        controller: ctrl,
        keyboardType: type,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppTheme.textMuted),
          prefixIcon: Icon(icon, color: AppTheme.brand, size: 18),
          filled: true,
          fillColor: AppTheme.card,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
        ),
      );

  static String _fmtN(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

// ── Detail row ────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _DetailRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon, color: AppTheme.brand, size: 18),
        title: Text(label,
            style: const TextStyle(
                color: AppTheme.textMuted, fontSize: 11)),
        subtitle: Text(value,
            style: const TextStyle(color: Colors.white, fontSize: 13)),
        dense: true,
      );
}

// ── Plan badge ────────────────────────────────────────────────────
class _PlanBadge extends StatelessWidget {
  final String plan;
  const _PlanBadge({required this.plan});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (plan.toLowerCase()) {
      case 'enterprise':
        color = const Color(0xFFA78BFA); label = '💎 Enterprise'; break;
      case 'growth':
        color = const Color(0xFFFDE68A); label = '🚀 Growth Plan'; break;
      default:
        color = AppTheme.brand; label = '⭐ Starter';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Text(label,
          style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700)),
    );
  }
}

// ── Stat box ──────────────────────────────────────────────────────
class _StatBox extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatBox(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 11)),
          ]),
        ),
      );
}
