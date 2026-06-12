import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/models.dart';

class LiveMapScreen extends StatelessWidget {
  const LiveMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = authService.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: const Text('🗺️ Live Fleet Map')),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: fsService.summaryStream(uid),
        builder: (_, summSnap) {
          final summ = summSnap.data ?? {};
          final activeCars = (summ['activeCars'] ?? 0) as int;
          final totalImpressions = (summ['totalImpressions'] ?? 0) as int;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

              // ── Live stats row ────────────────────────────────
              Row(children: [
                Expanded(
                    child: _StatCard(
                  label: 'Active Cars Now',
                  value: '$activeCars',
                  icon: Icons.directions_car_rounded,
                  color: AppTheme.green,
                  live: true,
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: _StatCard(
                  label: 'Impressions Today',
                  value: _fmtN(totalImpressions),
                  icon: Icons.visibility_rounded,
                  color: AppTheme.brand,
                  live: false,
                )),
              ]),
              const SizedBox(height: 20),

              // ── Map placeholder ───────────────────────────────
              _MapPlaceholder(activeCars: activeCars),
              const SizedBox(height: 20),

              // ── Active campaigns on map ───────────────────────
              const Text('Active Campaign Coverage',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
              const SizedBox(height: 12),
              StreamBuilder<List<Campaign>>(
                stream: fsService.myActiveCampaignsStream(uid),
                builder: (_, snap) {
                  final campaigns = snap.data ?? [];
                  if (campaigns.isEmpty) {
                    return Card(
                      child: const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Text('No active campaigns',
                              style: TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 13)),
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: campaigns
                        .map((c) => _CampaignCoverageRow(campaign: c))
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 20),

              // ── City distribution ─────────────────────────────
              const Text('Coverage by City',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
              const SizedBox(height: 12),
              StreamBuilder<List<Campaign>>(
                stream: fsService.myCampaignsStream(uid),
                builder: (_, snap) {
                  final campaigns = snap.data ?? [];
                  final cityMap = <String, int>{};
                  for (final c in campaigns) {
                    final city = c.city.isNotEmpty ? c.city : 'Unknown';
                    cityMap[city] =
                        (cityMap[city] ?? 0) + c.actualImpressions;
                  }
                  if (cityMap.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  final sorted = cityMap.entries.toList()
                    ..sort((a, b) => b.value.compareTo(a.value));
                  final total = sorted.fold(
                      0, (sum, e) => sum + e.value);

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: sorted.map((e) {
                          final ratio =
                              total > 0 ? e.value / total : 0.0;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(children: [
                              SizedBox(
                                width: 110,
                                child: Text(e.key,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12)),
                              ),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: ratio,
                                    backgroundColor: Colors.white12,
                                    valueColor:
                                        const AlwaysStoppedAnimation(
                                            AppTheme.brand),
                                    minHeight: 6,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${(ratio * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                    color: AppTheme.brand,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700),
                              ),
                            ]),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 80),
            ]),
          );
        },
      ),
    );
  }

  static String _fmtN(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

// ── Map placeholder (real map integration future) ─────────────────
class _MapPlaceholder extends StatelessWidget {
  final int activeCars;
  const _MapPlaceholder({required this.activeCars});

  @override
  Widget build(BuildContext context) {
    // Positions of simulated car dots on the placeholder "map"
    final carPositions = activeCars > 0
        ? List.generate(
            activeCars.clamp(0, 20),
            (i) => Offset(
                0.15 + (i * 37 % 70) / 100,
                0.20 + (i * 53 % 60) / 100))
        : <Offset>[];

    return Container(
      width: double.infinity,
      height: 240,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Grid lines (map grid feel)
            CustomPaint(
              size: const Size(double.infinity, 240),
              painter: _GridPainter(),
            ),

            // Road lines
            Positioned(
              left: 0, right: 0, top: 100,
              child: Container(height: 2, color: Colors.white12)),
            Positioned(
              left: 0, right: 0, top: 150,
              child: Container(height: 1, color: Colors.white10)),
            Positioned(
              left: 120, top: 0, bottom: 0,
              child: Container(width: 2, color: Colors.white12)),
            Positioned(
              left: 220, top: 0, bottom: 0,
              child: Container(width: 1, color: Colors.white10)),

            // Riyadh label
            const Positioned(
              left: 16, top: 16,
              child: Text('Riyadh, Saudi Arabia',
                  style: TextStyle(
                      color: Colors.white38, fontSize: 11))),

            // Car dots
            ...carPositions.map((pos) => Positioned(
                  left: pos.dx * 360,
                  top: pos.dy * 240,
                  child: Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(
                      color: AppTheme.brand,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.brand.withValues(alpha: 0.6),
                          blurRadius: 6,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                  ),
                )),

            // Overlay badge
            if (activeCars > 0)
              Positioned(
                right: 12, bottom: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.green.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.circle,
                        color: Colors.white, size: 8),
                    const SizedBox(width: 6),
                    Text('$activeCars cars live',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),

            if (activeCars == 0)
              const Center(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                  Icon(Icons.directions_car_rounded,
                      color: Colors.white24, size: 40),
                  SizedBox(height: 8),
                  Text('No cars active right now',
                      style: TextStyle(
                          color: Colors.white38, fontSize: 13)),
                ]),
              ),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;

    for (var x = 0.0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Campaign coverage row ─────────────────────────────────────────
class _CampaignCoverageRow extends StatelessWidget {
  final Campaign campaign;
  const _CampaignCoverageRow({required this.campaign});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          Container(
            width: 10, height: 10,
            decoration: const BoxDecoration(
                color: AppTheme.green, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(campaign.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(
                '${campaign.city.isNotEmpty ? campaign.city : "Riyadh"}  ·  ${campaign.activeCars} cars',
                style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 11),
              ),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(
              '${campaign.kmCovered.toStringAsFixed(1)} km',
              style: const TextStyle(
                  color: AppTheme.brand,
                  fontSize: 13,
                  fontWeight: FontWeight.w800),
            ),
            const Text('today',
                style: TextStyle(
                    color: AppTheme.textMuted, fontSize: 10)),
          ]),
        ]),
      ),
    );
  }
}

// ── Stat card ─────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  final bool live;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color,
      required this.live});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Row(children: [
              Icon(icon, color: color, size: 18),
              if (live) ...[
                const Spacer(),
                Container(
                  width: 7, height: 7,
                  decoration: BoxDecoration(
                      color: AppTheme.green, shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                const Text('LIVE',
                    style: TextStyle(
                        color: AppTheme.green,
                        fontSize: 9,
                        fontWeight: FontWeight.w800)),
              ],
            ]),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 22,
                    fontWeight: FontWeight.w900)),
            Text(label,
                style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 11)),
          ]),
        ),
      );
}
