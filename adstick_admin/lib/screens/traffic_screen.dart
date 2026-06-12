import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';
import '../models/models.dart';

class TrafficScreen extends StatelessWidget {
  const TrafficScreen({super.key});

  static const _hourMultipliers = [
    0.1, 0.1, 0.1, 0.1, 0.2, 0.3, // 0-5
    0.6, 0.9, 1.0, 0.8, 0.7, 0.7, // 6-11
    0.8, 0.7, 0.6, 0.6, 0.7, 0.9, // 12-17
    1.0, 0.9, 0.8, 0.6, 0.4, 0.2, // 18-23
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🗺️ Traffic Intelligence')),
      body: StreamBuilder<List<DriverRecord>>(
        stream: fsService.activeDriversStream(),
        builder: (_, snap) {
          return StreamBuilder<PlatformStats>(
            stream: fsService.platformStatsStream(),
            builder: (_, statSnap) {
              if (snap.connectionState == ConnectionState.waiting ||
                  statSnap.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: AppTheme.brand));
              }

              final activeDrivers = snap.data ?? [];
              final stats         = statSnap.data ?? const PlatformStats();
              final liveCount     = activeDrivers.length;

              final hour    = DateTime.now().hour;
              final factor  = _hourMultipliers[hour];
              final isPeak  = factor >= 0.8;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ── Live banner ──────────────────────────────────
                  Card(
                    color: isPeak
                        ? AppTheme.brand.withValues(alpha: 0.15)
                        : AppTheme.card,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                              color: (isPeak ? AppTheme.brand : AppTheme.green)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14)),
                          child: Icon(
                            isPeak
                                ? Icons.bolt_rounded
                                : Icons.directions_car_rounded,
                            color:
                                isPeak ? AppTheme.brand : AppTheme.green,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(
                              isPeak ? '⚡ Peak Hour' : '🟢 Normal Traffic',
                              style: TextStyle(
                                  color: isPeak
                                      ? AppTheme.brand
                                      : AppTheme.green,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800),
                            ),
                            Text(
                              '$liveCount vehicles active · ${(factor * 100).toInt()}% capacity',
                              style: const TextStyle(
                                  color: AppTheme.textMuted, fontSize: 11),
                            ),
                          ]),
                        ),
                        Text(_formatHour(hour),
                            style: const TextStyle(
                                color: AppTheme.textMuted, fontSize: 11)),
                      ]),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── KPI row ──────────────────────────────────────
                  Row(children: [
                    _kpi('Live Vehicles', '$liveCount', AppTheme.green),
                    const SizedBox(width: 8),
                    _kpi('Total Fleet', '${stats.totalDrivers}', AppTheme.blue),
                    const SizedBox(width: 8),
                    _kpi('KM Today',
                        '${stats.totalKmToday.toStringAsFixed(0)}',
                        AppTheme.yellow),
                  ]),

                  const SizedBox(height: 16),
                  const Text('24h Traffic Heatmap',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(children: [
                        _HeatmapGrid(
                            activeCount: liveCount,
                            currentHour: hour,
                            multipliers: _hourMultipliers),
                        const SizedBox(height: 12),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          _legend(AppTheme.red, 'Peak'),
                          const SizedBox(width: 12),
                          _legend(AppTheme.yellow, 'Busy'),
                          const SizedBox(width: 12),
                          _legend(AppTheme.green, 'Normal'),
                          const SizedBox(width: 12),
                          _legend(AppTheme.border, 'Quiet'),
                        ]),
                      ]),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Text('Active Vehicles',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  ...activeDrivers
                      .take(5)
                      .map((d) => _DriverLiveCard(driver: d)),
                  if (activeDrivers.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('No active vehicles right now',
                            style: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 13)),
                      ),
                    ),

                  const SizedBox(height: 16),
                  const Text('Deployment Recommendations',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  ..._deploymentRecs(liveCount, isPeak),
                ],
              );
            },
          );
        },
      ),
    );
  }

  List<Widget> _deploymentRecs(int liveCount, bool isPeak) => [
        if (isPeak)
          _RecCard(
              icon: '⚡',
              title: 'Deploy to King Fahd Road',
              desc:
                  'Peak hour — high CPM zone. ${liveCount < 10 ? "Boost deployment by activating idle drivers." : "Coverage is optimal."}',
              priority: 'High'),
        _RecCard(
            icon: '🛣️',
            title: 'Route 65 Corridor',
            desc:
                'Consistent 3× engagement rate. Priority targeting enabled.',
            priority: isPeak ? 'High' : 'Medium'),
        _RecCard(
            icon: '🏪',
            title: 'Mall Districts',
            desc:
                'Weekend peak window. ${liveCount >= 5 ? "Currently covered." : "Deploy 5+ vehicles."}',
            priority: 'Medium'),
      ];

  Widget _kpi(String label, String val, Color c) => Expanded(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: [
              Text(val,
                  style: TextStyle(
                      color: c,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
              Text(label,
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 10),
                  textAlign: TextAlign.center),
            ]),
          ),
        ),
      );

  Widget _legend(Color c, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10, height: 10,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 10)),
        ],
      );

  String _formatHour(int h) {
    final suffix = h < 12 ? 'AM' : 'PM';
    final h12    = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$h12:00 $suffix';
  }
}

class _HeatmapGrid extends StatelessWidget {
  final int activeCount;
  final int currentHour;
  final List<double> multipliers;

  const _HeatmapGrid(
      {required this.activeCount,
      required this.currentHour,
      required this.multipliers});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          childAspectRatio: 1.6),
      itemCount: 24,
      itemBuilder: (_, i) {
        final m     = multipliers[i];
        final isCur = i == currentHour;
        final color = m >= 0.9
            ? AppTheme.red
            : m >= 0.7
                ? AppTheme.yellow
                : m >= 0.4
                    ? AppTheme.green
                    : AppTheme.border;

        return Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: isCur ? 0.9 : 0.3 + m * 0.5),
            borderRadius: BorderRadius.circular(4),
            border: isCur
                ? Border.all(color: Colors.white, width: 1.5)
                : null,
          ),
          child: Center(
            child: Text(
              '${i}h',
              style: TextStyle(
                  color: isCur
                      ? Colors.white
                      : color.withValues(alpha: 0.8),
                  fontSize: 8,
                  fontWeight: isCur ? FontWeight.w800 : FontWeight.w400),
            ),
          ),
        );
      },
    );
  }
}

class _DriverLiveCard extends StatelessWidget {
  final DriverRecord driver;
  const _DriverLiveCard({required this.driver});

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Container(
              width: 8, height: 8,
              margin: const EdgeInsets.only(right: 10),
              decoration: const BoxDecoration(
                  color: AppTheme.green, shape: BoxShape.circle),
            ),
            Expanded(
              child: Text(driver.name,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 12)),
            ),
            Text(
              '${driver.totalKm.toStringAsFixed(0)} km · ${driver.tier}',
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 11),
            ),
          ]),
        ),
      );
}

class _RecCard extends StatelessWidget {
  final String icon, title, desc, priority;
  const _RecCard(
      {required this.icon,
      required this.title,
      required this.desc,
      required this.priority});

  @override
  Widget build(BuildContext context) {
    final pc = priority == 'High' ? AppTheme.red : AppTheme.yellow;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Row(children: [
                Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                      color: pc.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999)),
                  child: Text(priority,
                      style: TextStyle(
                          color: pc,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ),
              ]),
              const SizedBox(height: 4),
              Text(desc,
                  style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                      height: 1.4)),
            ]),
          ),
        ]),
      ),
    );
  }
}
