import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../config/zuss_icons.dart';
import '../../config/animations.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/weather_service.dart';
import '../../services/destination_images.dart';

class DestinationDetailScreen extends StatefulWidget {
  final String destinationId;
  const DestinationDetailScreen({super.key, required this.destinationId});
  @override
  State<DestinationDetailScreen> createState() => _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  Map<String, dynamic>? _dest;
  Map<String, dynamic> _weather = {'temp': '--', 'icon': 'sun'};
  bool _isLoading = true, _isCreating = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final r = await ApiService.getDestinationBySlug(widget.destinationId);
    if (mounted) setState(() { _isLoading = false; if (r["success"] == true && r["data"] != null) _dest = Map<String, dynamic>.from(r["data"]); });
    final w = await WeatherService.getWeather(widget.destinationId);
    if (mounted) setState(() => _weather = w);
  }

  Future<void> _pickDatesAndCreateTrip() async {
    final c = context.colors;
    final range = await showDateRangePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)),
        builder: (ctx, child) => Theme(data: Theme.of(context).copyWith(colorScheme: ColorScheme.dark(primary: c.primary, surface: c.surface, onSurface: c.text), dialogBackgroundColor: c.surface), child: child!));
    if (range == null) return;
    final user = await AuthService.getSavedUser();
    if (user?['userId'] == null || _dest == null) return;
    setState(() => _isCreating = true);
    final r = await ApiService.createTrip(userId: user!['userId'], destinationId: _dest!['id'], startDate: range.start.toUtc().toIso8601String(), endDate: range.end.toUtc().toIso8601String());
    setState(() => _isCreating = false);
    if (r["success"] == true && mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Trip to ${_dest!['name']} created!'), backgroundColor: context.colors.primary)); }
    else if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(r['message'] ?? 'Failed to create trip'), backgroundColor: context.colors.rose)); }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (_isLoading) return Scaffold(backgroundColor: c.bg, body: Center(child: CircularProgressIndicator(strokeWidth: 2, color: c.primary)));
    if (_dest == null) return Scaffold(backgroundColor: c.bg, body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(ZussIcons.map, size: 44, color: c.muted.withValues(alpha: 0.3)), const SizedBox(height: 8),
      Text('Destination not found', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: c.text)),
    ])));

    final name = _dest!['name'] ?? '';
    final slug = _dest!['slug'] ?? name.toLowerCase().replaceAll(' ', '-');
    final state = _dest!['state'] ?? 'India';
    final country = _dest!['country'] ?? 'India';
    final travelerCount = _dest!['travelerCount'] ?? 0;
    final temp = _weather['temp']?.toString() ?? '--';
    final imagePath = DestinationImages.getAssetPath(slug);

    return Scaffold(
      backgroundColor: c.bg,
      body: Column(children: [
        Expanded(child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Hero with real destination image ──
          Container(
            height: 280,
            child: Stack(children: [
              // Destination photo
              Positioned.fill(child: Image.asset(imagePath, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(decoration: BoxDecoration(gradient: ZussGoTheme.gradientHero)))),
              // Gradient overlay
              Positioned.fill(child: Container(decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withValues(alpha: 0.3), Colors.transparent, c.bg], stops: const [0.0, 0.4, 1.0])))),
              // Back button
              Positioned(top: MediaQuery.of(context).padding.top + 8, left: 16,
                  child: GestureDetector(onTap: () => context.pop(),
                      child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(13)),
                          child: Icon(ZussIcons.back, color: Colors.white, size: 18)))),
              // Content
              Positioned(bottom: 20, left: 24, right: 24, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: c.primary.withValues(alpha: 0.3), blurRadius: 8)]),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(ZussIcons.trending, size: 12, color: Colors.white), const SizedBox(width: 4),
                      Text('Trending', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white))])).zussPop(delay: 200),
                const SizedBox(height: 8),
                Text(name, style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1)).zussHero(delay: 100),
                const SizedBox(height: 4),
                Text('$state, $country', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.white.withValues(alpha: 0.7))),
              ])),
            ]),
          ),

          // ── Info Pills — consistent equal-width with icon ──
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Row(children: [
              _InfoPill(icon: ZussIcons.group, label: 'Travelers', value: '$travelerCount', color: c.primary, c: c),
              const SizedBox(width: 10),
              _InfoPill(icon: Icons.thermostat_rounded, label: 'Weather', value: '$temp°C', color: c.gold, c: c),
              const SizedBox(width: 10),
              _InfoPill(icon: ZussIcons.star, label: 'Rating', value: '4.8', color: c.gold, c: c),
            ]).zussEntrance(index: 0, baseDelay: 300),
          ),

          const SizedBox(height: 24),

          // ── Actions ──
          Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Column(children: [
            GestureDetector(onTap: _isCreating ? null : _pickDatesAndCreateTrip,
                child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(gradient: ZussGoTheme.gradientPrimary, borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: c.primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))]),
                    child: Center(child: _isCreating ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Row(mainAxisSize: MainAxisSize.min, children: [Icon(ZussIcons.compass, size: 16, color: Colors.white), const SizedBox(width: 8),
                      Text("I'm Going Here", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white))])))).zussEntrance(index: 0, baseDelay: 400),
            const SizedBox(height: 12),
            GestureDetector(onTap: () => context.push('/browse/${widget.destinationId}', extra: {'name': name, 'destinationId': _dest!['id']}),
                child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.border)),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(ZussIcons.group, size: 18, color: c.primary), const SizedBox(width: 8),
                      Text('Browse Travelers & Groups', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: c.primary))]))).zussEntrance(index: 1, baseDelay: 400),
          ])),

          // ── Description ──
          if (_dest!['description'] != null && _dest!['description'].toString().isNotEmpty)
            Padding(padding: const EdgeInsets.fromLTRB(24, 24, 24, 0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('About', style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: c.text)), const SizedBox(height: 8),
              Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: ZussGoTheme.floatingCardDecoration(context),
                  child: Text(_dest!['description'], style: GoogleFonts.plusJakartaSans(fontSize: 13, color: c.textSecondary, height: 1.6))),
            ])).zussEntrance(index: 2, baseDelay: 500),

          // ── Quick Info ──
          Padding(padding: const EdgeInsets.fromLTRB(24, 24, 24, 0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Quick Info', style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: c.text)), const SizedBox(height: 12),
            _QuickInfoRow(icon: ZussIcons.location, label: 'Location', value: '$state, $country', c: c).zussEntrance(index: 0, baseDelay: 600),
            _QuickInfoRow(icon: Icons.thermostat_rounded, label: 'Weather', value: '$temp°C', c: c).zussEntrance(index: 1, baseDelay: 600),
            _QuickInfoRow(icon: ZussIcons.group, label: 'Active Travelers', value: '$travelerCount going', c: c).zussEntrance(index: 2, baseDelay: 600),
            _QuickInfoRow(icon: ZussIcons.cashback, label: 'Budget Range', value: '₹500–₹10,000/day', c: c).zussEntrance(index: 3, baseDelay: 600),
          ])),
          const SizedBox(height: 40),
        ]))),
      ]),
    );
  }
}

// ── Consistent equal-width info pill with icon ──
class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  final ZussGoColors c;
  const _InfoPill({required this.icon, required this.label, required this.value, required this.color, required this.c});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 14),
    decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.border)),
    child: Column(children: [
      Icon(icon, size: 18, color: color.withValues(alpha: 0.6)),
      const SizedBox(height: 6),
      Text(value, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
      const SizedBox(height: 2),
      Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: c.muted, fontWeight: FontWeight.w500)),
    ]),
  ));
}

class _QuickInfoRow extends StatelessWidget {
  final IconData icon; final String label, value; final ZussGoColors c;
  const _QuickInfoRow({required this.icon, required this.label, required this.value, required this.c});
  @override Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: c.border)),
      child: Row(children: [Icon(icon, size: 18, color: c.primary), const SizedBox(width: 12),
        Expanded(child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: c.text))),
        Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: c.textSecondary))]));
}