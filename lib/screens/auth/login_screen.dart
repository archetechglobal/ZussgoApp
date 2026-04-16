import '../../config/zuss_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';
import '../../config/zuss_icons.dart';

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
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── TOP SECTION (Brand) ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(28, 50, 28, 28),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.3),
                    radius: 1.2,
                    colors: [const Color(0x0CFF6B4A), Colors.transparent],
                  ),
                ),
                child: Column(
                  children: [
                    // Logo emoji
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(colors: [Color(0xFFFF6B4A), Color(0xFFFF8A65)]),
                        boxShadow: [BoxShadow(color: const Color(0x30FF6B4A), blurRadius: 20)],
                      ),
                      child: const Icon(ZussIcons.globe, size: 32, color: Colors.white),
                    ),
                    const SizedBox(height: 12),

                    // Brand
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.outfit(fontSize: 38, fontWeight: FontWeight.w900, letterSpacing: -1.5, color: c.text),
                        children: [
                          const TextSpan(text: 'Zuss'),
                          TextSpan(text: 'Go', style: TextStyle(color: c.primary)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      'Find your perfect travel companion\nacross India',
                      style: GoogleFonts.plusJakartaSans(fontSize: 14, color: c.textSecondary, height: 1.6),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // India flag badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: c.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: c.border),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(ZussIcons.location, size: 12, color: c.textSecondary),
                        const SizedBox(width: 3),
                        Text('India', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: c.textSecondary)),
                      ]),
                    ),
                  ],
                ),
              ),

              // ── FORM SECTION ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email', style: GoogleFonts.plusJakartaSans(color: c.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailC,
                      decoration: ZussGoTheme.inputDecorationOf(context, hint: 'arjun@email.com', prefix: Icon(Icons.mail_outline_rounded, color: c.muted, size: 20)),
                      style: GoogleFonts.plusJakartaSans(color: c.text, fontSize: 14),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    Text('Password', style: GoogleFonts.plusJakartaSans(color: c.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passC,
                      decoration: ZussGoTheme.inputDecorationOf(context,
                        hint: '••••••••',
                        prefix: Icon(Icons.lock_outline_rounded, color: c.muted, size: 20),
                        suffix: GestureDetector(
                          onTap: () => setState(() => _obscure = !_obscure),
                          child: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: c.muted, size: 20),
                        ),
                      ),
                      style: GoogleFonts.plusJakartaSans(color: c.text, fontSize: 14),
                      obscureText: _obscure,
                      onSubmitted: (_) => _login(),
                    ),
                    const SizedBox(height: 14),

                    // Remember me + Forgot
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      GestureDetector(
                        onTap: () => setState(() => _rememberMe = !_rememberMe),
                        child: Row(children: [
                          Container(
                            width: 20, height: 20,
                            decoration: BoxDecoration(
                              color: _rememberMe ? c.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: _rememberMe ? null : Border.all(color: c.border, width: 1.5),
                            ),
                            child: _rememberMe ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
                          ),
                          const SizedBox(width: 8),
                          Text('Remember me', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: c.textSecondary)),
                        ]),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/forgot-password'),
                        child: Text('Forgot Password?', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: c.primary, fontWeight: FontWeight.w600)),
                      ),
                    ]),

                    // Error
                    if (_error != null)
                      Container(
                        width: double.infinity, padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(top: 12),
                        decoration: BoxDecoration(color: c.roseSoft, border: Border.all(color: c.rose.withValues(alpha: 0.3)), borderRadius: BorderRadius.circular(12)),
                        child: Row(children: [
                          Icon(Icons.info_outline_rounded, color: c.rose, size: 18), const SizedBox(width: 8),
                          Expanded(child: Text(_error!, style: GoogleFonts.plusJakartaSans(color: c.rose, fontSize: 12, fontWeight: FontWeight.w500))),
                        ]),
                      ),

                    const SizedBox(height: 24),

                    // Sign In button
                    GestureDetector(
                      onTap: _loading ? null : _login,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: c.primary,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: const Color(0x40FF6B4A), blurRadius: 20, offset: const Offset(0, 4))],
                        ),
                        child: Center(
                          child: _loading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : Text('Sign In', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Sign up link
                    Center(
                      child: GestureDetector(
                        onTap: () => context.push('/signup'),
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: c.muted),
                            children: [TextSpan(text: 'Sign Up', style: TextStyle(color: c.primary, fontWeight: FontWeight.w600))],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Trust indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _TrustBadge(color: c.sage, label: 'Verified users'),
                        const SizedBox(width: 16),
                        _TrustBadge(color: c.primary, label: 'SOS built-in'),
                        const SizedBox(width: 16),
                        _TrustBadge(color: c.gold, label: 'Free to start'),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrustBadge extends StatelessWidget {
  final Color color;
  final String label;
  const _TrustBadge({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF7D7573), fontWeight: FontWeight.w600)),
      ],
    );
  }
}