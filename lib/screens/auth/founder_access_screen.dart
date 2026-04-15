import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';

class FounderAccessScreen extends StatefulWidget {
  const FounderAccessScreen({super.key});
  @override
  State<FounderAccessScreen> createState() => _FounderAccessScreenState();
}

class _FounderAccessScreenState extends State<FounderAccessScreen> with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _perksController;
  late Animation<double> _iconScale;
  late Animation<double> _iconRotation;

  static const _perks = [
    _PerkData('🚀', 'Nomad Pro — 90 days free', 'FREE'),
    _PerkData('⭐', 'Trek Points signup bonus', '+500 TP'),
    _PerkData('🤝', 'Unlimited companion matches', '∞'),
    _PerkData('🛡️', 'SOS+ Emergency alerts', 'Active'),
  ];

  @override
  void initState() {
    super.initState();

    // Pop-in animation for 🎉
    _iconController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _iconScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.1), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _iconController, curve: Curves.easeOut));
    _iconRotation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: -0.26, end: 0.05), weight: 60), // -15deg to 3deg
      TweenSequenceItem(tween: Tween(begin: 0.05, end: 0.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _iconController, curve: Curves.easeOut));

    // Staggered fade for perk rows
    _perksController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

    Future.delayed(const Duration(milliseconds: 200), () {
      _iconController.forward();
      Future.delayed(const Duration(milliseconds: 300), () => _perksController.forward());
    });
  }

  @override
  void dispose() {
    _iconController.dispose();
    _perksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.2),
            radius: 1.2,
            colors: [const Color(0x0CFF6B4A), Colors.transparent],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // 🎉 Pop-in icon
                AnimatedBuilder(
                  animation: _iconController,
                  builder: (_, __) {
                    return Transform.scale(
                      scale: _iconScale.value,
                      child: Transform.rotate(
                        angle: _iconRotation.value,
                        child: const Text('🎉', style: TextStyle(fontSize: 72)),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Title
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.outfit(fontSize: 30, fontWeight: FontWeight.w900, color: c.text, height: 1.2),
                    children: [
                      const TextSpan(text: "You're all set,\n"),
                      TextSpan(text: "let's explore!", style: TextStyle(color: c.primary)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Your ZussGo profile is ready.',
                  style: GoogleFonts.plusJakartaSans(fontSize: 14, color: c.textSecondary, height: 1.7),
                ),
                const SizedBox(height: 28),

                // Perk rows with staggered animation
                ...List.generate(_perks.length, (i) {
                  final perk = _perks[i];
                  final delay = i * 0.2; // 0.0, 0.2, 0.4, 0.6
                  return AnimatedBuilder(
                    animation: _perksController,
                    builder: (_, __) {
                      final progress = ((_perksController.value - delay) / 0.3).clamp(0.0, 1.0);
                      return Transform.translate(
                        offset: Offset(0, 12 * (1 - progress)),
                        child: Opacity(
                          opacity: progress,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: c.card,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: c.border),
                            ),
                            child: Row(
                              children: [
                                Text(perk.emoji, style: const TextStyle(fontSize: 22)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    perk.label,
                                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: c.text),
                                  ),
                                ),
                                Text(
                                  perk.value,
                                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: c.primary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),

                const SizedBox(height: 28),

                // Open ZussGo button
                GestureDetector(
                  onTap: () => context.go('/home'),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: c.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: const Color(0x40FF6B4A), blurRadius: 20, offset: const Offset(0, 4))],
                    ),
                    child: Center(
                      child: Text('Open ZussGo', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Text(
                  'No card needed · Cancel anytime',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: c.muted),
                ),

                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PerkData {
  final String emoji, label, value;
  const _PerkData(this.emoji, this.label, this.value);
}