import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/overview_screen.dart';
import 'screens/campaigns_screen.dart';
import 'screens/live_map_screen.dart';
import 'screens/reports_screen.dart';
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
          builder: (context, state, child) => MainShell(child: child),
          routes: [
            GoRoute(path: '/overview',   builder: (_, __) => const OverviewScreen()),
            GoRoute(path: '/campaigns',  builder: (_, __) => const CampaignsScreen()),
            GoRoute(path: '/map',        builder: (_, __) => const LiveMapScreen()),
            GoRoute(path: '/reports',    builder: (_, __) => const ReportsScreen()),
            GoRoute(path: '/profile',    builder: (_, __) => const ProfileScreen()),
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

class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  final _tabs = const [
    (icon: Icons.home_rounded,       label: 'Overview',   path: '/overview'),
    (icon: Icons.campaign_rounded,   label: 'Campaigns',  path: '/campaigns'),
    (icon: Icons.map_rounded,        label: 'Live Map',   path: '/map'),
    (icon: Icons.analytics_rounded,  label: 'Reports',    path: '/reports'),
    (icon: Icons.person_rounded,     label: 'Profile',    path: '/profile'),
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
