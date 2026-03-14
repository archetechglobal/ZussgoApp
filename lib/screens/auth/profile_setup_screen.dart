import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../widgets/gradient_button.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  String _selectedStyle = 'Explorer';
  final Set<String> _selectedInterests = {'Sunsets', 'Mountains'};

  final _styles = [
    {'name': 'Explorer', 'emoji': '🧭', 'desc': 'Adventure first'},
    {'name': 'Wanderer', 'emoji': '🌿', 'desc': 'Go with the flow'},
    {'name': 'Luxe', 'emoji': '✨', 'desc': 'Comfort matters'},
  ];
  final _interests = ['Sunsets', 'Mountains', 'Street Food', 'Temples', 'Nightlife', 'Photography', 'Trekking', 'Beaches', 'Cafés', 'Wildlife'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Step 2 of 2', style: ZussGoTheme.bodySmall),
              const SizedBox(height: 4),
              Text('Your Travel DNA', style: ZussGoTheme.displayLarge.copyWith(fontSize: 24)),
              const SizedBox(height: 4),
              Text('Helps us find your perfect match', style: ZussGoTheme.bodySmall),
              const SizedBox(height: 24),

              // Avatar
              Center(
                child: Container(
                  width: 88, height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ZussGoTheme.bgSecondary,
                    border: Border.all(color: ZussGoTheme.amber.withValues(alpha: 0.3), style: BorderStyle.solid, width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_alt_rounded, color: ZussGoTheme.textMuted, size: 28),
                      const SizedBox(height: 2),
                      Text('Add photo', style: ZussGoTheme.bodySmall.copyWith(fontSize: 10)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              _label('Age'),
              TextFormField(decoration: const InputDecoration(hintText: '24'), keyboardType: TextInputType.number),
              const SizedBox(height: 16),

              _label('Home City'),
              TextFormField(decoration: const InputDecoration(hintText: 'Mumbai')),
              const SizedBox(height: 20),

              // Travel style cards
              _label('Your travel style'),
              const SizedBox(height: 10),
              Row(
                children: _styles.map((s) {
                  final isSelected = s['name'] == _selectedStyle;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedStyle = s['name'] as String),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                        decoration: BoxDecoration(
                          gradient: isSelected ? ZussGoTheme.gradientPrimary : null,
                          color: isSelected ? null : ZussGoTheme.bgCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isSelected ? Colors.transparent : ZussGoTheme.borderDefault),
                        ),
                        child: Column(
                          children: [
                            Text(s['emoji'] as String, style: const TextStyle(fontSize: 22)),
                            const SizedBox(height: 4),
                            Text(s['name'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : ZussGoTheme.textPrimary)),
                            Text(s['desc'] as String, style: TextStyle(fontSize: 9, color: isSelected ? Colors.white70 : ZussGoTheme.textMuted)),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Interests
              _label('What excites you?'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _interests.map((i) {
                  final isSelected = _selectedInterests.contains(i);
                  return GestureDetector(
                    onTap: () => setState(() {
                      isSelected ? _selectedInterests.remove(i) : _selectedInterests.add(i);
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected ? ZussGoTheme.amber.withValues(alpha: 0.12) : ZussGoTheme.bgCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? ZussGoTheme.amber.withValues(alpha: 0.3) : ZussGoTheme.borderDefault),
                      ),
                      child: Text(i, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? ZussGoTheme.amber : ZussGoTheme.textMuted)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              GradientButton(text: 'Find My Tribe →', onPressed: () => context.go('/home')),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text, style: ZussGoTheme.bodySmall.copyWith(fontWeight: FontWeight.w600, color: ZussGoTheme.textSecondary));
}
