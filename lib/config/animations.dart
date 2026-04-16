import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// ZussGo motion language.
/// Usage: `MyWidget().zussEntrance(index: 2)`
extension ZussAnimations on Widget {
  /// Cards/sections — fade + slide up, staggered by index
  Widget zussEntrance({int index = 0, int baseDelay = 0}) => animate()
      .fadeIn(duration: 400.ms, delay: Duration(milliseconds: baseDelay + (index * 80)), curve: Curves.easeOut)
      .slideY(begin: 0.06, end: 0, duration: 400.ms, delay: Duration(milliseconds: baseDelay + (index * 80)), curve: Curves.easeOut);

  /// Hero content — fade + slide + scale
  Widget zussHero({int delay = 100}) => animate()
      .fadeIn(duration: 500.ms, delay: Duration(milliseconds: delay), curve: Curves.easeOut)
      .slideY(begin: 0.08, end: 0, duration: 500.ms, delay: Duration(milliseconds: delay), curve: Curves.easeOut)
      .scaleXY(begin: 0.97, end: 1.0, duration: 500.ms, delay: Duration(milliseconds: delay), curve: Curves.easeOut);

  /// Horizontal list items — fade + slide from right
  Widget zussCascade({int index = 0}) => animate()
      .fadeIn(duration: 350.ms, delay: Duration(milliseconds: 100 + (index * 60)), curve: Curves.easeOut)
      .slideX(begin: 0.08, end: 0, duration: 350.ms, delay: Duration(milliseconds: 100 + (index * 60)), curve: Curves.easeOut);

  /// Badges/scores — elastic scale pop
  Widget zussPop({int delay = 200}) => animate()
      .fadeIn(duration: 300.ms, delay: Duration(milliseconds: delay))
      .scaleXY(begin: 0.7, end: 1.0, duration: 400.ms, delay: Duration(milliseconds: delay), curve: Curves.elasticOut);

  /// Loading shimmer (loops)
  Widget zussShimmer() => animate(onPlay: (c) => c.repeat())
      .shimmer(duration: 1200.ms, color: const Color(0x15FFFFFF));
}