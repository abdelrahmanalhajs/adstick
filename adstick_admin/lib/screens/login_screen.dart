import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _State();
}
class _State extends State<LoginScreen> {
  final _email = TextEditingController(text: 'admin@adstick.sa');
  final _pass  = TextEditingController(text: '••••••••');
  bool _loading = false;
  void _login() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) context.go('/dashboard');
  }
  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: AppTheme.dark,
    body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(28), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 40),
      Row(children: [
        Container(padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppTheme.brand.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.admin_panel_settings_rounded, color: AppTheme.brand, size: 28)),
        const SizedBox(width: 12),
        RichText(text: const TextSpan(children: [
          TextSpan(text: 'Ad', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.brand)),
          TextSpan(text: 'Stick', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
        ])),
      ]),
      const SizedBox(height: 4),
      const Padding(padding: EdgeInsets.only(left: 48), child: Text('Admin Console', style: TextStyle(color: AppTheme.textMuted, fontSize: 12))),
      const SizedBox(height: 48),
      const Text('Admin Sign In', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
      const SizedBox(height: 6),
      const Text('Restricted access — authorized personnel only', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
      const SizedBox(height: 36),
      _f('Email', _email, Icons.email_rounded),
      const SizedBox(height: 16),
      _f('Password', _pass, Icons.lock_rounded, obscure: true),
      const SizedBox(height: 28),
      SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _loading ? null : _login,
        child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Sign In to Admin Console'))),
      const SizedBox(height: 20),
      Container(padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.border)),
        child: const Row(children: [
          Icon(Icons.security_rounded, color: AppTheme.brand, size: 18),
          SizedBox(width: 8),
          Expanded(child: Text('All admin actions are logged and audited.', style: TextStyle(color: AppTheme.textMuted, fontSize: 12))),
        ])),
    ]))),
  );
  Widget _f(String label, TextEditingController ctrl, IconData icon, {bool obscure = false}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
    const SizedBox(height: 8),
    TextField(controller: ctrl, obscureText: obscure, style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(prefixIcon: Icon(icon, color: AppTheme.textMuted, size: 20),
        filled: true, fillColor: AppTheme.card,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.brand, width: 2)))),
  ]);
}
