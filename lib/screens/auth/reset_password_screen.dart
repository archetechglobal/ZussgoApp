import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../widgets/gradient_button.dart';
import '../../services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passC = TextEditingController(), _confC = TextEditingController();
  bool _loading = false, _ob1 = true, _ob2 = true; String? _error;

  @override
  void dispose() { _passC.dispose(); _confC.dispose(); super.dispose(); }

  Future<void> _reset() async {
    if (_passC.text.isEmpty || _confC.text.isEmpty) { setState(() => _error = "Fill in both fields"); return; }
    if (_passC.text.length < 8) { setState(() => _error = "At least 8 characters"); return; }
    if (_passC.text != _confC.text) { setState(() => _error = "Passwords don't match"); return; }
    setState(() { _error = null; _loading = true; });
    final r = await AuthService.resetPassword(email: widget.email, newPassword: _passC.text);
    setState(() => _loading = false);
    if (r["success"] == true && mounted) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)
              ),
          child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                      const Text('✅', style: TextStyle(fontSize: 42)), const SizedBox(height: 10), Text('Password Reset!', style: ZussGoTheme.displaySmall), const SizedBox(height: 6),
                      Text('You can now sign in.', style: ZussGoTheme.bodyMedium, textAlign: TextAlign.center), const SizedBox(height: 18),
                      GradientButton(text: 'Sign In', onPressed: () { Navigator.pop(context); context.go('/login'); }),
          ]))));
    } else setState(() => _error = r["message"]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: ZussGoTheme.bgPrimary, body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GestureDetector(onTap: () => context.pop(), child: Container(width: 38, height: 38, decoration: BoxDecoration(color: ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.arrow_back_rounded, color: ZussGoTheme.textSecondary, size: 18))),
      const SizedBox(height: 20),
      Text('ALMOST THERE', style: TextStyle(fontSize: 11, color: ZussGoTheme.green, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
      const SizedBox(height: 6),
      Text('Set Your New\nPassword', style: ZussGoTheme.displayLarge.copyWith(fontSize: 28)),
      const SizedBox(height: 10),
      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: ZussGoTheme.greenLight, borderRadius: BorderRadius.circular(10)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.check_circle_rounded, color: ZussGoTheme.green, size: 16), const SizedBox(width: 6),
            Text('Verified: ', style: TextStyle(fontSize: 11, color: ZussGoTheme.green, fontWeight: FontWeight.w600)), Text(widget.email, style: TextStyle(fontSize: 11, color: ZussGoTheme.textSecondary))])),
      const SizedBox(height: 24),
      Text('New Password', style: ZussGoTheme.labelBold.copyWith(color: ZussGoTheme.textSecondary, fontSize: 13)),
      const SizedBox(height: 8),
      TextField(controller: _passC, obscureText: _ob1, style: ZussGoTheme.bodyMedium.copyWith(color: ZussGoTheme.textPrimary),
          decoration: ZussGoTheme.inputDecoration(hint: '••••••••', prefix: Icon(Icons.lock_outline_rounded, color: ZussGoTheme.textMuted, size: 20),
              suffix: GestureDetector(onTap: () => setState(() => _ob1 = !_ob1), child: Icon(_ob1 ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: ZussGoTheme.textMuted, size: 20)))),
      const SizedBox(height: 16),
      Text('Confirm Password', style: ZussGoTheme.labelBold.copyWith(color: ZussGoTheme.textSecondary, fontSize: 13)),
      const SizedBox(height: 8),
      TextField(controller: _confC, obscureText: _ob2, style: ZussGoTheme.bodyMedium.copyWith(color: ZussGoTheme.textPrimary), onSubmitted: (_) => _reset(),
          decoration: ZussGoTheme.inputDecoration(hint: '••••••••', prefix: Icon(Icons.lock_outline_rounded, color: ZussGoTheme.textMuted, size: 20),
              suffix: GestureDetector(onTap: () => setState(() => _ob2 = !_ob2), child: Icon(_ob2 ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: ZussGoTheme.textMuted, size: 20)))),
      if (_error != null) Container(width: double.infinity, padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(color: ZussGoTheme.rose.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12)),
          child: Row(children: [Icon(Icons.info_outline_rounded, color: ZussGoTheme.rose, size: 16), const SizedBox(width: 6), Expanded(child: Text(_error!, style: TextStyle(color: ZussGoTheme.rose, fontSize: 11)))])),
      const SizedBox(height: 24),
      GradientButton(text: 'Reset Password', isLoading: _loading, onPressed: _reset),
    ]))));
  }
}