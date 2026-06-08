import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../l10n/app_l10n.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name  = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _pass  = TextEditingController();
  final _pass2 = TextEditingController();
  bool _loading = false;
  bool _obscure1 = true;
  bool _obscure2 = true;
  String? _error;

  @override
  void dispose() {
    _name.dispose(); _email.dispose(); _phone.dispose();
    _pass.dispose(); _pass2.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final l = AppL10n.of(context);
    setState(() { _error = null; });

    // Validate
    if (_name.text.trim().isEmpty || _email.text.trim().isEmpty ||
        _pass.text.isEmpty) {
      setState(() => _error = l.isAr
          ? 'يرجى ملء جميع الحقول'
          : 'Please fill in all required fields.');
      return;
    }
    if (_pass.text != _pass2.text) {
      setState(() => _error = l.isAr
          ? 'كلمات المرور غير متطابقة'
          : 'Passwords do not match.');
      return;
    }
    if (_pass.text.length < 6) {
      setState(() => _error = l.isAr
          ? 'يجب أن تكون كلمة المرور 6 أحرف على الأقل'
          : 'Password must be at least 6 characters.');
      return;
    }

    setState(() => _loading = true);
    final err = await authService.register(
      email:    _email.text,
      password: _pass.text,
      name:     _name.text,
      phone:    _phone.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (err != null) {
      setState(() => _error = err);
    } else {
      context.go('/overview');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return Scaffold(
      backgroundColor: AppTheme.dark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 20),
            // Back
            GestureDetector(
              onTap: () => context.go('/login'),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.border),
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(height: 32),
            RichText(text: const TextSpan(children: [
              TextSpan(text: 'Ad', style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w900,
                  color: AppTheme.driverGreen)),
              TextSpan(text: 'Stick', style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w900,
                  color: Colors.white)),
            ])),
            const SizedBox(height: 8),
            Text(
              l.isAr ? 'إنشاء حساب سائق جديد' : 'Create Driver Account',
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              l.isAr
                  ? 'انضم إلى شبكة سائقي AdStick'
                  : 'Join the AdStick driver network',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
            ),
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
                  const Icon(Icons.error_outline_rounded,
                      color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!,
                      style: const TextStyle(color: Colors.red, fontSize: 13))),
                ]),
              ),
              const SizedBox(height: 16),
            ],

            _field(l.isAr ? 'الاسم الكامل' : 'Full Name *',
                _name, Icons.person_rounded),
            const SizedBox(height: 14),
            _field(l.t('email'), _email, Icons.email_rounded,
                type: TextInputType.emailAddress),
            const SizedBox(height: 14),
            _field(l.isAr ? 'رقم الهاتف' : 'Phone Number',
                _phone, Icons.phone_rounded,
                type: TextInputType.phone),
            const SizedBox(height: 14),
            _passField(
              label: l.isAr ? 'كلمة المرور *' : 'Password *',
              ctrl: _pass,
              obscure: _obscure1,
              toggle: () => setState(() => _obscure1 = !_obscure1),
            ),
            const SizedBox(height: 14),
            _passField(
              label: l.isAr ? 'تأكيد كلمة المرور *' : 'Confirm Password *',
              ctrl: _pass2,
              obscure: _obscure2,
              toggle: () => setState(() => _obscure2 = !_obscure2),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _register,
                child: _loading
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(l.isAr ? 'إنشاء الحساب' : 'Create Account',
                        style: const TextStyle(fontSize: 16,
                            fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 16),
            Center(child: GestureDetector(
              onTap: () => context.go('/login'),
              child: RichText(text: TextSpan(children: [
                TextSpan(
                    text: l.isAr ? 'لديك حساب بالفعل؟ ' : 'Already registered? ',
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 14)),
                TextSpan(
                    text: l.t('sign_in'),
                    style: const TextStyle(
                        color: AppTheme.driverGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
              ])),
            )),
          ]),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, IconData icon,
      {TextInputType type = TextInputType.text}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(
          color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
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
              borderSide: const BorderSide(
                  color: AppTheme.driverGreen, width: 2)),
        ),
      ),
    ]);
  }

  Widget _passField({
    required String label,
    required TextEditingController ctrl,
    required bool obscure,
    required VoidCallback toggle,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(
          color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
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
              borderSide: const BorderSide(
                  color: AppTheme.driverGreen, width: 2)),
        ),
      ),
    ]);
  }
}
