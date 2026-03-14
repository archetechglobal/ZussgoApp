import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../widgets/traveler_card.dart';

class DestinationDetailScreen extends StatelessWidget {
  final String destinationId;
  const DestinationDetailScreen({super.key, required this.destinationId});

  String get _name => destinationId[0].toUpperCase() + destinationId.substring(1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero
            Container(
              height: 220,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFF43F5E)]),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0x99000000)], stops: [0.3, 1.0]),
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
                    ),
                  ),
                  Positioned(
                    top: 50, left: 20,
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20, left: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🏖️ $_name', style: ZussGoTheme.displayLarge.copyWith(fontSize: 28)),
                        Text('Beaches, sunsets & good vibes', style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.65), fontWeight: FontWeight.w300)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date + match count
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(color: ZussGoTheme.bgSecondary, borderRadius: BorderRadius.circular(16), border: Border.all(color: ZussGoTheme.borderDefault)),
                          child: Column(
                            children: [
                              Text('YOUR DATES', style: TextStyle(fontSize: 10, color: ZussGoTheme.textMuted, fontWeight: FontWeight.w600, letterSpacing: 1)),
                              const SizedBox(height: 2),
                              Text('Dec 20 - 25', style: ZussGoTheme.labelBold.copyWith(color: ZussGoTheme.amber, fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        decoration: BoxDecoration(
                          color: ZussGoTheme.mint.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: ZussGoTheme.mint.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          children: [
                            Container(width: 6, height: 6, decoration: const BoxDecoration(color: ZussGoTheme.mint, shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Text('12 matches', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: ZussGoTheme.mint)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Text('Travelers on your dates', style: ZussGoTheme.displaySmall),
                  const SizedBox(height: 14),

                  const TravelerCard(id: '1', name: 'Priya', age: 24, destination: 'Goa', dates: 'Dec 20-25', travelStyle: 'Explorer', avatar: '🧡', matchPercent: '91%', accentColor: Color(0xFFF43F5E)),
                  const TravelerCard(id: '2', name: 'Karan', age: 26, destination: 'Goa', dates: 'Dec 21-26', travelStyle: 'Wanderer', avatar: '💙', matchPercent: '85%', accentColor: Color(0xFF38BDF8)),
                  const TravelerCard(id: '3', name: 'Meera', age: 25, destination: 'Goa', dates: 'Dec 22-28', travelStyle: 'Luxe', avatar: '💚', matchPercent: '78%', accentColor: Color(0xFF22C55E)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
