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

    final userId = _currentUser['userId'];
    final destR = await ApiService.getDestinationBySlug(widget.destinationSlug, userId: userId);
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
    if (score >= 85) return 'Perfect Match';
    if (score >= 70) return 'Great Match';
    if (score >= 55) return 'Good Match';
    return 'Fair Match';
  }

  Color _scoreColor(int score) {
    if (score >= 85) return context.colors.mint;
    if (score >= 70) return context.colors.amber;
    if (score >= 55) return context.colors.sky;
    return context.colors.textMuted;
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

  Color _c(int i) { final cs = [context.colors.mint, context.colors.amber, context.colors.sky, context.colors.rose, ZussGoTheme.lavender]; return cs[i % cs.length]; }

  Widget _chip(String label, bool sel, VoidCallback onTap) => GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: sel ? context.colors.green : ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: sel ? FontWeight.w600 : FontWeight.w400, color: sel ? Colors.white : ZussGoTheme.textSecondary))));

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: ZussGoTheme.scaffoldBg(context), body: SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(22, 10, 22, 0), child: Row(children: [
        GestureDetector(onTap: () => context.pop(), child: Container(width: 36, height: 36, decoration: BoxDecoration(color: ZussGoTheme.mutedBg(context), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.arrow_back_rounded, color: ZussGoTheme.secondaryText(context), size: 18))),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Icon(Icons.place_rounded, size: 18, color: context.colors.green),
              const SizedBox(width: 6),
              Text(_showGroups ? '${widget.destinationName} Groups' : widget.destinationName, style: const TextStyle(fontFamily: 'Playfair Display', fontSize: 22, fontWeight: FontWeight.w700)),
            ],
          ),
          Text(_showGroups ? '${_groups.length} open groups' : '${_filtered.length} travelers • ${_groups.length} groups', style: context.textTheme.bodySmall!.adaptive(context)),
        ])),
      ])),
      const SizedBox(height: 16),

      // Toggle
      Padding(padding: const EdgeInsets.symmetric(horizontal: 22), child: Container(
        decoration: BoxDecoration(color: ZussGoTheme.mutedBg(context), borderRadius: BorderRadius.circular(14)), padding: const EdgeInsets.all(4),
        child: Row(children: [
          _tab('Solo', !_showGroups, () => setState(() => _showGroups = false)),
          _tab('Groups', _showGroups, () => setState(() => _showGroups = true)),
        ]),
      )),
      const SizedBox(height: 16),

      // Scrollable Filter Pills
      if (!_showGroups)
        SizedBox(
          height: 38,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            scrollDirection: Axis.horizontal,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: context.colors.green, borderRadius: BorderRadius.circular(20)),
                child: const Center(child: Text('20-28', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12))),
              ),
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: context.colors.green, borderRadius: BorderRadius.circular(20)),
                child: const Center(child: Text('Backpacker', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12))),
              ),
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: context.colors.green, borderRadius: BorderRadius.circular(20)),
                child: const Center(child: Text('Budget', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12))),
              ),
              GestureDetector(
                onTap: () => setState(() => _showFilters = !_showFilters),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: ZussGoTheme.mutedBg(context), borderRadius: BorderRadius.circular(20)),
                  child: const Center(child: Icon(Icons.settings_rounded, size: 16, color: Colors.grey)),
                ),
              ),
            ],
          ),
        ),

      // Filters
      if (_showFilters && !_showGroups)
        Container(margin: const EdgeInsets.fromLTRB(22, 10, 22, 0), padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: ZussGoTheme.cardBg(context), 
            borderRadius: BorderRadius.circular(18), 
            border: Theme.of(context).brightness == Brightness.dark ? Border.all(color: ZussGoTheme.border(context)) : null,
            boxShadow: [if (Theme.of(context).brightness == Brightness.light) BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)]
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Age: ${_ageRange.start.round()} — ${_ageRange.end.round()}', style: context.textTheme.labelLarge!.copyWith(fontSize: 12)),
              if (_hasFilters) GestureDetector(onTap: _clearFilters, child: Text('Clear', style: TextStyle(fontSize: 11, color: context.colors.rose, fontWeight: FontWeight.w600))),
            ]),
            RangeSlider(values: _ageRange, min: 18, max: 60, divisions: 42, activeColor: context.colors.green, inactiveColor: ZussGoTheme.borderDefault,
                onChanged: (v) => setState(() { _ageRange = v; _applyFilters(); })),
            Text('Gender', style: context.textTheme.labelLarge!.copyWith(fontSize: 12)), SizedBox(height: 4),
            Wrap(spacing: 6, runSpacing: 6, children: ['Male', 'Female', 'Other'].map((g) => _chip(g, _genderFilter == g, () => setState(() { _genderFilter = _genderFilter == g ? null : g; _applyFilters(); }))).toList()),
            const SizedBox(height: 10),
            Text('Style', style: context.textTheme.labelLarge!.copyWith(fontSize: 12)), SizedBox(height: 4),
            Wrap(spacing: 6, runSpacing: 6, children: _styles.map((s) => _chip(s, _styleFilter == s, () => setState(() { _styleFilter = _styleFilter == s ? null : s; _applyFilters(); }))).toList()),
            const SizedBox(height: 10),
            Text('Mindset', style: context.textTheme.labelLarge!.copyWith(fontSize: 12)), SizedBox(height: 4),
            Wrap(spacing: 6, runSpacing: 6, children: _mindsets.map((m) => _chip(m, _mindsetFilter == m, () => setState(() { _mindsetFilter = _mindsetFilter == m ? null : m; _applyFilters(); }))).toList()),
          ]),
        ),

      const SizedBox(height: 10),
      Divider(color: ZussGoTheme.border(context), height: 1),

      Expanded(child: _loading ? Center(child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.green))
          : !_showGroups ? _buildSoloList() : _buildGroupsList()),
    ])));
  }

  Widget _tab(String label, bool active, VoidCallback onTap) => Expanded(child: GestureDetector(onTap: onTap,
      child: Container(padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: active ? ZussGoTheme.cardBg(context) : Colors.transparent, borderRadius: BorderRadius.circular(10),
              boxShadow: active && Theme.of(context).brightness == Brightness.light ? [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4)] : null),
          child: Center(child: Text(label, style: TextStyle(fontSize: 13, fontWeight: active ? FontWeight.w600 : FontWeight.w400, color: active ? ZussGoTheme.primaryText(context) : ZussGoTheme.mutedText(context)))))));

  Widget _buildSoloList() {
    if (_filtered.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.person_search_rounded, size: 44, color: context.colors.green.withValues(alpha: 0.4)), SizedBox(height: 8),
      Text('No travelers found', style: context.textTheme.displaySmall!.adaptive(context)),
      Text(_hasFilters ? 'Try adjusting filters' : 'Be the first to go!', style: context.textTheme.bodySmall!.adaptive(context))]));

    return ListView.builder(padding: const EdgeInsets.fromLTRB(22, 10, 22, 20), itemCount: _filtered.length, itemBuilder: (_, i) {
      final t = _filtered[i];
      final score = _calculateScore(t);
      final sColor = _scoreColor(score);

      return GestureDetector(onTap: () => context.push('/traveler/${t['id'] ?? ''}', extra: {'tripId': t['tripId'], 'score': score.roundToDouble()}),
          child: Container(margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Theme.of(context).brightness == Brightness.dark ? Border.all(color: ZussGoTheme.border(context)) : null,
                  boxShadow: [if (Theme.of(context).brightness == Brightness.light) BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ZussGoTheme.cardBg(context),
                    border: Border(left: BorderSide(color: sColor, width: 4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(_scoreLabel(score), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: sColor)),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: sColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                            child: Text('$score%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: sColor))),
                      ]),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Container(width: 44, height: 44, decoration: BoxDecoration(color: _c(i).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14)),
                            alignment: Alignment.center, child: Text((t['fullName'] ?? 'U')[0], style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _c(i), fontFamily: 'Playfair Display'))),
                        const SizedBox(width: 10),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                          Text('${t['fullName'] ?? 'Unknown'}${t['age'] != null ? ', ${t['age']}' : ''}', style: context.textTheme.labelLarge!.adaptive(context)),
                          Text('${t['city'] ?? 'Explorer'} • ${t['travelStyle'] ?? 'Adventurer'}', style: context.textTheme.bodySmall!.adaptive(context)),
                          if (t['schedule'] != null || t['socialEnergy'] != null)
                            Padding(padding: const EdgeInsets.only(top: 4), child: Wrap(spacing: 4, runSpacing: 4, children: [
                              if (t['schedule'] != null) Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2), decoration: BoxDecoration(color: ZussGoTheme.mutedBg(context), borderRadius: BorderRadius.circular(4)),
                                  child: Text('${t['schedule']}', style: TextStyle(fontSize: 9, color: ZussGoTheme.mutedText(context)))),
                              if (t['socialEnergy'] != null) Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2), decoration: BoxDecoration(color: ZussGoTheme.mutedBg(context), borderRadius: BorderRadius.circular(4)),
                                  child: Text('${t['socialEnergy']}', style: TextStyle(fontSize: 9, color: ZussGoTheme.mutedText(context)))),
                            ])),
                        ])),
                      ]),
                      const SizedBox(height: 12),
                      Center(child: Text('View Profile →', style: TextStyle(fontSize: 13, color: context.colors.green, fontWeight: FontWeight.w700))),
                    ]
                  ),
                ),
              )));
    });
  }

  void _showCreateGroupModal() {
    if (widget.destinationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot create group for this destination')));
      return;
    }

    final formKey = GlobalKey<FormState>();
    String name = '';
    String budget = 'Budget';
    int maxMembers = 6;
    String genderFilter = 'Everyone';
    DateTime? startDate;
    DateTime? endDate;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
              decoration: BoxDecoration(
                color: ZussGoTheme.scaffoldBg(ctx),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Create Group Trip', style: context.textTheme.displayLarge!.copyWith(fontSize: 22)),
                      const SizedBox(height: 16),
                      Text('Group Name', style: context.textTheme.labelLarge!.copyWith(fontSize: 12)),
                      const SizedBox(height: 6),
                      TextFormField(
                        decoration: ZussGoTheme.inputDecorationOf(ctx, hint: 'e.g., Goa Backpackers'),
                        style: context.textTheme.bodyMedium!.adaptive(ctx),
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                        onSaved: (v) => name = v!,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Budget Style', style: context.textTheme.labelLarge!.copyWith(fontSize: 12)),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  value: budget,
                                  decoration: ZussGoTheme.inputDecorationOf(ctx),
                                  dropdownColor: ZussGoTheme.cardBg(ctx),
                                  style: context.textTheme.bodyMedium!.adaptive(ctx),
                                  items: ['Budget', 'Mid-range', 'Luxury']
                                      .map((b) => DropdownMenuItem(value: b, child: Text(b, style: const TextStyle(fontSize: 14))))
                                      .toList(),
                                  onChanged: (v) => setModalState(() => budget = v!),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Who can join?', style: context.textTheme.labelLarge!.copyWith(fontSize: 12)),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  value: genderFilter,
                                  decoration: ZussGoTheme.inputDecorationOf(ctx),
                                  dropdownColor: ZussGoTheme.cardBg(ctx),
                                  style: context.textTheme.bodyMedium!.adaptive(ctx),
                                  items: ['Everyone', 'Women only', 'Men only']
                                      .map((b) => DropdownMenuItem(value: b, child: Text(b, style: const TextStyle(fontSize: 14))))
                                      .toList(),
                                  onChanged: (v) => setModalState(() => genderFilter = v!),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('Trip Dates', style: context.textTheme.labelLarge!.copyWith(fontSize: 12)),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () async {
                          final range = await showDateRangePicker(
                            context: ctx,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                            builder: (c, child) => Theme(data: Theme.of(context).copyWith(colorScheme: Theme.of(context).colorScheme.copyWith(primary: context.colors.green)), child: child!),
                          );
                          if (range != null) {
                            setModalState(() {
                              startDate = range.start;
                              endDate = range.end;
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: ZussGoTheme.mutedBg(ctx),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: ZussGoTheme.border(ctx)),
                          ),
                          child: Text(
                            startDate != null && endDate != null
                                ? '${startDate!.day}/${startDate!.month}/${startDate!.year} - ${endDate!.day}/${endDate!.month}/${endDate!.year}'
                                : 'Select trip dates',
                            style: context.textTheme.bodyMedium!.copyWith(
                              color: startDate != null ? ZussGoTheme.primaryText(ctx) : ZussGoTheme.mutedText(ctx),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Max Travelers ($maxMembers)', style: context.textTheme.labelLarge!.copyWith(fontSize: 12)),
                      Slider(
                        value: maxMembers.toDouble(),
                        min: 3, max: 10, divisions: 7,
                        activeColor: context.colors.green, inactiveColor: ZussGoTheme.borderDefault,
                        onChanged: (v) => setModalState(() => maxMembers = v.toInt()),
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () async {
                          if (!formKey.currentState!.validate()) return;
                          if (startDate == null || endDate == null) {
                            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Please select trip dates'), backgroundColor: context.colors.rose));
                            return;
                          }
                          formKey.currentState!.save();
                          
                          if (_currentUser['userId'] == null) {
                            final u = await AuthService.getSavedUser();
                            if (u != null) _currentUser = u;
                            if (_currentUser['userId'] == null) {
                              if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Session expired. Please log in again.'), backgroundColor: context.colors.rose));
                              return;
                            }
                          }

                          setModalState(() => isSubmitting = true);

                          final r = await ApiService.createGroup({
                            'destinationId': widget.destinationId,
                            'userId': _currentUser['userId'],
                            'name': name,
                            'budget': budget,
                            'maxMembers': maxMembers,
                            'genderFilter': genderFilter,
                            'startDate': startDate!.toUtc().toIso8601String(),
                            'endDate': endDate!.toUtc().toIso8601String(),
                          });

                          setModalState(() => isSubmitting = false);

                          if (r['success'] == true) {
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Group created.'), backgroundColor: context.colors.green));
                              _load();
                            }
                          } else {
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(r['message'] ?? 'Failed to create group'), backgroundColor: context.colors.rose));
                            }
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(gradient: ZussGoTheme.gradientPrimary, borderRadius: BorderRadius.circular(16)),
                          child: Center(
                            child: isSubmitting
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Create Group', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGroupsList() {
    return Column(children: [
      Expanded(
        child: _groups.isEmpty ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.group_rounded, size: 44, color: context.colors.green.withValues(alpha: 0.4)), SizedBox(height: 8),
          Text('No groups yet', style: context.textTheme.displaySmall!.adaptive(context)), Text('Create the first group!', style: context.textTheme.bodySmall!.adaptive(context))]))
        : ListView.builder(padding: const EdgeInsets.fromLTRB(22, 10, 22, 10), itemCount: _groups.length, itemBuilder: (_, i) {
            final g = _groups[i];
      final members = List<Map<String, dynamic>>.from(g['members'] ?? []);
      final memberCount = g['memberCount'] ?? g['_count']?['members'] ?? members.length;
      final maxMembers = g['maxMembers'] ?? 6;
      final creator = members.isNotEmpty ? (members[0]['user']?['fullName'] ?? 'Creator') : 'Creator';

      return Container(margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(color: ZussGoTheme.cardBg(context), borderRadius: BorderRadius.circular(18), border: Theme.of(context).brightness == Brightness.dark ? Border.all(color: ZussGoTheme.border(context)) : null, boxShadow: [if (Theme.of(context).brightness == Brightness.light) BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)]),
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
              Text('${g['budget'] ?? ''} • By $creator', style: context.textTheme.bodySmall!.adaptive(context)),
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
                if (r['success'] == true && mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Join request sent.'), backgroundColor: context.colors.green)); _load(); }
              }, child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(gradient: ZussGoTheme.gradientPrimary, borderRadius: BorderRadius.circular(12)),
                  child: const Center(child: Text('Join Group', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13))))),
            ])),
          ]));
        }),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(22, 10, 22, 20),
        child: GestureDetector(
          onTap: _showCreateGroupModal,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(border: Border.all(color: context.colors.green, width: 1.5), borderRadius: BorderRadius.circular(16)),
            child: Center(child: Text('+ Create a Group Trip', style: TextStyle(fontSize: 14, color: context.colors.green, fontWeight: FontWeight.w600))),
          ),
        ),
      ),
    ]);
  }
}