import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../widgets/gradient_button.dart';
import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = "Please fill in all fields");
      return;
    }

    if (password.length < 8) {
      setState(() => _errorMessage = "Password must be at least 8 characters");
      return;
    }

    setState(() { _errorMessage = null; _isLoading = true; });

    final result = await AuthService.signup(
      fullName: fullName,
      email: email,
      password: password,
    );

    setState(() => _isLoading = false);

    if (result["success"] == true) {
      // Navigate to OTP verification screen
      if (mounted) {
        context.push('/verify-otp', extra: {'email': email, 'type': 'signup'});
      }
    } else {
      setState(() => _errorMessage = result["message"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('JOIN THE JOURNEY', style: ZussGoTheme.bodySmall.copyWith(color: ZussGoTheme.amber, fontWeight: FontWeight.w600, letterSpacing: 2)),
              const SizedBox(height: 8),
              Text('Create Your\nAccount', style: ZussGoTheme.displayLarge.copyWith(fontSize: 28)),
              const SizedBox(height: 4),
              Text('Takes less than a minute', style: ZussGoTheme.bodySmall),
              const SizedBox(height: 28),

              _buildLabel('Full Name'),
              const SizedBox(height: 6),
              TextField(controller: _fullNameController, decoration: const InputDecoration(hintText: 'Arjun Sharma'), style: ZussGoTheme.bodyMedium.copyWith(color: ZussGoTheme.textPrimary)),
              const SizedBox(height: 16),

              _buildLabel('Email'),
              const SizedBox(height: 6),
              TextField(controller: _emailController, decoration: const InputDecoration(hintText: 'arjun@email.com'), style: ZussGoTheme.bodyMedium.copyWith(color: ZussGoTheme.textPrimary), keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),

              _buildLabel('Password'),
              const SizedBox(height: 6),
              TextField(controller: _passwordController, decoration: const InputDecoration(hintText: '••••••••'), style: ZussGoTheme.bodyMedium.copyWith(color: ZussGoTheme.textPrimary), obscureText: true),
              const SizedBox(height: 8),

              if (_errorMessage != null)
                Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(_errorMessage!, style: TextStyle(color: ZussGoTheme.rose, fontSize: 13))),

              const SizedBox(height: 16),

              GradientButton(text: 'Create Account', isLoading: _isLoading, onPressed: _handleSignup),
              const SizedBox(height: 20),

              Row(children: [
                Expanded(child: Divider(color: ZussGoTheme.borderDefault)),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('or sign up with', style: ZussGoTheme.bodySmall.copyWith(fontSize: 11))),
                Expanded(child: Divider(color: ZussGoTheme.borderDefault)),
              ]),
              const SizedBox(height: 20),

              Row(children: [
                Expanded(child: _SocialButton(icon: Icons.g_mobiledata_rounded, label: 'Google')),
                const SizedBox(width: 12),
                Expanded(child: _SocialButton(icon: Icons.phone_rounded, label: 'Phone')),
              ]),
              const SizedBox(height: 32),

              Center(
                child: GestureDetector(
                  onTap: () => context.go('/login'),
                  child: RichText(text: TextSpan(
                    text: 'Already traveling? ',
                    style: ZussGoTheme.bodyMedium.copyWith(color: ZussGoTheme.textMuted),
                    children: [TextSpan(text: 'Sign in', style: TextStyle(color: ZussGoTheme.amber, fontWeight: FontWeight.w600))],
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(text, style: ZussGoTheme.bodySmall.copyWith(fontWeight: FontWeight.w600, color: ZussGoTheme.textSecondary));
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SocialButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: ZussGoTheme.bgSecondary, borderRadius: BorderRadius.circular(14), border: Border.all(color: ZussGoTheme.borderDefault)),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 20, color: ZussGoTheme.textSecondary),
        const SizedBox(width: 8),
        Text(label, style: ZussGoTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
      ]),
    );
  }
}