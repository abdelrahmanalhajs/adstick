import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override State<RegisterScreen> createState() => _State();
}

class _State extends State<RegisterScreen> {
  final _company  = TextEditingController();
  final _name     = TextEditingController();
  final _email    = TextEditingController();
  final _phone    = TextEditingController();
  final _pass     = TextEditingController();
  final _confirm  = TextEditingController();
  bool _loading   = false;
  bool _obscureP  = true;
  bool _obscureC  = true;
  String? _error;

  @override
  void dispose() {
    _company.dispose(); _name.dispose(); _email.dispose();
    _phone.dispose();   _pass.dispose(); _confirm.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    // Validate
    if (_company.text.trim().isEmpty) { _setErr('Company name is required.'); return; }
    if (_name.text.trim().isEmpty)    { _setErr('Contact name is required.'); return; }
    if (_email.text.trim().isEmpty)   { _setErr('Email is required.'); return; }
    if (_pass.text.isEmpty)           { _setErr('Password is required.'); return; }
    if (_pass.text.length < 6)        { _setErr('Password must be at least 6 characters.'); return; }
    if (_pass.text != _confirm.text)  { _setErr('Passwords do not match.'); return; }

    setState(() { _loading = true; _error = null; });
    final err = await authService.register(
      email:       _email.text.trim(),
      password:    _pass.text,
      name:        _name.text.trim(),
      phone:       _phone.text.trim(),
      company:     _company.text.trim(),
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (err != null) {
      setState(() => _error = err);
    } else {
      context.go('/overview');
    }
  }

  void _setErr(String msg) => setState(() => _error = msg);

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.dark,
    body: SafeArea(child: SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 24),
        Row(children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => context.go('/login'),
          ),
          const SizedBox(width: 8),
          RichText(text: const TextSpan(children: [
            TextSpan(text: 'Ad', style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.brand)),
            TextSpan(text: 'Stick', style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
          ])),
        ]),
        const SizedBox(height: 32),
        const Text('Create Advertiser Account',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
                color: Colors.white)),
        const SizedBox(height: 6),
        const Text('Start reaching customers with your brand',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
        const SizedBox(height: 30),

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

        _f('Company / Brand Name *', _company, Icons.business_rounded),
        const SizedBox(height: 14),
        _f('Contact Person Name *', _name, Icons.person_rounded),
        const SizedBox(height: 14),
        _f('Email *', _email, Icons.email_rounded,
            type: TextInputType.emailAddress),
        const SizedBox(height: 14),
        _f('Phone', _phone, Icons.phone_rounded,
            type: TextInputType.phone),
        const SizedBox(height: 14),
        _fPass('Password *', _pass, _obscureP,
            () => setState(() => _obscureP = !_obscureP)),
        const SizedBox(height: 14),
        _fPass('Confirm Password *', _confirm, _obscureC,
            () => setState(() => _obscureC = !_obscureC)),
        const SizedBox(height: 28),

        SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: _loading ? null : _register,
          style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48)),
          child: _loading
              ? const SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : const Text('Create Account',
                  style: TextStyle(fontWeight: FontWeight.w800)))),
        const SizedBox(height: 16),
        Center(child: TextButton(
          onPressed: () => context.go('/login'),
          child: const Text('Already have an account? Sign In',
              style: TextStyle(color: AppTheme.brand, fontSize: 13)),
        )),
        const SizedBox(height: 24),
      ]))),
  );

  Widget _f(String label, TextEditingController ctrl, IconData icon,
      {TextInputType type = TextInputType.text}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(
            color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: type,
          style: const TextStyle(color: Colors.white),
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

  Widget _fPass(String label, TextEditingController ctrl,
      bool obscure, VoidCallback toggle) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(
            color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          obscureText: obscure,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_rounded,
                color: AppTheme.textMuted, size: 20),
            suffixIcon: IconButton(
              icon: Icon(obscure
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
                  color: AppTheme.textMuted, size: 20),
              onPressed: toggle,
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
      ]);
}
