import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
  List<Map<String, dynamic>> _groups = [];
  Map<String, dynamic> _currentUser = {};
  bool _loading = true;
  bool _showGroups = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final u = await AuthService.getSavedUser();
    if (u != null) _currentUser = u;
    final userId = u?['userId'];
    if (userId != null) {
      final travR = await AuthService.getUsers(userId: userId);
      if (travR['success'] == true) _travelers = List<Map<String, dynamic>>.from(travR['data'] ?? []);
    }
    if (widget.destinationId != null) {
      final groupR = await ApiService.getGroups(widget.destinationId!);
      if (groupR['success'] == true) _groups = List<Map<String, dynamic>>.from(groupR['data'] ?? []);
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      body: Column(children: [
        // Header
        Padding(
          padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 0),
          child: Row(children: [
            GestureDetector(onTap: () => context.pop(),
                child: Container(width: 40, height: 40, decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(13)),
                    child: Icon(Icons.arrow_back_rounded, color: c.text, size: 16))),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.destinationName, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: c.text)),
              Text('${_travelers.length} travelers · ${_groups.length} groups', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: c.muted)),
            ])),
            GestureDetector(onTap: _showCreateGroupModal,
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: c.primarySoft, borderRadius: BorderRadius.circular(12)),
                    child: Text('+ Group', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: c.primary)))),
          ]),
        ),

        // Tabs
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(children: [
            _Tab(label: 'Travelers', active: !_showGroups, onTap: () => setState(() => _showGroups = false), c: c),
            const SizedBox(width: 8),
            _Tab(label: 'Groups', active: _showGroups, onTap: () => setState(() => _showGroups = true), c: c),
          ]),
        ),

        Expanded(
          child: _loading
              ? Center(child: CircularProgressIndicator(strokeWidth: 2, color: c.primary))
              : !_showGroups ? _buildTravelers(c) : _buildGroups(c),
        ),
      ]),
    );
  }

  Widget _buildTravelers(ZussGoColors c) {
    if (_travelers.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('🗺️', style: TextStyle(fontSize: 44)), const SizedBox(height: 12),
      Text('No travelers yet', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: c.text)),
    ]));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: _travelers.length,
      itemBuilder: (_, i) {
        final t = _travelers[i];
        final name = t['fullName'] ?? 'Traveler';
        final photo = t['profilePhotoUrl'];
        final matchScore = 94 - (i * 4);
        return GestureDetector(
          onTap: () => context.push('/traveler/${t['id'] ?? ''}'),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Row(children: [
                Container(width: 52, height: 52, decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: LinearGradient(colors: [c.primary.withValues(alpha: 0.3), c.card])),
                    clipBehavior: Clip.hardEdge,
                    child: photo != null ? Image.network(photo, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _initial(name, c)) : _initial(name, c)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: c.text)),
                  Text('${t['city'] ?? 'India'} · ${t['travelStyle'] ?? 'Explorer'}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: c.muted)),
                ])),
                Text('$matchScore%', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: c.primary)),
              ]),
            ),
          ),
        );
      },
    );
  }

  Widget _initial(String name, ZussGoColors c) => Center(child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: c.primary)));

  Widget _buildGroups(ZussGoColors c) {
    if (_groups.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('👥', style: TextStyle(fontSize: 44)), const SizedBox(height: 12),
      Text('No groups yet', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: c.text)),
      const SizedBox(height: 16),
      GestureDetector(onTap: _showCreateGroupModal,
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(12)),
              child: Text('+ Create Group', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)))),
    ]));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: _groups.length,
      itemBuilder: (_, i) {
        final g = _groups[i];
        final dest = g['destination'] ?? {};
        final memberCount = g['memberCount'] ?? g['_count']?['members'] ?? 0;
        final maxMembers = g['maxMembers'] ?? 6;
        final isFull = g['isFull'] == true;
        return GestureDetector(
          onTap: () => context.push('/group/${g['id']}'),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(18)),
            child: Row(children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(color: c.lavenderSoft, borderRadius: BorderRadius.circular(14)),
                  alignment: Alignment.center, child: Text(dest['emoji'] ?? '🗺️', style: const TextStyle(fontSize: 22))),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(g['name'] ?? 'Group Trip', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800, color: c.text)),
                Text('$memberCount/$maxMembers members', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: c.muted)),
              ])),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: isFull ? c.roseSoft : c.sageSoft, borderRadius: BorderRadius.circular(10)),
                  child: Text(isFull ? 'Full' : 'Open', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: isFull ? c.rose : c.sage))),
            ]),
          ),
        );
      },
    );
  }

  void _showCreateGroupModal() {
    if (widget.destinationId == null) return;
    final c = context.colors;
    final nameC = TextEditingController();
    final descC = TextEditingController();
    DateTime? start, end;
    bool creating = false;

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheet) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        decoration: BoxDecoration(color: c.surface, borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28))),
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: c.border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('Create Group Trip', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: c.text)),
            Text('to ${widget.destinationName}', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: c.primary)),
            const SizedBox(height: 20),

            Text('Group Name', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: c.textSecondary)),
            const SizedBox(height: 6),
            TextField(controller: nameC, style: GoogleFonts.plusJakartaSans(color: c.text, fontSize: 14),
                decoration: ZussGoTheme.inputDecorationOf(context, hint: 'e.g. Spiti Valley Squad')),
            const SizedBox(height: 14),

            Text('Description', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: c.textSecondary)),
            const SizedBox(height: 6),
            TextField(controller: descC, maxLines: 2, style: GoogleFonts.plusJakartaSans(color: c.text, fontSize: 14),
                decoration: ZussGoTheme.inputDecorationOf(context, hint: 'What\'s the plan?')),
            const SizedBox(height: 14),

            GestureDetector(
              onTap: () async {
                final range = await showDateRangePicker(context: ctx, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (c2, child) => Theme(data: Theme.of(context).copyWith(colorScheme: ColorScheme.dark(primary: c.primary, surface: c.surface, onSurface: c.text)), child: child!));
                if (range != null) setSheet(() { start = range.start; end = range.end; });
              },
              child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(16)),
                  child: Text(start != null ? '📅 ${_fmt(start!)} – ${_fmt(end!)}' : '📅 Select dates',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, color: start != null ? c.text : c.muted))),
            ),
            const SizedBox(height: 20),

            GestureDetector(
              onTap: creating ? null : () async {
                if (nameC.text.trim().isEmpty || start == null || end == null) return;
                setSheet(() => creating = true);
                final userId = _currentUser['userId'];
                if (userId == null) return;
                final r = await ApiService.createGroup({
                  'userId': userId,  // Fixed: was 'creatorId'
                  'name': nameC.text.trim(),
                  'destinationId': widget.destinationId,
                  'startDate': start!.toUtc().toIso8601String(),
                  'endDate': end!.toUtc().toIso8601String(),
                  'description': descC.text.trim(),
                });
                setSheet(() => creating = false);
                if (r['success'] == true) {
                  Navigator.pop(ctx);
                  _load();
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Group created! 🎉'), backgroundColor: c.primary));
                } else {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(r['message'] ?? 'Failed to create group'), backgroundColor: c.rose));
                }
              },
              child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(16)),
                  child: Center(child: creating
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text('Create Group', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)))),
            ),
          ])),
        ),
      )),
    );
  }

  String _fmt(DateTime d) { const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']; return '${m[d.month - 1]} ${d.day}'; }
}

class _Tab extends StatelessWidget {
  final String label; final bool active; final VoidCallback onTap; final ZussGoColors c;
  const _Tab({required this.label, required this.active, required this.onTap, required this.c});
  @override
  Widget build(BuildContext context) => Expanded(child: GestureDetector(onTap: onTap,
      child: Container(padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: active ? c.primary : c.card, borderRadius: BorderRadius.circular(14)),
          child: Center(child: Text(label, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: active ? Colors.white : c.muted))))));
}