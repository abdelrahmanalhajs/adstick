import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'l10n/app_l10n.dart';
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
import 'widgets/float_cluster.dart';

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
          builder: (ctx, state, child) =>
              DriverShell(child: child, location: state.uri.path),
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

    return ValueListenableBuilder<String>(
      valueListenable: localeNotifier,
      builder: (_, locale, __) => AppL10n(
        locale: locale,
        child: MaterialApp.router(
          title: 'AdStick Driver',
          theme: AppTheme.driverTheme(),
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

// ── Shell ─────────────────────────────────────────────────────
class DriverShell extends StatelessWidget {
  final Widget child;
  final String location;
  const DriverShell({super.key, required this.child, required this.location});

  static const _bottomPaths = ['/overview', '/earnings', '/route', '/campaign'];

  int _bottomIndex() {
    final i = _bottomPaths.indexOf(location);
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return Scaffold(
      body: FloatCluster(accentColor: AppTheme.driverGreen, child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _bottomIndex(),
        onDestinationSelected: (i) => context.go(_bottomPaths[i]),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_rounded),                   label: l.t('overview')),
          NavigationDestination(icon: const Icon(Icons.account_balance_wallet_rounded),  label: l.t('earnings')),
          NavigationDestination(icon: const Icon(Icons.map_rounded),                    label: l.t('route')),
          NavigationDestination(icon: const Icon(Icons.label_rounded),                  label: l.t('campaign')),
        ],
      ),
      drawer: _DriverDrawer(currentPath: location),
    );
  }
}

// ── Drawer ────────────────────────────────────────────────────
class _DriverDrawer extends StatelessWidget {
  final String currentPath;
  const _DriverDrawer({required this.currentPath});

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return Drawer(
      backgroundColor: AppTheme.dark2,
      child: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header + lang toggle
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.driverGreen.withValues(alpha: 0.2),
                  child: const Icon(Icons.directions_car_rounded,
                      color: AppTheme.driverGreen, size: 28),
                ),
                const Spacer(),
                _LangToggle(accentColor: AppTheme.driverGreen),
              ]),
              const SizedBox(height: 10),
              const Text('Ahmed Khalid',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: const Color(0xFF78350F),
                    borderRadius: BorderRadius.circular(999)),
                child: Text(l.t('gold_driver'),
                    style: const TextStyle(
                        color: Color(0xFFFDE68A),
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ]),
          ),
          const Divider(color: AppTheme.border, height: 1),
          Expanded(
            child: ListView(padding: const EdgeInsets.symmetric(vertical: 8), children: [
              _sec(l.t('sec_main')),
              _t(context, Icons.home_rounded,                   l.t('overview'),   '/overview'),
              _t(context, Icons.account_balance_wallet_rounded, l.t('earnings'),   '/earnings'),
              _t(context, Icons.map_rounded,                    l.t('my_route'),   '/route'),
              _t(context, Icons.label_rounded,                  l.t('my_campaign'),'/campaign'),
              _t(context, Icons.auto_awesome_rounded,           l.t('ai_route'),   '/ai-route'),
              _sec(l.t('sec_rewards')),
              _t(context, Icons.leaderboard_rounded,            l.t('leaderboard'),'/leaderboard'),
              _t(context, Icons.handshake_rounded,              l.t('referrals'),  '/referrals'),
              _t(context, Icons.card_giftcard_rounded,          l.t('benefits'),   '/benefits'),
              _sec(l.t('sec_account')),
              _t(context, Icons.person_rounded,                 l.t('profile'),    '/profile'),
            ]),
          ),
          const Divider(color: AppTheme.border, height: 1),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
            title: Text(l.t('sign_out'),
                style: const TextStyle(color: Colors.red, fontSize: 14)),
            onTap: () => context.go('/login'),
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
      leading:
          Icon(icon, color: sel ? AppTheme.driverGreen : AppTheme.textMuted, size: 20),
      title: Text(label,
          style: TextStyle(
              color: sel ? AppTheme.driverGreen : Colors.white,
              fontSize: 14,
              fontWeight: sel ? FontWeight.w700 : FontWeight.w400)),
      tileColor: sel ? AppTheme.driverGreen.withValues(alpha: 0.08) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () {
        Navigator.pop(ctx);
        ctx.go(path);
      },
    );
  }
}

// ── Language toggle chip ──────────────────────────────────────
class _LangToggle extends StatelessWidget {
  final Color accentColor;
  const _LangToggle({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: localeNotifier,
      builder: (_, locale, __) {
        return GestureDetector(
          onTap: () => localeNotifier.value = locale == 'en' ? 'ar' : 'en',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              border: Border.all(color: accentColor.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(locale == 'en' ? '🇺🇸' : '🇸🇦',
                  style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(locale == 'en' ? 'EN' : 'AR',
                  style: TextStyle(
                      color: accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w800)),
              const SizedBox(width: 3),
              Icon(Icons.swap_horiz_rounded, color: accentColor, size: 14),
            ]),
          ),
        );
      },
    );
  }
}
