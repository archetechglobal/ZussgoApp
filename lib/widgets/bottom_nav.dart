import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../services/notification_service.dart';

class ZussGoBottomNav extends StatelessWidget {
  final int currentIndex;
  const ZussGoBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      margin: EdgeInsets.fromLTRB(16, 0, 16, 8 + bottomInset),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.border, width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 32, offset: const Offset(0, -8))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(emoji: '🏠', label: 'Home', index: 0, currentIndex: currentIndex, onTap: () => context.go('/home')),
          _NavItem(emoji: '🗺️', label: 'Discover', index: 1, currentIndex: currentIndex, onTap: () => context.go('/search')),
          _NavItem(emoji: '⭐', label: 'Rewards', index: 2, currentIndex: currentIndex, onTap: () => context.go('/matches')),
          _NavItem(emoji: '💬', label: 'Chats', index: 3, currentIndex: currentIndex, hasBadge: true, onTap: () => context.go('/chats')),
          _NavItem(emoji: '👤', label: 'Profile', index: 4, currentIndex: currentIndex, onTap: () => context.go('/settings')),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String emoji;
  final String label;
  final int index;
  final int currentIndex;
  final bool hasBadge;
  final VoidCallback onTap;

  const _NavItem({
    required this.emoji,
    required this.label,
    required this.index,
    required this.currentIndex,
    this.hasBadge = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    final c = context.colors;

    bool hasUnseen = false;
    if (hasBadge && index == 3) {
      hasUnseen = context.watch<NotificationService>().hasUnseenNotifications;
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? c.primarySoft : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Text(emoji, style: TextStyle(fontSize: 19, color: isActive ? null : Colors.white.withValues(alpha: 0.35))),
                if (hasBadge && hasUnseen)
                  Positioned(
                    top: -2, right: -4,
                    child: Container(
                      width: 7, height: 7,
                      decoration: BoxDecoration(
                        color: c.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: c.card, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: isActive ? c.primary : c.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}