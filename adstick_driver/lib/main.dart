import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/overview_screen.dart';
import 'screens/earnings_screen.dart';
import 'screens/route_screen.dart';
import 'screens/campaign_screen.dart';
import 'screens/leaderboard_screen.dart';
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
        GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
        GoRoute(path: '/login',  builder: (_, __) => const LoginScreen()),
        ShellRoute(
          builder: (context, state, child) => MainShell(child: child),
          routes: [
            GoRoute(path: '/overview',    builder: (_, __) => const OverviewScreen()),
            GoRoute(path: '/earnings',    builder: (_, __) => const EarningsScreen()),
            GoRoute(path: '/route',       builder: (_, __) => const RouteScreen()),
            GoRoute(path: '/campaign',    builder: (_, __) => const CampaignScreen()),
            GoRoute(path: '/leaderboard', builder: (_, __) => const LeaderboardScreen()),
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

class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _tabs = const [
    (icon: Icons.home_rounded,                   label: 'Overview',    path: '/overview'),
    (icon: Icons.account_balance_wallet_rounded, label: 'Earnings',    path: '/earnings'),
    (icon: Icons.map_rounded,                    label: 'Route',       path: '/route'),
    (icon: Icons.label_rounded,                  label: 'Campaign',    path: '/campaign'),
    (icon: Icons.leaderboard_rounded,            label: 'Ranks',       path: '/leaderboard'),
    (icon: Icons.person_rounded,                 label: 'Profile',     path: '/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          setState(() => _index = i);
          context.go(_tabs[i].path);
        },
        destinations: _tabs.map((t) => NavigationDestination(
          icon: Icon(t.icon), label: t.label,
        )).toList(),
      ),
    );
  }
}
