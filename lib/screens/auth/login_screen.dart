import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../widgets/gradient_button.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  bool _loading = false, _rememberMe = true, _obscure = true;
  String? _error;

  @override
  void dispose() { _emailC.dispose(); _passC.dispose(); super.dispose(); }

  Future<void> _login() async {
    if (_emailC.text.trim().isEmpty || _passC.text.isEmpty) { setState(() => _error = "Please fill in all fields"); return; }
    setState(() { _error = null; _loading = true; });

    final r = await AuthService.login(email: _emailC.text.trim(), password: _passC.text);
    setState(() => _loading = false);

    if (r["success"] == true) {
      final d = r["data"];
      if (d != null && d["accessToken"] != null) {
        await AuthService.saveSession(accessToken: d["accessToken"], refreshToken: d["refreshToken"] ?? "", user: d["user"] ?? {});
        final u = d["user"];
        if (u != null && u["isProfileCompleted"] == true) { if (mounted) context.go('/home'); }
        else { if (mounted) context.go('/profile-setup'); }
      }
    } else {
      if (r["code"] == "EMAIL_NOT_VERIFIED") { if (mounted) context.push('/verify-otp', extra: {'email': _emailC.text.trim(), 'type': 'signup'}); }
      else { setState(() => _error = r["message"]); }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZussGoTheme.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 36),
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(gradient: ZussGoTheme.gradientPrimary, borderRadius: BorderRadius.circular(16)),
              alignment: Alignment.center,
              child: const Text('Z', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 22, fontFamily: 'Playfair Display')),
            ),
            const SizedBox(height: 24),
            Text('Welcome\nBack', style: ZussGoTheme.displayLarge),
            const SizedBox(height: 8),
            Text('Sign in to continue your journey', style: ZussGoTheme.bodyLarge),
            const SizedBox(height: 32),

            Text('Email', style: ZussGoTheme.labelBold.copyWith(color: ZussGoTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: _emailC,
              decoration: ZussGoTheme.inputDecoration(hint: 'arjun@email.com', prefix: Icon(Icons.mail_outline_rounded, color: ZussGoTheme.textMuted, size: 20)),
              style: ZussGoTheme.bodyMedium.copyWith(color: ZussGoTheme.textPrimary),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 18),

            Text('Password', style: ZussGoTheme.labelBold.copyWith(color: ZussGoTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: _passC,
              decoration: ZussGoTheme.inputDecoration(
                hint: '••••••••',
                prefix: Icon(Icons.lock_outline_rounded, color: ZussGoTheme.textMuted, size: 20),
                suffix: GestureDetector(
                  onTap: () => setState(() => _obscure = !_obscure),
                  child: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: ZussGoTheme.textMuted, size: 20),
                ),
              ),
              style: ZussGoTheme.bodyMedium.copyWith(color: ZussGoTheme.textPrimary),
              obscureText: _obscure,
              onSubmitted: (_) => _login(),
            ),
            const SizedBox(height: 14),

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              GestureDetector(
                onTap: () => setState(() => _rememberMe = !_rememberMe),
                child: Row(children: [
                  Container(
                    width: 20, height: 20,
                    decoration: BoxDecoration(
                      color: _rememberMe ? ZussGoTheme.green : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: _rememberMe ? null : Border.all(color: ZussGoTheme.borderDefault, width: 1.5),
                    ),
                    child: _rememberMe ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
                  ),
                  const SizedBox(width: 8),
                  Text('Remember me', style: ZussGoTheme.bodySmall.copyWith(color: ZussGoTheme.textSecondary)),
                ]),
              ),
              GestureDetector(
                onTap: () => context.push('/forgot-password'),
                child: Text('Forgot Password?', style: TextStyle(fontSize: 12, color: ZussGoTheme.green, fontWeight: FontWeight.w600)),
              ),
            ]),

            if (_error != null)
              Container(
                width: double.infinity, padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(color: ZussGoTheme.rose.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  Icon(Icons.info_outline_rounded, color: ZussGoTheme.rose, size: 18), const SizedBox(width: 8),
                  Expanded(child: Text(_error!, style: TextStyle(color: ZussGoTheme.rose, fontSize: 12, fontWeight: FontWeight.w500))),
                ]),
              ),

            const SizedBox(height: 28),
            GradientButton(text: 'Sign In', isLoading: _loading, onPressed: _login),
            const SizedBox(height: 28),
            Center(
              child: GestureDetector(
                onTap: () => context.push('/signup'),
                child: RichText(text: TextSpan(text: "Don't have an account? ", style: ZussGoTheme.bodyMedium, children: [TextSpan(text: 'Sign Up', style: TextStyle(color: ZussGoTheme.green, fontWeight: FontWeight.w700))])),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}