import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/overview_screen.dart';
import 'screens/earnings_screen.dart';
import 'screens/route_screen.dart';
import 'screens/campaign_screen.dart';
import 'screens/ai_route_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/referral_screen.dart';
import 'screens/benefits_screen.dart';
import 'screens/profile_screen.dart';
import 'theme/app_theme.dart';

void main() => runApp(const AdStickDriverApp());

class AdStickDriverApp extends StatelessWidget {
  const AdStickDriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(path: '/splash',      builder: (_, __) => const SplashScreen()),
        GoRoute(path: '/login',       builder: (_, __) => const LoginScreen()),
        ShellRoute(
          builder: (ctx, state, child) => DriverShell(child: child, location: state.uri.path),
          routes: [
            GoRoute(path: '/overview',    builder: (_, __) => const OverviewScreen()),
            GoRoute(path: '/earnings',    builder: (_, __) => const EarningsScreen()),
            GoRoute(path: '/route',       builder: (_, __) => const RouteScreen()),
            GoRoute(path: '/campaign',    builder: (_, __) => const CampaignScreen()),
            GoRoute(path: '/ai-route',    builder: (_, __) => const AiRouteScreen()),
            GoRoute(path: '/leaderboard', builder: (_, __) => const LeaderboardScreen()),
            GoRoute(path: '/referrals',   builder: (_, __) => const ReferralScreen()),
            GoRoute(path: '/benefits',    builder: (_, __) => const BenefitsScreen()),
            GoRoute(path: '/profile',     builder: (_, __) => const ProfileScreen()),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      title: 'AdStick Driver',
      theme: AppTheme.driverTheme(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class DriverShell extends StatelessWidget {
  final Widget child;
  final String location;
  const DriverShell({super.key, required this.child, required this.location});

  // Bottom nav tabs (most-used screens)
  static const _bottomTabs = [
    (icon: Icons.home_rounded,                   label: 'Overview', path: '/overview'),
    (icon: Icons.account_balance_wallet_rounded,  label: 'Earnings', path: '/earnings'),
    (icon: Icons.map_rounded,                    label: 'Route',    path: '/route'),
    (icon: Icons.label_rounded,                  label: 'Campaign', path: '/campaign'),
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
      drawer: _DriverDrawer(currentPath: location),
    );
  }
}

class _DriverDrawer extends StatelessWidget {
  final String currentPath;
  const _DriverDrawer({required this.currentPath});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.dark2,
      child: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CircleAvatar(radius: 28, backgroundColor: AppTheme.driverGreen.withOpacity(0.2),
                child: const Icon(Icons.directions_car_rounded, color: AppTheme.driverGreen, size: 28)),
            const SizedBox(height: 10),
            const Text('Ahmed Khalid', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFF78350F), borderRadius: BorderRadius.circular(999)),
                child: const Text('🥇 Gold Driver', style: TextStyle(color: Color(0xFFFDE68A), fontSize: 11, fontWeight: FontWeight.w600))),
          ]),
        ),
        const Divider(color: AppTheme.border, height: 1),
        Expanded(child: ListView(padding: const EdgeInsets.symmetric(vertical: 8), children: [
          _sectionLabel('MAIN'),
          _tile(context, Icons.home_rounded, 'Overview', '/overview'),
          _tile(context, Icons.account_balance_wallet_rounded, 'Earnings', '/earnings'),
          _tile(context, Icons.map_rounded, 'My Route', '/route'),
          _tile(context, Icons.label_rounded, 'My Campaign', '/campaign'),
          _tile(context, Icons.auto_awesome_rounded, 'AI Route Optimizer', '/ai-route'),
          _sectionLabel('REWARDS & GROWTH'),
          _tile(context, Icons.leaderboard_rounded, 'Leaderboard', '/leaderboard'),
          _tile(context, Icons.handshake_rounded, 'Referrals', '/referrals'),
          _tile(context, Icons.card_giftcard_rounded, 'My Benefits', '/benefits'),
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
      leading: Icon(icon, color: selected ? AppTheme.driverGreen : AppTheme.textMuted, size: 20),
      title: Text(label, style: TextStyle(color: selected ? AppTheme.driverGreen : Colors.white, fontSize: 14, fontWeight: selected ? FontWeight.w700 : FontWeight.w400)),
      tileColor: selected ? AppTheme.driverGreen.withOpacity(0.08) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () { Navigator.pop(ctx); ctx.go(path); },
    );
  }
}
