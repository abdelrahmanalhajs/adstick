import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _State();
}

class _State extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass  = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() { _email.dispose(); _pass.dispose(); super.dispose(); }

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    final err = await authService.signIn(_email.text, _pass.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (err != null) {
      setState(() => _error = err);
    } else {
      context.go('/overview');
    }
  }

  Future<void> _forgot() async {
    final email = _email.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Enter your email first to reset password.');
      return;
    }
    final err = await authService.resetPassword(email);
    if (!mounted) return;
    if (err != null) {
      setState(() => _error = err);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent. Check your inbox.')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.dark,
    body: SafeArea(child: SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 40),
        RichText(text: const TextSpan(children: [
          TextSpan(text: 'Ad', style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.w900, color: AppTheme.brand)),
          TextSpan(text: 'Stick', style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.w900, color: Colors.white)),
        ])),
        const SizedBox(height: 4),
        const Text('Advertiser Portal',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 15)),
        const SizedBox(height: 48),
        const Text('Welcome back 👋',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900,
                color: Colors.white)),
        const SizedBox(height: 6),
        const Text('Sign in to manage your campaigns',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
        const SizedBox(height: 36),

        // Error banner
        if (_error != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
            ),
            child: Row(children: [
              const Icon(Icons.error_outline_rounded, color: Colors.red, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(_error!,
                  style: const TextStyle(color: Colors.red, fontSize: 13))),
            ]),
          ),
          const SizedBox(height: 16),
        ],

        _f('Email', _email, Icons.email_rounded),
        const SizedBox(height: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Password', style: TextStyle(
              color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _pass,
            obscureText: _obscure,
            style: const TextStyle(color: Colors.white),
            onSubmitted: (_) => _login(),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_rounded,
                  color: AppTheme.textMuted, size: 20),
              suffixIcon: IconButton(
                icon: Icon(_obscure
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
                    color: AppTheme.textMuted, size: 20),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
              filled: true, fillColor: AppTheme.card,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.border)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.border)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.brand, width: 2)),
            ),
          ),
        ]),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _forgot,
            child: const Text('Forgot password?',
                style: TextStyle(color: AppTheme.brand, fontSize: 13)),
          ),
        ),
        const SizedBox(height: 16),

        SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: _loading ? null : _login,
          child: _loading
              ? const SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : const Text('Sign In'))),
        const SizedBox(height: 16),
        Center(child: TextButton(
          onPressed: () => context.go('/register'),
          child: const Text('New advertiser? Create account →',
              style: TextStyle(color: AppTheme.brand)),
        )),
      ]))),
  );

  Widget _f(String label, TextEditingController ctrl, IconData icon) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(
            color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppTheme.textMuted, size: 20),
            filled: true, fillColor: AppTheme.card,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.border)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.border)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.brand, width: 2)),
          ),
        ),
      ]);
}
