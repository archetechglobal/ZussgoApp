import 'dart:ui';
import 'package:flutter/material.dart';
import '../config/theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final BoxDecoration? decoration;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            decoration: decoration ?? ZussGoTheme.glassCardDecoration(context),
            child: child,
          ),
        ),
      ),
    );
  }
}
