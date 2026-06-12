import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';
import '../models/models.dart';

class CitiesScreen extends StatelessWidget {
  const CitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🏙️ City Coverage')),
      body: StreamBuilder<List<DriverRecord>>(
        stream: fsService.allDriversStream(),
        builder: (_, dSnap) {
          return StreamBuilder<List<Campaign>>(
            stream: fsService.allCampaignsStream(),
            builder: (_, cSnap) {
              if (dSnap.connectionState == ConnectionState.waiting ||
                  cSnap.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: AppTheme.brand));
              }

              final drivers   = dSnap.data ?? [];
              final campaigns = cSnap.data ?? [];
              final cityMap   = _buildCityMap(drivers, campaigns);

              if (cityMap.isEmpty) {
                return const Center(
                  child: Text('No city data yet',
                      style: TextStyle(
                          color: AppTheme.textMuted, fontSize: 13)),
                );
              }

              final sorted = cityMap.entries.toList()
                ..sort((a, b) =>
                    b.value.totalDrivers.compareTo(a.value.totalDrivers));

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Wrap(spacing: 8, children: [
                      _pill('${cityMap.length} Cities', AppTheme.brand),
                      _pill('${drivers.length} Drivers', AppTheme.green),
                      _pill(
                          '${campaigns.where((c) => c.status == "active").length} Campaigns',
                          AppTheme.blue),
                    ]),
                  ),
                  ...sorted.map((e) => _CityCard(
                      city: e.key, data: e.value, key: ValueKey(e.key))),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Map<String, _CityData> _buildCityMap(
      List<DriverRecord> drivers, List<Campaign> campaigns) {
    final map = <String, _CityData>{};

    for (final d in drivers) {
      final cityName = _inferCity(d.vehicleId) ?? 'Riyadh';
      map.putIfAbsent(cityName, () => _CityData(name: cityName));
      map[cityName]!.drivers.add(d);
    }

    for (final c in campaigns) {
      final cityName = c.city.isNotEmpty ? _capitalise(c.city) : 'Riyadh';
      map.putIfAbsent(cityName, () => _CityData(name: cityName));
      map[cityName]!.campaigns.add(c);
    }

    return map;
  }

  String? _inferCity(String vehicleId) {
    final v = vehicleId.toLowerCase();
    if (v.contains('ryd') || v.contains('riyadh')) return 'Riyadh';
    if (v.contains('jed') || v.contains('jeddah')) return 'Jeddah';
    if (v.contains('mec') || v.contains('makkah')) return 'Makkah';
    if (v.contains('dam') || v.contains('dammam')) return 'Dammam';
    return null;
  }

  String _capitalise(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  Widget _pill(String label, Color c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: c.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: c.withValues(alpha: 0.3))),
        child: Text(label,
            style: TextStyle(
                color: c, fontSize: 11, fontWeight: FontWeight.w700)),
      );
}

class _CityData {
  final String name;
  final List<DriverRecord> drivers   = [];
  final List<Campaign> campaigns     = [];

  _CityData({required this.name});

  int get totalDrivers    => drivers.length;
  int get activeDrivers   => drivers.where((d) => d.isActive).length;
  int get activeCampaigns =>
      campaigns.where((c) => c.status == 'active').length;
  double get totalKm =>
      drivers.fold(0.0, (s, d) => s + d.totalKm);
  double get totalSpend =>
      campaigns.fold(0.0, (s, c) => s + c.spentBudget);
}

class _CityCard extends StatelessWidget {
  final String city;
  final _CityData data;
  const _CityCard({required this.city, required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Row(children: [
            const Text('🏙️', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(city,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800)),
            ),
            if (data.activeDrivers > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: AppTheme.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 6, height: 6,
                    decoration: const BoxDecoration(
                        color: AppTheme.green, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 4),
                  Text('${data.activeDrivers} live',
                      style: const TextStyle(
                          color: AppTheme.green,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ]),
              ),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            _stat(Icons.people_rounded, '${data.totalDrivers}', 'Drivers'),
            _stat(Icons.campaign_rounded, '${data.activeCampaigns}',
                'Active Ads'),
            _stat(Icons.route_rounded,
                '${data.totalKm.toStringAsFixed(0)} km', 'Total KM'),
            _stat(Icons.payments_rounded, 'SAR ${_fmt(data.totalSpend)}',
                'Ad Spend'),
          ]),
          if (data.totalDrivers > 0) ...[
            const SizedBox(height: 12),
            Row(children: [
              const Text('Active ratio: ',
                  style: TextStyle(
                      color: AppTheme.textMuted, fontSize: 11)),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: data.activeDrivers / data.totalDrivers,
                    backgroundColor: AppTheme.border,
                    valueColor:
                        const AlwaysStoppedAnimation(AppTheme.green),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${(data.activeDrivers / data.totalDrivers * 100).toInt()}%',
                style: const TextStyle(
                    color: AppTheme.green,
                    fontSize: 11,
                    fontWeight: FontWeight.w700),
              ),
            ]),
          ],
        ]),
      ),
    );
  }

  Widget _stat(IconData icon, String val, String label) => Expanded(
        child: Column(children: [
          Icon(icon, color: AppTheme.brand, size: 16),
          const SizedBox(height: 3),
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

  String _fmt(double v) =>
      v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}K' : v.toStringAsFixed(0);
}
