import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../services/destination_data.dart';

class SeeAllEventsScreen extends StatefulWidget {
  const SeeAllEventsScreen({super.key});
  @override
  State<SeeAllEventsScreen> createState() => _SeeAllEventsScreenState();
}

class _SeeAllEventsScreenState extends State<SeeAllEventsScreen> {
  List<Map<String, dynamic>> _events = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final events = await DestinationData.getUpcomingEvents();
    if (mounted) setState(() { _events = events; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    const monthNames = ['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

    final tagColors = <String, Color>{
      'Festival': context.colors.rose, 'Cultural': ZussGoTheme.lavender, 'Music': context.colors.sky,
      'Spiritual': context.colors.green, 'Harvest': context.colors.amber, 'Nature': context.colors.mint,
      'National': context.colors.amber, 'Film': context.colors.sky, 'Carnival': context.colors.rose,
      'Literary': ZussGoTheme.lavender, 'Dance': context.colors.rose,
    };

    // Group by month
    final grouped = <int, List<Map<String, dynamic>>>{};
    for (final e in _events) {
      final m = e['month'] as int? ?? 1;
      grouped.putIfAbsent(m, () => []).add(e);
    }
    final sortedMonths = grouped.keys.toList()..sort((a, b) {
      final now = DateTime.now().month;
      final da = (a - now + 12) % 12;
      final db = (b - now + 12) % 12;
      return da.compareTo(db);
    });

    return Scaffold(backgroundColor: ZussGoTheme.scaffoldBg(context), body: SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(22, 10, 22, 10), child: Row(children: [
        GestureDetector(onTap: () => context.pop(), child: Container(width: 34, height: 34, decoration: BoxDecoration(color: ZussGoTheme.mutedBg(context), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.arrow_back_rounded, color: ZussGoTheme.secondaryText(context), size: 18))),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Events & Festivals', style: context.textTheme.displaySmall!.adaptive(context)),
          Text('${_events.length} upcoming events', style: context.textTheme.bodySmall!.adaptive(context)),
        ]),
      ])),
      Divider(color: ZussGoTheme.border(context), height: 1),

      if (_loading) Expanded(child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.green))),

      if (!_loading && _events.isEmpty) Expanded(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.celebration_outlined, size: 40, color: context.colors.green.withValues(alpha: 0.4)), SizedBox(height: 8),
        Text('No upcoming events', style: context.textTheme.displaySmall!.adaptive(context)),
        const SizedBox(height: 4),
        Text('Check back later', style: context.textTheme.bodySmall!.adaptive(context)),
      ]))),

      if (!_loading && _events.isNotEmpty)
        Expanded(child: ListView.builder(padding: const EdgeInsets.fromLTRB(22, 10, 22, 20),
          itemCount: sortedMonths.length,
          itemBuilder: (_, mi) {
            final month = sortedMonths[mi];
            final monthEvents = grouped[month]!;
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (mi > 0) const SizedBox(height: 14),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: ZussGoTheme.mutedBg(context), borderRadius: BorderRadius.circular(8)),
                  child: Text(monthNames[month], style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: ZussGoTheme.secondaryText(context), letterSpacing: 0.5))),
              const SizedBox(height: 8),
              ...monthEvents.map((e) {
                final tag = e['tag']?.toString() ?? 'Event';
                final tagColor = tagColors[tag] ?? context.colors.textMuted;
                return Container(padding: const EdgeInsets.all(14), margin: const EdgeInsets.only(bottom: 8), decoration: ZussGoTheme.cardDecoration(context),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Container(width: 40, height: 40, decoration: BoxDecoration(color: tagColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
                            alignment: Alignment.center, child: Icon(Icons.celebration_rounded, size: 20, color: tagColor)),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(e['name'] ?? '', style: context.textTheme.labelLarge!.adaptive(context)),
                          Text('${e['destination'] ?? ''} • ${e['dates'] ?? ''}', style: context.textTheme.bodySmall!.adaptive(context)),
                        ])),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: tagColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                            child: Text(tag, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: tagColor))),
                      ]),
                      if (e['description'] != null) Padding(padding: const EdgeInsets.only(top: 8, left: 52), child: Text(e['description'], style: context.textTheme.bodySmall!.copyWith(color: ZussGoTheme.secondaryText(context)))),
                    ]));
              }),
            ]);
          },
        )),
    ])));
  }
}