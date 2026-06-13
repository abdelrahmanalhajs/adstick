import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';
import '../models/models.dart';

class CarsScreen extends StatefulWidget {
  const CarsScreen({super.key});
  @override
  State<CarsScreen> createState() => _CarsScreenState();
}

class _CarsScreenState extends State<CarsScreen> {
  String _filter = 'All';
  final _filters = ['All', 'Active', 'Idle', 'Suspended'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🚘 Cars Registry')),
      body: StreamBuilder<Map<String, Map<String, dynamic>>>(
        stream: fsService.allDriversRtdbStream(),
        builder: (_, rtdbSnap) {
          final rtdb = rtdbSnap.data ?? {};
          return StreamBuilder<List<DriverRecord>>(
            stream: fsService.allDriversStream(),
            builder: (_, snap) {
              if (snap.connectionState == ConnectionState.waiting &&
                  rtdbSnap.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: AppTheme.brand));
              }
              final all     = snap.data ?? [];
              final drivers = _applyFilter(all, _filter);

              return Column(children: [
                // ── Filter chips ───────────────────────────────────
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: _filters.map((f) {
                      final count = _applyFilter(all, f).length;
                      final sel   = _filter == f;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text('$f ($count)'),
                          selected: sel,
                          onSelected: (_) =>
                              setState(() => _filter = f),
                          selectedColor:
                              AppTheme.brand.withValues(alpha: 0.2),
                          checkmarkColor: AppTheme.brand,
                          labelStyle: TextStyle(
                              color: sel
                                  ? AppTheme.brand
                                  : AppTheme.textMuted,
                              fontSize: 12,
                              fontWeight: sel
                                  ? FontWeight.w700
                                  : FontWeight.w400),
                          backgroundColor: AppTheme.card,
                          side: BorderSide(
                              color: sel
                                  ? AppTheme.brand.withValues(alpha: 0.6)
                                  : AppTheme.border),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 0),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                if (drivers.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        _filter == 'All'
                            ? 'No vehicles registered'
                            : 'No $_filter vehicles',
                        style: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 13),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      padding:
                          const EdgeInsets.fromLTRB(16, 0, 16, 80),
                      itemCount: drivers.length,
                      itemBuilder: (_, i) => _CarCard(
                          driver: drivers[i],
                          rtdbData: rtdb[drivers[i].uid],
                          key: ValueKey(drivers[i].uid)),
                    ),
                  ),
              ]);
            },
          );
        },
      ),
    );
  }

  List<DriverRecord> _applyFilter(List<DriverRecord> list, String f) {
    switch (f) {
      case 'Active':
        return list.where((d) => d.isActive).toList();
      case 'Idle':
        return list
            .where((d) => !d.isActive && d.status != 'suspended')
            .toList();
      case 'Suspended':
        return list.where((d) => d.status == 'suspended').toList();
      default:
        return list;
    }
  }
}

class _CarCard extends StatelessWidget {
  final DriverRecord driver;
  final Map<String, dynamic>? rtdbData;
  const _CarCard({required this.driver, this.rtdbData, super.key});

  @override
  Widget build(BuildContext context) {
    final statusColor = driver.isActive
        ? AppTheme.green
        : driver.status == 'suspended'
            ? AppTheme.red
            : AppTheme.yellow;
    final statusLabel = driver.isActive
        ? 'Active'
        : driver.status == 'suspended'
            ? 'Suspended'
            : 'Idle';

    // Today's live stats from RTDB
    final stats    = rtdbData?['todayStats'] as Map?;
    final todayKm  = double.tryParse(
            stats?['distanceKm']?.toString() ?? '0') ?? 0;
    final todayMin = int.tryParse(
            stats?['durationMinutes']?.toString() ?? '0') ?? 0;
    final todayEarn = todayKm * 1.0; // SAR 1 / km base
    final isLive   = rtdbData?['isActive'] == true;

    // Current speed from RTDB location
    final locMap   = rtdbData?['location'] as Map?;
    final speedKmh = double.tryParse(
            locMap?['speed']?.toString() ?? '0') ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // ── Top row: icon + plate + driver + status ───────────
          Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.directions_car_filled_rounded,
                  color: statusColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  Text(
                    driver.vehicleId.isNotEmpty
                        ? driver.vehicleId
                        : 'VEH-${driver.uid.substring(0, 6).toUpperCase()}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
                  if (isLive) ...[
                    const SizedBox(width: 6),
                    Container(
                      width: 7, height: 7,
                      decoration: const BoxDecoration(
                          color: AppTheme.green,
                          shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                    Text('${speedKmh.toStringAsFixed(0)} km/h',
                        style: const TextStyle(
                            color: AppTheme.green,
                            fontSize: 10,
                            fontWeight: FontWeight.w700)),
                  ],
                ]),
                const SizedBox(height: 2),
                Text(driver.name,
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 11)),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.route_rounded,
                      color: AppTheme.textMuted, size: 12),
                  const SizedBox(width: 3),
                  Text('${driver.totalKm.toStringAsFixed(0)} km total',
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 11)),
                  const SizedBox(width: 10),
                  const Icon(Icons.local_fire_department_rounded,
                      color: Color(0xFFFB923C), size: 12),
                  const SizedBox(width: 3),
                  Text('${driver.streakDays}d streak',
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 11)),
                ]),
              ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999)),
                child: Text(statusLabel,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 6),
              Text(_tierLabel(driver.tier),
                  style: TextStyle(
                      color: _tierColor(driver.tier), fontSize: 11)),
            ]),
          ]),

          const SizedBox(height: 10),

          // ── Today live stats ────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
                color: isLive
                    ? AppTheme.green.withValues(alpha: 0.07)
                    : const Color(0xFF12121A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: isLive
                        ? AppTheme.green.withValues(alpha: 0.25)
                        : AppTheme.border)),
            child: Row(children: [
              Text(isLive ? '🟢 Today (live)' : '📅 Today',
                  style: TextStyle(
                      color:
                          isLive ? AppTheme.green : AppTheme.textMuted,
                      fontSize: 9,
                      fontWeight: FontWeight.w700)),
              const Spacer(),
              _liveStat(Icons.route_rounded,
                  '${todayKm.toStringAsFixed(1)} km', AppTheme.brand),
              const SizedBox(width: 12),
              _liveStat(Icons.timer_rounded, _fmtMin(todayMin),
                  AppTheme.blue),
              const SizedBox(width: 12),
              _liveStat(Icons.monetization_on_rounded,
                  'SAR ${todayEarn.toStringAsFixed(1)}', AppTheme.green),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _liveStat(IconData icon, String val, Color c) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: c, size: 12),
        const SizedBox(width: 3),
        Text(val,
            style: TextStyle(
                color: c,
                fontSize: 11,
                fontWeight: FontWeight.w700)),
      ]);

  static String _fmtMin(int m) {
    if (m == 0) return '0m';
    if (m < 60) return '${m}m';
    return '${m ~/ 60}h ${m % 60}m';
  }

  String _tierLabel(String t) {
    switch (t) {
      case 'elite':  return '👑 Elite';
      case 'gold':   return '🥇 Gold';
      case 'silver': return '🥈 Silver';
      default:       return '🥉 Bronze';
    }
  }

  Color _tierColor(String t) {
    switch (t) {
      case 'elite':  return const Color(0xFFA78BFA);
      case 'gold':   return const Color(0xFFFDE68A);
      case 'silver': return const Color(0xFF94A3B8);
      default:       return const Color(0xFFCD7F32);
    }
  }
}
