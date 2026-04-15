import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});
  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  int _step = 0; // 0=basics, 1=style, 2=interests, 3=budget
  bool _loading = false;
  String? _error;

  // Step 0: Basics (gender, age, city, bio)
  String? _gender;
  final _ageC = TextEditingController();
  final _cityC = TextEditingController();
  final _bioC = TextEditingController();

  // Step 1: Travel Style
  String? _travelStyle;

  // Step 2: Interests/Vibe
  final Set<String> _interests = {};

  // Step 3: Budget
  String? _budget;

  // Mindset defaults (sent with profile)
  String? _schedule;
  String? _social;
  String? _planning;
  String? _energy;
  final Set<String> _values = {};
  String? _priority;

  static const _styleOptions = [
    _StyleOpt('🎒', 'Backpacker', 'Budget-first, hostels & local food'),
    _StyleOpt('🗓️', 'Planner', 'Itinerary-driven, pre-booked'),
    _StyleOpt('🌊', 'Slow Traveler', 'Stays longer, goes deeper'),
    _StyleOpt('⚡', 'Weekend Warrior', 'Short intense trips, max adventure'),
  ];

  static const _interestOptions = [
    '🏔️ Trekking', '🏖️ Beaches', '🕌 Heritage', '🎉 Festivals',
    '🍛 Food Tours', '🛕 Temples', '🦁 Wildlife', '🎭 Culture',
    '🏄 Adventure', '📸 Photography', '🧘 Wellness', '🌲 Nature', '🏕️ Camping',
  ];

  static const _budgetOptions = [
    _BudgetOpt('🎒', 'Budget', '₹500–₹1,500/day', 'Hostels, local food, buses'),
    _BudgetOpt('🏨', 'Comfortable', '₹1,500–₹4,000/day', 'Mid-range hotels, ride-share'),
    _BudgetOpt('✨', 'Premium', '₹4,000–₹10,000/day', 'Boutique stays, flights'),
    _BudgetOpt('💎', 'Luxury', '₹10,000+/day', 'Heritage hotels, private cars'),
  ];

  @override
  void dispose() { _ageC.dispose(); _cityC.dispose(); _bioC.dispose(); super.dispose(); }

  void _nextStep() {
    if (_step == 0) {
      if (_gender == null) { setState(() => _error = "Please select your gender"); return; }
      if (_ageC.text.isEmpty) { setState(() => _error = "Please enter your age"); return; }
      setState(() { _error = null; _step = 1; });
    } else if (_step == 1) {
      if (_travelStyle == null) { setState(() => _error = "Please select your travel style"); return; }
      setState(() { _error = null; _step = 2; });
    } else if (_step == 2) {
      if (_interests.length < 3) { setState(() => _error = "Pick at least 3 interests"); return; }
      setState(() { _error = null; _step = 3; });
    } else {
      if (_budget == null) { setState(() => _error = "Please select your budget"); return; }
      _submit();
    }
  }

  Future<void> _submit() async {
    setState(() { _error = null; _loading = true; });

    final user = await AuthService.getSavedUser();
    final userId = user?['userId'];
    if (userId == null) { setState(() { _loading = false; _error = "Session expired"; }); return; }

    // Map interests: strip emoji prefix for backend
    final cleanInterests = _interests.map((i) {
      final parts = i.split(' ');
      return parts.length > 1 ? parts.sublist(1).join(' ') : i;
    }).toList();

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
      interests: cleanInterests,
      travelPriority: _priority,
    );

    setState(() => _loading = false);

    if (r["success"] == true) {
      final updatedUser = r["data"];
      if (updatedUser != null) await AuthService.updateSavedUser(updatedUser);
      if (mounted) context.go('/founder-access');
    } else {
      setState(() => _error = r["message"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
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
        backgroundColor: c.bg,
        body: SafeArea(
          child: Column(
            children: [
              // ── HEADER ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
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
                        width: 44, height: 44,
                        decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: c.border)),
                        child: Icon(Icons.arrow_back_rounded, color: c.text, size: 18),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Progress bars
                    Row(
                      children: List.generate(4, (i) => Expanded(
                        child: Container(
                          height: 4,
                          margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(99),
                            color: i < _step ? c.primary : (i == _step ? null : c.border),
                            gradient: i == _step ? LinearGradient(colors: [c.primary, c.primaryMid]) : null,
                          ),
                        ),
                      )),
                    ),
                    const SizedBox(height: 16),

                    // Step label
                    Text(
                      'STEP ${_step + 1} OF 4',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: c.primary, fontWeight: FontWeight.w700, letterSpacing: 1),
                    ),
                    const SizedBox(height: 6),

                    // Title
                    if (_step == 0) ...[
                      RichText(text: TextSpan(style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: c.text, height: 1.25), children: [
                        const TextSpan(text: 'About '),
                        TextSpan(text: 'You', style: TextStyle(color: c.primary)),
                      ])),
                      const SizedBox(height: 6),
                      Text('Help us find your travel companions', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: c.textSecondary, height: 1.6)),
                    ],
                    if (_step == 1) ...[
                      RichText(text: TextSpan(style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: c.text, height: 1.25), children: [
                        const TextSpan(text: 'Your travel '),
                        TextSpan(text: 'style', style: TextStyle(color: c.primary)),
                      ])),
                      const SizedBox(height: 6),
                      Text('Helps match you with compatible companions.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: c.textSecondary, height: 1.6)),
                    ],
                    if (_step == 2) ...[
                      RichText(text: TextSpan(style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: c.text, height: 1.25), children: [
                        const TextSpan(text: 'Pick your '),
                        TextSpan(text: 'vibe', style: TextStyle(color: c.primary)),
                      ])),
                      const SizedBox(height: 6),
                      Text('Choose at least 3 for better matches.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: c.textSecondary, height: 1.6)),
                    ],
                    if (_step == 3) ...[
                      RichText(text: TextSpan(style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: c.text, height: 1.25), children: [
                        const TextSpan(text: 'Daily travel '),
                        TextSpan(text: 'budget', style: TextStyle(color: c.primary)),
                      ])),
                      const SizedBox(height: 6),
                      Text('Helps match companions with similar spending.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: c.textSecondary, height: 1.6)),
                    ],
                  ],
                ),
              ),

              // ── SCROLLABLE CONTENT ──
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_step == 0) _buildBasicsStep(c),
                      if (_step == 1) _buildStyleStep(c),
                      if (_step == 2) _buildInterestsStep(c),
                      if (_step == 3) _buildBudgetStep(c),

                      // Error
                      if (_error != null)
                        Container(
                          width: double.infinity, padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(top: 12),
                          decoration: BoxDecoration(color: c.roseSoft, border: Border.all(color: c.rose.withValues(alpha: 0.3)), borderRadius: BorderRadius.circular(12)),
                          child: Row(children: [
                            Icon(Icons.info_outline_rounded, color: c.rose, size: 18), const SizedBox(width: 8),
                            Expanded(child: Text(_error!, style: GoogleFonts.plusJakartaSans(color: c.rose, fontSize: 12))),
                          ]),
                        ),
                    ],
                  ),
                ),
              ),

              // ── CTA BUTTON ──
              Padding(
                padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).padding.bottom + 16),
                child: GestureDetector(
                  onTap: _loading ? null : _nextStep,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: c.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: const Color(0x30FF6B4A), blurRadius: 20, offset: const Offset(0, 4))],
                    ),
                    child: Center(
                      child: _loading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(
                        _step == 3 ? 'Almost Done' : 'Continue',
                        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // STEP 0: Basics
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildBasicsStep(ZussGoColors c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gender
        Text('Gender', style: GoogleFonts.plusJakartaSans(color: c.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(children: ['Male', 'Female', 'Other'].map((g) {
          final sel = _gender == g;
          return Expanded(child: GestureDetector(
            onTap: () => setState(() => _gender = g),
            child: Container(
              margin: EdgeInsets.only(right: g != 'Other' ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: sel ? c.primarySoft : c.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: sel ? c.primary : c.border, width: sel ? 2 : 1),
              ),
              alignment: Alignment.center,
              child: Text(g, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: sel ? FontWeight.w700 : FontWeight.w400, color: sel ? c.primary : c.textSecondary)),
            ),
          ));
        }).toList()),
        const SizedBox(height: 16),

        // Age
        Text('Age', style: GoogleFonts.plusJakartaSans(color: c.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _ageC,
          decoration: ZussGoTheme.inputDecorationOf(context, hint: '24'),
          style: GoogleFonts.plusJakartaSans(color: c.text, fontSize: 14),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),

        // City
        Text('City', style: GoogleFonts.plusJakartaSans(color: c.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _cityC,
          decoration: ZussGoTheme.inputDecorationOf(context, hint: 'Mumbai'),
          style: GoogleFonts.plusJakartaSans(color: c.text, fontSize: 14),
        ),
        const SizedBox(height: 16),

        // Bio
        Text('Bio', style: GoogleFonts.plusJakartaSans(color: c.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _bioC,
          decoration: ZussGoTheme.inputDecorationOf(context, hint: 'Love sunrises & road trips'),
          style: GoogleFonts.plusJakartaSans(color: c.text, fontSize: 14),
          maxLines: 2,
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // STEP 1: Travel Style (radio list)
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildStyleStep(ZussGoColors c) {
    return Column(
      children: _styleOptions.map((opt) {
        final sel = _travelStyle == opt.name;
        return GestureDetector(
          onTap: () => setState(() => _travelStyle = opt.name),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: sel ? const Color(0xFF1E150F) : c.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: sel ? c.primary : c.border, width: sel ? 2 : 1),
              gradient: sel ? const LinearGradient(colors: [Color(0xFF1E150F), Color(0xFF1A1520)]) : null,
            ),
            child: Row(children: [
              Text(opt.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(opt.name, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: c.text)),
                const SizedBox(height: 2),
                Text(opt.desc, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: c.textSecondary)),
              ])),
              Container(
                width: 22, height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: sel ? c.primary : Colors.transparent,
                  border: sel ? null : Border.all(color: c.border, width: 2),
                ),
                child: sel ? Center(child: Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white))) : null,
              ),
            ]),
          ),
        );
      }).toList(),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // STEP 2: Interests (chip grid)
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildInterestsStep(ZussGoColors c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _interestOptions.map((interest) {
            final sel = _interests.contains(interest);
            return GestureDetector(
              onTap: () => setState(() {
                sel ? _interests.remove(interest) : _interests.add(interest);
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? c.primarySoft : c.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: sel ? c.primary : c.border, width: sel ? 2 : 1),
                ),
                child: Text(
                  interest,
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: sel ? c.primary : c.text),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Text(
          _interests.length < 3
              ? '${_interests.length} selected · pick at least 3'
              : '${_interests.length} selected · looking good! ✓',
          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: c.textSecondary),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // STEP 3: Budget (radio list)
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildBudgetStep(ZussGoColors c) {
    return Column(
      children: _budgetOptions.map((opt) {
        final sel = _budget == opt.name;
        return GestureDetector(
          onTap: () => setState(() => _budget = opt.name),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: sel ? const Color(0xFF1E150F) : c.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: sel ? c.primary : c.border, width: sel ? 2 : 1),
              gradient: sel ? const LinearGradient(colors: [Color(0xFF1E150F), Color(0xFF1A1520)]) : null,
            ),
            child: Row(children: [
              Text(opt.emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(opt.name, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: c.text)),
                const SizedBox(height: 2),
                Text(opt.range, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: c.primary)),
                const SizedBox(height: 2),
                Text(opt.desc, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: c.textSecondary)),
              ])),
              Container(
                width: 22, height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: sel ? c.primary : Colors.transparent,
                  border: sel ? null : Border.all(color: c.border, width: 2),
                ),
                child: sel ? Center(child: Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white))) : null,
              ),
            ]),
          ),
        );
      }).toList(),
    );
  }
}

class _StyleOpt {
  final String emoji, name, desc;
  const _StyleOpt(this.emoji, this.name, this.desc);
}

class _BudgetOpt {
  final String emoji, name, range, desc;
  const _BudgetOpt(this.emoji, this.name, this.range, this.desc);
}