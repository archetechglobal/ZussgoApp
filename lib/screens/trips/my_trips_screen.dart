import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/gradient_button.dart';

class MyTripsScreen extends StatelessWidget {
  const MyTripsScreen({super.key});

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
                  Text('Your Journeys', style: ZussGoTheme.displayMedium),
                  const SizedBox(height: 20),

                  Text('COMING UP', style: TextStyle(fontSize: 11, color: ZussGoTheme.textMuted, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
                  const SizedBox(height: 10),

                  // Upcoming trip card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [ZussGoTheme.amber.withValues(alpha: 0.06), ZussGoTheme.rose.withValues(alpha: 0.06)]),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: ZussGoTheme.amber.withValues(alpha: 0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('🏖️ Goa', style: ZussGoTheme.labelBold.copyWith(fontSize: 17)),
                              Text('Dec 20 - 25, 2026', style: ZussGoTheme.bodySmall),
                            ]),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(color: ZussGoTheme.mint.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                              child: Text('5 days', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: ZussGoTheme.mint)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Traveler avatars
                        SizedBox(
                          height: 32,
                          child: Stack(
                            children: [
                              _MonogramCircle(letter: 'P', offset: 0, color: const Color(0xFFF43F5E)),
                              _MonogramCircle(letter: 'K', offset: 22, color: const Color(0xFF38BDF8)),
                              Positioned(
                                left: 44,
                                child: Container(
                                  width: 32, height: 32,
                                  decoration: BoxDecoration(color: ZussGoTheme.bgCard, shape: BoxShape.circle, border: Border.all(color: ZussGoTheme.bgPrimary, width: 2)),
                                  alignment: Alignment.center,
                                  child: Text('+2', style: TextStyle(fontSize: 10, color: ZussGoTheme.textMuted)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text('MEMORIES', style: TextStyle(fontSize: 11, color: ZussGoTheme.textMuted, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
                  const SizedBox(height: 10),

                  Opacity(
                    opacity: 0.5,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: ZussGoTheme.glassCard,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('🏔️ Manali', style: ZussGoTheme.labelBold),
                        Text('Oct 10 - 15, 2026 · 3 travelers', style: ZussGoTheme.bodySmall),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 24),

                  GradientButton(text: '+ Plan a New Escape', onPressed: () => context.go('/search')),
                ],
              ),
            ),
            const Positioned(bottom: 0, left: 0, right: 0, child: ZussGoBottomNav(currentIndex: 3)),
          ],
        ),
      ),
    );
  }
}

class _MonogramCircle extends StatelessWidget {
  final String letter;
  final double offset;
  final Color color;
  const _MonogramCircle({required this.letter, required this.offset, required this.color});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: offset,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(color: ZussGoTheme.bgPrimary, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(letter, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color, fontFamily: 'Playfair Display')),
      ),
    );
  }
}
