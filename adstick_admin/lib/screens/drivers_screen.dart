import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';
import '../models/models.dart';

class DriversScreen extends StatelessWidget {
  const DriversScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🚗 Drivers'),
          bottom: const TabBar(tabs: [
            Tab(text: 'All Drivers'),
            Tab(text: 'Active Now'),
          ]),
        ),
        body: const TabBarView(children: [
          _AllDriversTab(),
          _ActiveDriversTab(),
        ]),
      ),
    );
  }
}

// ── All Drivers ───────────────────────────────────────────────────
class _AllDriversTab extends StatelessWidget {
  const _AllDriversTab();

  @override
  Widget build(BuildContext context) =>
      StreamBuilder<List<DriverRecord>>(
        stream: fsService.allDriversStream(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.brand));
          }
          final drivers = snap.data ?? [];
          if (drivers.isEmpty) {
            return const Center(
              child: Text('No drivers registered yet',
                  style:
                      TextStyle(color: AppTheme.textMuted, fontSize: 13)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: drivers.length,
            itemBuilder: (_, i) =>
                _DriverCard(driver: drivers[i], key: ValueKey(drivers[i].uid)),
          );
        },
      );
}

// ── Active Now ────────────────────────────────────────────────────
class _ActiveDriversTab extends StatelessWidget {
  const _ActiveDriversTab();

  @override
  Widget build(BuildContext context) =>
      StreamBuilder<List<DriverRecord>>(
        stream: fsService.activeDriversStream(),
        builder: (_, snap) {
          final drivers = snap.data ?? [];
          if (drivers.isEmpty) {
            return const Center(
              child: Text('No drivers active right now',
                  style:
                      TextStyle(color: AppTheme.textMuted, fontSize: 13)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: drivers.length,
            itemBuilder: (_, i) => _DriverCard(
                driver: drivers[i],
                showLive: true,
                key: ValueKey(drivers[i].uid)),
          );
        },
      );
}

// ── Driver card ───────────────────────────────────────────────────
class _DriverCard extends StatelessWidget {
  final DriverRecord driver;
  final bool showLive;
  const _DriverCard(
      {required this.driver, this.showLive = false, super.key});

  @override
  Widget build(BuildContext context) {
    final tierColor = _tierColor(driver.tier);
    final statusColor =
        driver.status == 'active' ? AppTheme.green : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Row(children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: tierColor.withValues(alpha: 0.15),
              child: Text(
                driver.name.isNotEmpty
                    ? driver.name[0].toUpperCase() : '?',
                style: TextStyle(
                    color: tierColor,
                    fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(driver.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                Text(driver.email,
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 11),
                    overflow: TextOverflow.ellipsis),
              ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              _TierBadge(tier: driver.tier),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999)),
                child: Text(
                  driver.status,
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ]),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _stat('Total KM',
                '${driver.totalKm.toStringAsFixed(0)} km', AppTheme.brand),
            _stat('Earnings',
                'SAR ${driver.totalEarnings.toStringAsFixed(0)}',
                AppTheme.green),
            _stat('Quality',
                driver.qualityScore > 0
                    ? '${driver.qualityScore.toStringAsFixed(0)}/100'
                    : '—',
                AppTheme.yellow),
          ]),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            if (driver.status == 'active')
              TextButton.icon(
                onPressed: () => _confirmSuspend(context, driver),
                icon: const Icon(Icons.block_rounded,
                    color: Colors.red, size: 16),
                label: const Text('Suspend',
                    style: TextStyle(color: Colors.red, fontSize: 12)),
              )
            else
              TextButton.icon(
                onPressed: () =>
                    fsService.activateDriver(driver.uid),
                icon: const Icon(Icons.check_circle_rounded,
                    color: AppTheme.green, size: 16),
                label: const Text('Activate',
                    style: TextStyle(
                        color: AppTheme.green, fontSize: 12)),
              ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded,
                  color: AppTheme.textMuted, size: 18),
              color: AppTheme.dark2,
              onSelected: (val) =>
                  _handleTierChange(context, driver, val),
              itemBuilder: (_) => [
                const PopupMenuItem(
                    value: 'bronze',
                    child: Text('Set Bronze',
                        style: TextStyle(color: Colors.white))),
                const PopupMenuItem(
                    value: 'silver',
                    child: Text('Set Silver',
                        style: TextStyle(color: Colors.white))),
                const PopupMenuItem(
                    value: 'gold',
                    child: Text('Set Gold',
                        style: TextStyle(color: Colors.white))),
                const PopupMenuItem(
                    value: 'elite',
                    child: Text('Set Elite',
                        style: TextStyle(color: Colors.white))),
              ],
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _stat(String lbl, String val, Color c) => Expanded(
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(lbl,
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 9)),
          Text(val,
              style: TextStyle(
                  color: c, fontSize: 12, fontWeight: FontWeight.w800)),
        ]),
      );

  Color _tierColor(String tier) {
    switch (tier) {
      case 'elite':  return const Color(0xFFA78BFA);
      case 'gold':   return const Color(0xFFFDE68A);
      case 'silver': return const Color(0xFF94A3B8);
      default:       return const Color(0xFFCD7F32);
    }
  }

  void _confirmSuspend(BuildContext context, DriverRecord d) {
    showDialog(
      context: context,
      builder: (_) {
        final ctrl = TextEditingController();
        return AlertDialog(
          backgroundColor: AppTheme.dark2,
          title: Text('Suspend ${d.name}?',
              style: const TextStyle(color: Colors.white)),
          content: TextField(
            controller: ctrl,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Reason (optional)',
              hintStyle: TextStyle(color: AppTheme.textMuted),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel',
                    style: TextStyle(color: AppTheme.textMuted))),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                fsService.suspendDriver(d.uid,
                    reason: ctrl.text.trim().isNotEmpty
                        ? ctrl.text.trim()
                        : null);
                Navigator.pop(context);
              },
              child: const Text('Suspend'),
            ),
          ],
        );
      },
    );
  }

  void _handleTierChange(
      BuildContext context, DriverRecord d, String tier) {
    fsService.updateDriverTier(d.uid, tier);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('${d.name} tier updated to $tier'),
          backgroundColor: AppTheme.dark2),
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
        label = '👑 Elite'; break;
      case 'gold':
        bg = const Color(0xFF78350F); fg = const Color(0xFFFDE68A);
        label = '🥇 Gold'; break;
      case 'silver':
        bg = const Color(0xFF1F2937); fg = const Color(0xFF94A3B8);
        label = '🥈 Silver'; break;
      default:
        bg = const Color(0xFF1C1007); fg = const Color(0xFFCD7F32);
        label = '🥉 Bronze';
    }
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(label,
          style: TextStyle(
              color: fg, fontSize: 9, fontWeight: FontWeight.w700)),
    );
  }
}
