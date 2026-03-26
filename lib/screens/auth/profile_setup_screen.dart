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
  int _step = 0; // 0=basics, 1=mindset, 2=interests
  bool _loading = false;
  String? _error;

  // Step 1: Basics
  String? _gender;
  final _ageC = TextEditingController();
  final _cityC = TextEditingController();
  final _bioC = TextEditingController();
  String? _travelStyle;

  // Step 2: Mindset
  String? _schedule;    // Early Bird / Night Owl
  String? _social;      // Social Butterfly / Ambivert / Introvert
  String? _planning;    // Planner / Spontaneous

  // Step 3: Interests
  String? _energy;      // Chill / Energetic / Depends
  final Set<String> _values = {};
  final Set<String> _interests = {};
  String? _priority;

  final _travelStyles = ['Backpacker', 'Explorer', 'Foodie', 'Photography', 'Luxury', 'Party', 'Spiritual', 'Adventure'];
  final _styleEmojis = {'Backpacker': '🎒', 'Explorer': '🗺️', 'Foodie': '🍜', 'Photography': '📸', 'Luxury': '💎', 'Party': '🎉', 'Spiritual': '🧘', 'Adventure': '🏃'};
  final _valueOptions = ['🌿 Eco-conscious', '💆 Comfort-first', '🚭 Non-smoker', '🍷 Social drinker', '🥗 Vegetarian', '🐕 Pet friendly'];
  final _interestOptions = ['📸 Photography', '🎶 Music', '🏄 Water Sports', '🍜 Street Food', '🧘 Yoga', '🎨 Art', '📖 Reading', '🏃 Trekking', '🌌 Stargazing', '🏕️ Camping', '✍️ Journaling', '🎮 Gaming'];
  final _priorityOptions = ['🍜 Foodie-first', '🗺️ Adventure', '📸 Creator', '🧘 Wellness', '🎉 Nightlife', '🏛️ Culture'];

  @override
  void dispose() { _ageC.dispose(); _cityC.dispose(); _bioC.dispose(); super.dispose(); }

  void _nextStep() {
    if (_step == 0) {
      if (_gender == null) { setState(() => _error = "Please select your gender"); return; }
      if (_ageC.text.isEmpty) { setState(() => _error = "Please enter your age"); return; }
      setState(() { _error = null; _step = 1; });
    } else if (_step == 1) {
      setState(() { _error = null; _step = 2; });
    } else {
      _submit();
    }
  }

  Future<void> _submit() async {
    setState(() { _error = null; _loading = true; });

    final user = await AuthService.getSavedUser();
    final userId = user?['userId'];
    if (userId == null) { setState(() { _loading = false; _error = "Session expired"; }); return; }

    final r = await AuthService.profileSetup(
      userId: userId,
      gender: _gender!,
      age: int.tryParse(_ageC.text) ?? 0,
      city: _cityC.text.trim(),
      bio: _bioC.text.trim(),
      travelStyle: _travelStyle,
    );

    setState(() => _loading = false);

    if (r["success"] == true) {
      final updatedUser = r["data"]?["user"];
      if (updatedUser != null) await AuthService.updateSavedUser(updatedUser);
      if (mounted) context.go('/home');
    } else { setState(() => _error = r["message"]); }
  }

  Widget _buildChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? ZussGoTheme.green : ZussGoTheme.bgMuted,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: selected ? FontWeight.w600 : FontWeight.w400, color: selected ? Colors.white : ZussGoTheme.textSecondary)),
      ),
    );
  }

  Widget _buildMindsetOption(String emoji, String title, String subtitle, String value, String? groupValue, ValueChanged<String> onTap) {
    final selected = value == groupValue;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: selected ? ZussGoTheme.greenLight : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? ZussGoTheme.green : Colors.transparent, width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 1))],
        ),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(10)),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: ZussGoTheme.labelBold),
            if (subtitle.isNotEmpty) Text(subtitle, style: ZussGoTheme.bodySmall.copyWith(color: ZussGoTheme.textSecondary)),
          ])),
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(
              color: selected ? ZussGoTheme.green : Colors.transparent,
              shape: BoxShape.circle,
              border: selected ? null : Border.all(color: ZussGoTheme.borderDefault, width: 1.5),
            ),
            child: selected ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZussGoTheme.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Progress bar
            Row(children: List.generate(3, (i) => Expanded(
              child: Container(
                height: 4, margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                decoration: BoxDecoration(color: i <= _step ? ZussGoTheme.green : ZussGoTheme.borderDefault, borderRadius: BorderRadius.circular(2)),
              ),
            ))),
            const SizedBox(height: 12),
            Text('STEP ${_step + 1} OF 3', style: TextStyle(fontSize: 11, color: ZussGoTheme.green, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
            const SizedBox(height: 8),

            // ── STEP 1: BASICS ──
            if (_step == 0) ...[
              Text('About You', style: ZussGoTheme.displayLarge.copyWith(fontSize: 28)),
              const SizedBox(height: 6),
              Text('Help us find your travel companions', style: ZussGoTheme.bodyMedium),
              const SizedBox(height: 24),

              Text('Gender', style: ZussGoTheme.labelBold.copyWith(color: ZussGoTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 8),
              Row(children: ['Male', 'Female', 'Other'].map((g) {
                final sel = _gender == g;
                return Expanded(child: GestureDetector(
                  onTap: () => setState(() => _gender = g),
                  child: Container(
                    margin: EdgeInsets.only(right: g != 'Other' ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: sel ? ZussGoTheme.greenLight : ZussGoTheme.bgMuted,
                      borderRadius: BorderRadius.circular(12),
                      border: sel ? Border.all(color: ZussGoTheme.green, width: 1.5) : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(g, style: TextStyle(fontSize: 13, fontWeight: sel ? FontWeight.w600 : FontWeight.w400, color: sel ? ZussGoTheme.green : ZussGoTheme.textSecondary)),
                  ),
                ));
              }).toList()),
              const SizedBox(height: 16),

              Text('Age', style: ZussGoTheme.labelBold.copyWith(color: ZussGoTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(controller: _ageC, decoration: ZussGoTheme.inputDecoration(hint: '24'), style: ZussGoTheme.bodyMedium.copyWith(color: ZussGoTheme.textPrimary), keyboardType: TextInputType.number),
              const SizedBox(height: 16),

              Text('City', style: ZussGoTheme.labelBold.copyWith(color: ZussGoTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(controller: _cityC, decoration: ZussGoTheme.inputDecoration(hint: 'Mumbai'), style: ZussGoTheme.bodyMedium.copyWith(color: ZussGoTheme.textPrimary)),
              const SizedBox(height: 16),

              Text('Bio', style: ZussGoTheme.labelBold.copyWith(color: ZussGoTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(controller: _bioC, decoration: ZussGoTheme.inputDecoration(hint: 'Love sunrises & road trips 🌅'), style: ZussGoTheme.bodyMedium.copyWith(color: ZussGoTheme.textPrimary), maxLines: 2),
              const SizedBox(height: 16),

              Text('Travel Style', style: ZussGoTheme.labelBold.copyWith(color: ZussGoTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(spacing: 6, runSpacing: 6, children: _travelStyles.map((s) => _buildChip('${_styleEmojis[s]} $s', _travelStyle == s, () => setState(() => _travelStyle = s))).toList()),
            ],

            // ── STEP 2: MINDSET ──
            if (_step == 1) ...[
              Text('Your Travel\nMindset', style: ZussGoTheme.displayLarge.copyWith(fontSize: 28)),
              const SizedBox(height: 6),
              Text('Pick one from each — helps match like-minded travelers', style: ZussGoTheme.bodyMedium),
              const SizedBox(height: 20),

              Text('SCHEDULE', style: TextStyle(fontSize: 11, color: ZussGoTheme.textSecondary, fontWeight: FontWeight.w600, letterSpacing: 1)),
              const SizedBox(height: 6),
              _buildMindsetOption('🌅', 'Early Bird', 'Up at sunrise, packed days', 'Early Bird', _schedule, (v) => setState(() => _schedule = v)),
              _buildMindsetOption('🦉', 'Night Owl', 'Late starts, nightlife', 'Night Owl', _schedule, (v) => setState(() => _schedule = v)),
              const SizedBox(height: 12),

              Text('SOCIAL ENERGY', style: TextStyle(fontSize: 11, color: ZussGoTheme.textSecondary, fontWeight: FontWeight.w600, letterSpacing: 1)),
              const SizedBox(height: 6),
              _buildMindsetOption('🦋', 'Social Butterfly', 'Love meeting people', 'Social Butterfly', _social, (v) => setState(() => _social = v)),
              _buildMindsetOption('🌿', 'Ambivert', 'Mix of social & solo', 'Ambivert', _social, (v) => setState(() => _social = v)),
              _buildMindsetOption('📖', 'Introvert', 'Quiet, deep conversations', 'Introvert', _social, (v) => setState(() => _social = v)),
              const SizedBox(height: 12),

              Text('PLANNING', style: TextStyle(fontSize: 11, color: ZussGoTheme.textSecondary, fontWeight: FontWeight.w600, letterSpacing: 1)),
              const SizedBox(height: 6),
              _buildMindsetOption('📋', 'Planner', 'Everything organized', 'Planner', _planning, (v) => setState(() => _planning = v)),
              _buildMindsetOption('🎲', 'Spontaneous', 'Go with the flow', 'Spontaneous', _planning, (v) => setState(() => _planning = v)),
            ],

            // ── STEP 3: INTERESTS ──
            if (_step == 2) ...[
              Text('Vibe &\nInterests', style: ZussGoTheme.displayLarge.copyWith(fontSize: 28)),
              const SizedBox(height: 6),
              Text('Select all that apply — more picks = better matches', style: ZussGoTheme.bodyMedium),
              const SizedBox(height: 20),

              Text('ENERGY', style: TextStyle(fontSize: 11, color: ZussGoTheme.textSecondary, fontWeight: FontWeight.w600, letterSpacing: 1)),
              const SizedBox(height: 6),
              Wrap(spacing: 6, runSpacing: 6, children: ['😌 Chill', '⚡ Energetic', '🔄 Depends'].map((e) => _buildChip(e, _energy == e, () => setState(() => _energy = e))).toList()),
              const SizedBox(height: 14),

              Text('VALUES', style: TextStyle(fontSize: 11, color: ZussGoTheme.textSecondary, fontWeight: FontWeight.w600, letterSpacing: 1)),
              const SizedBox(height: 6),
              Wrap(spacing: 6, runSpacing: 6, children: _valueOptions.map((v) => _buildChip(v, _values.contains(v), () => setState(() { _values.contains(v) ? _values.remove(v) : _values.add(v); }))).toList()),
              const SizedBox(height: 14),

              Text('INTERESTS', style: TextStyle(fontSize: 11, color: ZussGoTheme.textSecondary, fontWeight: FontWeight.w600, letterSpacing: 1)),
              const SizedBox(height: 6),
              Wrap(spacing: 6, runSpacing: 6, children: _interestOptions.map((i) => _buildChip(i, _interests.contains(i), () => setState(() { _interests.contains(i) ? _interests.remove(i) : _interests.add(i); }))).toList()),
              const SizedBox(height: 14),

              Text('TRAVEL PRIORITY', style: TextStyle(fontSize: 11, color: ZussGoTheme.textSecondary, fontWeight: FontWeight.w600, letterSpacing: 1)),
              const SizedBox(height: 6),
              Wrap(spacing: 6, runSpacing: 6, children: _priorityOptions.map((p) => _buildChip(p, _priority == p, () => setState(() => _priority = p))).toList()),
            ],

            if (_error != null)
              Container(
                width: double.infinity, padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(color: ZussGoTheme.rose.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12)),
                child: Row(children: [Icon(Icons.info_outline_rounded, color: ZussGoTheme.rose, size: 18), const SizedBox(width: 8), Expanded(child: Text(_error!, style: TextStyle(color: ZussGoTheme.rose, fontSize: 12)))]),
              ),

            const SizedBox(height: 24),
            GradientButton(
              text: _step == 2 ? 'Find My Tribe ✨' : 'Continue →',
              isLoading: _loading,
              onPressed: _nextStep,
            ),
            if (_step > 0) ...[
              const SizedBox(height: 12),
              Center(child: GestureDetector(
                onTap: () => setState(() { _step--; _error = null; }),
                child: Text('← Back', style: TextStyle(fontSize: 13, color: ZussGoTheme.textMuted, fontWeight: FontWeight.w500)),
              )),
            ],
            const SizedBox(height: 16),
          ]),
        ),
      ),
    );
  }
}