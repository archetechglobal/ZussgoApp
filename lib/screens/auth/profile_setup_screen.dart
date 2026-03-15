import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../widgets/gradient_button.dart';
import '../../services/auth_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  String? _selectedGender;
  String _selectedStyle = 'Explorer';
  final Set<String> _selectedInterests = {};
  final _ageController = TextEditingController();
  final _cityController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  final _genders = ['Male', 'Female', 'Non-binary', 'Prefer not to say'];
  final _styles = [
    {'name': 'Explorer', 'emoji': '🧭', 'desc': 'Adventure first'},
    {'name': 'Wanderer', 'emoji': '🌿', 'desc': 'Go with the flow'},
    {'name': 'Luxe', 'emoji': '✨', 'desc': 'Comfort matters'},
  ];
  final _interests = ['Sunsets', 'Mountains', 'Street Food', 'Temples', 'Nightlife', 'Photography', 'Trekking', 'Beaches', 'Cafés', 'Wildlife'];

  @override
  void dispose() {
    _ageController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    final age = int.tryParse(_ageController.text.trim());

    // ── MANDATORY CHECKS ──
    if (_selectedGender == null) {
      setState(() => _errorMessage = "Please select your gender — we need this to find you the perfect matches");
      return;
    }

    if (age == null || age < 18 || age > 99) {
      setState(() => _errorMessage = "Please enter a valid age (18-99) — we need this to find you the perfect matches");
      return;
    }

    setState(() { _errorMessage = null; _isLoading = true; });

    // Get the saved user ID from session
    final savedUser = await AuthService.getSavedUser();
    final userId = savedUser?['userId'];

    if (userId == null) {
      setState(() { _isLoading = false; _errorMessage = "Session expired. Please login again."; });
      return;
    }

    // Send profile data to backend
    final result = await AuthService.profileSetup(
      userId: userId,
      gender: _selectedGender!,
      age: age,
      city: _cityController.text.trim().isNotEmpty ? _cityController.text.trim() : null,
      travelStyle: _selectedStyle,
    );

    setState(() => _isLoading = false);

    if (result["success"] == true) {
      // Update the saved session so app knows profile is completed
      final updatedUser = result["data"];
      if (updatedUser != null) {
        await AuthService.updateSavedUser({
          'userId': updatedUser['userId'],
          'fullName': updatedUser['fullName'],
          'email': updatedUser['email'],
          'isProfileCompleted': true,
        });
      }

      if (mounted) context.go('/home');
    } else {
      setState(() => _errorMessage = result["message"]);
    }
  }

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
                    border: Border.all(color: ZussGoTheme.amber.withValues(alpha: 0.3), width: 2),
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

              // ── GENDER (MANDATORY) ──
              Row(children: [
                _label('Gender'),
                const SizedBox(width: 4),
                Text('*', style: TextStyle(color: ZussGoTheme.rose, fontSize: 14, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _genders.map((g) {
                  final isSelected = g == _selectedGender;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedGender = g),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(
                        gradient: isSelected ? ZussGoTheme.gradientPrimary : null,
                        color: isSelected ? null : ZussGoTheme.bgCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? Colors.transparent : ZussGoTheme.borderDefault),
                      ),
                      child: Text(g, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : ZussGoTheme.textSecondary)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // ── AGE (MANDATORY) ──
              Row(children: [
                _label('Age'),
                const SizedBox(width: 4),
                Text('*', style: TextStyle(color: ZussGoTheme.rose, fontSize: 14, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 6),
              TextField(
                controller: _ageController,
                decoration: const InputDecoration(hintText: '24'),
                style: ZussGoTheme.bodyMedium.copyWith(color: ZussGoTheme.textPrimary),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // ── CITY (optional) ──
              _label('Home City'),
              const SizedBox(height: 6),
              TextField(
                controller: _cityController,
                decoration: const InputDecoration(hintText: 'Mumbai'),
                style: ZussGoTheme.bodyMedium.copyWith(color: ZussGoTheme.textPrimary),
              ),
              const SizedBox(height: 20),

              // ── TRAVEL STYLE (optional) ──
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
                        child: Column(children: [
                          Text(s['emoji'] as String, style: const TextStyle(fontSize: 22)),
                          const SizedBox(height: 4),
                          Text(s['name'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : ZussGoTheme.textPrimary)),
                          Text(s['desc'] as String, style: TextStyle(fontSize: 9, color: isSelected ? Colors.white70 : ZussGoTheme.textMuted)),
                        ]),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // ── INTERESTS (optional) ──
              _label('What excites you?'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8, runSpacing: 8,
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
              const SizedBox(height: 16),

              // ── ERROR MESSAGE ──
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: ZussGoTheme.rose.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ZussGoTheme.rose.withValues(alpha: 0.15)),
                  ),
                  child: Row(children: [
                    Icon(Icons.info_outline_rounded, color: ZussGoTheme.rose, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_errorMessage!, style: TextStyle(color: ZussGoTheme.rose, fontSize: 12, fontWeight: FontWeight.w500))),
                  ]),
                ),

              // ── INFO NOTICE ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: ZussGoTheme.amber.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ZussGoTheme.amber.withValues(alpha: 0.1)),
                ),
                child: Row(children: [
                  Text('✦', style: TextStyle(color: ZussGoTheme.amber, fontSize: 14)),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Gender and age are required so we can recommend the perfect travel matches for you.', style: TextStyle(color: ZussGoTheme.textMuted, fontSize: 11))),
                ]),
              ),

              GradientButton(text: 'Find My Tribe →', isLoading: _isLoading, onPressed: _handleContinue),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text, style: ZussGoTheme.bodySmall.copyWith(fontWeight: FontWeight.w600, color: ZussGoTheme.textSecondary));
}
