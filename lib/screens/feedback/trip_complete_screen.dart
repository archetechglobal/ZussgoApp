import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../widgets/gradient_button.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class TripCompleteScreen extends StatefulWidget {
  const TripCompleteScreen({super.key});
  @override
  State<TripCompleteScreen> createState() => _TripCompleteScreenState();
}

class _TripCompleteScreenState extends State<TripCompleteScreen> {
  bool _showFeedback = false;

  // Mock trip members for feedback (replace with real data)
  final _members = [
    {'id': '1', 'name': 'Priya Sharma', 'initial': 'P', 'color': ZussGoTheme.rose, 'days': 5, 'rating': 0, 'moods': <String>[], 'review': ''},
    {'id': '2', 'name': 'Rohan Verma', 'initial': 'R', 'color': ZussGoTheme.sky, 'days': 4, 'rating': 0, 'moods': <String>[], 'review': ''},
  ];

  final _allMoods = ['😊 Friendly', '🎉 Fun energy', '😴 Boring', '🗣️ Communicator', '😤 Difficult', '🤝 Reliable', '⏰ Late always', '😂 Joking', '🤫 Quiet', '💪 Adventurous', '📸 Great photos', '🍜 Foodie buddy'];
  final _groupVibes = ['🎉 Happening', '😴 Boring', '😂 Lots of laughs', '😤 Drama', '🤝 Everyone clicked', '🧍 Cliques formed', '📸 Insta-worthy', '✈️ Would repeat'];

  int _groupRating = 4;
  final Set<String> _selectedGroupVibes = {'🎉 Happening', '😂 Lots of laughs', '🤝 Everyone clicked'};

  @override
  Widget build(BuildContext context) {
    if (!_showFeedback) {
      return Scaffold(backgroundColor: ZussGoTheme.bgPrimary, body: SafeArea(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 28), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('🎉', style: TextStyle(fontSize: 56)),
        const SizedBox(height: 14),
        Text('Trip Complete!', style: ZussGoTheme.displayLarge.copyWith(fontSize: 26)),
        const SizedBox(height: 8),
        Text('Hope you had an amazing time in Goa!', style: ZussGoTheme.bodyMedium, textAlign: TextAlign.center),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(8)), child: const Text('🏖️ Goa', style: TextStyle(fontSize: 11, color: ZussGoTheme.textMuted))),
          const SizedBox(width: 6),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(8)), child: const Text('Dec 20-25', style: TextStyle(fontSize: 11, color: ZussGoTheme.textMuted))),
          const SizedBox(width: 6),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(8)), child: const Text('5 days', style: TextStyle(fontSize: 11, color: ZussGoTheme.textMuted))),
        ]),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)]),
              child: Column(children: [Text('3', style: TextStyle(fontFamily: 'Playfair Display', fontSize: 20, fontWeight: FontWeight.w700, color: ZussGoTheme.green)), Text('Travelers', style: ZussGoTheme.bodySmall)]))),
          const SizedBox(width: 8),
          Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)]),
              child: Column(children: [Text('5', style: TextStyle(fontFamily: 'Playfair Display', fontSize: 20, fontWeight: FontWeight.w700, color: ZussGoTheme.sky)), Text('Days', style: ZussGoTheme.bodySmall)]))),
          const SizedBox(width: 8),
          Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)]),
              child: Column(children: [Text('₹8K', style: TextStyle(fontFamily: 'Playfair Display', fontSize: 20, fontWeight: FontWeight.w700, color: ZussGoTheme.amber)), Text('Spent', style: ZussGoTheme.bodySmall)]))),
        ]),
        const SizedBox(height: 28),
        GradientButton(text: 'Rate Your Companions ⭐', onPressed: () => setState(() => _showFeedback = true)),
        const SizedBox(height: 10),
        GestureDetector(onTap: () => context.go('/home'), child: Text('Skip for now', style: TextStyle(fontSize: 13, color: ZussGoTheme.textMuted))),
      ]))));
    }

    // Feedback screen
    return Scaffold(backgroundColor: ZussGoTheme.bgPrimary, body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GestureDetector(onTap: () => setState(() => _showFeedback = false), child: Container(width: 34, height: 34, decoration: BoxDecoration(color: ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.arrow_back_rounded, color: ZussGoTheme.textSecondary, size: 18))),
      const SizedBox(height: 10),
      Text('Rate Your Trip', style: ZussGoTheme.displayMedium), Text('🏖️ Goa • Dec 20-25', style: ZussGoTheme.bodySmall),
      const SizedBox(height: 16),

      // Rate each member
      ...List.generate(_members.length, (i) {
        final m = _members[i];
        return Container(padding: const EdgeInsets.all(14), margin: const EdgeInsets.only(bottom: 10), decoration: ZussGoTheme.cardDecoration,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 42, height: 42, decoration: BoxDecoration(color: (m['color'] as Color).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14)),
                    alignment: Alignment.center, child: Text(m['initial'] as String, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: m['color'] as Color, fontFamily: 'Playfair Display'))),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(m['name'] as String, style: ZussGoTheme.labelBold), Text('${m['days']} days together', style: ZussGoTheme.bodySmall)]),
              ]),
              const SizedBox(height: 10),
              Text('Rating', style: ZussGoTheme.labelBold.copyWith(fontSize: 12, color: ZussGoTheme.textSecondary)),
              const SizedBox(height: 4),
              Row(children: List.generate(5, (s) => GestureDetector(
                  onTap: () => setState(() => _members[i]['rating'] = s + 1),
                  child: Padding(padding: const EdgeInsets.only(right: 4), child: Text('★', style: TextStyle(fontSize: 22, color: s < (m['rating'] as int) ? ZussGoTheme.amber : ZussGoTheme.borderDefault)))))),
              const SizedBox(height: 10),
              Text('How were they?', style: ZussGoTheme.labelBold.copyWith(fontSize: 12, color: ZussGoTheme.textSecondary)),
              const SizedBox(height: 6),
              Wrap(spacing: 4, runSpacing: 4, children: _allMoods.map((mood) {
                final selected = (m['moods'] as List<String>).contains(mood);
                return GestureDetector(
                    onTap: () => setState(() { selected ? (m['moods'] as List<String>).remove(mood) : (m['moods'] as List<String>).add(mood); }),
                    child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(
                        color: selected ? ZussGoTheme.greenLight : ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: selected ? ZussGoTheme.green : Colors.transparent, width: 1)),
                        child: Text(mood, style: TextStyle(fontSize: 10, fontWeight: selected ? FontWeight.w600 : FontWeight.w400, color: selected ? ZussGoTheme.green : ZussGoTheme.textSecondary))));
              }).toList()),
            ]));
      }),

      // Group vibe
      Container(padding: const EdgeInsets.all(14), decoration: ZussGoTheme.cardDecoration,
          child: Column(children: [
            Text('Overall Group Vibe', style: ZussGoTheme.displaySmall),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (s) => GestureDetector(
                onTap: () => setState(() => _groupRating = s + 1),
                child: Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: Text('★', style: TextStyle(fontSize: 28, color: s < _groupRating ? ZussGoTheme.amber : ZussGoTheme.borderDefault)))))),
            const SizedBox(height: 10),
            Wrap(spacing: 4, runSpacing: 4, children: _groupVibes.map((v) {
              final sel = _selectedGroupVibes.contains(v);
              return GestureDetector(onTap: () => setState(() { sel ? _selectedGroupVibes.remove(v) : _selectedGroupVibes.add(v); }),
                  child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(
                      color: sel ? ZussGoTheme.greenLight : ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: sel ? ZussGoTheme.green : Colors.transparent)),
                      child: Text(v, style: TextStyle(fontSize: 10, fontWeight: sel ? FontWeight.w600 : FontWeight.w400, color: sel ? ZussGoTheme.green : ZussGoTheme.textSecondary))));
            }).toList()),
          ])),

      const SizedBox(height: 14),
      GradientButton(text: 'Submit Ratings ⭐', onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ratings submitted! Thanks 🎉'), backgroundColor: ZussGoTheme.green));
        context.go('/home');
      }),
      const SizedBox(height: 14),
    ]))));
  }
}