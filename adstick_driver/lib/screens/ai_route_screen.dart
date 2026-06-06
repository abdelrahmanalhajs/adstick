import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AiRouteScreen extends StatefulWidget {
  const AiRouteScreen({super.key});
  @override
  State<AiRouteScreen> createState() => _AiRouteScreenState();
}

class _AiRouteScreenState extends State<AiRouteScreen> {
  bool _loading = false;
  bool _generated = false;

  void _generate() async {
    setState(() { _loading = true; _generated = false; });
    await Future.delayed(const Duration(seconds: 2));
    setState(() { _loading = false; _generated = true; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🤖 AI Route Optimizer')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Hero
          Container(
            width: double.infinity, padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1a0533), Color(0xFF2d1b69)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('AI-Powered Route', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 6),
              const Text('Maximize today\'s impressions', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              const Text('Our AI analyzes real-time traffic, campaign zones, and peak hours to build the most profitable route for you.', style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loading ? null : _generate,
                icon: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.auto_awesome_rounded, size: 18),
                label: Text(_loading ? 'Generating...' : 'Generate My Route'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.driverGreen, foregroundColor: Colors.white),
              ),
            ]),
          ),
          const SizedBox(height: 20),
          if (_generated) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.driverGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.driverGreen.withOpacity(0.3)),
              ),
              child: Row(children: const [
                Icon(Icons.check_circle_rounded, color: AppTheme.driverGreen),
                SizedBox(width: 10),
                Expanded(child: Text('Optimal route generated! Expected +34% more impressions today.', style: TextStyle(color: AppTheme.driverGreen, fontWeight: FontWeight.w600, fontSize: 13))),
              ]),
            ),
            const SizedBox(height: 20),
            const Text('Recommended Route', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 12),
            ...[
              ('07:30–09:00', 'King Fahd Road', 'High traffic · 8.4/10 density', const Color(0xFFEF4444)),
              ('09:00–11:00', 'Al-Olaya District', 'Business zone · 7.2/10', const Color(0xFFF59E0B)),
              ('11:00–13:00', 'Tahlia Street', 'Shopping peak · 7.8/10', const Color(0xFFF59E0B)),
              ('13:00–15:00', 'Al-Malaz', 'Residential · 5.1/10', AppTheme.driverGreen),
              ('15:00–18:00', 'King Fahd Road', 'Evening peak · 9.1/10', const Color(0xFFEF4444)),
            ].map((r) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: Container(width: 12, height: 12,
                    decoration: BoxDecoration(color: r.$4, shape: BoxShape.circle)),
                title: Text(r.$2, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                subtitle: Text(r.$3, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                trailing: Text(r.$1, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
              ),
            )),
            const SizedBox(height: 16),
          ],
          const Text('AI Insights', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 12),
          ...[
            (Icons.trending_up_rounded, 'Peak hours: 07:30–09:00 and 16:00–19:00', 'Drive these windows for max exposure'),
            (Icons.location_on_rounded, 'Hot zones: Al-Olaya, King Fahd Rd, Tahlia St', 'These 3 zones = 68% of all impressions'),
            (Icons.warning_amber_rounded, 'Avoid: Airport Rd 12:00–14:00', 'Low campaign density, high fuel cost'),
            (Icons.star_rounded, 'Your best day: Thursday 6:30 AM start', 'Historically +40% vs Mon–Wed'),
          ].map((i) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
              Icon(i.$1, color: AppTheme.driverGreen, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(i.$2, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                Text(i.$3, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
              ])),
            ])),
          )),
        ]),
      ),
    );
  }
}
