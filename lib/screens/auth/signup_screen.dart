import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../widgets/gradient_button.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

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
              TextFormField(decoration: const InputDecoration(hintText: 'Arjun Sharma')),
              const SizedBox(height: 16),

              _buildLabel('Email'),
              const SizedBox(height: 6),
              TextFormField(decoration: const InputDecoration(hintText: 'arjun@email.com'), keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),

              _buildLabel('Password'),
              const SizedBox(height: 6),
              TextFormField(decoration: const InputDecoration(hintText: '••••••••'), obscureText: true),
              const SizedBox(height: 24),

              GradientButton(text: 'Create Account', onPressed: () => context.go('/profile-setup')),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(child: Divider(color: ZussGoTheme.borderDefault)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or sign up with', style: ZussGoTheme.bodySmall.copyWith(fontSize: 11)),
                  ),
                  Expanded(child: Divider(color: ZussGoTheme.borderDefault)),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(child: _SocialButton(icon: Icons.g_mobiledata_rounded, label: 'Google')),
                  const SizedBox(width: 12),
                  Expanded(child: _SocialButton(icon: Icons.phone_rounded, label: 'Phone')),
                ],
              ),
              const SizedBox(height: 32),

              Center(
                child: GestureDetector(
                  onTap: () => context.go('/login'),
                  child: RichText(
                    text: TextSpan(
                      text: 'Already traveling? ',
                      style: ZussGoTheme.bodyMedium.copyWith(color: ZussGoTheme.textMuted),
                      children: [
                        TextSpan(text: 'Sign in', style: TextStyle(color: ZussGoTheme.amber, fontWeight: FontWeight.w600)),
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

  Widget _buildLabel(String text) {
    return Text(text, style: ZussGoTheme.bodySmall.copyWith(fontWeight: FontWeight.w600, color: ZussGoTheme.textSecondary));
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SocialButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: ZussGoTheme.bgSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ZussGoTheme.borderDefault),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: ZussGoTheme.textSecondary),
          const SizedBox(width: 8),
          Text(label, style: ZussGoTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
