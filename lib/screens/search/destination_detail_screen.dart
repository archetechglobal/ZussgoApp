import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/weather_service.dart';

class DestinationDetailScreen extends StatefulWidget {
  final String destinationId;
  const DestinationDetailScreen({super.key, required this.destinationId});
  @override
  State<DestinationDetailScreen> createState() => _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  Map<String, dynamic>? _dest;
  Map<String, dynamic> _weather = {'temp': '--', 'icon': '☀️'};
  bool _isLoading = true, _isCreating = false;
  DateTime? _startDate, _endDate;

  static const _destEmojis = {
    'Goa': '🌴', 'Varanasi': '🕌', 'Coorg': '🌿', 'Andaman': '🌊', 'Manali': '🏔️',
    'Ladakh': '🏔️', 'Spiti Valley': '🏔️', 'Shimla': '🌲', 'Kasol': '🏕️',
    'Dharamshala': '🛕', 'Rishikesh': '🕉️', 'Jaipur': '🏰', 'Udaipur': '🏰',
    'Munnar': '🌿', 'Hampi': '🏛️', 'Darjeeling': '🍵', 'Pushkar': '🐫',
  };

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final r = await ApiService.getDestinationBySlug(widget.destinationId);
    if (mounted) setState(() {
      _isLoading = false;
      if (r["success"] == true && r["data"] != null) _dest = Map<String, dynamic>.from(r["data"]);
    });
    final w = await WeatherService.getWeather(widget.destinationId);
    if (mounted) setState(() => _weather = w);
  }

  Future<void> _pickDatesAndCreateTrip() async {
    final c = context.colors;
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(primary: c.primary, surface: c.surface, onSurface: c.text),
          dialogBackgroundColor: c.surface,
        ),
        child: child!,
      ),
    );
    if (range == null) return;
    _startDate = range.start;
    _endDate = range.end;

    final user = await AuthService.getSavedUser();
    if (user?['userId'] == null || _dest == null) return;

    setState(() => _isCreating = true);
    final r = await ApiService.createTrip(
      userId: user!['userId'],
      destinationId: _dest!['id'],
      startDate: _startDate!.toUtc().toIso8601String(),
      endDate: _endDate!.toUtc().toIso8601String(),
    );
    setState(() => _isCreating = false);

    if (r["success"] == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Trip to ${_dest!['name']} created! 🎉'),
        backgroundColor: context.colors.primary,
      ));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(r['message'] ?? 'Failed to create trip'),
        backgroundColor: context.colors.rose,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    if (_isLoading) return Scaffold(backgroundColor: c.bg, body: Center(child: CircularProgressIndicator(strokeWidth: 2, color: c.primary)));
    if (_dest == null) return Scaffold(backgroundColor: c.bg, body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('🗺️', style: TextStyle(fontSize: 44)),
      const SizedBox(height: 8),
      Text('Destination not found', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: c.text)),
    ])));

    final name = _dest!['name'] ?? '';
    final emoji = _destEmojis[name] ?? _dest!['emoji'] ?? '🗺️';
    final state = _dest!['state'] ?? 'India';
    final country = _dest!['country'] ?? 'India';
    final travelerCount = _dest!['travelerCount'] ?? 0;
    final temp = _weather['temp']?.toString() ?? '--';

    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero ──
                  Container(
                    height: 260,
                    decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF2A1810), Color(0xFF1A1020), Color(0xFF0E0818)])),
                    child: Stack(children: [
                      Center(child: Opacity(opacity: 0.15, child: Text(emoji, style: const TextStyle(fontSize: 120)))),
                      Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, c.bg], stops: const [0.5, 1.0]))),
                      // Back button
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 8, left: 16,
                        child: GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(13)),
                              child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18)),
                        ),
                      ),
                      // Content
                      Positioned(bottom: 20, left: 24, right: 24, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(8)),
                            child: Text('🔥 Trending', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white))),
                        const SizedBox(height: 8),
                        Text(name, style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1)),
                        const SizedBox(height: 4),
                        Text('$state, $country', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.white.withValues(alpha: 0.7))),
                      ])),
                    ]),
                  ),

                  // ── Info Pills ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Row(children: [
                      _InfoPill(label: 'Travelers', value: '$travelerCount', color: c.primary, c: c),
                      const SizedBox(width: 10),
                      _InfoPill(label: 'Weather', value: '$temp°C', color: c.gold, c: c),
                      const SizedBox(width: 10),
                      _InfoPill(label: 'Rating', value: '4.8 ★', color: c.gold, c: c),
                    ]),
                  ),

                  const SizedBox(height: 24),

                  // ── Actions ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(children: [
                      // Create Trip
                      GestureDetector(
                        onTap: _isCreating ? null : _pickDatesAndCreateTrip,
                        child: Container(
                          width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0x30FF6B4A), blurRadius: 16)]),
                          child: Center(
                            child: _isCreating
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : Text("I'm Going Here →", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Browse Travelers
                      GestureDetector(
                        onTap: () => context.push('/browse/${widget.destinationId}', extra: {'name': name, 'destinationId': _dest!['id']}),
                        child: Container(
                          width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.border)),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.people_rounded, size: 18, color: c.primary),
                            const SizedBox(width: 8),
                            Text('Browse Travelers & Groups', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: c.primary)),
                          ]),
                        ),
                      ),
                    ]),
                  ),

                  // ── Description ──
                  if (_dest!['description'] != null && _dest!['description'].toString().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('About', style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: c.text)),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity, padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: c.border)),
                          child: Text(_dest!['description'], style: GoogleFonts.plusJakartaSans(fontSize: 13, color: c.textSecondary, height: 1.6)),
                        ),
                      ]),
                    ),

                  // ── Quick Info ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Quick Info', style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: c.text)),
                      const SizedBox(height: 12),
                      _QuickInfoRow(emoji: '📍', label: 'Location', value: '$state, $country', c: c),
                      _QuickInfoRow(emoji: '🌤️', label: 'Weather', value: '$temp°C', c: c),
                      _QuickInfoRow(emoji: '👥', label: 'Active Travelers', value: '$travelerCount going', c: c),
                      _QuickInfoRow(emoji: '💰', label: 'Budget Range', value: '₹500–₹10,000/day', c: c),
                    ]),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label, value;
  final Color color;
  final ZussGoColors c;
  const _InfoPill({required this.label, required this.value, required this.color, required this.c});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 16),
    decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: c.border)),
    child: Column(children: [
      Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: c.muted, fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      Text(value, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
    ]),
  ));
}

class _QuickInfoRow extends StatelessWidget {
  final String emoji, label, value;
  final ZussGoColors c;
  const _QuickInfoRow({required this.emoji, required this.label, required this.value, required this.c});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: c.border)),
    child: Row(children: [
      Text(emoji, style: const TextStyle(fontSize: 18)),
      const SizedBox(width: 12),
      Expanded(child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: c.text))),
      Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: c.textSecondary)),
    ]),
  );
}