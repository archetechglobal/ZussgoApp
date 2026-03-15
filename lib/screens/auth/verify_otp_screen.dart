import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../widgets/gradient_button.dart';
import '../../services/auth_service.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;
  final String type;
  final String? fullName;

  const VerifyOtpScreen({
    super.key,
    required this.email,
    required this.type,
    this.fullName,
  });

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  // 6 controllers for 6 OTP boxes
  final List<TextEditingController> _controllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
  List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  String? _errorMessage;
  int _resendSeconds = 60;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    for (var c in _controllers) { c.dispose(); }
    for (var f in _focusNodes) { f.dispose(); }
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendSeconds = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  String get _otp => _controllers.map((c) => c.text).join();

  Future<void> _handleVerify() async {
    final otp = _otp;

    if (otp.length != 6) {
      setState(() => _errorMessage = "Please enter the complete 6-digit code");
      return;
    }

    setState(() { _errorMessage = null; _isLoading = true; });

    final result = await AuthService.verifyOtp(
      email: widget.email,
      otp: otp,
      type: widget.type,
      fullName: widget.fullName,
    );

    setState(() => _isLoading = false);

    if (result["success"] == true) {
      if (widget.type == "signup") {
        // Save session and navigate to profile setup
        final data = result["data"];
        if (data != null && data["accessToken"] != null) {
          await AuthService.saveSession(
            accessToken: data["accessToken"],
            refreshToken: data["refreshToken"] ?? "",
            user: data["user"] ?? {},
          );
        }
        if (mounted) context.go('/profile-setup');
      } else {
        // Recovery verified — navigate to reset password screen
        if (mounted) {
          context.push('/reset-password', extra: {
            'email': widget.email,
            'otp': otp,
          });
        }
      }
    } else {
      setState(() => _errorMessage = result["message"]);
    }
  }

  Future<void> _handleResend() async {
    if (_resendSeconds > 0) return;

    final result = await AuthService.resendOtp(email: widget.email);

    if (result["success"] == true) {
      _startResendTimer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('New code sent to ${widget.email}'),
            backgroundColor: ZussGoTheme.mint.withValues(alpha: 0.8),
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
              // Back button
              GestureDetector(
                onTap: () => context.pop(),
                child: const Icon(Icons.arrow_back_rounded, color: ZussGoTheme.textSecondary),
              ),
              const SizedBox(height: 24),

              Text('VERIFY EMAIL', style: ZussGoTheme.bodySmall.copyWith(color: ZussGoTheme.amber, fontWeight: FontWeight.w600, letterSpacing: 2)),
              const SizedBox(height: 8),
              Text('Enter the\nCode', style: ZussGoTheme.displayLarge.copyWith(fontSize: 28)),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  text: 'We sent a 6-digit code to ',
                  style: ZussGoTheme.bodySmall,
                  children: [
                    TextSpan(text: widget.email, style: TextStyle(color: ZussGoTheme.amber, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // OTP input boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) {
                  return SizedBox(
                    width: 48,
                    height: 56,
                    child: TextField(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: ZussGoTheme.displaySmall.copyWith(fontSize: 20),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        counterText: "",
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: ZussGoTheme.amber.withValues(alpha: 0.5), width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && i < 5) {
                          // Auto-move to next box
                          _focusNodes[i + 1].requestFocus();
                        }
                        if (value.isEmpty && i > 0) {
                          // Auto-move back on delete
                          _focusNodes[i - 1].requestFocus();
                        }
                        // Auto-submit when all 6 digits entered
                        if (_otp.length == 6) {
                          _handleVerify();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Error message
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(_errorMessage!, style: TextStyle(color: ZussGoTheme.rose, fontSize: 13)),
                ),

              const SizedBox(height: 24),

              GradientButton(text: 'Verify', isLoading: _isLoading, onPressed: _handleVerify),
              const SizedBox(height: 24),

              // Resend
              Center(
                child: GestureDetector(
                  onTap: _resendSeconds == 0 ? _handleResend : null,
                  child: RichText(
                    text: TextSpan(
                      text: "Didn't receive a code? ",
                      style: ZussGoTheme.bodySmall,
                      children: [
                        TextSpan(
                          text: _resendSeconds > 0
                              ? 'Resend in ${_resendSeconds}s'
                              : 'Resend code',
                          style: TextStyle(
                            color: _resendSeconds > 0 ? ZussGoTheme.textMuted : ZussGoTheme.amber,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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