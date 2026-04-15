import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  bool _loading = false, _obscure = true;
  bool _agreedTerms = false, _agreedPrivacy = false;
  String? _error;

  @override
  void dispose() { _nameC.dispose(); _emailC.dispose(); _passC.dispose(); super.dispose(); }

  bool get _canSignup => _agreedTerms && _agreedPrivacy;

  Future<void> _signup() async {
    if (_nameC.text.trim().isEmpty || _emailC.text.trim().isEmpty || _passC.text.isEmpty) {
      setState(() => _error = "Please fill in all fields"); return;
    }
    if (_passC.text.length < 8) {
      setState(() => _error = "Password must be at least 8 characters"); return;
    }
    if (!_canSignup) {
      setState(() => _error = "Please agree to the Terms & Conditions and Privacy Policy"); return;
    }
    setState(() { _error = null; _loading = true; });

    final r = await AuthService.signup(fullName: _nameC.text.trim(), email: _emailC.text.trim(), password: _passC.text);
    setState(() => _loading = false);

    if (r["success"] == true && mounted) {
      context.push('/verify-otp', extra: {'email': _emailC.text.trim(), 'type': 'signup', 'fullName': _nameC.text.trim()});
    } else {
      setState(() => _error = r["message"]);
    }
  }

  void _openTerms() async {
    final uri = Uri.parse('https://zussgo.com/terms');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showPolicyDialog('Terms & Conditions', _termsText);
    }
  }

  void _openPrivacy() async {
    final uri = Uri.parse('https://zussgo.com/privacy');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showPolicyDialog('Privacy Policy', _privacyText);
    }
  }

  void _showPolicyDialog(String title, String content) {
    final c = context.colors;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
          border: Border.all(color: c.border),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: c.border, borderRadius: BorderRadius.circular(2))),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: c.text)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 30, height: 30,
                      decoration: BoxDecoration(color: c.card, shape: BoxShape.circle, border: Border.all(color: c.border)),
                      child: Icon(Icons.close_rounded, size: 16, color: c.muted),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: c.border),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                child: Text(content, style: GoogleFonts.plusJakartaSans(height: 1.7, color: c.textSecondary, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.canPop()) { context.pop(); } else { context.go('/login'); }
      },
      child: Scaffold(
        backgroundColor: c.bg,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                GestureDetector(
                  onTap: () => context.canPop() ? context.pop() : context.go('/login'),
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: c.border)),
                    child: Icon(Icons.arrow_back_rounded, color: c.text, size: 18),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text('Create\nAccount', style: GoogleFonts.outfit(fontSize: 30, fontWeight: FontWeight.w900, color: c.text, height: 1.15, letterSpacing: -1.5)),
                const SizedBox(height: 8),
                Text('Join travelers finding their tribe', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: c.textSecondary)),
                const SizedBox(height: 28),

                // Full Name
                Text('Full Name', style: GoogleFonts.plusJakartaSans(color: c.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameC,
                  decoration: ZussGoTheme.inputDecorationOf(context, hint: 'Arjun Sharma', prefix: Icon(Icons.person_outline_rounded, color: c.muted, size: 20)),
                  style: GoogleFonts.plusJakartaSans(color: c.text, fontSize: 14),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // Email
                Text('Email', style: GoogleFonts.plusJakartaSans(color: c.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailC,
                  decoration: ZussGoTheme.inputDecorationOf(context, hint: 'arjun@email.com', prefix: Icon(Icons.mail_outline_rounded, color: c.muted, size: 20)),
                  style: GoogleFonts.plusJakartaSans(color: c.text, fontSize: 14),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Password
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
                ),
                const SizedBox(height: 4),
                Text('At least 8 characters', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: c.muted)),
                const SizedBox(height: 20),

                // Terms checkbox
                _PolicyCheckbox(
                  checked: _agreedTerms,
                  onChanged: (v) => setState(() => _agreedTerms = v),
                  label: 'I agree to the ',
                  linkText: 'Terms & Conditions',
                  onLinkTap: _openTerms,
                ),
                const SizedBox(height: 8),

                // Privacy checkbox
                _PolicyCheckbox(
                  checked: _agreedPrivacy,
                  onChanged: (v) => setState(() => _agreedPrivacy = v),
                  label: 'I agree to the ',
                  linkText: 'Privacy Policy',
                  onLinkTap: _openPrivacy,
                ),

                // Error
                if (_error != null)
                  Container(
                    width: double.infinity, padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(top: 14),
                    decoration: BoxDecoration(color: c.roseSoft, border: Border.all(color: c.rose.withValues(alpha: 0.3)), borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      Icon(Icons.info_outline_rounded, color: c.rose, size: 18), const SizedBox(width: 8),
                      Expanded(child: Text(_error!, style: GoogleFonts.plusJakartaSans(color: c.rose, fontSize: 12, fontWeight: FontWeight.w500))),
                    ]),
                  ),

                const SizedBox(height: 24),

                // Create Account button
                AnimatedOpacity(
                  opacity: _canSignup ? 1.0 : 0.4,
                  duration: const Duration(milliseconds: 200),
                  child: GestureDetector(
                    onTap: _loading ? null : _signup,
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
                            : Text('Create Account', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Center(
                  child: GestureDetector(
                    onTap: () => context.canPop() ? context.pop() : context.go('/login'),
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an account? ',
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, color: c.muted),
                        children: [TextSpan(text: 'Sign In', style: TextStyle(color: c.primary, fontWeight: FontWeight.w600))],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const _termsText = '''TERMS AND CONDITIONS\n\nLast updated: March 2026\n\nWelcome to ZussGo. By using our app, you agree to these terms.\n\n1. ACCEPTANCE OF TERMS\nBy creating an account or using ZussGo, you agree to be bound by these Terms and Conditions.\n\n2. ELIGIBILITY\nYou must be at least 18 years old to use ZussGo.\n\n3. ACCOUNT REGISTRATION\nYou must provide accurate, current, and complete information during registration.\n\n4. USER CONDUCT\nYou agree to treat other users with respect, not share false information, not harass others, and not use the app for illegal activities.\n\n5. TRAVEL SAFETY\nZussGo connects travelers but does not guarantee safety. Use the SOS feature in emergencies.\n\n6. PRIVACY\nYour personal information is handled as described in our Privacy Policy.\n\n7. TERMINATION\nWe may suspend or terminate your account for violations.\n\n8. LIMITATION OF LIABILITY\nZussGo is provided "as is" without warranties.\n\n© 2026 ArcheTech Global. All rights reserved.''';

  static const _privacyText = '''PRIVACY POLICY\n\nLast updated: March 2026\n\nZussGo is committed to protecting your privacy.\n\n1. INFORMATION WE COLLECT\nPersonal Information: Name, email, age, gender, city, travel preferences.\nUsage Data: App usage, device info, location (only during trip tracking).\n\n2. HOW WE USE YOUR INFORMATION\nTo create your account, match companions, send notifications, and ensure safety.\n\n3. INFORMATION SHARING\nWe do NOT sell your data. Shared only with other users (profile) and emergency services (SOS).\n\n4. DATA SECURITY\nIndustry-standard encryption and security measures.\n\n5. YOUR RIGHTS\nAccess, update, delete your data, or opt out of communications.\n\n6. CONTACT US\nEmail: hello@zussgo.com\n\n© 2026 ArcheTech Global. All rights reserved.''';
}

class _PolicyCheckbox extends StatelessWidget {
  final bool checked;
  final ValueChanged<bool> onChanged;
  final String label;
  final String linkText;
  final VoidCallback onLinkTap;
  const _PolicyCheckbox({required this.checked, required this.onChanged, required this.label, required this.linkText, required this.onLinkTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: () => onChanged(!checked),
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22, height: 22,
            decoration: BoxDecoration(
              color: checked ? c.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: checked ? null : Border.all(color: c.border, width: 1.5),
              boxShadow: checked ? [BoxShadow(color: c.primary.withValues(alpha: 0.2), blurRadius: 6)] : null,
            ),
            child: checked ? const Icon(Icons.check_rounded, size: 15, color: Colors.white) : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: label,
                style: GoogleFonts.plusJakartaSans(color: c.textSecondary, fontSize: 13),
                children: [
                  TextSpan(
                    text: linkText,
                    style: TextStyle(color: c.primary, fontWeight: FontWeight.w600, decoration: TextDecoration.underline, decorationColor: c.primary.withValues(alpha: 0.3)),
                    recognizer: TapGestureRecognizer()..onTap = onLinkTap,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}