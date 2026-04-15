import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const GradientButton({super.key, required this.text, required this.onPressed, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: c.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: const Color(0x40FF6B4A), blurRadius: 20, offset: const Offset(0, 4))],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(text, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
        ),
      ),
    );
  }
}