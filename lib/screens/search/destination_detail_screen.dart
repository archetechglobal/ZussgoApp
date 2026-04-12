import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/destination_data.dart';
import '../../services/weather_service.dart';
import '../../services/destination_images.dart';
import '../../widgets/destination_image.dart';

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
  Map<String, dynamic> _weather = {'temp': '--', 'icon': '☀️', 'condition': 'Loading...'};
  String _rating = '4.8';
  bool _isLoading = true, _isCreating = false;
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
        if (_dest!["rating"] != null) _rating = _dest!["rating"].toString();
        if (_dest!["travelers"] != null) _travelers = List<Map<String, dynamic>>.from(_dest!["travelers"]);
      }
    });
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
        builder: (c, child) => Theme(data: Theme.of(context).copyWith(colorScheme: Theme.of(context).colorScheme.copyWith(primary: context.colors.green)), child: child!));
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Trip to ${_dest!['name']} created!'), backgroundColor: context.colors.green));
      _load();
    }
  }

  Color _tc(int i) { final cs = [context.colors.rose, context.colors.sky, context.colors.amber, ZussGoTheme.lavender, context.colors.green]; return cs[i % cs.length]; }

  Widget _buildHero() {
    return SizedBox(
      height: 280,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DestinationImage(
            destination: _dest!,
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                stops: const [0.3, 1.0],
              ),
            ),
          ),
          Positioned(
            top: 50, left: 16,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
          Positioned(
            bottom: 70, left: 22,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_dest!['name'] ?? '', style: const TextStyle(fontFamily: 'Playfair Display', fontSize: 36, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.white.withValues(alpha: 0.8)),
                    const SizedBox(width: 4),
                    Text('${_dest!['name'] ?? ''}, ${_dest!['country'] ?? 'India'}', style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.9), fontFamily: 'Outfit')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPills(String temp) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(color: ZussGoTheme.cardBg(context), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)]),
              child: Column(
                children: [
                  Text('Travelers', style: TextStyle(fontSize: 10, color: ZussGoTheme.mutedText(context), fontFamily: 'Outfit', fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  Text('${_dest!['travelerCount'] ?? 0}', style: TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.w800, color: context.colors.green)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(color: ZussGoTheme.cardBg(context), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)]),
              child: Column(
                children: [
                  Text('Weather', style: TextStyle(fontSize: 10, color: ZussGoTheme.mutedText(context), fontFamily: 'Outfit', fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  Text('$temp°C', style: TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.w800, color: context.colors.amber)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(color: ZussGoTheme.cardBg(context), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)]),
              child: Column(
                children: [
                  Text('Rating', style: TextStyle(fontSize: 10, color: ZussGoTheme.mutedText(context), fontFamily: 'Outfit', fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_rating, style: TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.w800, color: context.colors.amber)),
                      const SizedBox(width: 2),
                      Icon(Icons.star_rounded, color: context.colors.amber, size: 18),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(String slug) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              _pickDates().then((_) { if (_startDate != null) _createTrip(); });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(gradient: ZussGoTheme.gradientPrimary, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: context.colors.green.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 5))]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isCreating) const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) else const Text("I'm Going Here", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16, fontFamily: 'Outfit')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => context.push('/browse/$slug', extra: {'name': _dest!['name'], 'destinationId': _dest!['id']}),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(color: ZussGoTheme.mutedBg(context), borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_rounded, size: 18, color: context.colors.green),
                  const SizedBox(width: 8),
                  Text('Browse Travelers & Groups', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.colors.green, fontFamily: 'Outfit')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMustVisit(List<Map<String, String>> places) {
    if (places.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
          child: Row(
            children: [
              const Text('Must-Visit ', style: TextStyle(fontFamily: 'Playfair Display', fontSize: 24, fontWeight: FontWeight.w700)),
              Icon(Icons.place_rounded, size: 24, color: context.colors.amber),
            ],
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: places.length,
            itemBuilder: (_, i) {
              final place = places[i];
              return Container(
                width: 120,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  children: [
                    Container(
                      width: 110, height: 110,
                      decoration: BoxDecoration(color: ZussGoTheme.mutedBg(context), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4))]),
                      clipBehavior: Clip.hardEdge,
                      child: place.containsKey('image') 
                         ? Image.network(place['image']!, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Center(child: Icon(Icons.place_rounded, size: 34, color: Colors.grey)))
                         : const Center(child: Icon(Icons.place_rounded, size: 34, color: Colors.grey)),
                    ),
                    const SizedBox(height: 8),
                    Text(place['name']!, style: context.textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w600, color: ZussGoTheme.primaryText(context)), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEvents() {
    if (_events.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Row(
            children: [
              const Text('Events ', style: TextStyle(fontFamily: 'Playfair Display', fontSize: 24, fontWeight: FontWeight.w700)),
              Icon(Icons.event_rounded, size: 24, color: context.colors.amber),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: _events.map((e) => Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: ZussGoTheme.cardBg(context), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)]),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
                    alignment: Alignment.center,
                    child: const Icon(Icons.event_available_rounded, size: 20, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e['name'] ?? '', style: context.textTheme.labelLarge!.copyWith(fontSize: 15, color: ZussGoTheme.primaryText(context))),
                        const SizedBox(height: 4),
                        Text('${e['dates'] ?? ''} • ${e['tag'] ?? ''}', style: context.textTheme.bodySmall!.copyWith(color: ZussGoTheme.mutedText(context), fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Scaffold(backgroundColor: ZussGoTheme.scaffoldBg(context), body: Center(child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.green)));
    if (_dest == null) return Scaffold(backgroundColor: ZussGoTheme.scaffoldBg(context), body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.explore_off_rounded, size: 44, color: ZussGoTheme.mutedText(context).withValues(alpha: 0.4)), SizedBox(height: 8), Text('Not found', style: context.textTheme.labelLarge!.adaptive(context))])));

    return Scaffold(
      backgroundColor: ZussGoTheme.scaffoldBg(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                _buildHero(),
                Container(
                  margin: const EdgeInsets.only(top: 250),
                  decoration: BoxDecoration(
                    color: ZussGoTheme.scaffoldBg(context),
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      _buildPills(_weather['temp']?.toString() ?? '--'),
                      _buildActions(widget.destinationId),
                      _buildMustVisit(DestinationData.getMustVisit(widget.destinationId)),
                      _buildEvents(),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}