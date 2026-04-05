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
  final _emailC = TextEditingController();
  bool _loading = false; String? _error;

  @override
  void dispose() { _emailC.dispose(); super.dispose(); }

  Future<void> _send() async {
    if (_emailC.text.trim().isEmpty) { setState(() => _error = "Please enter your email"); return; }
    setState(() { _error = null; _loading = true; });
    final r = await AuthService.forgotPassword(email: _emailC.text.trim());
    setState(() => _loading = false);
    if (r["success"] == true && mounted) context.push('/verify-otp', extra: {'email': _emailC.text.trim(), 'type': 'recovery'});
    else setState(() => _error = r["message"]);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.canPop()) context.pop();
        else context.go('/login');
      },
      child: Scaffold(backgroundColor: ZussGoTheme.scaffoldBg(context), body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
            onTap: () => context.canPop() ? context.pop() : context.go('/login'),
            child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    color: ZussGoTheme.mutedBg(context),
                    borderRadius: BorderRadius.circular(12)
                ),
                child: Icon(
                    Icons.arrow_back_rounded,
                    color: ZussGoTheme.secondaryText(context),
                    size: 18
                )
            )
        ),
      const SizedBox(height: 20),
      Text('RESET PASSWORD',
          style: TextStyle(
              fontSize: 11,
              color: context.colors.green,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5)
      ),
      const SizedBox(height: 6),
      Text('Forgot Your\nPassword?',
          style: context.textTheme.displayLarge!.copyWith(fontSize: 28)
      ),
      const SizedBox(height: 6),
      Text("Enter your email and we'll send a 6-digit code.",
          style: context.textTheme.bodyMedium!
      ),
      const SizedBox(height: 28),
      Text('Email',
          style: context.textTheme.labelLarge!.copyWith(
              color: ZussGoTheme.secondaryText(context),
              fontSize: 13)
      ),
      const SizedBox(height: 8),
      TextField(
          controller: _emailC,
          decoration: ZussGoTheme.inputDecorationOf(context, 
              hint: 'arjun@email.com',
              prefix: Icon(
                  Icons.mail_outline_rounded,
                  color: ZussGoTheme.mutedText(context),
                  size: 20)
          ),
          style: context.textTheme.bodyMedium!.copyWith(color: ZussGoTheme.primaryText(context)),
          keyboardType: TextInputType.emailAddress,
          onSubmitted: (_) => _send()),
      if (_error != null) Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(_error!,
              style: TextStyle(
                  color: context.colors.rose,
                  fontSize: 12)
          )
      ),
      const SizedBox(height: 24),
      GradientButton(
          text: 'Send Reset Code',
          isLoading: _loading,
          onPressed: _send
      ),
      const SizedBox(height: 20),
      Center(
          child: GestureDetector(
              onTap: () => context.canPop() ? context.pop() : context.go('/login'),
              child: Text('Back to Sign In',
                  style: TextStyle(
                      fontSize: 13,
                      color: context.colors.green,
                      fontWeight: FontWeight.w600)
              )
          )
      ),
    ]
    )
    )
    )
    ));
  }
}