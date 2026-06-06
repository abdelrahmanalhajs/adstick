import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/section_header.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});
  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  @override
  void initState() { super.initState(); _tabs = TabController(length: 3, vsync: this); }
  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('💰 Earnings'),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppTheme.driverGreen,
          labelColor: AppTheme.driverGreen,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: const [Tab(text: 'Today'), Tab(text: 'This Week'), Tab(text: 'This Month')],
        ),
      ),
      body: TabBarView(controller: _tabs, children: [
        _EarningsView(total: 'SAR 87.40', km: 87.4, rate: 1.00, trips: 12),
        _EarningsView(total: 'SAR 418.50', km: 418.5, rate: 1.00, trips: 58),
        _EarningsView(total: 'SAR 1,724.00', km: 1724.0, rate: 1.00, trips: 241),
      ]),
    );
  }
}

class _EarningsView extends StatelessWidget {
  final String total; final double km, rate; final int trips;
  const _EarningsView({required this.total, required this.km, required this.rate, required this.trips});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: double.infinity, padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF064E3B), Color(0xFF065F46)]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: [
            const Text('Total Earned', style: TextStyle(color: Colors.white60, fontSize: 13)),
            const SizedBox(height: 8),
            Text(total, style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _mini('${km.toStringAsFixed(1)} km', 'Distance'),
              _mini('SAR $rate /km', 'Rate'),
              _mini('$trips trips', 'Trips'),
            ]),
          ]),
        ),
        const SizedBox(height: 20),
        const SectionHeader(title: 'Breakdown'),
        const SizedBox(height: 12),
        _row('Base earnings', 'SAR ${(km * 0.85).toStringAsFixed(2)}'),
        _row('Bonus (peak hours)', 'SAR ${(km * 0.10).toStringAsFixed(2)}', color: AppTheme.driverGreen),
        _row('Campaign bonus', 'SAR ${(km * 0.05).toStringAsFixed(2)}', color: AppTheme.driverGreen),
        const Divider(color: AppTheme.border, height: 24),
        _row('Total', total, bold: true),
        const SizedBox(height: 20),
        const SectionHeader(title: 'Payment Status'),
        const SizedBox(height: 12),
        Card(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            _payRow('Last payout', 'SAR 1,240.00', 'May 25', true),
            const Divider(color: AppTheme.border, height: 20),
            _payRow('Next payout', 'SAR 418.50', 'Jun 1', false),
          ]),
        )),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity,
          child: ElevatedButton.icon(icon: const Icon(Icons.account_balance_rounded), label: const Text('Request Early Payout'), onPressed: () {})),
      ]),
    );
  }

  Widget _mini(String val, String lbl) => Column(children: [
    Text(val, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
    Text(lbl, style: const TextStyle(color: Colors.white60, fontSize: 11)),
  ]);

  Widget _row(String l, String v, {Color? color, bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(l, style: TextStyle(color: bold ? Colors.white : AppTheme.textMuted, fontSize: 14, fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
      Text(v, style: TextStyle(color: color ?? (bold ? Colors.white : AppTheme.textMuted), fontSize: 14, fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
    ]),
  );

  Widget _payRow(String lbl, String amt, String date, bool done) => Row(children: [
    Icon(done ? Icons.check_circle_rounded : Icons.schedule_rounded, color: done ? AppTheme.driverGreen : AppTheme.textMuted, size: 20),
    const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(lbl, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
      Text(date, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
    ])),
    Text(amt, style: TextStyle(color: done ? AppTheme.driverGreen : Colors.white, fontWeight: FontWeight.w800)),
  ]);
}
