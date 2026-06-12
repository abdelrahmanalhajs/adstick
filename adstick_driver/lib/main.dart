import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'l10n/app_l10n.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/overview_screen.dart';
import 'screens/earnings_screen.dart';
import 'screens/route_screen.dart';
import 'screens/campaign_screen.dart';
import 'screens/ai_route_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/referral_screen.dart';
import 'screens/benefits_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/wallet_screen.dart';
import 'screens/notifications_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/float_cluster.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'models/models.dart';

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
      runApp(const AdStickDriverApp());
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

class AdStickDriverApp extends StatelessWidget {
  const AdStickDriverApp({super.key});

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
        GoRoute(path: '/splash',      builder: (_, __) => const SplashScreen()),
        GoRoute(path: '/login',       builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/register',    builder: (_, __) => const RegisterScreen()),
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
            GoRoute(path: '/profile',        builder: (_, __) => const ProfileScreen()),
            GoRoute(path: '/wallet',         builder: (_, __) => const WalletScreen()),
            GoRoute(path: '/notifications',  builder: (_, __) => const NotificationsScreen()),
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
      appBar: AppBar(
        title: Text(l.t('app_name')),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [_LangToggle(accentColor: AppTheme.driverGreen)],
      ),
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
    final l   = AppL10n.of(context);
    final uid = authService.currentUser?.uid;

    return Drawer(
      backgroundColor: AppTheme.dark2,
      child: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header + lang toggle
          Padding(
            padding: const EdgeInsets.all(20),
            child: uid == null
                ? const SizedBox.shrink()
                : StreamBuilder<DriverProfile>(
                    stream: fsService.driverProfileStream(uid),
                    builder: (_, snap) {
                      final profile = snap.data;
                      final name    = profile?.name ?? '...';
                      final tier    = profile?.tier ?? 'bronze';
                      return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Row(children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor:
                                AppTheme.driverGreen.withValues(alpha: 0.2),
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                  color: AppTheme.driverGreen,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900),
                            ),
                          ),
                          const Spacer(),
                          _LangToggle(accentColor: AppTheme.driverGreen),
                        ]),
                        const SizedBox(height: 10),
                        Text(name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        _TierChip(tier: tier),
                      ]);
                    },
                  ),
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
              _t(context, Icons.notifications_rounded,          l.t('notifications'), '/notifications'),
              _t(context, Icons.account_balance_wallet_rounded, l.t('wallet'),        '/wallet'),
              _t(context, Icons.person_rounded,                 l.t('profile'),       '/profile'),
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

// ── Tier chip ─────────────────────────────────────────────────
class _TierChip extends StatelessWidget {
  final String tier;
  const _TierChip({required this.tier});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    String label;
    switch (tier) {
      case 'elite':
        bg = const Color(0xFF4C1D95); fg = const Color(0xFFA78BFA);
        label = '👑 Elite Driver'; break;
      case 'gold':
        bg = const Color(0xFF78350F); fg = const Color(0xFFFDE68A);
        label = '🥇 Gold Driver'; break;
      case 'silver':
        bg = const Color(0xFF1F2937); fg = const Color(0xFF94A3B8);
        label = '🥈 Silver Driver'; break;
      default:
        bg = const Color(0xFF1C1007); fg = const Color(0xFFCD7F32);
        label = '🥉 Bronze Driver';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(label,
          style: TextStyle(
              color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
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
        return Padding(
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
        ));
      },
    );
  }
}
