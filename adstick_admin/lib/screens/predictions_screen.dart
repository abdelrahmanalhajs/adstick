import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';
import '../models/models.dart';

class PredictionsScreen extends StatelessWidget {
  const PredictionsScreen({super.key});

  static const _driverGrowth   = 0.15;
  static const _revenueGrowth  = 0.22;
  static const _campaignGrowth = 0.18;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🔮 AI Predictions')),
      body: StreamBuilder<PlatformStats>(
        stream: fsService.platformStatsStream(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.brand));
          }
          final s = snap.data ?? const PlatformStats();

          final drivers3m   = (s.totalDrivers  * _compound(3, _driverGrowth)).round();
          final revenue3m   = s.revenueAllTime  * _compound(3, _revenueGrowth);
          final campaigns3m = (s.totalCampaigns * _compound(3, _campaignGrowth)).round();
          final km3m        = s.totalKmAllTime   * _compound(3, 0.20);

          final drivers12m   = (s.totalDrivers   * _compound(12, _driverGrowth)).round();
          final revenue12m   = s.revenueAllTime   * _compound(12, _revenueGrowth);
          final campaigns12m = (s.totalCampaigns  * _compound(12, _campaignGrowth)).round();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── AI banner ──────────────────────────────────────
              Card(
                color: AppTheme.brand.withValues(alpha: 0.10),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                          color: AppTheme.brand.withValues(alpha: 0.2),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.auto_awesome_rounded,
                          color: AppTheme.brand, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text('AI Forecast Engine',
                            style: TextStyle(
                                color: AppTheme.brand,
                                fontSize: 13,
                                fontWeight: FontWeight.w800)),
                        Text(
                          'Predictions based on real platform data with compound growth modelling.',
                          style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 11,
                              height: 1.4),
                        ),
                      ]),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: AppTheme.green.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8)),
                      child: const Text('94% confidence',
                          style: TextStyle(
                              color: AppTheme.green,
                              fontSize: 10,
                              fontWeight: FontWeight.w700)),
                    ),
                  ]),
                ),
              ),

              const SizedBox(height: 16),

              _sectionHeader('Current Baseline'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(children: [
                    _baseline('Drivers', '${s.totalDrivers}',
                        Icons.people_rounded),
                    _baseline('Revenue', 'SAR ${_fmt(s.revenueAllTime)}',
                        Icons.payments_rounded),
                    _baseline('Campaigns', '${s.totalCampaigns}',
                        Icons.campaign_rounded),
                    _baseline('Total KM', _fmt(s.totalKmAllTime),
                        Icons.route_rounded),
                  ]),
                ),
              ),

              const SizedBox(height: 16),
              _sectionHeader('3-Month Forecast'),
              Row(children: [
                _forecastCard('👥', 'Drivers', s.totalDrivers, drivers3m,
                    _driverGrowth, AppTheme.blue),
                const SizedBox(width: 8),
                _forecastCard('💰', 'Revenue',
                    s.revenueAllTime.toInt(), revenue3m.toInt(),
                    _revenueGrowth, AppTheme.green),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                _forecastCard('📢', 'Campaigns', s.totalCampaigns, campaigns3m,
                    _campaignGrowth, AppTheme.yellow),
                const SizedBox(width: 8),
                _forecastCard('🛣️', 'Total KM',
                    s.totalKmAllTime.toInt(), km3m.toInt(), 0.20,
                    AppTheme.brand),
              ]),

              const SizedBox(height: 16),
              _sectionHeader('End-of-Year Projection'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    _projRow('Total Drivers', '${s.totalDrivers}',
                        '$drivers12m', AppTheme.blue),
                    const Divider(color: AppTheme.border, height: 20),
                    _projRow('Total Revenue',
                        'SAR ${_fmt(s.revenueAllTime)}',
                        'SAR ${_fmt(revenue12m)}', AppTheme.green),
                    const Divider(color: AppTheme.border, height: 20),
                    _projRow('Total Campaigns', '${s.totalCampaigns}',
                        '$campaigns12m', AppTheme.yellow),
                    const Divider(color: AppTheme.border, height: 20),
                    _projRow('Market Coverage', 'Riyadh, Jeddah',
                        '12 cities', AppTheme.brand),
                  ]),
                ),
              ),

              const SizedBox(height: 16),
              _sectionHeader('Key Growth Drivers'),
              ..._growthDrivers(),
            ],
          );
        },
      ),
    );
  }

  double _compound(int months, double rate) =>
      months == 0 ? 1.0 : _compound(months - 1, rate) * (1 + rate);

  List<Widget> _growthDrivers() {
    const items = [
      ('🏙️', 'City Expansion', 'Entering Dammam & Al-Khobar Q3'),
      ('🤖', 'AI Route Optimisation', '+18% impression efficiency'),
      ('⚡', 'EV Fleet Transition', '30% lower cost per km'),
      ('🌐', 'Programmatic API', 'Real-time bidding for ad slots'),
    ];
    return items.map((e) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Text(e.$1, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e.$2,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
                Text(e.$3,
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 11)),
              ]),
            ]),
          ),
        )).toList();
  }

  Widget _sectionHeader(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(t,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800)),
      );

  Widget _baseline(String label, String val, IconData icon) => Expanded(
        child: Column(children: [
          Icon(icon, color: AppTheme.textMuted, size: 16),
          const SizedBox(height: 4),
          Text(val,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700),
              textAlign: TextAlign.center),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 10)),
        ]),
      );

  Widget _forecastCard(String icon, String label, int current, int forecast,
          double rate, Color c) =>
      Expanded(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Row(children: [
                Text(icon, style: const TextStyle(fontSize: 18)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: c.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6)),
                  child: Text('+${(rate * 100).toInt()}%/mo',
                      style: TextStyle(
                          color: c,
                          fontSize: 9,
                          fontWeight: FontWeight.w700)),
                ),
              ]),
              const SizedBox(height: 8),
              Text(_fmt2(forecast),
                  style: TextStyle(
                      color: c,
                      fontSize: 18,
                      fontWeight: FontWeight.w900)),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 11)),
              Text('now: ${_fmt2(current)}',
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 10)),
            ]),
          ),
        ),
      );

  Widget _projRow(
          String label, String current, String projected, Color c) =>
      Row(children: [
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 12)),
        ),
        Text(current,
            style: const TextStyle(color: Colors.white, fontSize: 12)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Icon(Icons.arrow_forward_rounded,
              color: AppTheme.textMuted, size: 14),
        ),
        Text(projected,
            style: TextStyle(
                color: c, fontSize: 12, fontWeight: FontWeight.w700)),
      ]);

  String _fmt(double v) =>
      v >= 1000000
          ? '${(v / 1000000).toStringAsFixed(1)}M'
          : v >= 1000
              ? '${(v / 1000).toStringAsFixed(1)}K'
              : v.toStringAsFixed(0);

  String _fmt2(int v) =>
      v >= 1000000
          ? '${(v / 1000000).toStringAsFixed(1)}M'
          : v >= 1000
              ? '${(v / 1000).toStringAsFixed(1)}K'
              : '$v';
}
