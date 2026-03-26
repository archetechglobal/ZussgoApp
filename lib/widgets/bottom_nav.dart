import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/theme.dart';

class ZussGoBottomNav extends StatelessWidget {
  final int currentIndex;
  const ZussGoBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavIcon(icon: Icons.home_rounded, index: 0, currentIndex: currentIndex, onTap: () => context.go('/home')),
          _NavIcon(icon: Icons.explore_rounded, index: 1, currentIndex: currentIndex, onTap: () => context.go('/search')),
          _NavIcon(icon: Icons.people_rounded, index: 2, currentIndex: currentIndex, onTap: () => context.go('/matches')),
          _NavIcon(icon: Icons.luggage_rounded, index: 3, currentIndex: currentIndex, onTap: () => context.go('/trips')),
          _NavIcon(icon: Icons.person_rounded, index: 4, currentIndex: currentIndex, onTap: () => context.go('/settings')),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;
  const _NavIcon({required this.icon, required this.index, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 44, height: 44,
        decoration: isActive
            ? BoxDecoration(color: ZussGoTheme.green, shape: BoxShape.circle, boxShadow: [BoxShadow(color: ZussGoTheme.green.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 3))])
            : null,
        child: Icon(icon, size: 22, color: isActive ? Colors.white : ZussGoTheme.textMuted),
      ),
    );
  }
}