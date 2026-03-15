import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../widgets/gradient_button.dart';
import '../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => _errorMessage = "Please enter your email");
      return;
    }

    setState(() { _errorMessage = null; _successMessage = null; _isLoading = true; });

    final result = await AuthService.forgotPassword(email: email);

    setState(() => _isLoading = false);

    if (result["success"] == true) {
      // Navigate to OTP verification screen with recovery type
      if (mounted) {
        context.push('/verify-otp', extra: {
          'email': email,
          'type': 'recovery',
        });
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
              // Back button
              GestureDetector(
                onTap: () => context.pop(),
                child: const Icon(Icons.arrow_back_rounded, color: ZussGoTheme.textSecondary),
              ),
              const SizedBox(height: 24),

              Text('RESET PASSWORD', style: ZussGoTheme.bodySmall.copyWith(color: ZussGoTheme.amber, fontWeight: FontWeight.w600, letterSpacing: 2)),
              const SizedBox(height: 8),
              Text('Forgot Your\nPassword?', style: ZussGoTheme.displayLarge.copyWith(fontSize: 28)),
              const SizedBox(height: 8),
              Text(
                "No worries — enter your email and we'll send you a 6-digit code to reset it.",
                style: ZussGoTheme.bodyLarge.copyWith(fontSize: 14, fontWeight: FontWeight.w300),
              ),
              const SizedBox(height: 32),

              // Email
              Text('Email', style: ZussGoTheme.bodySmall.copyWith(fontWeight: FontWeight.w600, color: ZussGoTheme.textSecondary)),
              const SizedBox(height: 6),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(hintText: 'arjun@email.com'),
                style: ZussGoTheme.bodyMedium.copyWith(color: ZussGoTheme.textPrimary),
                keyboardType: TextInputType.emailAddress,
                onSubmitted: (_) => _handleSendOtp(),
              ),
              const SizedBox(height: 8),

              // Error
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(_errorMessage!, style: TextStyle(color: ZussGoTheme.rose, fontSize: 13)),
                ),

              // Success
              if (_successMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(_successMessage!, style: TextStyle(color: ZussGoTheme.mint, fontSize: 13)),
                ),

              const SizedBox(height: 24),

              GradientButton(text: 'Send Reset Code', isLoading: _isLoading, onPressed: _handleSendOtp),
              const SizedBox(height: 24),

              Center(
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Text(
                    'Back to Sign In',
                    style: ZussGoTheme.bodyMedium.copyWith(color: ZussGoTheme.amber, fontWeight: FontWeight.w600),
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