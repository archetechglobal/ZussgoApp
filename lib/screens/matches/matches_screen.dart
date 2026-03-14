import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../widgets/bottom_nav.dart';

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Connections', style: ZussGoTheme.displayMedium),
                  const SizedBox(height: 20),

                  _sectionLabel('PENDING'),
                  const SizedBox(height: 10),
                  _MatchTile(name: 'Priya', dest: 'Goa', avatar: 'P', color: const Color(0xFFF43F5E), status: 'Awaiting', statusColor: ZussGoTheme.amber, onTap: () => context.push('/traveler/1')),
                  const SizedBox(height: 20),

                  _sectionLabel('CONNECTED'),
                  const SizedBox(height: 10),
                  _MatchTile(name: 'Rohan', dest: 'Manali', avatar: 'R', color: const Color(0xFF38BDF8), status: 'Message →', statusColor: ZussGoTheme.mint, onTap: () => context.push('/chat/rohan')),
                  _MatchTile(name: 'Ananya', dest: 'Rishikesh', avatar: 'A', color: const Color(0xFFA78BFA), status: 'Message →', statusColor: ZussGoTheme.mint, onTap: () => context.push('/chat/ananya')),
                ],
              ),
            ),
            const Positioned(bottom: 0, left: 0, right: 0, child: ZussGoBottomNav(currentIndex: 2)),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text, style: TextStyle(fontSize: 11, color: ZussGoTheme.textMuted, fontWeight: FontWeight.w600, letterSpacing: 1.5));
  }
}

class _MatchTile extends StatelessWidget {
  final String name, dest, avatar, status;
  final Color color, statusColor;
  final VoidCallback onTap;

  const _MatchTile({required this.name, required this.dest, required this.avatar, required this.color, required this.status, required this.statusColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: ZussGoTheme.glassCard,
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withValues(alpha: 0.15)),
              ),
              alignment: Alignment.center,
              child: Text(avatar, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color, fontFamily: 'Playfair Display')),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: ZussGoTheme.labelBold),
                  Text(dest, style: ZussGoTheme.bodySmall),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
            ),
          ],
        ),
      ),
    );
  }
}
