import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController(text: 'ahmed@adstick.sa');
  final _pass  = TextEditingController(text: '••••••••');
  bool _loading = false;

  void _login() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) context.go('/overview');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.dark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 40),
            RichText(text: const TextSpan(children: [
              TextSpan(text: 'Ad', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: AppTheme.driverGreen)),
              TextSpan(text: 'Stick', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Colors.white)),
            ])),
            const SizedBox(height: 4),
            const Text('Driver Portal', style: TextStyle(color: AppTheme.textMuted, fontSize: 15)),
            const SizedBox(height: 48),
            const Text('Welcome back 👋', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 6),
            const Text('Sign in to your driver account', style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
            const SizedBox(height: 36),
            _field('Email', _email, Icons.email_rounded),
            const SizedBox(height: 16),
            _field('Password', _pass, Icons.lock_rounded, obscure: true),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Sign In'),
              ),
            ),
            const SizedBox(height: 20),
            Center(child: TextButton(
              onPressed: () {},
              child: const Text('Forgot password?', style: TextStyle(color: AppTheme.driverGreen)),
            )),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(children: [
                const Icon(Icons.shield_rounded, color: AppTheme.driverGreen, size: 20),
                const SizedBox(width: 10),
                const Expanded(child: Text('Your data is encrypted and secure.\nAdStick never shares your information.',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12, height: 1.5))),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, IconData icon, {bool obscure = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      TextField(
        controller: ctrl,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppTheme.textMuted, size: 20),
          filled: true, fillColor: AppTheme.card,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.driverGreen, width: 2)),
        ),
      ),
    ]);
  }
}
