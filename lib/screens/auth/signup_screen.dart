import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../widgets/gradient_button.dart';
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
      setState(() => _error = "Please fill in all fields");
      return;
    }
    if (_passC.text.length < 8) {
      setState(() => _error = "Password must be at least 8 characters");
      return;
    }
    if (!_canSignup) {
      setState(() => _error = "Please agree to the Terms & Conditions and Privacy Policy");
      return;
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
    // Replace with your actual Terms & Conditions URL
    final uri = Uri.parse('https://zussgo.com/terms');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showPolicyDialog('Terms & Conditions', _termsText);
    }
  }

  void _openPrivacy() async {
    // Replace with your actual Privacy Policy URL
    final uri = Uri.parse('https://zussgo.com/privacy');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showPolicyDialog('Privacy Policy', _privacyText);
    }
  }

  void _showPolicyDialog(String title, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        decoration: const BoxDecoration(
          color: ZussGoTheme.bgPrimary,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: ZussGoTheme.borderDefault, borderRadius: BorderRadius.circular(2))),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: ZussGoTheme.displaySmall),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 30, height: 30,
                      decoration: BoxDecoration(color: ZussGoTheme.bgMuted, shape: BoxShape.circle),
                      child: const Icon(Icons.close_rounded, size: 16, color: ZussGoTheme.textMuted),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: ZussGoTheme.borderDefault),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                child: Text(content, style: ZussGoTheme.bodyMedium.copyWith(height: 1.7, color: ZussGoTheme.textSecondary)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZussGoTheme.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.arrow_back_rounded, color: ZussGoTheme.textSecondary, size: 20),
                ),
              ),
              const SizedBox(height: 20),
              Text('Create\nAccount', style: ZussGoTheme.displayLarge),
              const SizedBox(height: 8),
              Text('Join travelers finding their tribe', style: ZussGoTheme.bodyLarge),
              const SizedBox(height: 28),

              Text('Full Name', style: ZussGoTheme.labelBold.copyWith(color: ZussGoTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameC,
                decoration: ZussGoTheme.inputDecoration(hint: 'Arjun Sharma', prefix: Icon(Icons.person_outline_rounded, color: ZussGoTheme.textMuted, size: 20)),
                style: ZussGoTheme.bodyMedium.copyWith(color: ZussGoTheme.textPrimary),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              Text('Email', style: ZussGoTheme.labelBold.copyWith(color: ZussGoTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailC,
                decoration: ZussGoTheme.inputDecoration(hint: 'arjun@email.com', prefix: Icon(Icons.mail_outline_rounded, color: ZussGoTheme.textMuted, size: 20)),
                style: ZussGoTheme.bodyMedium.copyWith(color: ZussGoTheme.textPrimary),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

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
              ),
              const SizedBox(height: 4),
              Text('At least 8 characters', style: ZussGoTheme.bodySmall),

              const SizedBox(height: 20),

              // ── TERMS & CONDITIONS CHECKBOX ──
              _PolicyCheckbox(
                checked: _agreedTerms,
                onChanged: (v) => setState(() => _agreedTerms = v),
                label: 'I agree to the ',
                linkText: 'Terms & Conditions',
                onLinkTap: _openTerms,
              ),

              const SizedBox(height: 8),

              // ── PRIVACY POLICY CHECKBOX ──
              _PolicyCheckbox(
                checked: _agreedPrivacy,
                onChanged: (v) => setState(() => _agreedPrivacy = v),
                label: 'I agree to the ',
                linkText: 'Privacy Policy',
                onLinkTap: _openPrivacy,
              ),

              if (_error != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(top: 14),
                  decoration: BoxDecoration(color: ZussGoTheme.rose.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: ZussGoTheme.rose, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_error!, style: TextStyle(color: ZussGoTheme.rose, fontSize: 12, fontWeight: FontWeight.w500))),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Sign up button — dimmed if not agreed
              AnimatedOpacity(
                opacity: _canSignup ? 1.0 : 0.5,
                duration: const Duration(milliseconds: 200),
                child: GradientButton(
                  text: 'Create Account',
                  isLoading: _loading,
                  onPressed: _signup,
                ),
              ),

              const SizedBox(height: 28),
              Center(
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: ZussGoTheme.bodyMedium,
                      children: [TextSpan(text: 'Sign In', style: TextStyle(color: ZussGoTheme.green, fontWeight: FontWeight.w700))],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Placeholder policy texts (replace with your real content) ──

  static const _termsText = '''TERMS AND CONDITIONS

Last updated: March 2026

Welcome to ZussGo. By using our app, you agree to these terms.

1. ACCEPTANCE OF TERMS
By creating an account or using ZussGo, you agree to be bound by these Terms and Conditions. If you do not agree, please do not use the app.

2. ELIGIBILITY
You must be at least 18 years old to use ZussGo. By signing up, you confirm that you meet this age requirement.

3. ACCOUNT REGISTRATION
You must provide accurate, current, and complete information during registration. You are responsible for maintaining the confidentiality of your account credentials.

4. USER CONDUCT
You agree to:
- Treat other users with respect and kindness
- Not share false, misleading, or harmful information
- Not harass, threaten, or intimidate other users
- Not use the app for any illegal activities
- Not create multiple accounts or impersonate others

5. TRAVEL SAFETY
ZussGo connects travelers but does not guarantee the safety of any trip or companion. Users are responsible for their own safety and should:
- Verify the identity of travel companions
- Share travel plans with trusted contacts
- Use the SOS feature in emergencies
- Meet in public places first

6. CONTENT
You retain ownership of content you post but grant ZussGo a license to use it within the app. We may remove content that violates these terms.

7. PRIVACY
Your personal information is handled as described in our Privacy Policy. By using ZussGo, you consent to our data practices.

8. TERMINATION
We may suspend or terminate your account for violations of these terms. You may delete your account at any time.

9. LIMITATION OF LIABILITY
ZussGo is provided "as is" without warranties. We are not liable for any damages arising from your use of the app or interactions with other users.

10. CHANGES TO TERMS
We may update these terms from time to time. Continued use of the app constitutes acceptance of the updated terms.

11. CONTACT
For questions about these terms, contact us at hello@zussgo.com.

© 2026 ArcheTech Global. All rights reserved.''';

  static const _privacyText = '''PRIVACY POLICY

Last updated: March 2026

ZussGo ("we", "us", "our") is committed to protecting your privacy. This policy explains how we collect, use, and protect your information.

1. INFORMATION WE COLLECT

Personal Information:
- Name, email address, age, gender, city
- Travel preferences, mindset, and interests
- Profile photos

Usage Data:
- App usage patterns and preferences
- Device information and IP address
- Location data (only when you activate trip tracking)

2. HOW WE USE YOUR INFORMATION

We use your information to:
- Create and manage your account
- Match you with compatible travel companions
- Display your profile to other travelers
- Send notifications about matches and messages
- Improve our matching algorithm
- Ensure safety through the SOS feature
- Communicate important updates

3. INFORMATION SHARING

We do NOT sell your personal data. We may share information with:
- Other ZussGo users (your public profile)
- Emergency services (only when SOS is triggered)
- Emergency contacts you designate
- Service providers who help us operate the app

4. DATA SECURITY

We implement industry-standard security measures to protect your data, including:
- Encrypted data transmission (HTTPS)
- Secure database storage
- Regular security audits

5. YOUR RIGHTS

You have the right to:
- Access your personal data
- Update or correct your information
- Delete your account and data
- Opt out of non-essential communications
- Request a copy of your data

6. LOCATION DATA

Location data is collected ONLY when you:
- Activate the "We're Going" trip tracking feature
- Trigger the SOS emergency feature

Location tracking stops when you mark a trip as complete.

7. COOKIES AND ANALYTICS

We use analytics to improve the app experience. No third-party advertising cookies are used.

8. CHILDREN'S PRIVACY

ZussGo is not intended for users under 18. We do not knowingly collect data from minors.

9. DATA RETENTION

We retain your data while your account is active. Upon deletion, your data is removed within 30 days.

10. CHANGES TO THIS POLICY

We may update this policy periodically. We will notify you of significant changes through the app.

11. CONTACT US

For privacy concerns, contact us at:
Email: hello@zussgo.com
Company: ArcheTech Global

© 2026 ArcheTech Global. All rights reserved.''';
}

// ── Custom checkbox widget with tappable link ──
class _PolicyCheckbox extends StatelessWidget {
  final bool checked;
  final ValueChanged<bool> onChanged;
  final String label;
  final String linkText;
  final VoidCallback onLinkTap;

  const _PolicyCheckbox({
    required this.checked,
    required this.onChanged,
    required this.label,
    required this.linkText,
    required this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!checked),
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Custom checkbox
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22, height: 22,
            decoration: BoxDecoration(
              color: checked ? ZussGoTheme.green : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: checked ? null : Border.all(color: ZussGoTheme.borderDefault, width: 1.5),
              boxShadow: checked ? [BoxShadow(color: ZussGoTheme.green.withValues(alpha: 0.2), blurRadius: 6)] : null,
            ),
            child: checked
                ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 10),
          // Text with tappable link
          Expanded(
            child: RichText(
              text: TextSpan(
                text: label,
                style: ZussGoTheme.bodySmall.copyWith(color: ZussGoTheme.textSecondary, fontSize: 13),
                children: [
                  TextSpan(
                    text: linkText,
                    style: TextStyle(
                      color: ZussGoTheme.green,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                      decorationColor: ZussGoTheme.green.withValues(alpha: 0.3),
                    ),
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