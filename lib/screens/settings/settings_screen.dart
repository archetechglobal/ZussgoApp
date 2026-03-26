import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../config/theme.dart';
import '../../config/api.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/gradient_button.dart';
import '../../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic> _user = {};
  bool _editing = false, _saving = false;

  late TextEditingController _nameC, _bioC, _cityC, _ageC;
  String? _gender, _travelStyle, _schedule, _social, _planning, _energy, _priority;
  Set<String> _interests = {}, _values = {};

  final _styles = ['Backpacker', 'Explorer', 'Foodie', 'Photography', 'Luxury', 'Party', 'Spiritual', 'Adventure'];
  final _schedules = ['Early Bird', 'Night Owl'];
  final _socials = ['Social Butterfly', 'Ambivert', 'Introvert'];
  final _plannings = ['Planner', 'Spontaneous'];
  final _energies = ['Chill', 'Energetic', 'Depends'];
  final _valueOpts = ['Eco-conscious', 'Comfort-first', 'Non-smoker', 'Social drinker', 'Vegetarian', 'Pet friendly'];
  final _interestOpts = ['Photography', 'Music', 'Water Sports', 'Street Food', 'Yoga', 'Art', 'Reading', 'Trekking', 'Stargazing', 'Camping', 'Journaling', 'Gaming'];
  final _priorities = ['Foodie-first', 'Adventure', 'Creator', 'Wellness', 'Nightlife', 'Culture'];

  @override
  void initState() {
    super.initState();
    _nameC = TextEditingController(); _bioC = TextEditingController(); _cityC = TextEditingController(); _ageC = TextEditingController();
    _load();
  }

  @override
  void dispose() { _nameC.dispose(); _bioC.dispose(); _cityC.dispose(); _ageC.dispose(); super.dispose(); }

  Future<void> _load() async {
    final u = await AuthService.getSavedUser();
    if (u != null && mounted) setState(() {
      _user = u;
      _nameC.text = u['fullName'] ?? '';
      _bioC.text = u['bio'] ?? '';
      _cityC.text = u['city'] ?? '';
      _ageC.text = (u['age'] ?? '').toString();
      if (_ageC.text == 'null') _ageC.text = '';
      _gender = u['gender'];
      _travelStyle = u['travelStyle'];
      _schedule = u['schedule'];
      _social = u['socialEnergy'];
      _planning = u['planningStyle'];
      _energy = u['energyLevel'];
      _interests = Set<String>.from(u['interests'] ?? []);
      _values = Set<String>.from(u['values'] ?? []);
      _priority = u['travelPriority'];
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final userId = _user['userId'];
    if (userId == null) { setState(() => _saving = false); return; }

    try {
      // Send ALL fields including mindset to backend
      final response = await http.post(
        Uri.parse(ApiConfig.profileSetup),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "gender": _gender ?? 'Male',
          "age": int.tryParse(_ageC.text) ?? 0,
          "city": _cityC.text.trim(),
          "travelStyle": _travelStyle,
          "bio": _bioC.text.trim(),
          "schedule": _schedule,
          "socialEnergy": _social,
          "planningStyle": _planning,
          "energyLevel": _energy,
          "values": _values.toList(),
          "interests": _interests.toList(),
          "travelPriority": _priority,
        }),
      );

      final data = jsonDecode(response.body);
      setState(() => _saving = false);

      if (data['success'] == true) {
        final updated = data['data'];
        if (updated != null) {
          // Save ALL returned fields to local storage
          await AuthService.updateSavedUser({
            'userId': updated['userId'],
            'fullName': updated['fullName'] ?? _nameC.text,
            'email': updated['email'] ?? _user['email'],
            'gender': updated['gender'],
            'age': updated['age'],
            'city': updated['city'],
            'bio': updated['bio'],
            'travelStyle': updated['travelStyle'],
            'isProfileCompleted': true,
            'schedule': updated['schedule'],
            'socialEnergy': updated['socialEnergy'],
            'planningStyle': updated['planningStyle'],
            'energyLevel': updated['energyLevel'],
            'values': updated['values'],
            'interests': updated['interests'],
            'travelPriority': updated['travelPriority'],
          });
        }
        await _load();
        setState(() => _editing = false);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated! ✓'), backgroundColor: ZussGoTheme.green));
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'] ?? 'Failed to save')));
      }
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not connect to server')));
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Sign Out?', style: ZussGoTheme.displaySmall),
      content: Text('You\'ll need to sign in again.', style: ZussGoTheme.bodyMedium),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: TextStyle(color: ZussGoTheme.textMuted))),
        TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Sign Out', style: TextStyle(color: ZussGoTheme.rose, fontWeight: FontWeight.w600))),
      ],
    ));
    if (confirm == true) { await AuthService.clearSession(); if (mounted) context.go('/login'); }
  }

  String get _name => _user['fullName'] ?? 'Traveler';
  String get _email => _user['email'] ?? '';
  String get _style => _user['travelStyle'] ?? '';
  String get _city => _user['city'] ?? '';

  Widget _chip(String label, bool sel, VoidCallback onTap) => GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(color: sel ? ZussGoTheme.green : ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: sel ? FontWeight.w600 : FontWeight.w400, color: sel ? Colors.white : ZussGoTheme.textSecondary))));

  @override
  Widget build(BuildContext context) {
    if (_editing) return _buildEditProfile();

    return Scaffold(backgroundColor: ZussGoTheme.bgPrimary, body: Stack(children: [
      SafeArea(bottom: false, child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(22, 8, 22, 90), child: Column(children: [
        const SizedBox(height: 12),
        Container(width: 76, height: 76, decoration: BoxDecoration(gradient: ZussGoTheme.gradientPrimary, borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: ZussGoTheme.green.withValues(alpha: 0.22), blurRadius: 14, offset: const Offset(0, 4))]),
            alignment: Alignment.center, child: Text(_name.isNotEmpty ? _name[0] : 'Z', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 28, fontFamily: 'Playfair Display'))),
        const SizedBox(height: 12),
        Text(_name, style: ZussGoTheme.displayMedium.copyWith(fontSize: 22)),
        Text(_email, style: ZussGoTheme.bodySmall),
        const SizedBox(height: 8),
        Wrap(alignment: WrapAlignment.center, spacing: 6, children: [
          if (_style.isNotEmpty) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: ZussGoTheme.greenLight, borderRadius: BorderRadius.circular(8)),
              child: Text('🎒 $_style', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: ZussGoTheme.green))),
          if (_city.isNotEmpty) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(8)),
              child: Text('📍 $_city', style: TextStyle(fontSize: 11, color: ZussGoTheme.textMuted))),
          if (_user['schedule'] != null) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(8)),
              child: Text(_user['schedule'] == 'Early Bird' ? '🌅 Early Bird' : '🦉 Night Owl', style: TextStyle(fontSize: 11, color: ZussGoTheme.textMuted))),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          _Stat(value: '3', label: 'Trips', color: ZussGoTheme.green),
          const SizedBox(width: 8),
          _Stat(value: '5', label: 'Matches', color: ZussGoTheme.amber),
          const SizedBox(width: 8),
          _Stat(value: '4.8', label: 'Rating', color: ZussGoTheme.rose),
        ]),
        const SizedBox(height: 20),
        _MenuItem(icon: '✏️', color: ZussGoTheme.greenLight, label: 'Edit Profile', onTap: () => setState(() => _editing = true)),
        _MenuItem(icon: '📞', color: ZussGoTheme.rose.withValues(alpha: 0.06), label: 'Emergency Contacts', onTap: () => context.push('/active-trip')),
        _MenuItem(icon: '🔔', color: ZussGoTheme.sky.withValues(alpha: 0.08), label: 'Notifications', onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming soon!')))),
        _MenuItem(icon: '🛡️', color: ZussGoTheme.amber.withValues(alpha: 0.08), label: 'Privacy & Safety', onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming soon!')))),
        _MenuItem(icon: '❓', color: ZussGoTheme.lavender.withValues(alpha: 0.08), label: 'Help & Support', onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contact hello@zussgo.com')))),
        _MenuItem(icon: '🚪', color: ZussGoTheme.rose.withValues(alpha: 0.06), label: 'Sign Out', isDestructive: true, onTap: _logout),
        const SizedBox(height: 16),
        Text('ZussGo v1.0 • ArcheTech Global', style: ZussGoTheme.bodySmall),
      ]))),
      const Positioned(bottom: 0, left: 0, right: 0, child: ZussGoBottomNav(currentIndex: 4)),
    ]));
  }

  Widget _buildEditProfile() {
    return Scaffold(backgroundColor: ZussGoTheme.bgPrimary, body: SafeArea(child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          GestureDetector(onTap: () => setState(() => _editing = false), child: Container(width: 34, height: 34, decoration: BoxDecoration(color: ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.arrow_back_rounded, color: ZussGoTheme.textSecondary, size: 18))),
          Text('Edit Profile', style: ZussGoTheme.displaySmall),
          const SizedBox(width: 34),
        ]),
        const SizedBox(height: 16),

        _editLabel('Full Name'),
        TextField(controller: _nameC, decoration: ZussGoTheme.inputDecoration(hint: 'Your name'), style: ZussGoTheme.bodyMedium.copyWith(color: ZussGoTheme.textPrimary)),
        const SizedBox(height: 12),
        _editLabel('Bio'),
        TextField(controller: _bioC, decoration: ZussGoTheme.inputDecoration(hint: 'About yourself'), style: ZussGoTheme.bodyMedium.copyWith(color: ZussGoTheme.textPrimary), maxLines: 3),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _editLabel('City'), TextField(controller: _cityC, decoration: ZussGoTheme.inputDecoration(hint: 'Mumbai'), style: ZussGoTheme.bodyMedium.copyWith(color: ZussGoTheme.textPrimary))])),
          const SizedBox(width: 10),
          SizedBox(width: 80, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _editLabel('Age'), TextField(controller: _ageC, decoration: ZussGoTheme.inputDecoration(hint: '24'), style: ZussGoTheme.bodyMedium.copyWith(color: ZussGoTheme.textPrimary), keyboardType: TextInputType.number)])),
        ]),
        const SizedBox(height: 12),

        _editLabel('Gender'),
        Row(children: ['Male', 'Female', 'Other'].map((g) {
          final sel = _gender == g;
          return Expanded(child: GestureDetector(onTap: () => setState(() => _gender = g),
              child: Container(margin: EdgeInsets.only(right: g != 'Other' ? 6 : 0), padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(color: sel ? ZussGoTheme.greenLight : ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(10),
                      border: sel ? Border.all(color: ZussGoTheme.green, width: 1.5) : null),
                  alignment: Alignment.center, child: Text(g, style: TextStyle(fontSize: 12, fontWeight: sel ? FontWeight.w600 : FontWeight.w400, color: sel ? ZussGoTheme.green : ZussGoTheme.textSecondary)))));
        }).toList()),
        const SizedBox(height: 14),

        _editLabel('Travel Style'),
        Wrap(spacing: 6, runSpacing: 6, children: _styles.map((s) => _chip(s, _travelStyle == s, () => setState(() => _travelStyle = s))).toList()),
        const SizedBox(height: 16),

        // ── MINDSET ──
        Text('MINDSET', style: TextStyle(fontSize: 11, color: ZussGoTheme.green, fontWeight: FontWeight.w600, letterSpacing: 1)),
        const SizedBox(height: 10),
        _editLabel('Schedule'),
        Wrap(spacing: 6, children: _schedules.map((s) => _chip(s == 'Early Bird' ? '🌅 $s' : '🦉 $s', _schedule == s, () => setState(() => _schedule = s))).toList()),
        const SizedBox(height: 8),
        _editLabel('Social Energy'),
        Wrap(spacing: 6, children: _socials.map((s) => _chip(s, _social == s, () => setState(() => _social = s))).toList()),
        const SizedBox(height: 8),
        _editLabel('Planning Style'),
        Wrap(spacing: 6, children: _plannings.map((s) => _chip(s == 'Planner' ? '📋 $s' : '🎲 $s', _planning == s, () => setState(() => _planning = s))).toList()),
        const SizedBox(height: 8),
        _editLabel('Energy Level'),
        Wrap(spacing: 6, children: _energies.map((s) => _chip(s, _energy == s, () => setState(() => _energy = s))).toList()),
        const SizedBox(height: 16),

        Text('INTERESTS & VALUES', style: TextStyle(fontSize: 11, color: ZussGoTheme.green, fontWeight: FontWeight.w600, letterSpacing: 1)),
        const SizedBox(height: 10),
        _editLabel('Interests'),
        Wrap(spacing: 6, runSpacing: 6, children: _interestOpts.map((i) => _chip(i, _interests.contains(i), () => setState(() { _interests.contains(i) ? _interests.remove(i) : _interests.add(i); }))).toList()),
        const SizedBox(height: 8),
        _editLabel('Values'),
        Wrap(spacing: 6, runSpacing: 6, children: _valueOpts.map((v) => _chip(v, _values.contains(v), () => setState(() { _values.contains(v) ? _values.remove(v) : _values.add(v); }))).toList()),
        const SizedBox(height: 8),
        _editLabel('Travel Priority'),
        Wrap(spacing: 6, runSpacing: 6, children: _priorities.map((p) => _chip(p, _priority == p, () => setState(() => _priority = p))).toList()),

        const SizedBox(height: 20),
        GradientButton(text: 'Save Changes ✓', isLoading: _saving, onPressed: _save),
        const SizedBox(height: 10),
        Center(child: GestureDetector(onTap: () => setState(() => _editing = false), child: Text('Cancel', style: TextStyle(fontSize: 13, color: ZussGoTheme.textMuted)))),
      ]),
    )));
  }

  Widget _editLabel(String t) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(t, style: ZussGoTheme.labelBold.copyWith(color: ZussGoTheme.textSecondary, fontSize: 12)));
}

class _Stat extends StatelessWidget {
  final String value, label; final Color color;
  const _Stat({required this.value, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)]),
      child: Column(children: [Text(value, style: TextStyle(fontFamily: 'Playfair Display', fontSize: 18, fontWeight: FontWeight.w700, color: color)), Text(label, style: ZussGoTheme.bodySmall)])));
}

class _MenuItem extends StatelessWidget {
  final String icon, label; final Color color; final VoidCallback onTap; final bool isDestructive;
  const _MenuItem({required this.icon, required this.color, required this.label, required this.onTap, this.isDestructive = false});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isDestructive ? Colors.transparent : ZussGoTheme.borderDefault))),
      child: Row(children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)), alignment: Alignment.center, child: Text(icon, style: const TextStyle(fontSize: 16))),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: ZussGoTheme.labelBold.copyWith(color: isDestructive ? ZussGoTheme.rose : ZussGoTheme.textPrimary))),
        if (!isDestructive) const Icon(Icons.chevron_right_rounded, color: ZussGoTheme.textMuted, size: 18),
      ])));
}