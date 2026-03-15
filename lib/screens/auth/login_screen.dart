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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = "Please fill in all fields");
      return;
    }

    setState(() { _errorMessage = null; _isLoading = true; });

    final result = await AuthService.login(email: email, password: password);

    setState(() => _isLoading = false);

    if (result["success"] == true) {
      final data = result["data"];

      // Save session if "remember me" is checked
      if (_rememberMe && data != null) {
        await AuthService.saveSession(
          accessToken: data["accessToken"] ?? "",
          refreshToken: data["refreshToken"] ?? "",
          user: data["user"] ?? {},
        );
      }

      // Smart routing based on profile completion
      final isProfileCompleted = data?["user"]?["isProfileCompleted"] ?? false;

      if (mounted) {
        if (isProfileCompleted) {
          context.go('/home');
        } else {
          context.go('/profile-setup');
        }
      }
    } else {
      // Check if email is not verified
      if (result["code"] == "EMAIL_NOT_VERIFIED") {
        // Send them to OTP screen to verify
        if (mounted) {
          context.push('/verify-otp', extra: {
            'email': _emailController.text.trim(),
            'type': 'signup',
          });
        }
      } else {
        setState(() => _errorMessage = result["message"]);
      }
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
              Text('WELCOME BACK', style: ZussGoTheme.bodySmall.copyWith(color: ZussGoTheme.amber, fontWeight: FontWeight.w600, letterSpacing: 2)),
              const SizedBox(height: 8),
              Text('Sign In', style: ZussGoTheme.displayLarge.copyWith(fontSize: 28)),
              const SizedBox(height: 4),
              Text('Your next adventure awaits', style: ZussGoTheme.bodySmall),
              const SizedBox(height: 28),

              // Email
              Text('Email', style: ZussGoTheme.bodySmall.copyWith(fontWeight: FontWeight.w600, color: ZussGoTheme.textSecondary)),
              const SizedBox(height: 6),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(hintText: 'arjun@email.com'),
                style: ZussGoTheme.bodyMedium.copyWith(color: ZussGoTheme.textPrimary),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Password
              Text('Password', style: ZussGoTheme.bodySmall.copyWith(fontWeight: FontWeight.w600, color: ZussGoTheme.textSecondary)),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(hintText: '••••••••'),
                style: ZussGoTheme.bodyMedium.copyWith(color: ZussGoTheme.textPrimary),
                obscureText: true,
                onSubmitted: (_) => _handleLogin(),
              ),
              const SizedBox(height: 12),

              // Remember me + Forgot password row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Remember me checkbox
                  GestureDetector(
                    onTap: () => setState(() => _rememberMe = !_rememberMe),
                    child: Row(
                      children: [
                        Container(
                          width: 20, height: 20,
                          decoration: BoxDecoration(
                            color: _rememberMe ? ZussGoTheme.amber : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _rememberMe ? ZussGoTheme.amber : ZussGoTheme.textMuted,
                              width: 1.5,
                            ),
                          ),
                          child: _rememberMe
                              ? const Icon(Icons.check, size: 14, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Remember me',
                          style: ZussGoTheme.bodySmall.copyWith(color: ZussGoTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),

                  // Forgot password
                  GestureDetector(
                    onTap: () => context.push('/forgot-password'),
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(fontSize: 13, color: ZussGoTheme.lavender, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Error message
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(_errorMessage!, style: TextStyle(color: ZussGoTheme.rose, fontSize: 13)),
                ),

              const SizedBox(height: 16),

              GradientButton(text: 'Sign In', isLoading: _isLoading, onPressed: _handleLogin),
              const SizedBox(height: 32),

              // Signup link
              Center(
                child: GestureDetector(
                  onTap: () => context.go('/signup'),
                  child: RichText(
                    text: TextSpan(
                      text: "New here? ",
                      style: ZussGoTheme.bodyMedium.copyWith(color: ZussGoTheme.textMuted),
                      children: [
                        TextSpan(text: 'Create account', style: TextStyle(color: ZussGoTheme.amber, fontWeight: FontWeight.w600)),
                      ],
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
}