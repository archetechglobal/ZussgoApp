import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../widgets/gradient_button.dart';
import '../../services/auth_service.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email, type;
  final String? fullName;
  const VerifyOtpScreen({super.key, required this.email, required this.type, this.fullName});
  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final List<TextEditingController> _c = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _f = List.generate(6, (_) => FocusNode());
  bool _loading = false; String? _error; int _resend = 60; Timer? _timer;

  @override
  void initState() { super.initState(); _startTimer(); }
  @override
  void dispose() { for (var c in _c) c.dispose(); for (var f in _f) f.dispose(); _timer?.cancel(); super.dispose(); }

  void _startTimer() { _resend = 60; _timer?.cancel(); _timer = Timer.periodic(const Duration(seconds: 1), (t) { if (_resend > 0) setState(() => _resend--); else t.cancel(); }); }
  String get _otp => _c.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_otp.length != 6) { setState(() => _error = "Enter complete 6-digit code"); return; }
    setState(() { _error = null; _loading = true; });
    final r = await AuthService.verifyOtp(email: widget.email, otp: _otp, type: widget.type, fullName: widget.fullName);
    setState(() => _loading = false);
    if (r["success"] == true) {
      if (widget.type == "signup") {
        final d = r["data"]; if (d?["accessToken"] != null) await AuthService.saveSession(accessToken: d["accessToken"], refreshToken: d["refreshToken"] ?? "", user: d["user"] ?? {});
        if (mounted) context.go('/profile-setup');
      } else { if (mounted) context.push('/reset-password', extra: {'email': widget.email}); }
    } else { setState(() => _error = r["message"]); }
  }

  Future<void> _resendOtp() async {
    if (_resend > 0) return;
    final r = await AuthService.resendOtp(email: widget.email);
    if (r["success"] == true) { _startTimer(); if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Code sent to ${widget.email}'), backgroundColor: ZussGoTheme.green)); }
    else { setState(() => _error = r["message"]); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: ZussGoTheme.bgPrimary, body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GestureDetector(onTap: () => context.pop(), child: Container(width: 38, height: 38, decoration: BoxDecoration(color: ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.arrow_back_rounded, color: ZussGoTheme.textSecondary, size: 18))),
      const SizedBox(height: 20),
      Text('VERIFY EMAIL', style: TextStyle(fontSize: 11, color: ZussGoTheme.green, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
      const SizedBox(height: 6),
      Text('Enter the\nCode', style: ZussGoTheme.displayLarge.copyWith(fontSize: 28)),
      const SizedBox(height: 6),
      RichText(text: TextSpan(text: 'Sent to ', style: ZussGoTheme.bodyMedium, children: [TextSpan(text: widget.email, style: TextStyle(color: ZussGoTheme.green, fontWeight: FontWeight.w600))])),
      const SizedBox(height: 28),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: List.generate(6, (i) => SizedBox(width: 46, height: 54, child: TextField(
        controller: _c[i], focusNode: _f[i], textAlign: TextAlign.center, keyboardType: TextInputType.number, maxLength: 1,
        style: ZussGoTheme.displaySmall.copyWith(fontSize: 20, color: ZussGoTheme.textPrimary),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(counterText: "", contentPadding: const EdgeInsets.symmetric(vertical: 14), filled: true, fillColor: ZussGoTheme.bgMuted,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: ZussGoTheme.green.withValues(alpha: 0.5), width: 1.5))),
        onChanged: (v) { if (v.isNotEmpty && i < 5) _f[i + 1].requestFocus(); if (v.isEmpty && i > 0) _f[i - 1].requestFocus(); if (_otp.length == 6) _verify(); },
      )))),
      if (_error != null) Container(width: double.infinity, padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(top: 14),
          decoration: BoxDecoration(color: ZussGoTheme.rose.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12)),
          child: Row(children: [Icon(Icons.info_outline_rounded, color: ZussGoTheme.rose, size: 16), const SizedBox(width: 6), Expanded(child: Text(_error!, style: TextStyle(color: ZussGoTheme.rose, fontSize: 11)))])),
      const SizedBox(height: 24),
      GradientButton(text: 'Verify', isLoading: _loading, onPressed: _verify),
      const SizedBox(height: 18),
      Center(child: GestureDetector(onTap: _resend == 0 ? _resendOtp : null, child: RichText(text: TextSpan(text: "Didn't receive? ", style: ZussGoTheme.bodySmall,
          children: [TextSpan(text: _resend > 0 ? 'Resend in ${_resend}s' : 'Resend code', style: TextStyle(color: _resend > 0 ? ZussGoTheme.textMuted : ZussGoTheme.green, fontWeight: FontWeight.w600))])))),
    ]))));
  }
}