import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/destination_card.dart';
import '../../widgets/traveler_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Good evening', style: ZussGoTheme.bodySmall.copyWith(fontWeight: FontWeight.w300)),
                            Text('Arjun ✨', style: ZussGoTheme.displayMedium),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => context.push('/settings'),
                          child: Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              gradient: ZussGoTheme.gradientPrimary,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: Text('A', style: ZussGoTheme.labelBold.copyWith(fontSize: 16, fontFamily: 'Playfair Display')),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: GestureDetector(
                      onTap: () => context.push('/search'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                        decoration: BoxDecoration(
                          color: ZussGoTheme.bgSecondary,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: ZussGoTheme.borderDefault),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search_rounded, color: ZussGoTheme.textMuted.withValues(alpha: 0.5), size: 20),
                            const SizedBox(width: 10),
                            Text("Where's your next escape?", style: ZussGoTheme.bodyMedium.copyWith(color: ZussGoTheme.textMuted, fontWeight: FontWeight.w300)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Trending
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Trending Escapes', style: ZussGoTheme.displaySmall),
                        Text('View all', style: TextStyle(fontSize: 13, color: ZussGoTheme.amber, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  SizedBox(
                    height: 195,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: const [
                        DestinationCard(id: 'goa', name: 'Goa', emoji: '🏖️', travelerCount: 47, gradient: LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFF43F5E)])),
                        SizedBox(width: 12),
                        DestinationCard(id: 'manali', name: 'Manali', emoji: '🏔️', travelerCount: 31, gradient: LinearGradient(colors: [Color(0xFF38BDF8), Color(0xFFA78BFA)])),
                        SizedBox(width: 12),
                        DestinationCard(id: 'ladakh', name: 'Ladakh', emoji: '🏍️', travelerCount: 29, gradient: LinearGradient(colors: [Color(0xFFF43F5E), Color(0xFFF59E0B)])),
                        SizedBox(width: 12),
                        DestinationCard(id: 'rishikesh', name: 'Rishikesh', emoji: '🧘', travelerCount: 22, gradient: LinearGradient(colors: [Color(0xFF22C55E), Color(0xFF38BDF8)])),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Matches
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('People Heading Out', style: ZussGoTheme.displaySmall),
                        const SizedBox(height: 4),
                        Text('Matched to your interests & dates', style: ZussGoTheme.bodySmall),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: const [
                        TravelerCard(id: '1', name: 'Priya', age: 24, destination: 'Goa', dates: 'Dec 20-25', travelStyle: 'Explorer', avatar: '🧡', matchPercent: '91%', accentColor: Color(0xFFF43F5E)),
                        TravelerCard(id: '2', name: 'Rohan', age: 22, destination: 'Manali', dates: 'Jan 5-10', travelStyle: 'Wanderer', avatar: '💜', matchPercent: '85%', accentColor: Color(0xFF38BDF8)),
                        TravelerCard(id: '3', name: 'Meera', age: 25, destination: 'Goa', dates: 'Dec 22-28', travelStyle: 'Luxe', avatar: '💚', matchPercent: '78%', accentColor: Color(0xFF22C55E)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Positioned(
              bottom: 0, left: 0, right: 0,
              child: ZussGoBottomNav(currentIndex: 0),
            ),
          ],
        ),
      ),
    );
  }
}
