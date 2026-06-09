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
import 'screens/register_screen.dart';
import 'screens/overview_screen.dart';
import 'screens/campaigns_screen.dart';
import 'screens/live_map_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/km_analytics_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/float_cluster.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    runApp(const AdStickAdvertiserApp());
  } catch (e, stack) {
    runApp(_ErrorApp(message: e.toString(), stack: stack.toString()));
  }
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

class AdStickAdvertiserApp extends StatelessWidget {
  const AdStickAdvertiserApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/splash',
      redirect: (ctx, state) {
        final user = FirebaseAuth.instance.currentUser;
        final loc  = state.matchedLocation;
        final pub  = loc == '/splash' || loc == '/login' || loc == '/register';
        if (user == null && !pub) return '/login';
        return null;
      },
      routes: [
        GoRoute(path: '/splash',       builder: (_, __) => const SplashScreen()),
        GoRoute(path: '/login',        builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/register',     builder: (_, __) => const RegisterScreen()),
        ShellRoute(
          builder: (ctx, state, child) =>
              AdvShell(child: child, location: state.uri.path),
          routes: [
            GoRoute(path: '/overview',     builder: (_, __) => const OverviewScreen()),
            GoRoute(path: '/campaigns',    builder: (_, __) => const CampaignsScreen()),
            GoRoute(path: '/map',          builder: (_, __) => const LiveMapScreen()),
            GoRoute(path: '/reports',      builder: (_, __) => const ReportsScreen()),
            GoRoute(path: '/km-analytics', builder: (_, __) => const KmAnalyticsScreen()),
            GoRoute(path: '/profile',      builder: (_, __) => const ProfileScreen()),
          ],
        ),
      ],
    );

    return ValueListenableBuilder<String>(
      valueListenable: localeNotifier,
      builder: (_, locale, __) => AppL10n(
        locale: locale,
        child: MaterialApp.router(
          title: 'AdStick Advertiser',
          theme: AppTheme.advertiserTheme(),
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

class AdvShell extends StatelessWidget {
  final Widget child;
  final String location;
  const AdvShell({super.key, required this.child, required this.location});

  static const _bottomPaths = ['/overview', '/campaigns', '/map', '/reports'];

  int _bottomIndex() {
    final i = _bottomPaths.indexOf(location);
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('app_name')),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [_LangToggle(accentColor: AppTheme.brand)],
      ),
      body: FloatCluster(accentColor: AppTheme.brand, child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _bottomIndex(),
        onDestinationSelected: (i) => context.go(_bottomPaths[i]),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_rounded),      label: l.t('overview')),
          NavigationDestination(icon: const Icon(Icons.campaign_rounded),   label: l.t('campaigns')),
          NavigationDestination(icon: const Icon(Icons.map_rounded),        label: l.t('live_map')),
          NavigationDestination(icon: const Icon(Icons.analytics_rounded),  label: l.t('reports')),
        ],
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
    final l = AppL10n.of(context);
    return Drawer(
      backgroundColor: AppTheme.dark2,
      child: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.brand.withValues(alpha: 0.2),
                  child: const Icon(Icons.business_rounded, color: AppTheme.brand, size: 28),
                ),
                const Spacer(),
                _LangToggle(accentColor: AppTheme.brand),
              ]),
              const SizedBox(height: 10),
              const Text('MyBrand Co.',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: AppTheme.brand.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999)),
                child: const Text('Growth Plan',
                    style: TextStyle(color: AppTheme.brand, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ]),
          ),
          const Divider(color: AppTheme.border, height: 1),
          Expanded(
            child: ListView(padding: const EdgeInsets.symmetric(vertical: 8), children: [
              _sec(l.t('sec_camps')),
              _t(context, Icons.home_rounded,       l.t('overview'),      '/overview'),
              _t(context, Icons.campaign_rounded,   l.t('campaigns'),     '/campaigns'),
              _t(context, Icons.map_rounded,        l.t('live_map'),      '/map'),
              _t(context, Icons.analytics_rounded,  l.t('reports'),       '/reports'),
              _t(context, Icons.route_rounded,      l.t('km_analytics'),  '/km-analytics'),
              _sec(l.t('sec_account')),
              _t(context, Icons.person_rounded,     l.t('profile'),       '/profile'),
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(label,
          style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8)));

  Widget _t(BuildContext ctx, IconData icon, String label, String path) {
    final sel = currentPath == path;
    return ListTile(
      leading: Icon(icon, color: sel ? AppTheme.brand : AppTheme.textMuted, size: 20),
      title: Text(label,
          style: TextStyle(
              color: sel ? AppTheme.brand : Colors.white,
              fontSize: 14,
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
            Text(locale == 'en' ? '🇺🇸' : '🇸🇦', style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(locale == 'en' ? 'EN' : 'AR',
                style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.w800)),
            const SizedBox(width: 3),
            Icon(Icons.swap_horiz_rounded, color: accentColor, size: 14),
          ]),
        ),
      )),
    );
  }
}
