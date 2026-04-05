import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';

class SeeAllTravelersScreen extends StatefulWidget {
  const SeeAllTravelersScreen({super.key});
  @override
  State<SeeAllTravelersScreen> createState() => _SeeAllTravelersScreenState();
}

class _SeeAllTravelersScreenState extends State<SeeAllTravelersScreen> {
  List<Map<String, dynamic>> _travelers = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;

  // Filters
  RangeValues _ageRange = const RangeValues(18, 40);
  String? _genderFilter;
  String? _styleFilter;
  String? _mindsetFilter;
  bool _showFilters = false;

  final _styles = ['Backpacker', 'Explorer', 'Foodie', 'Photography', 'Luxury', 'Party', 'Spiritual', 'Adventure'];
  final _mindsets = ['Early Bird', 'Night Owl', 'Social Butterfly', 'Ambivert', 'Introvert', 'Planner', 'Spontaneous'];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final u = await AuthService.getSavedUser();
    if (u?['userId'] == null) { setState(() => _loading = false); return; }
    final r = await AuthService.getUsers(userId: u!['userId']);
    if (mounted) setState(() {
      _loading = false;
      if (r["success"] == true) _travelers = List<Map<String, dynamic>>.from(r["data"] ?? []);
      _applyFilters();
    });
  }

  void _applyFilters() {
    _filtered = _travelers.where((t) {
      final age = t['age'] as int? ?? 25;
      if (age < _ageRange.start || age > _ageRange.end) return false;
      if (_genderFilter != null && t['gender'] != _genderFilter) return false;
      if (_styleFilter != null && t['travelStyle'] != _styleFilter) return false;
      if (_mindsetFilter != null) {
        final schedule = t['schedule'] ?? '';
        final social = t['socialEnergy'] ?? '';
        final planning = t['planningStyle'] ?? '';
        if (schedule != _mindsetFilter && social != _mindsetFilter && planning != _mindsetFilter) return false;
      }
      return true;
    }).toList();
  }

  void _clearFilters() { setState(() { _ageRange = const RangeValues(18, 40); _genderFilter = null; _styleFilter = null; _mindsetFilter = null; _applyFilters(); }); }

  Color _c(int i) { final cs = [context.colors.green, context.colors.sky, context.colors.amber, context.colors.rose, ZussGoTheme.lavender]; return cs[i % cs.length]; }

  Widget _buildChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: selected ? context.colors.green : ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: selected ? FontWeight.w600 : FontWeight.w400, color: selected ? Colors.white : ZussGoTheme.textSecondary)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final hasFilters = _genderFilter != null || _styleFilter != null || _mindsetFilter != null || _ageRange.start != 18 || _ageRange.end != 40;

    return Scaffold(backgroundColor: ZussGoTheme.scaffoldBg(context), body: SafeArea(child: Column(children: [
      // Header
      Padding(padding: const EdgeInsets.fromLTRB(22, 10, 22, 0), child: Row(children: [
        GestureDetector(onTap: () => context.pop(), child: Container(width: 34, height: 34, decoration: BoxDecoration(color: ZussGoTheme.mutedBg(context), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.arrow_back_rounded, color: ZussGoTheme.secondaryText(context), size: 18))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('All Travelers', style: context.textTheme.displaySmall!.adaptive(context)),
          Text('${_filtered.length} travelers found', style: context.textTheme.bodySmall!.adaptive(context)),
        ])),
        GestureDetector(
          onTap: () => setState(() => _showFilters = !_showFilters),
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: hasFilters ? context.colors.green : ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(12)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.tune_rounded, size: 16, color: hasFilters ? Colors.white : ZussGoTheme.textSecondary),
              const SizedBox(width: 4),
              Text('Filters', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: hasFilters ? Colors.white : ZussGoTheme.textSecondary)),
            ]),
          ),
        ),
      ])),
      const SizedBox(height: 10),

      // Filters panel
      if (_showFilters) Container(
        margin: const EdgeInsets.symmetric(horizontal: 22),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Age
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Age Range', style: context.textTheme.labelLarge!.copyWith(fontSize: 12)),
            Text('${_ageRange.start.round()} — ${_ageRange.end.round()}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.colors.green)),
          ]),
          RangeSlider(values: _ageRange, min: 18, max: 60, divisions: 42,
              activeColor: context.colors.green, inactiveColor: ZussGoTheme.borderDefault,
              onChanged: (v) => setState(() { _ageRange = v; _applyFilters(); })),

          // Gender
          Text('Gender', style: context.textTheme.labelLarge!.copyWith(fontSize: 12)),
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 6, children: ['Male', 'Female', 'Other'].map((g) => _buildChip(g, _genderFilter == g, () => setState(() { _genderFilter = _genderFilter == g ? null : g; _applyFilters(); }))).toList()),
          const SizedBox(height: 12),

          // Travel Style
          Text('Travel Style', style: context.textTheme.labelLarge!.copyWith(fontSize: 12)),
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 6, children: _styles.map((s) => _buildChip(s, _styleFilter == s, () => setState(() { _styleFilter = _styleFilter == s ? null : s; _applyFilters(); }))).toList()),
          const SizedBox(height: 12),

          // Mindset
          Text('Mindset', style: context.textTheme.labelLarge!.copyWith(fontSize: 12)),
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 6, children: _mindsets.map((m) => _buildChip(m, _mindsetFilter == m, () => setState(() { _mindsetFilter = _mindsetFilter == m ? null : m; _applyFilters(); }))).toList()),
          const SizedBox(height: 10),

          if (hasFilters) GestureDetector(onTap: _clearFilters, child: Center(child: Text('Clear all filters', style: TextStyle(fontSize: 12, color: context.colors.rose, fontWeight: FontWeight.w600)))),
        ]),
      ),

      // Active filter chips
      if (hasFilters && !_showFilters) Padding(padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
          child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
            if (_ageRange.start != 18 || _ageRange.end != 40) _activeChip('${_ageRange.start.round()}-${_ageRange.end.round()} yrs'),
            if (_genderFilter != null) _activeChip(_genderFilter!),
            if (_styleFilter != null) _activeChip(_styleFilter!),
            if (_mindsetFilter != null) _activeChip(_mindsetFilter!),
            const SizedBox(width: 4),
            GestureDetector(onTap: _clearFilters, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(border: Border.all(color: ZussGoTheme.border(context)), borderRadius: BorderRadius.circular(8)),
                child: Text('✕ Clear', style: TextStyle(fontSize: 10, color: ZussGoTheme.mutedText(context))))),
          ]))),

      const SizedBox(height: 6),
      Divider(color: ZussGoTheme.border(context), height: 1),

      // List
      Expanded(child: _loading
          ? Center(child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.green))
          : _filtered.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.person_search_rounded, size: 40, color: context.colors.green.withValues(alpha: 0.4)), SizedBox(height: 8), Text('No travelers match', style: context.textTheme.displaySmall!.adaptive(context)), SizedBox(height: 4), Text('Try adjusting your filters', style: context.textTheme.bodySmall!.adaptive(context))]))
          : ListView.builder(padding: const EdgeInsets.fromLTRB(22, 8, 22, 20), itemCount: _filtered.length, itemBuilder: (_, i) {
        final t = _filtered[i];
        return GestureDetector(
          onTap: () => context.push('/traveler/${t['id'] ?? ''}'),
          child: Container(padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 8), decoration: ZussGoTheme.cardDecoration(context),
              child: Row(children: [
                Container(width: 48, height: 48, decoration: BoxDecoration(color: _c(i).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14)),
                    alignment: Alignment.center, child: Text((t['fullName'] ?? 'U')[0], style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _c(i), fontFamily: 'Playfair Display'))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${t['fullName'] ?? 'Unknown'}${t['age'] != null ? ', ${t['age']}' : ''}', style: context.textTheme.labelLarge!.adaptive(context)),
                  Text('${t['city'] ?? 'Explorer'} • ${t['gender'] ?? ''}', style: context.textTheme.bodySmall!.adaptive(context)),
                  const SizedBox(height: 4),
                  Wrap(spacing: 4, children: [
                    if (t['travelStyle'] != null) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: context.colors.greenLight, borderRadius: BorderRadius.circular(6)),
                        child: Text(t['travelStyle'] ?? '', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500, color: context.colors.green))),
                    if (t['schedule'] != null) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: ZussGoTheme.mutedBg(context), borderRadius: BorderRadius.circular(6)),
                        child: Text('${t['schedule']}', style: TextStyle(fontSize: 9, color: ZussGoTheme.mutedText(context)))),
                  ]),
                ])),
                Icon(Icons.chevron_right_rounded, color: ZussGoTheme.mutedText(context), size: 18),
              ])),
        );
      })),
    ])));
  }

  Widget _activeChip(String label) => Container(margin: const EdgeInsets.only(right: 4), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: context.colors.green, borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white)));
}