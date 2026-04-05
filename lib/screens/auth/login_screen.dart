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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: ZussGoTheme.scaffoldBg(context),
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
            Text('Welcome\nBack', style: context.textTheme.displayLarge!.adaptive(context)),
            const SizedBox(height: 8),
            Text('Sign in to continue your journey', style: context.textTheme.bodyLarge!.adaptive(context)),
            const SizedBox(height: 32),

            Text('Email', style: context.textTheme.labelLarge!.copyWith(color: ZussGoTheme.secondaryText(context), fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: _emailC,
              decoration: ZussGoTheme.inputDecorationOf(context, hint: 'arjun@email.com', prefix: Icon(Icons.mail_outline_rounded, color: ZussGoTheme.mutedText(context), size: 20)),
              style: context.textTheme.bodyMedium!.copyWith(color: ZussGoTheme.primaryText(context)),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 18),

            Text('Password', style: context.textTheme.labelLarge!.copyWith(color: ZussGoTheme.secondaryText(context), fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: _passC,
              decoration: ZussGoTheme.inputDecorationOf(context, 
                hint: '••••••••',
                prefix: Icon(Icons.lock_outline_rounded, color: ZussGoTheme.mutedText(context), size: 20),
                suffix: GestureDetector(
                  onTap: () => setState(() => _obscure = !_obscure),
                  child: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: ZussGoTheme.mutedText(context), size: 20),
                ),
              ),
              style: context.textTheme.bodyMedium!.copyWith(color: ZussGoTheme.primaryText(context)),
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
                      color: _rememberMe ? context.colors.green : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: _rememberMe ? null : Border.all(color: ZussGoTheme.border(context), width: 1.5),
                    ),
                    child: _rememberMe ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
                  ),
                  const SizedBox(width: 8),
                  Text('Remember me', style: context.textTheme.bodySmall!.copyWith(color: ZussGoTheme.secondaryText(context))),
                ]),
              ),
              GestureDetector(
                onTap: () => context.push('/forgot-password'),
                child: Text('Forgot Password?', style: TextStyle(fontSize: 12, color: context.colors.green, fontWeight: FontWeight.w600)),
              ),
            ]),

            if (_error != null)
              Container(
                width: double.infinity, padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(color: context.colors.rose.withValues(alpha: isDark ? 0.15 : 0.06), border: isDark ? Border.all(color: context.colors.rose.withValues(alpha: 0.3)) : null, borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  Icon(Icons.info_outline_rounded, color: context.colors.rose, size: 18), SizedBox(width: 8),
                  Expanded(child: Text(_error!, style: TextStyle(color: isDark ? const Color(0xFFFFAEB4) : context.colors.rose, fontSize: 12, fontWeight: FontWeight.w500))),
                ]),
              ),

            const SizedBox(height: 28),
            GradientButton(text: 'Sign In', isLoading: _loading, onPressed: _login),
            const SizedBox(height: 28),
            Center(
              child: GestureDetector(
                onTap: () => context.push('/signup'),
                child: RichText(text: TextSpan(text: "Don't have an account? ", style: context.textTheme.bodyMedium!, children: [TextSpan(text: 'Sign Up', style: TextStyle(color: context.colors.green, fontWeight: FontWeight.w700))])),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}