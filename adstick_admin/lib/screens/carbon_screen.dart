import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';
import '../models/models.dart';

class CarbonScreen extends StatelessWidget {
  const CarbonScreen({super.key});

  static const _co2PerKm = 0.12;

  static const _initiatives = [
    {
      'icon': '🌱',
      'title': 'Solar-Charged Fleet',
      'desc': 'Partnering with EV charging stations in Riyadh & Jeddah',
      'status': 'Active',
    },
    {
      'icon': '♻️',
      'title': 'Vinyl Recycling Programme',
      'desc': 'End-of-campaign vinyls recycled through certified partners',
      'status': 'Active',
    },
    {
      'icon': '🌳',
      'title': 'Tree Planting Initiative',
      'desc': '1 tree planted for every 500 km driven on the platform',
      'status': 'Pilot',
    },
    {
      'icon': '🔋',
      'title': 'EV Driver Incentive',
      'desc': 'EV drivers earn a 15% bonus multiplier on all campaigns',
      'status': 'Coming Soon',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🌿 Carbon & Sustainability')),
      body: StreamBuilder<PlatformStats>(
        stream: fsService.platformStatsStream(),
        builder: (_, snap) {
          final stats    = snap.data ?? const PlatformStats();
          final totalKm  = stats.totalKmAllTime;
          final co2Saved = totalKm * _co2PerKm;
          final treesEq  = (co2Saved / 21).floor();
          final todayCo2 = stats.totalKmToday * _co2PerKm;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Hero metric ────────────────────────────────────
              Card(
                color: const Color(0xFF052E16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      const Text('🌿', style: TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(
                          '${co2Saved.toStringAsFixed(1)} kg',
                          style: const TextStyle(
                              color: Color(0xFF4ADE80),
                              fontSize: 26,
                              fontWeight: FontWeight.w900),
                        ),
                        const Text('CO₂ saved vs. billboards',
                            style: TextStyle(
                                color: Color(0xFF86EFAC),
                                fontSize: 12)),
                      ]),
                    ]),
                    const SizedBox(height: 16),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                      _greenStat('🚗', '${totalKm.toStringAsFixed(0)} km',
                          'Total platform km'),
                      _greenStat('🌳', '$treesEq', 'Trees equivalent'),
                      _greenStat('📅',
                          '${todayCo2.toStringAsFixed(2)} kg', 'Saved today'),
                    ]),
                  ]),
                ),
              ),

              const SizedBox(height: 16),
              _sectionHeader('Monthly CO₂ Progress'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    Row(children: [
                      const Expanded(
                        child: Text('Monthly Target: 500 kg',
                            style: TextStyle(
                                color: AppTheme.textMuted, fontSize: 12)),
                      ),
                      Text(
                        '${(co2Saved % 500).toStringAsFixed(1)} / 500 kg',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: ((co2Saved % 500) / 500).clamp(0.0, 1.0),
                        backgroundColor: AppTheme.border,
                        valueColor: const AlwaysStoppedAnimation(
                            Color(0xFF4ADE80)),
                        minHeight: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      stats.activeDrivers > 0
                          ? '${stats.activeDrivers} active drivers contributing right now'
                          : 'No drivers active currently',
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                  ]),
                ),
              ),

              const SizedBox(height: 16),
              _sectionHeader('Impact by the Numbers'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    _impactRow('🛣️', '${totalKm.toStringAsFixed(0)} km driven',
                        'eliminates billboard truck deliveries'),
                    const Divider(color: AppTheme.border, height: 20),
                    _impactRow('💡',
                        '${(co2Saved * 4.2).toStringAsFixed(0)} kWh',
                        'equivalent energy offset'),
                    const Divider(color: AppTheme.border, height: 20),
                    _impactRow('🌳', '$treesEq trees',
                        'annual absorption equivalent'),
                  ]),
                ),
              ),

              const SizedBox(height: 16),
              _sectionHeader('Green Initiatives'),
              ..._initiatives.map((init) => _InitiativeCard(
                    icon: init['icon']!,
                    title: init['title']!,
                    desc: init['desc']!,
                    status: init['status']!,
                  )),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800)),
      );

  Widget _greenStat(String icon, String val, String label) => Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(val,
              style: const TextStyle(
                  color: Color(0xFF4ADE80),
                  fontSize: 16,
                  fontWeight: FontWeight.w800)),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF86EFAC), fontSize: 10),
              textAlign: TextAlign.center),
        ],
      );

  Widget _impactRow(String icon, String value, String label) =>
      Row(children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 11)),
        ]),
      ]);
}

class _InitiativeCard extends StatelessWidget {
  final String icon, title, desc, status;
  const _InitiativeCard(
      {required this.icon,
      required this.title,
      required this.desc,
      required this.status});

  @override
  Widget build(BuildContext context) {
    Color sc;
    switch (status) {
      case 'Active':
        sc = AppTheme.green; break;
      case 'Pilot':
        sc = AppTheme.yellow; break;
      default:
        sc = AppTheme.textMuted;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Text(icon, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(desc,
                  style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                      height: 1.4)),
            ]),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: sc.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999)),
            child: Text(status,
                style: TextStyle(
                    color: sc,
                    fontSize: 10,
                    fontWeight: FontWeight.w700)),
          ),
        ]),
      ),
    );
  }
}
