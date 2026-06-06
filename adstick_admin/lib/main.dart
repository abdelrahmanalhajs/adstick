import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/cars_screen.dart';
import 'screens/campaigns_screen.dart';
import 'screens/drivers_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/live_map_screen.dart';
import 'screens/traffic_screen.dart';
import 'screens/roi_screen.dart';
import 'screens/events_screen.dart';
import 'screens/predictions_screen.dart';
import 'screens/fleet_screen.dart';
import 'screens/marketplace_screen.dart';
import 'screens/cities_screen.dart';
import 'screens/quality_screen.dart';
import 'screens/audit_screen.dart';
import 'screens/carbon_screen.dart';

void main() => runApp(const AdStickAdminApp());

class AdStickAdminApp extends StatelessWidget {
  const AdStickAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(path: '/splash',      builder: (_, __) => const SplashScreen()),
        GoRoute(path: '/login',       builder: (_, __) => const LoginScreen()),
        ShellRoute(
          builder: (ctx, state, child) => AdminShell(child: child, location: state.uri.path),
          routes: [
            GoRoute(path: '/dashboard',   builder: (_, __) => const DashboardScreen()),
            GoRoute(path: '/live-map',    builder: (_, __) => const LiveMapScreen()),
            GoRoute(path: '/cars',        builder: (_, __) => const CarsScreen()),
            GoRoute(path: '/fleet',       builder: (_, __) => const FleetScreen()),
            GoRoute(path: '/campaigns',   builder: (_, __) => const CampaignsScreen()),
            GoRoute(path: '/drivers',     builder: (_, __) => const DriversScreen()),
            GoRoute(path: '/reports',     builder: (_, __) => const ReportsScreen()),
            GoRoute(path: '/roi',         builder: (_, __) => const RoiScreen()),
            GoRoute(path: '/traffic',     builder: (_, __) => const TrafficScreen()),
            GoRoute(path: '/events',      builder: (_, __) => const EventsScreen()),
            GoRoute(path: '/predictions', builder: (_, __) => const PredictionsScreen()),
            GoRoute(path: '/marketplace', builder: (_, __) => const MarketplaceScreen()),
            GoRoute(path: '/cities',      builder: (_, __) => const CitiesScreen()),
            GoRoute(path: '/quality',     builder: (_, __) => const QualityScreen()),
            GoRoute(path: '/audit',       builder: (_, __) => const AuditScreen()),
            GoRoute(path: '/carbon',      builder: (_, __) => const CarbonScreen()),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      title: 'AdStick Admin',
      theme: AppTheme.adminTheme(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class AdminShell extends StatelessWidget {
  final Widget child;
  final String location;
  const AdminShell({super.key, required this.child, required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AdStick Admin'),
        leading: Builder(builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        )),
      ),
      body: child,
      drawer: _AdminDrawer(currentPath: location),
    );
  }
}

class _AdminDrawer extends StatelessWidget {
  final String currentPath;
  const _AdminDrawer({required this.currentPath});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.dark2,
      child: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppTheme.brand, Color(0xFFFF8A50)]),
              borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 26)),
          const SizedBox(height: 10),
          const Text('Admin Portal', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
          const Text('Super Administrator', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
        ])),
        const Divider(color: AppTheme.border, height: 1),
        Expanded(child: ListView(padding: const EdgeInsets.symmetric(vertical: 8), children: [
          _sec('OVERVIEW'),
          _t(context, Icons.dashboard_rounded, 'Dashboard', '/dashboard'),
          _t(context, Icons.map_rounded, 'Live Map', '/live-map'),
          _t(context, Icons.analytics_rounded, 'Reports', '/reports'),
          _t(context, Icons.auto_awesome_rounded, 'Predictions', '/predictions'),

          _sec('FLEET & DRIVERS'),
          _t(context, Icons.directions_car_rounded, 'Cars', '/cars'),
          _t(context, Icons.build_rounded, 'Fleet Management', '/fleet'),
          _t(context, Icons.people_rounded, 'Drivers', '/drivers'),
          _t(context, Icons.traffic_rounded, 'Traffic Intel', '/traffic'),

          _sec('CAMPAIGNS & REVENUE'),
          _t(context, Icons.campaign_rounded, 'Campaigns', '/campaigns'),
          _t(context, Icons.trending_up_rounded, 'ROI Analytics', '/roi'),
          _t(context, Icons.storefront_rounded, 'Marketplace', '/marketplace'),

          _sec('PLATFORM'),
          _t(context, Icons.event_rounded, 'Events', '/events'),
          _t(context, Icons.location_city_rounded, 'Cities', '/cities'),
          _t(context, Icons.verified_rounded, 'Quality Control', '/quality'),

          _sec('GOVERNANCE'),
          _t(context, Icons.description_rounded, 'Audit Log', '/audit'),
          _t(context, Icons.eco_rounded, 'Carbon & ESG', '/carbon'),
        ])),
        const Divider(color: AppTheme.border, height: 1),
        ListTile(
          leading: const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
          title: const Text('Sign Out', style: TextStyle(color: Colors.red, fontSize: 14)),
          onTap: () => context.go('/login'),
        ),
      ])),
    );
  }

  Widget _sec(String label) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
    child: Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
  );

  Widget _t(BuildContext ctx, IconData icon, String label, String path) {
    final sel = currentPath == path;
    return ListTile(
      dense: true,
      leading: Icon(icon, color: sel ? AppTheme.brand : AppTheme.textMuted, size: 19),
      title: Text(label, style: TextStyle(color: sel ? AppTheme.brand : Colors.white, fontSize: 13, fontWeight: sel ? FontWeight.w700 : FontWeight.w400)),
      tileColor: sel ? AppTheme.brand.withOpacity(0.08) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () { Navigator.pop(ctx); ctx.go(path); },
    );
  }
}
