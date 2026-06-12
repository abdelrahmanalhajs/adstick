import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

class AiRouteScreen extends StatelessWidget {
  const AiRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final slots = TimeSlot.defaultSlots();
    final now   = DateTime.now();
    final hour  = now.hour;

    // Determine best slot based on current hour
    TimeSlot? bestSlot;
    if (hour >= 7 && hour < 9)        bestSlot = slots[0];
    else if (hour >= 11 && hour < 13) bestSlot = slots[1];
    else if (hour >= 17 && hour < 20) bestSlot = slots[2];
    else if (hour >= 21)              bestSlot = slots[3];
    bestSlot ??= slots[2]; // default to evening

    return Scaffold(
      appBar: AppBar(title: const Text('🤖 AI Route Optimizer')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Today's recommendation ─────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.driverGreen.withValues(alpha: 0.3),
                  AppTheme.driverGreen.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppTheme.driverGreen.withValues(alpha: 0.4)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              const Row(children: [
                Icon(Icons.auto_awesome_rounded,
                    color: AppTheme.driverGreen, size: 18),
                SizedBox(width: 6),
                Text('AI Recommendation · Now',
                    style: TextStyle(
                        color: AppTheme.driverGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 12),
              Text(
                'Drive in ${bestSlot.zone}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(bestSlot.hours,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 6, children: [
                _pill('${bestSlot.multiplier}× earnings',
                    AppTheme.driverGreen),
                _pill(bestSlot.reason, Colors.white38),
              ]),
            ]),
          ),
          const SizedBox(height: 24),

          // ── Time slot grid ─────────────────────────────────────
          const Text('Time Slot Earnings Multipliers',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: slots.map((s) {
              final isActive = s == bestSlot;
              return _TimeSlotCard(slot: s, isActive: isActive);
            }).toList(),
          ),
          const SizedBox(height: 24),

          // ── Best zones ─────────────────────────────────────────
          const Text('Top Earning Zones Today',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 12),
          ..._bestZones().map((z) => _ZoneRow(
                name: z['name'] as String,
                multiplier: z['multiplier'] as double,
                status: z['status'] as String,
                impressions: z['impressions'] as String,
              )),
          const SizedBox(height: 24),

          // ── Peak hours chart ───────────────────────────────────
          const Text('Hourly Multiplier Today',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 12),
          _PeakHoursChart(currentHour: hour),
          const SizedBox(height: 24),

          // ── Tips ───────────────────────────────────────────────
          const Text('Pro Tips',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 12),
          ..._tips().map((t) => _TipCard(icon: t.$1, text: t.$2)),
          const SizedBox(height: 80),
        ]),
      ),
    );
  }

  Widget _pill(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(999)),
        child: Text(label,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      );

  List<Map<String, dynamic>> _bestZones() => [
        {'name': 'Downtown / City Centre', 'multiplier': 1.6,
         'status': 'High Traffic',   'impressions': '~1,200/hr'},
        {'name': 'Commercial District',    'multiplier': 1.4,
         'status': 'Medium Traffic', 'impressions': '~900/hr'},
        {'name': 'Shopping Malls',         'multiplier': 1.3,
         'status': 'Medium Traffic', 'impressions': '~750/hr'},
        {'name': 'Airport / Highway',      'multiplier': 1.1,
         'status': 'Low Traffic',    'impressions': '~500/hr'},
      ];

  List<(IconData, String)> _tips() => [
        (Icons.access_time_rounded,
            'Drive during 5–8 PM for the highest 1.6× multiplier'),
        (Icons.location_city_rounded,
            'City centre has the highest impression density'),
        (Icons.local_gas_station_rounded,
            'Refuel before peak hours to maximise driving time'),
        (Icons.route_rounded,
            'Loop routes cover more unique impressions than straight lines'),
      ];
}

// ── Time slot card ────────────────────────────────────────────────
class _TimeSlotCard extends StatelessWidget {
  final TimeSlot slot;
  final bool isActive;
  const _TimeSlotCard({required this.slot, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppTheme.driverGreen : AppTheme.textMuted;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.driverGreen.withValues(alpha: 0.1)
            : AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isActive
                ? AppTheme.driverGreen.withValues(alpha: 0.4)
                : AppTheme.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
            child: Text(slot.label,
                style: TextStyle(
                    color: isActive ? Colors.white : AppTheme.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis),
          ),
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.driverGreen.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text('Now',
                  style: TextStyle(
                      color: AppTheme.driverGreen,
                      fontSize: 10,
                      fontWeight: FontWeight.w800)),
            ),
        ]),
        const SizedBox(height: 4),
        Text(slot.hours,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
        const Spacer(),
        Text('${slot.multiplier}×',
            style: TextStyle(
                color: color, fontSize: 26, fontWeight: FontWeight.w900)),
        Text('earnings', style: TextStyle(color: color, fontSize: 10)),
      ]),
    );
  }
}

// ── Zone row ──────────────────────────────────────────────────────
class _ZoneRow extends StatelessWidget {
  final String name, status, impressions;
  final double multiplier;
  const _ZoneRow(
      {required this.name,
      required this.multiplier,
      required this.status,
      required this.impressions});

  @override
  Widget build(BuildContext context) {
    final color = multiplier >= 1.5
        ? AppTheme.driverGreen
        : multiplier >= 1.3
            ? const Color(0xFFFBBF24)
            : AppTheme.textMuted;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text('${multiplier}×',
                style: TextStyle(
                    color: color, fontSize: 13, fontWeight: FontWeight.w900)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name,
                style: const TextStyle(
                    color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
            Text('$status · $impressions',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
          ]),
        ),
        const Icon(Icons.arrow_forward_ios_rounded,
            color: AppTheme.textMuted, size: 14),
      ]),
    );
  }
}

// ── Peak hours chart ──────────────────────────────────────────────
class _PeakHoursChart extends StatelessWidget {
  final int currentHour;
  const _PeakHoursChart({required this.currentHour});

  static const _multipliers = {
    0: 1.0, 1: 0.9, 2: 0.8, 3: 0.8, 4: 0.9, 5: 1.0,
    6: 1.1, 7: 1.5, 8: 1.5, 9: 1.2, 10: 1.1, 11: 1.2,
    12: 1.2, 13: 1.1, 14: 1.0, 15: 1.1, 16: 1.3, 17: 1.6,
    18: 1.6, 19: 1.6, 20: 1.4, 21: 1.3, 22: 1.2, 23: 1.1,
  };

  @override
  Widget build(BuildContext context) {
    final hours = List.generate(12, (i) => (currentHour - 2 + i) % 24);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: hours.map((h) {
            final mult  = _multipliers[h] ?? 1.0;
            final isNow = h == currentHour;
            final height = (mult - 0.7) / (1.6 - 0.7) * 60 + 10;
            final color = isNow
                ? AppTheme.driverGreen
                : mult >= 1.5
                    ? const Color(0xFFFBBF24)
                    : AppTheme.textMuted;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    height: height,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: isNow ? 1.0 : 0.5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(_hLabel(h),
                      style: TextStyle(
                          color: isNow
                              ? AppTheme.driverGreen
                              : AppTheme.textMuted,
                          fontSize: 8,
                          fontWeight: isNow
                              ? FontWeight.w800
                              : FontWeight.w400)),
                ]),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          _legend(AppTheme.driverGreen, 'Now'),
          const SizedBox(width: 12),
          _legend(const Color(0xFFFBBF24), 'Peak (1.5×+)'),
          const SizedBox(width: 12),
          _legend(AppTheme.textMuted, 'Normal'),
        ]),
      ]),
    );
  }

  Widget _legend(Color color, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
        ]);

  String _hLabel(int h) {
    if (h == 0)  return '12A';
    if (h == 12) return '12P';
    return h < 12 ? '${h}A' : '${h - 12}P';
  }
}

// ── Tip card ──────────────────────────────────────────────────────
class _TipCard extends StatelessWidget {
  final IconData icon;
  final String text;
  const _TipCard({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(children: [
          Icon(icon, color: AppTheme.driverGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 13, height: 1.4))),
        ]),
      );
}
