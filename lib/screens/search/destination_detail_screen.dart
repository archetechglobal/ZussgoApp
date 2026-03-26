import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../widgets/gradient_button.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/destination_data.dart';
import '../../services/weather_service.dart';

class DestinationDetailScreen extends StatefulWidget {
  final String destinationId;
  const DestinationDetailScreen({super.key, required this.destinationId});
  @override
  State<DestinationDetailScreen> createState() => _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  Map<String, dynamic>? _dest;
  List<Map<String, dynamic>> _travelers = [];
  List<Map<String, dynamic>> _events = [];
  Map<String, dynamic> _weather = {'temp': '--', 'icon': '🌤️', 'condition': 'Loading...'};
  bool _isLoading = true, _isCreating = false, _tripCreated = false;
  DateTime? _startDate, _endDate;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final r = await ApiService.getDestinationBySlug(widget.destinationId);
    if (mounted) setState(() {
      _isLoading = false;
      if (r["success"] == true && r["data"] != null) {
        _dest = Map<String, dynamic>.from(r["data"]);
        if (_dest!["travelers"] != null) _travelers = List<Map<String, dynamic>>.from(_dest!["travelers"]);
      }
    });

    // Load weather + events in background
    _loadWeather();
    _loadEvents();
  }

  Future<void> _loadWeather() async {
    final w = await WeatherService.getWeather(widget.destinationId);
    if (mounted) setState(() => _weather = w);
  }

  Future<void> _loadEvents() async {
    final e = await DestinationData.getEventsForDestination(widget.destinationId);
    if (mounted) setState(() => _events = e);
  }

  Future<void> _pickDates() async {
    final range = await showDateRangePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)),
        builder: (c, child) => Theme(data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: ZussGoTheme.green)), child: child!));
    if (range != null) setState(() { _startDate = range.start; _endDate = range.end; });
  }

  Future<void> _createTrip() async {
    if (_startDate == null || _endDate == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select dates first'))); return; }
    final user = await AuthService.getSavedUser();
    if (user?['userId'] == null) return;
    setState(() => _isCreating = true);
    final r = await ApiService.createTrip(userId: user!['userId'], destinationId: _dest!['id'], startDate: _startDate!.toUtc().toIso8601String(), endDate: _endDate!.toUtc().toIso8601String());
    setState(() => _isCreating = false);
    if (r["success"] == true && mounted) {
      setState(() => _tripCreated = true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Trip to ${_dest!['name']} created! 🎉'), backgroundColor: ZussGoTheme.green));
      _load();
    }
  }

  String _fmtDate(DateTime d) { const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']; return '${m[d.month - 1]} ${d.day}'; }

  LinearGradient get _heroGradient {
    const gs = {'goa': LinearGradient(colors: [Color(0xFF0891B2), Color(0xFF22D3EE)]),
      'manali': LinearGradient(colors: [Color(0xFF059669), Color(0xFF34D399)]),
      'ladakh': LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)]),
      'rishikesh': LinearGradient(colors: [Color(0xFF047857), Color(0xFF10B981)]),
      'jaipur': LinearGradient(colors: [Color(0xFFD97706), Color(0xFFFBBF24)]),
      'kerala': LinearGradient(colors: [Color(0xFF059669), Color(0xFF34D399)]),
      'varanasi': LinearGradient(colors: [Color(0xFFDB2777), Color(0xFFF472B6)]),
      'udaipur': LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)])};
    return gs[widget.destinationId] ?? const LinearGradient(colors: [Color(0xFF2D9F6F), Color(0xFF4AADE8)]);
  }

  Color _tc(int i) { const cs = [ZussGoTheme.rose, ZussGoTheme.sky, ZussGoTheme.amber, ZussGoTheme.lavender, ZussGoTheme.green]; return cs[i % cs.length]; }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(backgroundColor: ZussGoTheme.bgPrimary, body: Center(child: CircularProgressIndicator(strokeWidth: 2, color: ZussGoTheme.green)));
    if (_dest == null) return Scaffold(backgroundColor: ZussGoTheme.bgPrimary, body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('😕', style: TextStyle(fontSize: 36)), const SizedBox(height: 8), Text('Not found', style: ZussGoTheme.labelBold)])));

    final slug = widget.destinationId;
    final bestLabel = DestinationData.getBestMonthsLabel(slug);
    final places = DestinationData.getMustVisit(slug);
    final temp = _weather['temp'];
    final wIcon = _weather['icon'];

    return Scaffold(backgroundColor: ZussGoTheme.bgPrimary, body: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Hero
      Container(height: 200, width: double.infinity, decoration: BoxDecoration(gradient: _heroGradient, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32))),
        child: Stack(children: [
          Center(child: Opacity(opacity: 0.1, child: Text(_dest!['emoji'] ?? '🌍', style: const TextStyle(fontSize: 100)))),
          Positioned(top: 50, left: 16, child: GestureDetector(onTap: () => context.pop(), child: Container(width: 34, height: 34, decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18)))),
          Positioned(top: 50, right: 16, child: Container(width: 34, height: 34, decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.favorite_border_rounded, color: Colors.white, size: 18))),
          Positioned(bottom: 16, left: 18, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${_dest!['emoji'] ?? ''} ${_dest!['name'] ?? ''}', style: ZussGoTheme.displayLarge.copyWith(color: Colors.white, fontSize: 26)),
            Text('📍 ${_dest!['state'] ?? 'India'}', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
          ])),
        ]),
      ),

      // Info pills (real weather from API)
      Padding(padding: const EdgeInsets.fromLTRB(18, 14, 18, 0), child: Row(children: [
        Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)]),
            child: Column(children: [Text('Travelers', style: TextStyle(fontSize: 9, color: ZussGoTheme.textMuted)), Text('${_dest!['travelerCount'] ?? 0}', style: TextStyle(fontFamily: 'Playfair Display', fontSize: 16, fontWeight: FontWeight.w700, color: ZussGoTheme.green))]))),
        const SizedBox(width: 6),
        Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)]),
            child: Column(children: [Text('Weather', style: TextStyle(fontSize: 9, color: ZussGoTheme.textMuted)), Text('$temp°C $wIcon', style: TextStyle(fontFamily: 'Playfair Display', fontSize: 14, fontWeight: FontWeight.w700, color: ZussGoTheme.amber))]))),
        const SizedBox(width: 6),
        Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)]),
            child: Column(children: [Text('Best', style: TextStyle(fontSize: 9, color: ZussGoTheme.textMuted)), Text(bestLabel, style: TextStyle(fontFamily: 'Playfair Display', fontSize: 12, fontWeight: FontWeight.w700, color: ZussGoTheme.sky))]))),
      ])),

      // Date picker + actions
      Padding(padding: const EdgeInsets.fromLTRB(18, 14, 18, 0), child: Column(children: [
        GestureDetector(onTap: _pickDates, child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(14)),
            child: Row(children: [Icon(Icons.calendar_month_rounded, color: ZussGoTheme.green, size: 18), const SizedBox(width: 10),
              Expanded(child: Text(_startDate != null ? '${_fmtDate(_startDate!)} — ${_fmtDate(_endDate!)}' : 'Select your travel dates', style: ZussGoTheme.bodyMedium.copyWith(color: _startDate != null ? ZussGoTheme.textPrimary : ZussGoTheme.textMuted))),
              if (_startDate != null) GestureDetector(onTap: () => setState(() { _startDate = null; _endDate = null; }), child: Icon(Icons.close_rounded, color: ZussGoTheme.textMuted, size: 16)),
            ]))),
        const SizedBox(height: 8),
        _tripCreated
            ? Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: ZussGoTheme.greenLight, borderRadius: BorderRadius.circular(14)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle_rounded, color: ZussGoTheme.green, size: 18), const SizedBox(width: 6), Text('Trip Created! ✈️', style: TextStyle(color: ZussGoTheme.green, fontWeight: FontWeight.w700, fontSize: 14))]))
            : GradientButton(text: "I'm Going Here ✈️", isLoading: _isCreating, onPressed: _createTrip),
        const SizedBox(height: 8),
        GestureDetector(onTap: () => context.push('/browse/$slug', extra: {'name': _dest!['name'], 'destinationId': _dest!['id']}), child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: ZussGoTheme.bgMuted, borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text('🔍 Browse Travelers & Groups', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ZussGoTheme.green))))),
      ])),

      // Must Visit (static — landmarks don't change)
      if (places.isNotEmpty) ...[
        Padding(padding: const EdgeInsets.fromLTRB(18, 16, 18, 6), child: Text('Must-Visit in ${_dest!['name']} 📍', style: ZussGoTheme.displaySmall)),
        SizedBox(height: 90, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 18),
            itemCount: places.length, itemBuilder: (_, i) {
              final p = places[i];
              return Container(width: 90, margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 5)]),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(width: 36, height: 36, decoration: BoxDecoration(gradient: _heroGradient, borderRadius: BorderRadius.circular(10)), alignment: Alignment.center, child: Text(p['emoji']!, style: const TextStyle(fontSize: 16))),
                    const SizedBox(height: 4), Text(p['name']!, style: ZussGoTheme.labelBold.copyWith(fontSize: 10), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis), Text(p['info']!, style: ZussGoTheme.bodySmall.copyWith(fontSize: 9)),
                  ]));
            })),
      ],

      // Events (from backend API)
      if (_events.isNotEmpty) ...[
        Padding(padding: const EdgeInsets.fromLTRB(18, 12, 18, 6), child: Text('Events & Festivals 🎉', style: ZussGoTheme.displaySmall)),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child: Column(children: _events.map((e) => Container(
          padding: const EdgeInsets.all(10), margin: const EdgeInsets.only(bottom: 6),
          decoration: ZussGoTheme.glassCard,
          child: Row(children: [
            Container(width: 32, height: 32, decoration: BoxDecoration(color: ZussGoTheme.rose.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)), alignment: Alignment.center, child: Text(e['emoji'] ?? '🎉', style: const TextStyle(fontSize: 14))),
            const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(e['name'] ?? '', style: ZussGoTheme.labelBold.copyWith(fontSize: 12)), Text('${e['dates'] ?? ''} • ${e['tag'] ?? ''}', style: ZussGoTheme.bodySmall)])),
          ]),
        )).toList())),
      ],

      // Travelers
      Padding(padding: const EdgeInsets.fromLTRB(18, 12, 18, 6), child: Text('Travelers Heading Here', style: ZussGoTheme.displaySmall)),
      if (_travelers.isEmpty)
        Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child: Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: ZussGoTheme.cardDecoration,
            child: Column(children: [const Text('🌍', style: TextStyle(fontSize: 28)), const SizedBox(height: 6), Text('No travelers yet', style: ZussGoTheme.labelBold), Text('Be the first!', style: ZussGoTheme.bodySmall)]))),

      if (_travelers.isNotEmpty)
        Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child: Column(children: List.generate(_travelers.length, (i) {
          final t = _travelers[i]; final u = t['user'] ?? {};
          return GestureDetector(onTap: () => context.push('/traveler/${u['id']}', extra: {'tripId': t['tripId']}),
              child: Container(padding: const EdgeInsets.all(10), margin: const EdgeInsets.only(bottom: 6), decoration: ZussGoTheme.glassCard,
                  child: Row(children: [
                    Container(width: 42, height: 42, decoration: BoxDecoration(color: _tc(i).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
                        alignment: Alignment.center, child: Text((u['fullName'] ?? 'U')[0], style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _tc(i), fontFamily: 'Playfair Display'))),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${u['fullName'] ?? 'Unknown'}${u['age'] != null ? ', ${u['age']}' : ''}', style: ZussGoTheme.labelBold.copyWith(fontSize: 13)),
                      Text('${u['city'] ?? 'Explorer'} • ${u['travelStyle'] ?? 'Adventurer'}', style: ZussGoTheme.bodySmall),
                    ])),
                    Icon(Icons.chevron_right_rounded, color: ZussGoTheme.textMuted, size: 18),
                  ])));
        }))),

      const SizedBox(height: 20),
    ])));
  }
}