import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';
import '../models/models.dart';

class FleetScreen extends StatelessWidget {
  const FleetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🚗 Fleet Management')),
      body: StreamBuilder<List<DriverRecord>>(
        stream: fsService.allDriversStream(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.brand));
          }
          final drivers = snap.data ?? [];

          final total   = drivers.length;
          final active  = drivers.where((d) => d.isActive).length;
          final idle    = drivers.where((d) => d.status == 'inactive').length;
          final susp    = drivers.where((d) => d.status == 'suspended').length;

          return Column(children: [
            // ── Summary row ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                _kpi('Total', '$total', AppTheme.blue),
                const SizedBox(width: 8),
                _kpi('Active', '$active', AppTheme.green),
                const SizedBox(width: 8),
                _kpi('Idle', '$idle', AppTheme.yellow),
                const SizedBox(width: 8),
                _kpi('Suspended', '$susp', AppTheme.red),
              ]),
            ),

            // ── Health overview bar ──────────────────────────────
            if (total > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: _HealthBar(
                    active: active, idle: idle,
                    suspended: susp, total: total),
              ),

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Driver Register',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
              ),
            ),

            Expanded(
              child: drivers.isEmpty
                  ? const Center(
                      child: Text('No drivers registered',
                          style: TextStyle(
                              color: AppTheme.textMuted, fontSize: 13)))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                      itemCount: drivers.length,
                      itemBuilder: (_, i) => _FleetCard(
                          driver: drivers[i],
                          key: ValueKey(drivers[i].uid)),
                    ),
            ),
          ]);
        },
      ),
    );
  }

  Widget _kpi(String label, String val, Color c) => Expanded(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(children: [
              Text(val,
                  style: TextStyle(
                      color: c,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
              Text(label,
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 10)),
            ]),
          ),
        ),
      );
}

class _HealthBar extends StatelessWidget {
  final int active, idle, suspended, total;
  const _HealthBar(
      {required this.active,
      required this.idle,
      required this.suspended,
      required this.total});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _dot('Active', '$active', AppTheme.green),
              _dot('Idle', '$idle', AppTheme.yellow),
              _dot('Suspended', '$suspended', AppTheme.red),
            ]),
            const SizedBox(height: 10),
            if (total > 0)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Row(children: [
                  if (active > 0)
                    Expanded(
                        flex: active,
                        child: Container(height: 10, color: AppTheme.green)),
                  if (idle > 0)
                    Expanded(
                        flex: idle,
                        child: Container(height: 10, color: AppTheme.yellow)),
                  if (suspended > 0)
                    Expanded(
                        flex: suspended,
                        child: Container(height: 10, color: AppTheme.red)),
                ]),
              ),
          ]),
        ),
      );

  Widget _dot(String lbl, String val, Color c) =>
      Column(children: [
        Text(val,
            style: TextStyle(
                color: c, fontSize: 20, fontWeight: FontWeight.w800)),
        Text(lbl,
            style: const TextStyle(
                color: AppTheme.textMuted, fontSize: 10)),
      ]);
}

class _FleetCard extends StatelessWidget {
  final DriverRecord driver;
  const _FleetCard({required this.driver, super.key});

  @override
  Widget build(BuildContext context) {
    final statusColor = driver.isActive
        ? AppTheme.green
        : driver.status == 'suspended'
            ? AppTheme.red
            : AppTheme.yellow;
    final healthScore = driver.qualityScore;
    final healthColor = healthScore >= 80
        ? AppTheme.green
        : healthScore >= 60
            ? AppTheme.yellow
            : AppTheme.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.directions_car_rounded,
                  color: statusColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(driver.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
                Text(driver.vehicleId.isNotEmpty
                    ? driver.vehicleId
                    : 'No vehicle ID',
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 11)),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999)),
              child: Text(
                driver.isActive
                    ? 'Active'
                    : driver.status == 'suspended'
                        ? 'Suspended'
                        : 'Idle',
                style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _detail(Icons.person_rounded, driver.email,
                overflow: true),
            const SizedBox(width: 8),
            _detail(Icons.route_rounded,
                '${driver.totalKm.toStringAsFixed(0)} km'),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            const Text('Health:',
                style: TextStyle(
                    color: AppTheme.textMuted, fontSize: 11)),
            const SizedBox(width: 6),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: healthScore / 100,
                  backgroundColor: AppTheme.border,
                  valueColor: AlwaysStoppedAnimation(healthColor),
                  minHeight: 7,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text('${healthScore.toInt()}%',
                style: TextStyle(
                    color: healthColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    side: BorderSide(
                        color: AppTheme.brand.withValues(alpha: 0.4))),
                child: const Text('Track',
                    style: TextStyle(
                        color: AppTheme.brand, fontSize: 12)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    side: BorderSide(
                        color: AppTheme.textMuted.withValues(alpha: 0.3))),
                child: const Text('Details',
                    style: TextStyle(
                        color: AppTheme.textMuted, fontSize: 12)),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _detail(IconData icon, String text, {bool overflow = false}) =>
      Expanded(
        child: Row(children: [
          Icon(icon, color: AppTheme.textMuted, size: 13),
          const SizedBox(width: 4),
          overflow
              ? Expanded(
                  child: Text(text,
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 11),
                      overflow: TextOverflow.ellipsis))
              : Text(text,
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 11)),
        ]),
      );
}
