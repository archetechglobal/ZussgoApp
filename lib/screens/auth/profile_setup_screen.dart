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
  final _valueOptions = ['Eco-conscious', 'Comfort-first', 'Non-smoker', 'Social drinker', 'Vegetarian', 'Pet friendly'];
  final _interestOptions = ['Photography', 'Music', 'Water Sports', 'Street Food', 'Yoga', 'Art', 'Reading', 'Trekking', 'Stargazing', 'Camping', 'Journaling', 'Gaming'];
  final _priorityOptions = ['Foodie-first', 'Adventure', 'Creator', 'Wellness', 'Nightlife', 'Culture'];

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
      age: int.tryParse(_ageC.text.trim()),
      city: _cityC.text.trim(),
      bio: _bioC.text.trim(),
      travelStyle: _travelStyle,
      schedule: _schedule,
      socialEnergy: _social,
      planningStyle: _planning,
      energyLevel: _energy,
      values: _values.toList(),
      interests: _interests.toList(),
      travelPriority: _priority,
    );

    setState(() => _loading = false);

    if (r["success"] == true) {
      final updatedUser = r["data"];
      if (updatedUser != null) await AuthService.updateSavedUser(updatedUser);
      if (mounted) context.go('/home');
    } else { setState(() => _error = r["message"]); }
  }

  Widget _buildChip(String label, bool selected, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? context.colors.green : ZussGoTheme.mutedBg(context),
          borderRadius: BorderRadius.circular(14),
          border: (!selected && isDark) ? Border.all(color: ZussGoTheme.border(context)) : null,
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: selected ? FontWeight.w600 : FontWeight.w400, color: selected ? Colors.white : ZussGoTheme.secondaryText(context))),
      ),
    );
  }

  Widget _buildMindsetOption(IconData icon, String title, String subtitle, String value, String? groupValue, ValueChanged<String> onTap) {
    final selected = value == groupValue;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: selected ? (isDark ? context.colors.green.withValues(alpha: 0.2) : context.colors.greenLight) : ZussGoTheme.cardBg(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? context.colors.green : (isDark ? ZussGoTheme.border(context) : Colors.transparent), width: 1.5),
          boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 1))],
        ),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: ZussGoTheme.mutedBg(context), borderRadius: BorderRadius.circular(10)),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: selected ? context.colors.green : ZussGoTheme.secondaryText(context)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: context.textTheme.labelLarge!.adaptive(context)),
            if (subtitle.isNotEmpty) Text(subtitle, style: context.textTheme.bodySmall!.copyWith(color: ZussGoTheme.secondaryText(context))),
          ])),
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(
              color: selected ? context.colors.green : Colors.transparent,
              shape: BoxShape.circle,
              border: selected ? null : Border.all(color: ZussGoTheme.border(context), width: 1.5),
            ),
            child: selected ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_step > 0) {
          setState(() { _step--; _error = null; });
        } else {
          await AuthService.clearSession();
          if (context.mounted) context.go('/login');
        }
      },
      child: Scaffold(
        backgroundColor: ZussGoTheme.scaffoldBg(context),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              GestureDetector(
                onTap: () async {
                  if (_step > 0) {
                    setState(() { _step--; _error = null; });
                  } else {
                    await AuthService.clearSession();
                    if (context.mounted) context.go('/login');
                  }
                },
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: ZussGoTheme.mutedBg(context), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.arrow_back_rounded, color: ZussGoTheme.secondaryText(context), size: 20),
                ),
              ),
              const SizedBox(height: 20),
              // Progress bar
            Row(children: List.generate(3, (i) => Expanded(
              child: Container(
                height: 4, margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                decoration: BoxDecoration(color: i <= _step ? context.colors.green : ZussGoTheme.borderDefault, borderRadius: BorderRadius.circular(2)),
              ),
            ))),
            const SizedBox(height: 12),
            Text('STEP ${_step + 1} OF 3', style: TextStyle(fontSize: 11, color: context.colors.green, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
            const SizedBox(height: 8),

            // ── STEP 1: BASICS ──
            if (_step == 0) ...[
              Text('About You', style: context.textTheme.displayLarge!.copyWith(fontSize: 28)),
              const SizedBox(height: 6),
              Text('Help us find your travel companions', style: context.textTheme.bodyMedium!),
              const SizedBox(height: 24),

              Text('Gender', style: context.textTheme.labelLarge!.copyWith(color: ZussGoTheme.secondaryText(context), fontSize: 13)),
              const SizedBox(height: 8),
              Row(children: ['Male', 'Female', 'Other'].map((g) {
                final sel = _gender == g;
                return Expanded(child: GestureDetector(
                  onTap: () => setState(() => _gender = g),
                  child: Container(
                    margin: EdgeInsets.only(right: g != 'Other' ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: sel ? (isDark ? context.colors.green.withValues(alpha: 0.2) : context.colors.greenLight) : ZussGoTheme.mutedBg(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: sel ? context.colors.green : (isDark ? ZussGoTheme.border(context) : Colors.transparent), width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(g, style: TextStyle(fontSize: 13, fontWeight: sel ? FontWeight.w600 : FontWeight.w400, color: sel ? context.colors.green : ZussGoTheme.secondaryText(context))),
                  ),
                ));
              }).toList()),
              const SizedBox(height: 16),

              Text('Age', style: context.textTheme.labelLarge!.copyWith(color: ZussGoTheme.secondaryText(context), fontSize: 13)),
              const SizedBox(height: 8),
              TextField(controller: _ageC, decoration: ZussGoTheme.inputDecorationOf(context, hint: '24'), style: context.textTheme.bodyMedium!.copyWith(color: ZussGoTheme.primaryText(context)), keyboardType: TextInputType.number),
              const SizedBox(height: 16),

              Text('City', style: context.textTheme.labelLarge!.copyWith(color: ZussGoTheme.secondaryText(context), fontSize: 13)),
              const SizedBox(height: 8),
              TextField(controller: _cityC, decoration: ZussGoTheme.inputDecorationOf(context, hint: 'Mumbai'), style: context.textTheme.bodyMedium!.copyWith(color: ZussGoTheme.primaryText(context))),
              const SizedBox(height: 16),

              Text('Bio', style: context.textTheme.labelLarge!.copyWith(color: ZussGoTheme.secondaryText(context), fontSize: 13)),
              const SizedBox(height: 8),
              TextField(controller: _bioC, decoration: ZussGoTheme.inputDecorationOf(context, hint: 'Love sunrises & road trips'), style: context.textTheme.bodyMedium!.copyWith(color: ZussGoTheme.primaryText(context)), maxLines: 2),
              const SizedBox(height: 16),

              Text('Travel Style', style: context.textTheme.labelLarge!.copyWith(color: ZussGoTheme.secondaryText(context), fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(spacing: 6, runSpacing: 6, children: _travelStyles.map((s) => _buildChip(s, _travelStyle == s, () => setState(() => _travelStyle = s))).toList()),
            ],

            // ── STEP 2: MINDSET ──
            if (_step == 1) ...[
              Text('Your Travel\nMindset', style: context.textTheme.displayLarge!.copyWith(fontSize: 28)),
              const SizedBox(height: 6),
              Text('Pick one from each — helps match like-minded travelers', style: context.textTheme.bodyMedium!),
              const SizedBox(height: 20),

              Text('SCHEDULE', style: TextStyle(fontSize: 11, color: ZussGoTheme.secondaryText(context), fontWeight: FontWeight.w600, letterSpacing: 1)),
              const SizedBox(height: 6),
              _buildMindsetOption(Icons.wb_sunny_rounded, 'Early Bird', 'Up at sunrise, packed days', 'Early Bird', _schedule, (v) => setState(() => _schedule = v)),
              _buildMindsetOption(Icons.nightlight_round, 'Night Owl', 'Late starts, nightlife', 'Night Owl', _schedule, (v) => setState(() => _schedule = v)),
              const SizedBox(height: 12),

              Text('SOCIAL ENERGY', style: TextStyle(fontSize: 11, color: ZussGoTheme.secondaryText(context), fontWeight: FontWeight.w600, letterSpacing: 1)),
              const SizedBox(height: 6),
              _buildMindsetOption(Icons.groups_rounded, 'Social Butterfly', 'Love meeting people', 'Social Butterfly', _social, (v) => setState(() => _social = v)),
              _buildMindsetOption(Icons.people_alt_rounded, 'Ambivert', 'Mix of social & solo', 'Ambivert', _social, (v) => setState(() => _social = v)),
              _buildMindsetOption(Icons.person_outline_rounded, 'Introvert', 'Quiet, deep conversations', 'Introvert', _social, (v) => setState(() => _social = v)),
              const SizedBox(height: 12),

              Text('PLANNING', style: TextStyle(fontSize: 11, color: ZussGoTheme.secondaryText(context), fontWeight: FontWeight.w600, letterSpacing: 1)),
              const SizedBox(height: 6),
              _buildMindsetOption(Icons.content_paste_rounded, 'Planner', 'Everything organized', 'Planner', _planning, (v) => setState(() => _planning = v)),
              _buildMindsetOption(Icons.explore_rounded, 'Spontaneous', 'Go with the flow', 'Spontaneous', _planning, (v) => setState(() => _planning = v)),
            ],

            // ── STEP 3: INTERESTS ──
            if (_step == 2) ...[
              Text('Vibe &\nInterests', style: context.textTheme.displayLarge!.copyWith(fontSize: 28)),
              const SizedBox(height: 6),
              Text('Select all that apply — more picks = better matches', style: context.textTheme.bodyMedium!),
              const SizedBox(height: 20),

              Text('ENERGY', style: TextStyle(fontSize: 11, color: ZussGoTheme.secondaryText(context), fontWeight: FontWeight.w600, letterSpacing: 1)),
              const SizedBox(height: 6),
              Wrap(spacing: 6, runSpacing: 6, children: ['Chill', 'Energetic', 'Depends'].map((e) => _buildChip(e, _energy == e, () => setState(() => _energy = e))).toList()),
              const SizedBox(height: 14),

              Text('VALUES', style: TextStyle(fontSize: 11, color: ZussGoTheme.secondaryText(context), fontWeight: FontWeight.w600, letterSpacing: 1)),
              const SizedBox(height: 6),
              Wrap(spacing: 6, runSpacing: 6, children: _valueOptions.map((v) => _buildChip(v, _values.contains(v), () => setState(() { _values.contains(v) ? _values.remove(v) : _values.add(v); }))).toList()),
              const SizedBox(height: 14),

              Text('INTERESTS', style: TextStyle(fontSize: 11, color: ZussGoTheme.secondaryText(context), fontWeight: FontWeight.w600, letterSpacing: 1)),
              const SizedBox(height: 6),
              Wrap(spacing: 6, runSpacing: 6, children: _interestOptions.map((i) => _buildChip(i, _interests.contains(i), () => setState(() { _interests.contains(i) ? _interests.remove(i) : _interests.add(i); }))).toList()),
              const SizedBox(height: 14),

              Text('TRAVEL PRIORITY', style: TextStyle(fontSize: 11, color: ZussGoTheme.secondaryText(context), fontWeight: FontWeight.w600, letterSpacing: 1)),
              const SizedBox(height: 6),
              Wrap(spacing: 6, runSpacing: 6, children: _priorityOptions.map((p) => _buildChip(p, _priority == p, () => setState(() => _priority = p))).toList()),
            ],

            if (_error != null)
              Container(
                width: double.infinity, padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(color: context.colors.rose.withValues(alpha: isDark ? 0.15 : 0.06), border: isDark ? Border.all(color: context.colors.rose.withValues(alpha: 0.3)) : null, borderRadius: BorderRadius.circular(12)),
                child: Row(children: [Icon(Icons.info_outline_rounded, color: context.colors.rose, size: 18), SizedBox(width: 8), Expanded(child: Text(_error!, style: TextStyle(color: isDark ? const Color(0xFFFFAEB4) : context.colors.rose, fontSize: 12)))]),
              ),

            const SizedBox(height: 24),
            GradientButton(
              text: _step == 2 ? 'Find My Tribe' : 'Continue →',
              isLoading: _loading,
              onPressed: _nextStep,
            ),
            if (_step > 0) ...[
              const SizedBox(height: 12),
              Center(child: GestureDetector(
                onTap: () => setState(() { _step--; _error = null; }),
                child: Text('← Back', style: TextStyle(fontSize: 13, color: ZussGoTheme.mutedText(context), fontWeight: FontWeight.w500)),
              )),
            ],
            const SizedBox(height: 16),
          ]),
        ),
      ),
    ));
  }
}