import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';
import '../models/models.dart';

class QualityScreen extends StatelessWidget {
  const QualityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('⭐ Driver Quality Scores')),
      body: StreamBuilder<List<QualityScore>>(
        stream: fsService.qualityScoresStream(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.brand));
          }
          final scores = snap.data ?? [];
          if (scores.isEmpty) {
            return Center(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                const Icon(Icons.analytics_rounded,
                    color: AppTheme.brand, size: 48),
                const SizedBox(height: 12),
                const Text('No quality scores yet',
                    style: TextStyle(
                        color: Colors.white, fontSize: 16,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () =>
                      _computeAllScores(context, scores),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Compute Scores'),
                ),
              ]),
            );
          }
          return Column(children: [
            // Header summary
            Padding(
              padding: const EdgeInsets.all(16),
              child: _SummaryRow(scores: scores),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                itemCount: scores.length,
                itemBuilder: (_, i) => _QualityCard(
                    score: scores[i],
                    key: ValueKey(scores[i].driverId)),
              ),
            ),
          ]);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Recompute quality for all drivers
          final drivers = await fsService.allDriversStream().first;
          for (final d in drivers) {
            await fsService.computeQualityScore(d.uid);
          }
        },
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Recompute All'),
        backgroundColor: AppTheme.brand,
      ),
    );
  }

  void _computeAllScores(BuildContext ctx, List<QualityScore> scores) {
    for (final s in scores) {
      fsService.computeQualityScore(s.driverId);
    }
  }
}

// ── Summary row ───────────────────────────────────────────────────
class _SummaryRow extends StatelessWidget {
  final List<QualityScore> scores;
  const _SummaryRow({required this.scores});

  @override
  Widget build(BuildContext context) {
    if (scores.isEmpty) return const SizedBox.shrink();
    final avg = scores
            .map((s) => s.score)
            .fold(0.0, (a, b) => a + b) /
        scores.length;
    final excellent = scores.where((s) => s.score >= 80).length;
    final poor = scores.where((s) => s.score < 50).length;

    return Row(children: [
      Expanded(
          child: _mini('Average', avg.toStringAsFixed(1), AppTheme.brand)),
      Expanded(
          child: _mini('Excellent (≥80)',
              '$excellent', AppTheme.green)),
      Expanded(
          child: _mini('Poor (<50)', '$poor', Colors.red)),
    ]);
  }

  Widget _mini(String lbl, String val, Color c) => Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(val,
                style: TextStyle(
                    color: c,
                    fontSize: 20,
                    fontWeight: FontWeight.w900)),
            Text(lbl,
                style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 10)),
          ]),
        ),
      );
}

// ── Quality card ──────────────────────────────────────────────────
class _QualityCard extends StatelessWidget {
  final QualityScore score;
  const _QualityCard({required this.score, super.key});

  @override
  Widget build(BuildContext context) {
    final overall = score.score;
    final color = overall >= 80
        ? AppTheme.green
        : overall >= 60
            ? AppTheme.yellow
            : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Row(children: [
            // Circular score
            SizedBox(
              width: 56, height: 56,
              child: Stack(alignment: Alignment.center, children: [
                CircularProgressIndicator(
                  value: overall / 100,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation(color),
                  strokeWidth: 5,
                ),
                Text('${overall.toInt()}',
                    style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.w900)),
              ]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(score.driverName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(score.scoreLabel,
                    style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded,
                  color: AppTheme.brand, size: 18),
              onPressed: () =>
                  fsService.computeQualityScore(score.driverId),
              tooltip: 'Recompute',
            ),
          ]),
          const SizedBox(height: 12),
          // Component bars
          _componentBar('GPS Consistency (30%)', score.gpsConsistency / 100, AppTheme.brand),
          const SizedBox(height: 6),
          _componentBar('Active Hours (30%)', score.activeHoursRatio / 100, AppTheme.blue),
          const SizedBox(height: 6),
          _componentBar('Campaign Compliance (25%)', score.campaignCompliance / 100, AppTheme.green),
          const SizedBox(height: 6),
          _componentBar('Customer Rating (15%)', score.customerRating / 100, AppTheme.yellow),
          if (score.lastComputed != null) ...[
            const SizedBox(height: 8),
            Text('Last computed: ${_fmt(score.lastComputed!)}',
                style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 10)),
          ],
        ]),
      ),
    );
  }

  /// [value] is 0.0–1.0 (already divided by 100 before calling)
  Widget _componentBar(String lbl, double value, Color color) => Row(
        children: [
          SizedBox(
            width: 170,
            child: Text(lbl,
                style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 10)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value.clamp(0.0, 1.0),
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            (value * 100).toStringAsFixed(0),
            style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700),
          ),
        ],
      );

  String _fmt(DateTime dt) {
    const m = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${m[dt.month]}  ${dt.hour.toString().padLeft(2, "0")}:${dt.minute.toString().padLeft(2, "0")}';
  }
}
