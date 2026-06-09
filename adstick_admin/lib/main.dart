import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'l10n/app_l10n.dart';
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
import 'widgets/float_cluster.dart';

bool _appStarted = false;

void _launchError(Object e, StackTrace s) {
  if (_appStarted) return;
  _appStarted = true;
  runApp(_ErrorApp(message: e.toString(), stack: s.toString()));
}

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      _appStarted = true;
      runApp(const AdStickAdminApp());
    } catch (e, s) {
      _launchError(e, s);
    }
  }, _launchError);
}

class _ErrorApp extends StatelessWidget {
  final String message;
  final String stack;
  const _ErrorApp({required this.message, required this.stack});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const Text('🔥 Firebase Init Error',
                  style: TextStyle(color: Color(0xFFFF6B6B), fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0D1A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.4)),
                ),
                child: SelectableText(
                  message,
                  style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 13, fontFamily: 'monospace'),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Stack trace:', style: TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D0D1A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      stack,
                      style: const TextStyle(color: Colors.white38, fontSize: 11, fontFamily: 'monospace'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdStickAdminApp extends StatelessWidget {
  const AdStickAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/splash',
      redirect: (ctx, state) {
        final user = FirebaseAuth.instance.currentUser;
        final loc  = state.matchedLocation;
        final pub  = loc == '/splash' || loc == '/login';
        if (user == null && !pub) return '/login';
        return null;
      },
      routes: [
        GoRoute(path: '/splash',      builder: (_, __) => const SplashScreen()),
        GoRoute(path: '/login',       builder: (_, __) => const LoginScreen()),
        ShellRoute(
          builder: (ctx, state, child) =>
              AdminShell(child: child, location: state.uri.path),
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

    return ValueListenableBuilder<String>(
      valueListenable: localeNotifier,
      builder: (_, locale, __) => AppL10n(
        locale: locale,
        child: MaterialApp.router(
          title: 'AdStick Admin',
          theme: AppTheme.adminTheme(),
          routerConfig: router,
          debugShowCheckedModeBanner: false,
          locale: Locale(locale),
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ),
    );
  }
}

class AdminShell extends StatelessWidget {
  final Widget child;
  final String location;
  const AdminShell({super.key, required this.child, required this.location});

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('admin_title')),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [_LangToggle(accentColor: AppTheme.brand)],
      ),
      body: FloatCluster(accentColor: AppTheme.brand, child: child),
      drawer: _AdminDrawer(currentPath: location),
    );
  }
}

class _AdminDrawer extends StatelessWidget {
  final String currentPath;
  const _AdminDrawer({required this.currentPath});

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return Drawer(
      backgroundColor: AppTheme.dark2,
      child: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [AppTheme.brand, Color(0xFFFF8A50)]),
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.admin_panel_settings_rounded,
                    color: Colors.white, size: 26),
              ),
              const SizedBox(height: 10),
              const Text('Admin Portal',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
              const Text('Super Administrator',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            ]),
          ),
          const Divider(color: AppTheme.border, height: 1),
          Expanded(
            child: ListView(padding: const EdgeInsets.symmetric(vertical: 8), children: [
              _sec(l.t('sec_overview')),
              _t(context, Icons.dashboard_rounded,        l.t('dashboard'),   '/dashboard'),
              _t(context, Icons.map_rounded,              l.t('live_map'),    '/live-map'),
              _t(context, Icons.analytics_rounded,        l.t('reports'),     '/reports'),
              _t(context, Icons.auto_awesome_rounded,     l.t('predictions'), '/predictions'),
              _sec(l.t('sec_fleet')),
              _t(context, Icons.directions_car_rounded,   l.t('cars'),        '/cars'),
              _t(context, Icons.build_rounded,            l.t('fleet'),       '/fleet'),
              _t(context, Icons.people_rounded,           l.t('drivers'),     '/drivers'),
              _t(context, Icons.traffic_rounded,          l.t('traffic'),     '/traffic'),
              _sec(l.t('sec_revenue')),
              _t(context, Icons.campaign_rounded,         l.t('campaigns'),   '/campaigns'),
              _t(context, Icons.trending_up_rounded,      l.t('roi'),         '/roi'),
              _t(context, Icons.storefront_rounded,       l.t('marketplace'), '/marketplace'),
              _sec(l.t('sec_platform')),
              _t(context, Icons.event_rounded,            l.t('events'),      '/events'),
              _t(context, Icons.location_city_rounded,    l.t('cities'),      '/cities'),
              _t(context, Icons.verified_rounded,         l.t('quality'),     '/quality'),
              _sec(l.t('sec_govern')),
              _t(context, Icons.description_rounded,      l.t('audit'),       '/audit'),
              _t(context, Icons.eco_rounded,              l.t('carbon'),      '/carbon'),
            ]),
          ),
          const Divider(color: AppTheme.border, height: 1),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
            title: Text(l.t('sign_out'),
                style: const TextStyle(color: Colors.red, fontSize: 14)),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ]),
      ),
    );
  }

  Widget _sec(String label) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Text(label,
          style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8)));

  Widget _t(BuildContext ctx, IconData icon, String label, String path) {
    final sel = currentPath == path;
    return ListTile(
      dense: true,
      leading: Icon(icon, color: sel ? AppTheme.brand : AppTheme.textMuted, size: 19),
      title: Text(label,
          style: TextStyle(
              color: sel ? AppTheme.brand : Colors.white,
              fontSize: 13,
              fontWeight: sel ? FontWeight.w700 : FontWeight.w400)),
      tileColor: sel ? AppTheme.brand.withValues(alpha: 0.08) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () { Navigator.pop(ctx); ctx.go(path); },
    );
  }
}

class _LangToggle extends StatelessWidget {
  final Color accentColor;
  const _LangToggle({required this.accentColor});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: localeNotifier,
      builder: (_, locale, __) => Padding(
        padding: locale == 'en'
            ? const EdgeInsets.only(right: 20, left: 4)
            : const EdgeInsets.only(left: 20, right: 4),
        child: GestureDetector(
          onTap: () => localeNotifier.value = locale == 'en' ? 'ar' : 'en',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              border: Border.all(color: accentColor.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(locale == 'en' ? '🇺🇸' : '🇸🇦', style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 4),
              Text(locale == 'en' ? 'EN' : 'AR',
                  style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.w800)),
            ]),
          ),
        ),
      ),
    );
  }
}
