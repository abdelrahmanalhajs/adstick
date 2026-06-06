import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 2200), () { if (mounted) context.go('/login'); });
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.dark,
    body: Center(child: FadeTransition(opacity: _fade, child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 96, height: 96,
        decoration: BoxDecoration(color: AppTheme.brand.withOpacity(0.15), shape: BoxShape.circle,
            border: Border.all(color: AppTheme.brand, width: 2)),
        child: const Icon(Icons.campaign_rounded, color: AppTheme.brand, size: 48)),
      const SizedBox(height: 24),
      RichText(text: const TextSpan(children: [
        TextSpan(text: 'Ad', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: AppTheme.brand)),
        TextSpan(text: 'Stick', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white)),
      ])),
      const SizedBox(height: 8),
      Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(color: AppTheme.brand.withOpacity(0.15), borderRadius: BorderRadius.circular(999)),
          child: const Text('Advertiser', style: TextStyle(color: AppTheme.brand, fontSize: 13, fontWeight: FontWeight.w700))),
      const SizedBox(height: 40),
      SizedBox(width: 32, height: 32, child: CircularProgressIndicator(color: AppTheme.brand, strokeWidth: 2.5)),
    ]))),
  );
}
