import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.go('/overview');
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.dark,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 96, height: 96,
              decoration: BoxDecoration(
                color: AppTheme.driverGreen.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.driverGreen, width: 2),
              ),
              child: const Icon(Icons.directions_car_rounded,
                  color: AppTheme.driverGreen, size: 48),
            ),
            const SizedBox(height: 24),
            RichText(text: const TextSpan(children: [
              TextSpan(text: 'Ad', style: TextStyle(
                  fontSize: 34, fontWeight: FontWeight.w900,
                  color: AppTheme.driverGreen)),
              TextSpan(text: 'Stick', style: TextStyle(
                  fontSize: 34, fontWeight: FontWeight.w900,
                  color: Colors.white)),
            ])),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.driverGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text('Driver',
                  style: TextStyle(color: AppTheme.driverGreen,
                      fontSize: 13, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 40),
            SizedBox(width: 32, height: 32,
              child: CircularProgressIndicator(
                  color: AppTheme.driverGreen, strokeWidth: 2.5)),
          ]),
        ),
      ),
    );
  }
}
