import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../services/notification_service.dart';

class ZussGoBottomNav extends StatelessWidget {
  final int currentIndex;
  const ZussGoBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      margin: EdgeInsets.fromLTRB(18, 0, 18, 16 + bottomInset),
      decoration: BoxDecoration(
        color: ZussGoTheme.cardBg(context),
        borderRadius: BorderRadius.circular(28),
        border: Theme.of(context).brightness == Brightness.dark
            ? Border.all(color: ZussGoTheme.border(context), width: 1)
            : null,
        boxShadow: [
          if (Theme.of(context).brightness == Brightness.light)
            BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, 4))
        ],
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

// _NavIcon stays exactly the same — no changes needed
class _NavIcon extends StatelessWidget {
  final IconData icon;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;
  const _NavIcon({required this.icon, required this.index, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    
    // Watch unseen notifications flag for the matches tab
    bool hasUnseen = false;
    if (index == 2) {
      hasUnseen = context.watch<NotificationService>().hasUnseenNotifications;
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 44, height: 44,
        decoration: isActive
            ? BoxDecoration(color: context.colors.green, shape: BoxShape.circle, boxShadow: [BoxShadow(color: context.colors.green.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 3))])
            : null,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 22, color: isActive ? Colors.white : ZussGoTheme.mutedText(context)),
            if (index == 2 && hasUnseen)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.redAccent : context.colors.rose,
                    shape: BoxShape.circle,
                    border: Border.all(color: isActive ? context.colors.green : ZussGoTheme.cardBg(context), width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}