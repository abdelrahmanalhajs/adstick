import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});
  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  @override void initState() { super.initState(); _tab = TabController(length: 3, vsync: this); }
  @override void dispose() { _tab.dispose(); super.dispose(); }

  static const _slots = [
    ('King Fahd Rd – Premium', '12 vehicles', 'SAR 8,500/mo', 'Available', AppTheme.green),
    ('Al-Olaya District', '8 vehicles', 'SAR 6,200/mo', 'Available', AppTheme.green),
    ('Tahlia Street', '6 vehicles', 'SAR 4,800/mo', '2 slots left', AppTheme.yellow),
    ('Riyadh Front', '10 vehicles', 'SAR 7,100/mo', 'Full', AppTheme.red),
    ('Airport Corridor', '15 vehicles', 'SAR 9,200/mo', 'Available', AppTheme.green),
  ];

  static const _advertisers = [
    ('MyBrand Co.', 'FMCG', 'SAR 12K/mo', 'Active', '3 campaigns'),
    ('TechLaunch SA', 'Technology', 'SAR 8.5K/mo', 'Active', '1 campaign'),
    ('Riyadh Homes', 'Real Estate', 'SAR 9K/mo', 'Active', '2 campaigns'),
    ('AutoDrive Arabia', 'Automotive', 'SAR 15K/mo', 'Pending', '1 campaign'),
    ('SavorKSA', 'F&B', 'SAR 6.2K/mo', 'Active', '2 campaigns'),
  ];

  static const _deals = [
    ('Q3 Bulk Package', 'SAR 45,000', '6 zones · 30 vehicles · 3 months', 'Open'),
    ('Eid Seasonal', 'SAR 18,000', 'City-wide · 2 weeks', 'Negotiating'),
    ('Formula E Sponsor', 'SAR 60,000', 'Al-Diriyah · exclusive', 'Open'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🛒 Marketplace'),
        bottom: TabBar(controller: _tab, tabs: const [
          Tab(text: 'Ad Slots'), Tab(text: 'Advertisers'), Tab(text: 'Deals'),
        ]),
      ),
      body: TabBarView(controller: _tab, children: [
        // Ad Slots
        ListView(padding: const EdgeInsets.all(16), children: [
          ..._slots.map((s) => Card(margin: const EdgeInsets.only(bottom: 10), child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Text(s.$1, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700))),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: s.$5.withOpacity(0.12), borderRadius: BorderRadius.circular(999)),
                  child: Text(s.$4, style: TextStyle(color: s.$5, fontSize: 11, fontWeight: FontWeight.w700))),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              Icon(Icons.directions_car_rounded, color: AppTheme.textMuted, size: 13),
              const SizedBox(width: 4),
              Text(s.$2, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              const Spacer(),
              Text(s.$3, style: const TextStyle(color: AppTheme.brand, fontSize: 14, fontWeight: FontWeight.w800)),
            ]),
            if (s.$4 != 'Full') ...[
              const SizedBox(height: 10),
              ElevatedButton(onPressed: () {}, child: const Text('Book Slot'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.brand, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 36), textStyle: const TextStyle(fontSize: 12))),
            ],
          ])))),
        ]),
        // Advertisers
        ListView(padding: const EdgeInsets.all(16), children: [
          ..._advertisers.map((a) {
            final isActive = a.$4 == 'Active';
            return Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
              leading: CircleAvatar(radius: 20, backgroundColor: AppTheme.brand.withOpacity(0.15),
                  child: Text(a.$1[0], style: const TextStyle(color: AppTheme.brand, fontWeight: FontWeight.w800))),
              title: Text(a.$1, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
              subtitle: Text('${a.$2} · ${a.$5}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
              trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(a.$3, style: const TextStyle(color: AppTheme.brand, fontSize: 12, fontWeight: FontWeight.w800)),
                Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(
                    color: (isActive ? AppTheme.green : AppTheme.yellow).withOpacity(0.12), borderRadius: BorderRadius.circular(999)),
                    child: Text(a.$4, style: TextStyle(color: isActive ? AppTheme.green : AppTheme.yellow, fontSize: 10, fontWeight: FontWeight.w700))),
              ]),
            ));
          }),
        ]),
        // Deals
        ListView(padding: const EdgeInsets.all(16), children: [
          ..._deals.map((d) => Card(margin: const EdgeInsets.only(bottom: 10), child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(d.$1, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
              Text(d.$3 == 'Open' ? '🟢' : '🟡', style: const TextStyle(fontSize: 14)),
            ]),
            const SizedBox(height: 4),
            Text(d.$3, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            const SizedBox(height: 10),
            Row(children: [
              Text(d.$2, style: const TextStyle(color: AppTheme.brand, fontSize: 18, fontWeight: FontWeight.w900)),
              const Spacer(),
              ElevatedButton(onPressed: () {}, child: const Text('View Deal'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.brand, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), textStyle: const TextStyle(fontSize: 12))),
            ]),
          ])))),
        ]),
      ]),
    );
  }
}
