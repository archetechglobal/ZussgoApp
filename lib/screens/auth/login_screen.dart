import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../widgets/gradient_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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

              Text('Email', style: ZussGoTheme.bodySmall.copyWith(fontWeight: FontWeight.w600, color: ZussGoTheme.textSecondary)),
              const SizedBox(height: 6),
              TextFormField(decoration: const InputDecoration(hintText: 'arjun@email.com'), keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),

              Text('Password', style: ZussGoTheme.bodySmall.copyWith(fontWeight: FontWeight.w600, color: ZussGoTheme.textSecondary)),
              const SizedBox(height: 6),
              TextFormField(decoration: const InputDecoration(hintText: '••••••••'), obscureText: true),
              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerRight,
                child: Text('Forgot password?', style: TextStyle(fontSize: 13, color: ZussGoTheme.lavender)),
              ),
              const SizedBox(height: 24),

              GradientButton(text: 'Sign In', onPressed: () => context.go('/home')),
              const SizedBox(height: 32),

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
