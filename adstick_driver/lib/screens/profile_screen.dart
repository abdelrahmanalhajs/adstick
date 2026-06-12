import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      appBar: AppBar(title: const Text('👤 Profile')),
      body: StreamBuilder<DriverProfile>(
        stream: fsService.driverProfileStream(uid),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
                    color: AppTheme.driverGreen));
          }

          final profile = snap.data;
          if (profile == null) {
            return const Center(
                child: Text('Profile not found',
                    style: TextStyle(color: AppTheme.textMuted)));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              // ── Avatar card ────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border)),
                child: Column(children: [
                  Stack(alignment: Alignment.bottomRight, children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor:
                          AppTheme.driverGreen.withValues(alpha: 0.2),
                      child: Text(
                        profile.name.isNotEmpty
                            ? profile.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            color: AppTheme.driverGreen,
                            fontSize: 36,
                            fontWeight: FontWeight.w900),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          color: AppTheme.textMuted, size: 16),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Text(profile.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(profile.email,
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 12)),
                  const SizedBox(height: 8),
                  _TierBadge(tier: profile.tier),
                  const SizedBox(height: 16),

                  // Stats row
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _ProfileStat(
                          label: 'Total KM',
                          value: _fmtKm(profile.totalKm),
                        ),
                        _ProfileStat(
                          label: 'Streak',
                          value: '${profile.streakDays} 🔥',
                        ),
                        _ProfileStat(
                          label: 'Quality',
                          value:
                              '${profile.qualityScore.toStringAsFixed(0)}%',
                        ),
                      ]),
                ]),
              ),
              const SizedBox(height: 16),

              // ── Quality score ring ─────────────────────────────
              _QualityCard(score: profile.qualityScore),
              const SizedBox(height: 16),

              // ── Tier progress ──────────────────────────────────
              if (!profile.isElite) ...[
                _TierProgressCard(profile: profile),
                const SizedBox(height: 16),
              ],

              // ── Referral code ──────────────────────────────────
              _ReferralCard(code: profile.referralCode),
              const SizedBox(height: 16),

              // ── Menu items ─────────────────────────────────────
              _menuItem(context, Icons.person_outline_rounded,
                  'Personal Information',
                  () => _showEditProfile(context, profile)),
              _menuItem(context, Icons.account_balance_rounded,
                  'Bank Account', () {}),
              _menuItem(context, Icons.directions_car_outlined,
                  'My Vehicle', () {}),
              _menuItem(context, Icons.notifications_outlined,
                  'Notifications', () {}),
              _menuItem(context, Icons.language_rounded, 'Language', () {}),
              _menuItem(context, Icons.help_outline_rounded,
                  'Help & Support', () {}),
              _menuItem(context, Icons.shield_outlined,
                  'Privacy Policy', () {}),
              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) context.go('/login');
                  },
                  icon: const Icon(Icons.logout_rounded,
                      color: Colors.red),
                  label: const Text('Sign Out',
                      style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                        color: Color(0x42EF4444)),
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ]),
          );
        },
      ),
    );
  }

  void _showEditProfile(BuildContext context, DriverProfile profile) {
    final nameCtrl  = TextEditingController(text: profile.name);
    final phoneCtrl = TextEditingController(text: profile.phone);
    bool saving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          backgroundColor: AppTheme.card,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text('Edit Profile',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w800)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            _field('Name', nameCtrl),
            const SizedBox(height: 12),
            _field('Phone', phoneCtrl,
                type: TextInputType.phone),
          ]),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              onPressed: saving
                  ? null
                  : () async {
                      setLocal(() => saving = true);
                      try {
                        await fsService.updateProfile(
                            profile.uid, {
                          'name': nameCtrl.text.trim(),
                          'phone': phoneCtrl.text.trim(),
                        });
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text('✅ Profile updated'),
                            backgroundColor: AppTheme.driverGreen,
                          ));
                        }
                      } catch (e) {
                        setLocal(() => saving = false);
                      }
                    },
              child: saving
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {TextInputType type = TextInputType.text}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                color: AppTheme.textMuted, fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: type,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true, fillColor: AppTheme.dark3,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ]);

  Widget _menuItem(BuildContext ctx, IconData icon, String label,
          VoidCallback onTap) =>
      Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Icon(icon, color: AppTheme.driverGreen, size: 22),
          title: Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          trailing: const Icon(Icons.chevron_right_rounded,
              color: AppTheme.textMuted),
          onTap: onTap,
        ),
      );

  String _fmtKm(double km) {
    if (km >= 1000) return '${(km / 1000).toStringAsFixed(1)}K';
    return km.toStringAsFixed(0);
  }
}

// ── Quality score card ────────────────────────────────────────────
class _QualityCard extends StatelessWidget {
  final double score;
  const _QualityCard({required this.score});

  @override
  Widget build(BuildContext context) {
    final color = score >= 90
        ? AppTheme.driverGreen
        : score >= 70
            ? const Color(0xFFFBBF24)
            : Colors.red;

    final label = score >= 90
        ? 'Excellent'
        : score >= 70
            ? 'Good'
            : 'Needs Improvement';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(children: [
        SizedBox(
          width: 64, height: 64,
          child: Stack(children: [
            CircularProgressIndicator(
              value: score / 100,
              backgroundColor: AppTheme.border,
              valueColor: AlwaysStoppedAnimation(color),
              strokeWidth: 6,
            ),
            Center(
              child: Text(score.toStringAsFixed(0),
                  style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.w900)),
            ),
          ]),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Quality Score',
                    style: TextStyle(
                        color: AppTheme.textMuted, fontSize: 12)),
                const SizedBox(height: 2),
                Text(label,
                    style: TextStyle(
                        color: color,
                        fontSize: 16,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text(
                  'Based on GPS consistency, active hours & campaign compliance',
                  style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 10,
                      height: 1.4),
                ),
              ]),
        ),
      ]),
    );
  }
}

// ── Tier progress card ────────────────────────────────────────────
class _TierProgressCard extends StatelessWidget {
  final DriverProfile profile;
  const _TierProgressCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final nextTier  = DriverProfile.nextTier(profile.tier);
    final nextKm    = DriverProfile.tierMinKm(nextTier);
    final progress  = nextKm > 0 ? (profile.totalKm / nextKm).clamp(0.0, 1.0) : 0.0;
    final remaining = (nextKm - profile.totalKm).clamp(0, double.infinity);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${_tierLabel(profile.tier)} → ${_tierLabel(nextTier)}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
          Text('${(progress * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                  color: AppTheme.driverGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.border,
            valueColor:
                const AlwaysStoppedAnimation(AppTheme.driverGreen),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${remaining.toStringAsFixed(0)} km to ${_tierLabel(nextTier)} tier',
          style: const TextStyle(
              color: AppTheme.textMuted, fontSize: 11),
        ),
      ]),
    );
  }

  String _tierLabel(String tier) {
    switch (tier) {
      case 'silver': return '🥈 Silver';
      case 'gold':   return '🥇 Gold';
      case 'elite':  return '👑 Elite';
      default:       return '🥉 Bronze';
    }
  }
}

// ── Referral card ─────────────────────────────────────────────────
class _ReferralCard extends StatelessWidget {
  final String code;
  const _ReferralCard({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.driverGreen.withValues(alpha: 0.15),
            AppTheme.driverGreen.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppTheme.driverGreen.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.card_giftcard_rounded,
            color: AppTheme.driverGreen, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your Referral Code',
                    style: TextStyle(
                        color: AppTheme.textMuted, fontSize: 11)),
                const SizedBox(height: 2),
                Text(
                  code.isEmpty ? '—' : code,
                  style: const TextStyle(
                      color: AppTheme.driverGreen,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2),
                ),
                const Text('Earn SAR 20 for each driver you refer',
                    style: TextStyle(
                        color: AppTheme.textMuted, fontSize: 10)),
              ]),
        ),
        IconButton(
          onPressed: code.isEmpty
              ? null
              : () {
                  Clipboard.setData(ClipboardData(text: code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Referral code copied!'),
                      backgroundColor: AppTheme.driverGreen,
                    ),
                  );
                },
          icon: const Icon(Icons.copy_rounded,
              color: AppTheme.driverGreen),
        ),
      ]),
    );
  }
}

// ── Tier badge ────────────────────────────────────────────────────
class _TierBadge extends StatelessWidget {
  final String tier;
  const _TierBadge({required this.tier});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    String label;
    switch (tier) {
      case 'elite':
        bg = const Color(0xFF4C1D95); fg = const Color(0xFFA78BFA);
        label = '👑 Elite Driver'; break;
      case 'gold':
        bg = const Color(0xFF78350F); fg = const Color(0xFFFDE68A);
        label = '🥇 Gold Driver'; break;
      case 'silver':
        bg = const Color(0xFF1F2937); fg = const Color(0xFF94A3B8);
        label = '🥈 Silver Driver'; break;
      default:
        bg = const Color(0xFF1C1007); fg = const Color(0xFFCD7F32);
        label = '🥉 Bronze Driver';
    }
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(label,
          style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w700)),
    );
  }
}

// ── Profile stat ──────────────────────────────────────────────────
class _ProfileStat extends StatelessWidget {
  final String label, value;
  const _ProfileStat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800)),
        Text(label,
            style: const TextStyle(
                color: AppTheme.textMuted, fontSize: 11)),
      ]);
}
