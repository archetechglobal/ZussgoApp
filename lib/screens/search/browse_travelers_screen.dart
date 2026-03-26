import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class BrowseTravelersScreen extends StatefulWidget {
  final String destinationSlug;
  final String destinationName;
  final String? destinationId;
  const BrowseTravelersScreen({super.key, required this.destinationSlug, required this.destinationName, this.destinationId});
  @override
  State<BrowseTravelersScreen> createState() => _BrowseTravelersScreenState();
}

class _BrowseTravelersScreenState extends State<BrowseTravelersScreen> {
  List<Map<String, dynamic>> _travelers = [];
  List<Map<String, dynamic>> _filtered = [];
  List<Map<String, dynamic>> _groups = [];
  Map<String, dynamic> _currentUser = {};
  bool _loading = true, _showGroups = false, _showFilters = false;

  RangeValues _ageRange = const RangeValues(18, 40);
  String? _genderFilter, _styleFilter, _mindsetFilter;

  final _styles = ['Backpacker', 'Explorer', 'Foodie', 'Photography', 'Luxury', 'Party', 'Spiritual', 'Adventure'];
  final _mindsets = ['Early Bird', 'Night Owl', 'Social Butterfly', 'Ambivert', 'Introvert', 'Planner', 'Spontaneous'];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    // Load current user for scoring
    final u = await AuthService.getSavedUser();
    if (u != null) _currentUser = u;

    final destR = await ApiService.getDestinationBySlug(widget.destinationSlug);
    if (destR["success"] == true && destR["data"] != null) {
      final data = destR["data"];
      if (data["travelers"] != null) {
        _travelers = List<Map<String, dynamic>>.from(data["travelers"]).map((t) {
          final user = t['user'] as Map<String, dynamic>? ?? {};
          return {...user, 'tripId': t['tripId'], 'startDate': t['startDate'], 'endDate': t['endDate']};
        }).toList();
      }
    }

    if (widget.destinationId != null) {
      final groupR = await ApiService.getGroups(widget.destinationId!);
      if (groupR["success"] == true) _groups = List<Map<String, dynamic>>.from(groupR["data"] ?? []);
    }

    if (mounted) setState(() { _loading = false; _applyFilters(); });
  }

  // ── REAL MATCH SCORING ──
  int _calculateScore(Map<String, dynamic> traveler) {
    int score = 40;

    // Travel style match (+20)
    final myStyle = _currentUser['travelStyle']?.toString() ?? '';
    final theirStyle = traveler['travelStyle']?.toString() ?? '';
    if (myStyle.isNotEmpty && theirStyle.isNotEmpty) {
      if (myStyle == theirStyle) score += 20;
      else {
        const compatible = {
          'Backpacker': ['Explorer', 'Adventure'], 'Explorer': ['Backpacker', 'Photography', 'Adventure'],
          'Foodie': ['Explorer', 'Photography'], 'Photography': ['Explorer', 'Foodie'],
          'Luxury': ['Foodie'], 'Party': ['Backpacker', 'Adventure'],
          'Spiritual': ['Explorer'], 'Adventure': ['Backpacker', 'Explorer', 'Party'],
        };
        if (compatible[myStyle]?.contains(theirStyle) ?? false) score += 10;
      }
    }

    // Age proximity (+15)
    final myAge = _currentUser['age'] as int? ?? 25;
    final theirAge = traveler['age'] as int? ?? 25;
    final ageDiff = (myAge - theirAge).abs();
    if (ageDiff <= 2) score += 15;
    else if (ageDiff <= 5) score += 12;
    else if (ageDiff <= 8) score += 8;
    else if (ageDiff <= 12) score += 4;

    // Schedule match (+10)
    final mySchedule = _currentUser['schedule']?.toString() ?? '';
    final theirSchedule = traveler['schedule']?.toString() ?? '';
    if (mySchedule.isNotEmpty && theirSchedule.isNotEmpty && mySchedule == theirSchedule) score += 10;

    // Social energy match (+10)
    final mySocial = _currentUser['socialEnergy']?.toString() ?? '';
    final theirSocial = traveler['socialEnergy']?.toString() ?? '';
    if (mySocial.isNotEmpty && theirSocial.isNotEmpty) {
      if (mySocial == theirSocial) score += 10;
      else if (mySocial == 'Ambivert' || theirSocial == 'Ambivert') score += 5;
    }

    // Planning style match (+5)
    final myPlanning = _currentUser['planningStyle']?.toString() ?? '';
    final theirPlanning = traveler['planningStyle']?.toString() ?? '';
    if (myPlanning.isNotEmpty && theirPlanning.isNotEmpty && myPlanning == theirPlanning) score += 5;

    return score.clamp(20, 98);
  }

  String _scoreLabel(int score) {
    if (score >= 85) return '🔥 Perfect Match';
    if (score >= 70) return '✨ Great Match';
    if (score >= 55) return '👍 Good Match';
    return '🤝 Decent';
  }

  Color _scoreColor(int score) {
    if (score >= 85) return ZussGoTheme.mint;
    if (score >= 70) return ZussGoTheme.amber;
    if (score >= 55) return ZussGoTheme.sky;
    return ZussGoTheme.textMuted;
  }

  void _applyFilters() {
    _filtered = _travelers.where((t) {
      final age = t['age'] as int? ?? 25;
      if (age < _ageRange.start || age > _ageRange.end) return false;
      if (_genderFilter != null && t['gender'] != _genderFilter) return false;
      if (_styleFilter != null && t['travelStyle'] != _styleFilter) return false;
      if (_mindsetFilter != null) {
        if (t['schedule'] != _mindsetFilter && t['socialEnergy'] != _mindsetFilter && t['planningStyle'] != _mindsetFilter) return false;
      }
      return true;
    }).toList();
    // Sort by match score descending
    _filtered.sort((a, b) => _calculateScore(b).compareTo(_calculateScore(a)));
  }

  void _clearFilters() { setState(() { _ageRange = const RangeValues(18, 40); _genderFilter = null; _styleFilter = null; _mindsetFilter = null; _applyFilters(); }); }
  bool get _hasFilters => _genderFilter != null || _styleFilter != null || _mindsetFilter != null || _ageRange.start != 18 || _ageRange.end != 40;

  Color _c(int i) { const cs = [ZussGoTheme.mint, ZussGoTheme.amber, ZussGoTheme.sky, ZussGoTheme.rose, ZussGoTheme.lavender]; return cs[i % cs.length]; }

  Widget _chip(String label, bool sel, VoidCallback onTap) => GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: sel ? ZussGoTheme.green : ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: sel ? FontWeight.w600 : FontWeight.w400, color: sel ? Colors.white : ZussGoTheme.textSecondary))));

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: ZussGoTheme.bgPrimary, body: SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(22, 10, 22, 0), child: Row(children: [
        GestureDetector(onTap: () => context.pop(), child: Container(width: 34, height: 34, decoration: BoxDecoration(color: ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.arrow_back_rounded, color: ZussGoTheme.textSecondary, size: 18))),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('🏖️ ${widget.destinationName}', style: ZussGoTheme.displaySmall),
          Text('${_filtered.length} travelers • ${_groups.length} groups', style: ZussGoTheme.bodySmall),
        ])),
        GestureDetector(onTap: () => setState(() => _showFilters = !_showFilters),
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: _hasFilters ? ZussGoTheme.green : ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.tune_rounded, size: 16, color: _hasFilters ? Colors.white : ZussGoTheme.textSecondary))),
      ])),
      const SizedBox(height: 10),

      // Toggle
      Padding(padding: const EdgeInsets.symmetric(horizontal: 22), child: Container(
        decoration: BoxDecoration(color: ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.all(3),
        child: Row(children: [
          _tab('Solo', !_showGroups, () => setState(() => _showGroups = false)),
          _tab('Groups', _showGroups, () => setState(() => _showGroups = true)),
        ]),
      )),

      // Filters
      if (_showFilters && !_showGroups)
        Container(margin: const EdgeInsets.fromLTRB(22, 10, 22, 0), padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Age: ${_ageRange.start.round()} — ${_ageRange.end.round()}', style: ZussGoTheme.labelBold.copyWith(fontSize: 12)),
              if (_hasFilters) GestureDetector(onTap: _clearFilters, child: Text('Clear', style: TextStyle(fontSize: 11, color: ZussGoTheme.rose, fontWeight: FontWeight.w600))),
            ]),
            RangeSlider(values: _ageRange, min: 18, max: 60, divisions: 42, activeColor: ZussGoTheme.green, inactiveColor: ZussGoTheme.borderDefault,
                onChanged: (v) => setState(() { _ageRange = v; _applyFilters(); })),
            Text('Gender', style: ZussGoTheme.labelBold.copyWith(fontSize: 12)), const SizedBox(height: 4),
            Wrap(spacing: 6, runSpacing: 6, children: ['Male', 'Female', 'Other'].map((g) => _chip(g, _genderFilter == g, () => setState(() { _genderFilter = _genderFilter == g ? null : g; _applyFilters(); }))).toList()),
            const SizedBox(height: 10),
            Text('Style', style: ZussGoTheme.labelBold.copyWith(fontSize: 12)), const SizedBox(height: 4),
            Wrap(spacing: 6, runSpacing: 6, children: _styles.map((s) => _chip(s, _styleFilter == s, () => setState(() { _styleFilter = _styleFilter == s ? null : s; _applyFilters(); }))).toList()),
            const SizedBox(height: 10),
            Text('Mindset', style: ZussGoTheme.labelBold.copyWith(fontSize: 12)), const SizedBox(height: 4),
            Wrap(spacing: 6, runSpacing: 6, children: _mindsets.map((m) => _chip(m, _mindsetFilter == m, () => setState(() { _mindsetFilter = _mindsetFilter == m ? null : m; _applyFilters(); }))).toList()),
          ]),
        ),

      const SizedBox(height: 10),
      const Divider(color: ZussGoTheme.borderDefault, height: 1),

      Expanded(child: _loading ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: ZussGoTheme.green))
          : !_showGroups ? _buildSoloList() : _buildGroupsList()),
    ])));
  }

  Widget _tab(String label, bool active, VoidCallback onTap) => Expanded(child: GestureDetector(onTap: onTap,
      child: Container(padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: active ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(10),
              boxShadow: active ? [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4)] : null),
          child: Center(child: Text(label, style: TextStyle(fontSize: 13, fontWeight: active ? FontWeight.w600 : FontWeight.w400, color: active ? ZussGoTheme.textPrimary : ZussGoTheme.textMuted))))));

  Widget _buildSoloList() {
    if (_filtered.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('🔍', style: TextStyle(fontSize: 36)), const SizedBox(height: 8),
      Text('No travelers found', style: ZussGoTheme.displaySmall),
      Text(_hasFilters ? 'Try adjusting filters' : 'Be the first to go!', style: ZussGoTheme.bodySmall)]));

    return ListView.builder(padding: const EdgeInsets.fromLTRB(22, 10, 22, 20), itemCount: _filtered.length, itemBuilder: (_, i) {
      final t = _filtered[i];
      final score = _calculateScore(t);
      final sColor = _scoreColor(score);

      return GestureDetector(onTap: () => context.push('/traveler/${t['id'] ?? ''}', extra: {'tripId': t['tripId']}),
          child: Container(padding: const EdgeInsets.all(14), margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                  border: Border(left: BorderSide(color: sColor, width: 3)),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8)]),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(_scoreLabel(score), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: sColor)),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: sColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text('$score%', style: TextStyle(fontFamily: 'Playfair Display', fontSize: 14, fontWeight: FontWeight.w700, color: sColor))),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Container(width: 44, height: 44, decoration: BoxDecoration(color: _c(i).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14)),
                      alignment: Alignment.center, child: Text((t['fullName'] ?? 'U')[0], style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _c(i), fontFamily: 'Playfair Display'))),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${t['fullName'] ?? 'Unknown'}${t['age'] != null ? ', ${t['age']}' : ''}', style: ZussGoTheme.labelBold),
                    Text('${t['city'] ?? 'Explorer'} • ${t['travelStyle'] ?? 'Adventurer'}', style: ZussGoTheme.bodySmall),
                    if (t['schedule'] != null || t['socialEnergy'] != null)
                      Padding(padding: const EdgeInsets.only(top: 3), child: Wrap(spacing: 3, children: [
                        if (t['schedule'] != null) Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1), decoration: BoxDecoration(color: ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(4)),
                            child: Text(t['schedule'] == 'Early Bird' ? '🌅 ${t['schedule']}' : '🦉 ${t['schedule']}', style: const TextStyle(fontSize: 8, color: ZussGoTheme.textMuted))),
                        if (t['socialEnergy'] != null) Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1), decoration: BoxDecoration(color: ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(4)),
                            child: Text('${t['socialEnergy']}', style: const TextStyle(fontSize: 8, color: ZussGoTheme.textMuted))),
                      ])),
                  ])),
                ]),
                const SizedBox(height: 8),
                Center(child: Text('View Profile →', style: TextStyle(fontSize: 12, color: ZussGoTheme.green, fontWeight: FontWeight.w600))),
              ])));
    });
  }

  Widget _buildGroupsList() {
    if (_groups.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('👥', style: TextStyle(fontSize: 36)), const SizedBox(height: 8),
      Text('No groups yet', style: ZussGoTheme.displaySmall), Text('Create the first group!', style: ZussGoTheme.bodySmall)]));

    return ListView.builder(padding: const EdgeInsets.fromLTRB(22, 10, 22, 20), itemCount: _groups.length + 1, itemBuilder: (_, i) {
      if (i == _groups.length) return Container(padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(border: Border.all(color: ZussGoTheme.green), borderRadius: BorderRadius.circular(16)),
          child: Center(child: Text('+ Create a Group Trip', style: TextStyle(fontSize: 13, color: ZussGoTheme.green, fontWeight: FontWeight.w600))));

      final g = _groups[i];
      final members = List<Map<String, dynamic>>.from(g['members'] ?? []);
      final memberCount = g['memberCount'] ?? g['_count']?['members'] ?? members.length;
      final maxMembers = g['maxMembers'] ?? 6;
      final creator = members.isNotEmpty ? (members[0]['user']?['fullName'] ?? 'Creator') : 'Creator';

      return Container(margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)]),
          child: Column(children: [
            Container(height: 70, width: double.infinity,
                decoration: BoxDecoration(gradient: LinearGradient(colors: [_c(i), _c(i + 2)]),
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18))),
                child: Stack(children: [
                  Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withValues(alpha: 0.4)]),
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18)))),
                  Positioned(bottom: 8, left: 12, child: Text(g['name'] ?? 'Group Trip', style: const TextStyle(fontFamily: 'Playfair Display', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white))),
                  Positioned(top: 6, right: 6, child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(5)),
                      child: Text('$memberCount/$maxMembers', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)))),
                ])),
            Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${g['budget'] ?? ''} • By $creator', style: ZussGoTheme.bodySmall),
              const SizedBox(height: 8),
              if (members.isNotEmpty) Row(children: members.take(4).toList().asMap().entries.map((e) {
                final m = e.value['user'] ?? {};
                return Container(width: 24, height: 24, margin: EdgeInsets.only(left: e.key > 0 ? -6 : 0),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: _c(e.key), border: Border.all(color: Colors.white, width: 1.5)),
                    alignment: Alignment.center, child: Text((m['fullName'] ?? 'U')[0], style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white)));
              }).toList()),
              const SizedBox(height: 10),
              GestureDetector(onTap: () async {
                final user = await AuthService.getSavedUser();
                if (user?['userId'] == null) return;
                final r = await ApiService.joinGroup(g['id'], user!['userId']);
                if (r['success'] == true && mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Join request sent! 🙌'), backgroundColor: ZussGoTheme.green)); _load(); }
              }, child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(gradient: ZussGoTheme.gradientPrimary, borderRadius: BorderRadius.circular(12)),
                  child: const Center(child: Text('Join Group 🙌', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13))))),
            ])),
          ]));
    });
  }
}