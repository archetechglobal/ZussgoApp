import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../widgets/gradient_button.dart';
import '../../services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({
    super.key,
    required this.email,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

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
      newPassword: password,
    );

    setState(() => _isLoading = false);

    if (result["success"] == true && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          backgroundColor: ZussGoTheme.bgSecondary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('✅', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text('Password Reset!', style: ZussGoTheme.displaySmall),
              const SizedBox(height: 8),
              Text('Your password has been updated. You can now sign in with your new password.', style: ZussGoTheme.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              GradientButton(text: 'Sign In', onPressed: () { Navigator.pop(context); context.go('/login'); }),
            ]),
          ),
        ),
      );
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
              GestureDetector(
                onTap: () => context.pop(),
                child: const Icon(Icons.arrow_back_rounded, color: ZussGoTheme.textSecondary),
              ),
              const SizedBox(height: 24),

              Text('ALMOST THERE', style: ZussGoTheme.bodySmall.copyWith(color: ZussGoTheme.amber, fontWeight: FontWeight.w600, letterSpacing: 2)),
              const SizedBox(height: 8),
              Text('Set Your New\nPassword', style: ZussGoTheme.displayLarge.copyWith(fontSize: 28)),
              const SizedBox(height: 8),
              Text('Choose a strong password you haven\'t used before.', style: ZussGoTheme.bodySmall),
              const SizedBox(height: 12),

              // Email indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: ZussGoTheme.mint.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ZussGoTheme.mint.withValues(alpha: 0.1)),
                ),
                child: Row(children: [
                  Icon(Icons.check_circle_rounded, color: ZussGoTheme.mint, size: 18),
                  const SizedBox(width: 8),
                  Text('Verified: ', style: TextStyle(fontSize: 12, color: ZussGoTheme.mint, fontWeight: FontWeight.w600)),
                  Text(widget.email, style: TextStyle(fontSize: 12, color: ZussGoTheme.textSecondary)),
                ]),
              ),
              const SizedBox(height: 28),

              // New Password
              Text('New Password', style: ZussGoTheme.bodySmall.copyWith(fontWeight: FontWeight.w600, color: ZussGoTheme.textSecondary)),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                    child: Icon(_obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: ZussGoTheme.textMuted, size: 20),
                  ),
                ),
                style: ZussGoTheme.bodyMedium.copyWith(color: ZussGoTheme.textPrimary),
                obscureText: _obscurePassword,
              ),
              const SizedBox(height: 16),

              // Confirm Password
              Text('Confirm Password', style: ZussGoTheme.bodySmall.copyWith(fontWeight: FontWeight.w600, color: ZussGoTheme.textSecondary)),
              const SizedBox(height: 6),
              TextField(
                controller: _confirmController,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    child: Icon(_obscureConfirm ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: ZussGoTheme.textMuted, size: 20),
                  ),
                ),
                style: ZussGoTheme.bodyMedium.copyWith(color: ZussGoTheme.textPrimary),
                obscureText: _obscureConfirm,
                onSubmitted: (_) => _handleReset(),
              ),
              const SizedBox(height: 8),

              // Error
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(color: ZussGoTheme.rose.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: ZussGoTheme.rose.withValues(alpha: 0.15))),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(Icons.info_outline_rounded, color: ZussGoTheme.rose, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_errorMessage!, style: TextStyle(color: ZussGoTheme.rose, fontSize: 12, fontWeight: FontWeight.w500))),
                  ]),
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