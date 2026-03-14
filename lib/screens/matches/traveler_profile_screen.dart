import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../widgets/gradient_button.dart';

class TravelerProfileScreen extends StatelessWidget {
  final String travelerId;
  const TravelerProfileScreen({super.key, required this.travelerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: const Icon(Icons.arrow_back_rounded, color: ZussGoTheme.textSecondary),
              ),
              const SizedBox(height: 16),

              // Avatar + name
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 96, height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF43F5E).withValues(alpha: 0.06),
                        border: Border.all(color: const Color(0xFFF43F5E).withValues(alpha: 0.2), width: 2.5),
                      ),
                      alignment: Alignment.center,
                      child: Text('P', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, fontFamily: 'Playfair Display', color: const Color(0xFFF43F5E))),
                    ),
                    const SizedBox(height: 12),
                    Text('Priya, 24', style: ZussGoTheme.displayMedium),
                    const SizedBox(height: 4),
                    Text('Mumbai • Explorer', style: ZussGoTheme.bodySmall),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _Badge(text: '91% match', color: ZussGoTheme.amber),
                        const SizedBox(width: 8),
                        _Badge(text: '✓ Verified', color: ZussGoTheme.mint),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Trip info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: ZussGoTheme.bgSecondary, borderRadius: BorderRadius.circular(18), border: Border.all(color: ZussGoTheme.borderDefault)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('NEXT TRIP', style: TextStyle(fontSize: 10, color: ZussGoTheme.textMuted, fontWeight: FontWeight.w600, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('🏖️ Goa', style: ZussGoTheme.labelBold.copyWith(fontSize: 16)),
                          Text('Dec 20 - 25, 2026', style: ZussGoTheme.bodySmall),
                        ]),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text('Explorer', style: TextStyle(fontSize: 13, color: ZussGoTheme.amber, fontWeight: FontWeight.w600)),
                          Text('Budget-friendly', style: ZussGoTheme.bodySmall),
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // About
              Text('ABOUT', style: TextStyle(fontSize: 10, color: ZussGoTheme.textMuted, fontWeight: FontWeight.w600, letterSpacing: 1)),
              const SizedBox(height: 6),
              Text(
                'Sunsets, scooters & seafood. First solo trip and looking for chill people to explore North Goa with. Into water sports, beach hopping and trying local food!',
                style: ZussGoTheme.bodyLarge.copyWith(fontSize: 14, fontWeight: FontWeight.w300),
              ),
              const SizedBox(height: 20),

              // Interests
              Text('VIBES', style: TextStyle(fontSize: 10, color: ZussGoTheme.textMuted, fontWeight: FontWeight.w600, letterSpacing: 1)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6, runSpacing: 6,
                children: ['Sunsets', 'Photography', 'Street Food', 'Beaches', 'Nightlife'].map((i) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(color: ZussGoTheme.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: ZussGoTheme.borderDefault)),
                    child: Text(i, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ZussGoTheme.textSecondary)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: ZussGoTheme.borderDefault),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text('Pass', style: ZussGoTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: GradientButton(
                      text: "Let's Go Together 🤝",
                      onPressed: () {
                        showDialog(context: context, builder: (_) => _MatchSentDialog(onDone: () { Navigator.pop(context); context.pop(); }));
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _MatchSentDialog extends StatelessWidget {
  final VoidCallback onDone;
  const _MatchSentDialog({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ZussGoTheme.bgSecondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌟', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text('Request Sent!', style: ZussGoTheme.displaySmall),
            const SizedBox(height: 8),
            Text("We've let Priya know you're interested", style: ZussGoTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text("You'll hear back soon ✨", style: ZussGoTheme.bodySmall),
            const SizedBox(height: 24),
            GradientButton(text: 'Done', onPressed: onDone),
          ],
        ),
      ),
    );
  }
}
