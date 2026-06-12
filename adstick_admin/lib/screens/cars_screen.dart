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
      body: StreamBuilder<List<DriverRecord>>(
        stream: fsService.allDriversStream(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.brand));
          }
          final all     = snap.data ?? [];
          final drivers = _applyFilter(all, _filter);

          return Column(children: [
            // ── Filter chips ─────────────────────────────────────
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
                      onSelected: (_) => setState(() => _filter = f),
                      selectedColor: AppTheme.brand.withValues(alpha: 0.2),
                      checkmarkColor: AppTheme.brand,
                      labelStyle: TextStyle(
                          color: sel ? AppTheme.brand : AppTheme.textMuted,
                          fontSize: 12,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w400),
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
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  itemCount: drivers.length,
                  itemBuilder: (_, i) => _CarCard(
                      driver: drivers[i], key: ValueKey(drivers[i].uid)),
                ),
              ),
          ]);
        },
      ),
    );
  }

  List<DriverRecord> _applyFilter(List<DriverRecord> list, String f) {
    switch (f) {
      case 'Active':
        return list.where((d) => d.isActive).toList();
      case 'Idle':
        return list.where((d) => !d.isActive && d.status != 'suspended').toList();
      case 'Suspended':
        return list.where((d) => d.status == 'suspended').toList();
      default:
        return list;
    }
  }
}

class _CarCard extends StatelessWidget {
  final DriverRecord driver;
  const _CarCard({required this.driver, super.key});

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

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
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
              Text(
                driver.vehicleId.isNotEmpty
                    ? driver.vehicleId
                    : 'VEH-${driver.uid.substring(0, 6).toUpperCase()}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(driver.name,
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 11)),
              const SizedBox(height: 4),
              Row(children: [
                Icon(Icons.route_rounded,
                    color: AppTheme.textMuted, size: 12),
                const SizedBox(width: 3),
                Text('${driver.totalKm.toStringAsFixed(0)} km total',
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 11)),
                const SizedBox(width: 10),
                Icon(Icons.local_fire_department_rounded,
                    color: const Color(0xFFFB923C), size: 12),
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
      ),
    );
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
