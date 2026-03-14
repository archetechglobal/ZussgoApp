import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/theme.dart';

class ZussGoBottomNav extends StatelessWidget {
  final int currentIndex;

  const ZussGoBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _NavItem(icon: Icons.home_rounded, label: 'Home', route: '/home'),
      _NavItem(icon: Icons.search_rounded, label: 'Explore', route: '/search'),
      _NavItem(icon: Icons.handshake_rounded, label: 'Matches', route: '/matches'),
      _NavItem(icon: Icons.flight_takeoff_rounded, label: 'Trips', route: '/trips'),
      _NavItem(icon: Icons.person_rounded, label: 'You', route: '/settings'),
    ];

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: ZussGoTheme.bgPrimary.withValues(alpha: 0.92),
            border: const Border(
              top: BorderSide(color: ZussGoTheme.borderDefault),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(tabs.length, (index) {
              final isActive = index == currentIndex;
              return GestureDetector(
                onTap: () => context.go(tabs[index].route),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 64,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        tabs[index].icon,
                        size: 24,
                        color: isActive ? ZussGoTheme.amber : ZussGoTheme.textMuted,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tabs[index].label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isActive ? ZussGoTheme.amber : ZussGoTheme.textMuted,
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(height: 4),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: ZussGoTheme.amber,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  _NavItem({required this.icon, required this.label, required this.route});
}
