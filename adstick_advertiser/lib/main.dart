import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/overview_screen.dart';
import 'screens/campaigns_screen.dart';
import 'screens/live_map_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/km_analytics_screen.dart';
import 'screens/profile_screen.dart';

void main() => runApp(const AdStickAdvertiserApp());

class AdStickAdvertiserApp extends StatelessWidget {
  const AdStickAdvertiserApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(path: '/splash',    builder: (_, __) => const SplashScreen()),
        GoRoute(path: '/login',     builder: (_, __) => const LoginScreen()),
        ShellRoute(
          builder: (context, state, child) => AdvShell(child: child, location: state.uri.path),
          routes: [
            GoRoute(path: '/overview',    builder: (_, __) => const OverviewScreen()),
            GoRoute(path: '/campaigns',   builder: (_, __) => const CampaignsScreen()),
            GoRoute(path: '/map',         builder: (_, __) => const LiveMapScreen()),
            GoRoute(path: '/reports',     builder: (_, __) => const ReportsScreen()),
            GoRoute(path: '/km-analytics',builder: (_, __) => const KmAnalyticsScreen()),
            GoRoute(path: '/profile',     builder: (_, __) => const ProfileScreen()),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      title: 'AdStick Advertiser',
      theme: AppTheme.advertiserTheme(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class AdvShell extends StatelessWidget {
  final Widget child;
  final String location;
  const AdvShell({super.key, required this.child, required this.location});

  static const _bottomTabs = [
    (icon: Icons.home_rounded,       label: 'Overview',   path: '/overview'),
    (icon: Icons.campaign_rounded,   label: 'Campaigns',  path: '/campaigns'),
    (icon: Icons.map_rounded,        label: 'Live Map',   path: '/map'),
    (icon: Icons.analytics_rounded,  label: 'Reports',    path: '/reports'),
  ];

  int _bottomIndex() {
    for (var i = 0; i < _bottomTabs.length; i++) {
      if (location == _bottomTabs[i].path) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _bottomIndex(),
        onDestinationSelected: (i) => context.go(_bottomTabs[i].path),
        destinations: _bottomTabs.map((t) => NavigationDestination(
            icon: Icon(t.icon), label: t.label)).toList(),
      ),
      drawer: _AdvDrawer(currentPath: location),
    );
  }
}

class _AdvDrawer extends StatelessWidget {
  final String currentPath;
  const _AdvDrawer({required this.currentPath});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.dark2,
      child: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CircleAvatar(radius: 28, backgroundColor: AppTheme.brand.withOpacity(0.2),
                child: const Icon(Icons.business_rounded, color: AppTheme.brand, size: 28)),
            const SizedBox(height: 10),
            const Text('MyBrand Co.', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppTheme.brand.withOpacity(0.15), borderRadius: BorderRadius.circular(999)),
                child: const Text('Growth Plan', style: TextStyle(color: AppTheme.brand, fontSize: 11, fontWeight: FontWeight.w600))),
          ]),
        ),
        const Divider(color: AppTheme.border, height: 1),
        Expanded(child: ListView(padding: const EdgeInsets.symmetric(vertical: 8), children: [
          _sectionLabel('CAMPAIGNS & ANALYTICS'),
          _tile(context, Icons.home_rounded, 'Overview', '/overview'),
          _tile(context, Icons.campaign_rounded, 'My Campaigns', '/campaigns'),
          _tile(context, Icons.map_rounded, 'Live Map', '/map'),
          _tile(context, Icons.analytics_rounded, 'Reports', '/reports'),
          _tile(context, Icons.route_rounded, 'KM Analytics', '/km-analytics'),
          _sectionLabel('ACCOUNT'),
          _tile(context, Icons.person_rounded, 'Profile', '/profile'),
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

  Widget _sectionLabel(String label) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
    child: Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
  );

  Widget _tile(BuildContext ctx, IconData icon, String label, String path) {
    final selected = currentPath == path;
    return ListTile(
      leading: Icon(icon, color: selected ? AppTheme.brand : AppTheme.textMuted, size: 20),
      title: Text(label, style: TextStyle(color: selected ? AppTheme.brand : Colors.white, fontSize: 14, fontWeight: selected ? FontWeight.w700 : FontWeight.w400)),
      tileColor: selected ? AppTheme.brand.withOpacity(0.08) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () { Navigator.pop(ctx); ctx.go(path); },
    );
  }
}
