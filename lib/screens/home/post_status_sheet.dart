import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../widgets/gradient_button.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class PostStatusSheet extends StatefulWidget {
  const PostStatusSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PostStatusSheet(),
    );
  }

  @override
  State<PostStatusSheet> createState() => _PostStatusSheetState();
}

class _PostStatusSheetState extends State<PostStatusSheet> {
  List<Map<String, dynamic>> _destinations = [];
  Map<String, dynamic>? _selectedDest;
  DateTime? _startDate, _endDate;
  String? _budget;
  bool _loading = true, _creating = false;

  @override
  void initState() { super.initState(); _loadDestinations(); }

  Future<void> _loadDestinations() async {
    final r = await ApiService.getDestinations();
    if (mounted) setState(() {
      _loading = false;
      if (r["success"] == true) _destinations = List<Map<String, dynamic>>.from(r["data"] ?? []);
    });
  }

  Future<void> _pickDates() async {
    final range = await showDateRangePicker(
      context: context, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (c, child) => Theme(data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: ZussGoTheme.green)), child: child!),
    );
    if (range != null) setState(() { _startDate = range.start; _endDate = range.end; });
  }

  String _fmtDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[d.month - 1]} ${d.day}';
  }

  Future<void> _post() async {
    if (_selectedDest == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a destination'))); return; }
    if (_startDate == null || _endDate == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select your travel dates'))); return; }

    final user = await AuthService.getSavedUser();
    if (user?['userId'] == null) return;

    setState(() => _creating = true);
    final r = await ApiService.createTrip(
      userId: user!['userId'],
      destinationId: _selectedDest!['id'],
      startDate: _startDate!.toUtc().toIso8601String(),
      endDate: _endDate!.toUtc().toIso8601String(),
      budget: _budget,
    );
    setState(() => _creating = false);

    if (r["success"] == true && mounted) {
      Navigator.pop(context, true); // return true to refresh home
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Posted! You\'re heading to ${_selectedDest!['name']} 🎉'),
        backgroundColor: ZussGoTheme.green,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(r['message'] ?? 'Something went wrong')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: const BoxDecoration(
        color: ZussGoTheme.bgPrimary,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Handle
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: ZussGoTheme.borderDefault, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),

          Text("I'm Going To...", style: ZussGoTheme.displayMedium),
          const SizedBox(height: 4),
          Text('Let other travelers find and connect with you', style: ZussGoTheme.bodySmall),
          const SizedBox(height: 20),

          // ── SELECT DESTINATION ──
          Text('Where are you going?', style: ZussGoTheme.labelBold.copyWith(color: ZussGoTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),

          if (_loading)
            const SizedBox(height: 60, child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: ZussGoTheme.green))),

          if (!_loading)
            Container(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _destinations.length,
                itemBuilder: (_, i) {
                  final d = _destinations[i];
                  final sel = _selectedDest?['id'] == d['id'];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDest = d),
                    child: Container(
                      width: 85, margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: sel ? ZussGoTheme.greenLight : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: sel ? ZussGoTheme.green : ZussGoTheme.borderDefault, width: sel ? 2 : 1),
                        boxShadow: sel ? [BoxShadow(color: ZussGoTheme.green.withValues(alpha: 0.1), blurRadius: 8)] : null,
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(d['emoji'] ?? '🌍', style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 4),
                        Text(d['name'] ?? '', style: TextStyle(fontSize: 11, fontWeight: sel ? FontWeight.w700 : FontWeight.w500, color: sel ? ZussGoTheme.green : ZussGoTheme.textSecondary), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ]),
                    ),
                  );
                },
              ),
            ),

          if (_selectedDest != null)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: ZussGoTheme.greenLight, borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                Icon(Icons.check_circle_rounded, color: ZussGoTheme.green, size: 16),
                const SizedBox(width: 6),
                Text('${_selectedDest!['emoji']} ${_selectedDest!['name']}', style: TextStyle(fontSize: 13, color: ZussGoTheme.green, fontWeight: FontWeight.w600)),
              ]),
            ),

          const SizedBox(height: 20),

          // ── SELECT DATES ──
          Text('When?', style: ZussGoTheme.labelBold.copyWith(color: ZussGoTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickDates,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                Icon(Icons.calendar_month_rounded, color: ZussGoTheme.green, size: 20),
                const SizedBox(width: 10),
                Text(
                  _startDate != null ? '${_fmtDate(_startDate!)} — ${_fmtDate(_endDate!)} (${_endDate!.difference(_startDate!).inDays} days)' : 'Tap to select dates',
                  style: ZussGoTheme.bodyMedium.copyWith(color: _startDate != null ? ZussGoTheme.textPrimary : ZussGoTheme.textMuted),
                ),
              ]),
            ),
          ),

          const SizedBox(height: 20),

          // ── BUDGET ──
          Text('Budget', style: ZussGoTheme.labelBold.copyWith(color: ZussGoTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          Row(children: ['Budget', 'Mid-range', 'Luxury'].map((b) {
            final sel = _budget == b;
            return Expanded(child: GestureDetector(
              onTap: () => setState(() => _budget = b),
              child: Container(
                margin: EdgeInsets.only(right: b != 'Luxury' ? 8 : 0),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: sel ? ZussGoTheme.greenLight : ZussGoTheme.bgMuted,
                  borderRadius: BorderRadius.circular(12),
                  border: sel ? Border.all(color: ZussGoTheme.green, width: 1.5) : null,
                ),
                alignment: Alignment.center,
                child: Text(b, style: TextStyle(fontSize: 12, fontWeight: sel ? FontWeight.w600 : FontWeight.w400, color: sel ? ZussGoTheme.green : ZussGoTheme.textSecondary)),
              ),
            ));
          }).toList()),

          const SizedBox(height: 28),
          GradientButton(text: "Post Status ✈️", isLoading: _creating, onPressed: _post),
          const SizedBox(height: 8),
          Center(child: Text('Others will see you on the destination page', style: ZussGoTheme.bodySmall)),
        ]),
      ),
    );
  }
}