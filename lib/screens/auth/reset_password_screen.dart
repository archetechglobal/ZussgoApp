import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../widgets/gradient_button.dart';
import '../../services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (password.isEmpty || confirm.isEmpty) {
      setState(() => _errorMessage = "Please fill in both fields");
      return;
    }

    if (password.length < 8) {
      setState(() => _errorMessage = "Password must be at least 8 characters");
      return;
    }

    if (password != confirm) {
      setState(() => _errorMessage = "Passwords don't match");
      return;
    }

    setState(() { _errorMessage = null; _isLoading = true; });

    final result = await AuthService.resetPassword(
      email: widget.email,
      otp: widget.otp,
      newPassword: password,
    );

    setState(() => _isLoading = false);

    if (result["success"] == true) {
      if (mounted) {
        // Show success dialog then navigate to login
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => Dialog(
            backgroundColor: ZussGoTheme.bgSecondary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('✅', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text('Password Reset!', style: ZussGoTheme.displaySmall),
                  const SizedBox(height: 8),
                  Text('Your password has been updated successfully.', style: ZussGoTheme.bodyMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  GradientButton(
                    text: 'Sign In',
                    onPressed: () {
                      Navigator.pop(context); // close dialog
                      context.go('/login');
                    },
                  ),
                ],
              ),
            ),
          ),
        );
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
              // Back
              GestureDetector(
                onTap: () => context.pop(),
                child: const Icon(Icons.arrow_back_rounded, color: ZussGoTheme.textSecondary),
              ),
              const SizedBox(height: 24),

              Text('ALMOST DONE', style: ZussGoTheme.bodySmall.copyWith(color: ZussGoTheme.amber, fontWeight: FontWeight.w600, letterSpacing: 2)),
              const SizedBox(height: 8),
              Text('Set New\nPassword', style: ZussGoTheme.displayLarge.copyWith(fontSize: 28)),
              const SizedBox(height: 8),
              Text('Choose a strong password you\'ll remember.', style: ZussGoTheme.bodySmall),
              const SizedBox(height: 32),

              // New password
              Text('New Password', style: ZussGoTheme.bodySmall.copyWith(fontWeight: FontWeight.w600, color: ZussGoTheme.textSecondary)),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(hintText: '••••••••'),
                style: ZussGoTheme.bodyMedium.copyWith(color: ZussGoTheme.textPrimary),
                obscureText: true,
              ),
              const SizedBox(height: 16),

              // Confirm password
              Text('Confirm Password', style: ZussGoTheme.bodySmall.copyWith(fontWeight: FontWeight.w600, color: ZussGoTheme.textSecondary)),
              const SizedBox(height: 6),
              TextField(
                controller: _confirmController,
                decoration: const InputDecoration(hintText: '••••••••'),
                style: ZussGoTheme.bodyMedium.copyWith(color: ZussGoTheme.textPrimary),
                obscureText: true,
                onSubmitted: (_) => _handleReset(),
              ),
              const SizedBox(height: 8),

              // Error
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(_errorMessage!, style: TextStyle(color: ZussGoTheme.rose, fontSize: 13)),
                ),

              const SizedBox(height: 24),

              GradientButton(text: 'Reset Password', isLoading: _isLoading, onPressed: _handleReset),
            ],
          ),
        ),
      ),
    );
  }
}