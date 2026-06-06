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

void main() => runApp(const AdStickAdminApp());

class AdStickAdminApp extends StatelessWidget {
  const AdStickAdminApp({super.key});
  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(path: '/splash',    builder: (_, __) => const SplashScreen()),
        GoRoute(path: '/login',     builder: (_, __) => const LoginScreen()),
        ShellRoute(
          builder: (context, state, child) => MainShell(child: child),
          routes: [
            GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
            GoRoute(path: '/cars',      builder: (_, __) => const CarsScreen()),
            GoRoute(path: '/campaigns', builder: (_, __) => const CampaignsScreen()),
            GoRoute(path: '/drivers',   builder: (_, __) => const DriversScreen()),
            GoRoute(path: '/reports',   builder: (_, __) => const ReportsScreen()),
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

class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  final _tabs = const [
    (icon: Icons.dashboard_rounded,   label: 'Dashboard', path: '/dashboard'),
    (icon: Icons.directions_car_rounded, label: 'Cars',   path: '/cars'),
    (icon: Icons.campaign_rounded,    label: 'Campaigns', path: '/campaigns'),
    (icon: Icons.people_rounded,      label: 'Drivers',   path: '/drivers'),
    (icon: Icons.analytics_rounded,   label: 'Reports',   path: '/reports'),
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    body: widget.child,
    bottomNavigationBar: NavigationBar(
      selectedIndex: _index,
      onDestinationSelected: (i) { setState(() => _index = i); context.go(_tabs[i].path); },
      destinations: _tabs.map((t) => NavigationDestination(icon: Icon(t.icon), label: t.label)).toList(),
    ),
  );
}
