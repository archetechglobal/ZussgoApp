import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../widgets/gradient_button.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class DestinationDetailScreen extends StatefulWidget {
  final String destinationId;
  const DestinationDetailScreen({super.key, required this.destinationId});

  @override
  State<DestinationDetailScreen> createState() => _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  Map<String, dynamic>? _destination;
  List<Map<String, dynamic>> _travelers = [];
  bool _isLoading = true;
  bool _isCreatingTrip = false;
  bool _tripCreated = false;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final result = await ApiService.getDestinationBySlug(widget.destinationId);
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result["success"] == true && result["data"] != null) {
          _destination = Map<String, dynamic>.from(result["data"]);
          if (_destination!["travelers"] != null) {
            _travelers = List<Map<String, dynamic>>.from(_destination!["travelers"]);
          }
        }
      });
    }
  }

  Future<void> _pickDates() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(primary: Color(0xFFF59E0B), surface: Color(0xFF1C1917)),
          ),
          child: child!,
        );
      },
    );

    if (range != null) {
      setState(() {
        _startDate = range.start;
        _endDate = range.end;
      });
    }
  }

  Future<void> _createTrip() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select your travel dates first'),
          backgroundColor: ZussGoTheme.rose.withValues(alpha: 0.8),
        ),
      );
      return;
    }

    final user = await AuthService.getSavedUser();
    final userId = user?['userId'];
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login again')),
        );
      }
      return;
    }

    setState(() => _isCreatingTrip = true);

    final result = await ApiService.createTrip(
      userId: userId,
      destinationId: _destination!['id'],
      startDate: _startDate!.toUtc().toIso8601String(),
      endDate: _endDate!.toUtc().toIso8601String(),
    );

    setState(() => _isCreatingTrip = false);

    if (mounted) {
      if (result["success"] == true) {
        setState(() => _tripCreated = true);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Trip to ${_destination!['name']} created! 🎉'),
            backgroundColor: ZussGoTheme.mint.withValues(alpha: 0.8),
            duration: const Duration(seconds: 3),
          ),
        );

        // Reload destination data to update traveler count
        await _load();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result["message"] ?? "Failed to create trip"),
            backgroundColor: ZussGoTheme.rose.withValues(alpha: 0.8),
          ),
        );
      }
    }
  }

  Color _travelerColor(int index) {
    final colors = [ZussGoTheme.rose, ZussGoTheme.sky, ZussGoTheme.sage, ZussGoTheme.lavender, ZussGoTheme.amber];
    return colors[index % colors.length];
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(strokeWidth: 2, color: ZussGoTheme.amber.withValues(alpha: 0.5))),
      );
    }

    if (_destination == null) {
      return Scaffold(
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('😕', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text('Destination not found', style: ZussGoTheme.labelBold),
            const SizedBox(height: 16),
            GestureDetector(onTap: () => context.pop(), child: Text('Go back', style: TextStyle(color: ZussGoTheme.amber))),
          ]),
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero
            Container(
              height: 220,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFF43F5E)]),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
              ),
              child: Stack(children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0x99000000)], stops: [0.3, 1.0]),
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
                  ),
                ),
                Positioned(
                  top: 50, left: 20,
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
                  bottom: 20, left: 24, right: 24,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${_destination!['emoji'] ?? '🌍'} ${_destination!['name'] ?? ''}', style: ZussGoTheme.displayLarge.copyWith(fontSize: 28)),
                    if (_destination!['description'] != null)
                      Text(_destination!['description'], style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.65), fontWeight: FontWeight.w300)),
                  ]),
                ),
              ]),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Info row
                Row(children: [
                  if (_destination!['state'] != null)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(color: ZussGoTheme.bgSecondary, borderRadius: BorderRadius.circular(16), border: Border.all(color: ZussGoTheme.borderDefault)),
                        child: Column(children: [
                          Text('LOCATION', style: TextStyle(fontSize: 10, color: ZussGoTheme.textMuted, fontWeight: FontWeight.w600, letterSpacing: 1)),
                          const SizedBox(height: 2),
                          Text(_destination!['state'] ?? '', style: ZussGoTheme.labelBold.copyWith(fontSize: 14)),
                        ]),
                      ),
                    ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: ZussGoTheme.mint.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ZussGoTheme.mint.withValues(alpha: 0.15)),
                    ),
                    child: Row(children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: ZussGoTheme.mint, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text('${_destination!['travelerCount'] ?? 0} going', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: ZussGoTheme.mint)),
                    ]),
                  ),
                ]),
                const SizedBox(height: 24),

                // Plan your trip
                Text('Plan Your Trip', style: ZussGoTheme.displaySmall),
                const SizedBox(height: 12),

                // Date picker
                GestureDetector(
                  onTap: _pickDates,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ZussGoTheme.bgSecondary,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _startDate != null ? ZussGoTheme.amber.withValues(alpha: 0.2) : ZussGoTheme.borderDefault),
                    ),
                    child: Row(children: [
                      Icon(Icons.calendar_month_rounded, color: ZussGoTheme.amber, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _startDate != null
                              ? '${_formatDate(_startDate!)} — ${_formatDate(_endDate!)} (${_endDate!.difference(_startDate!).inDays} days)'
                              : 'Tap to select your travel dates',
                          style: ZussGoTheme.bodyMedium.copyWith(color: _startDate != null ? ZussGoTheme.textPrimary : ZussGoTheme.textMuted),
                        ),
                      ),
                      if (_startDate != null)
                        GestureDetector(
                          onTap: () => setState(() { _startDate = null; _endDate = null; }),
                          child: Icon(Icons.close_rounded, color: ZussGoTheme.textMuted, size: 18),
                        ),
                    ]),
                  ),
                ),
                const SizedBox(height: 12),

                // Create trip button
                if (_tripCreated)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: ZussGoTheme.mint.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ZussGoTheme.mint.withValues(alpha: 0.2)),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.check_circle_rounded, color: ZussGoTheme.mint, size: 20),
                      const SizedBox(width: 8),
                      Text('Trip Created! ✈️', style: TextStyle(color: ZussGoTheme.mint, fontWeight: FontWeight.w700, fontSize: 16)),
                    ]),
                  )
                else
                  GradientButton(
                    text: "I'm Going! ✈️",
                    isLoading: _isCreatingTrip,
                    onPressed: _createTrip,
                  ),
                const SizedBox(height: 28),

                // Travelers
                Text('Travelers Heading Here', style: ZussGoTheme.displaySmall),
                const SizedBox(height: 4),
                Text('People with planned trips to ${_destination!['name']}', style: ZussGoTheme.bodySmall),
                const SizedBox(height: 14),

                if (_travelers.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: ZussGoTheme.bgSecondary, borderRadius: BorderRadius.circular(20), border: Border.all(color: ZussGoTheme.borderDefault)),
                    child: Column(children: [
                      const Text('🌍', style: TextStyle(fontSize: 32)),
                      const SizedBox(height: 8),
                      Text('No travelers yet', style: ZussGoTheme.labelBold),
                      const SizedBox(height: 4),
                      Text('Be the first to plan a trip here!', style: ZussGoTheme.bodySmall, textAlign: TextAlign.center),
                    ]),
                  ),

                ...List.generate(_travelers.length, (i) {
                  final t = _travelers[i];
                  final user = t['user'] ?? {};
                  final color = _travelerColor(i);
                  final startStr = t['startDate'];
                  final endStr = t['endDate'];
                  String dateRange = '';
                  if (startStr != null && endStr != null) {
                    final start = DateTime.tryParse(startStr);
                    final end = DateTime.tryParse(endStr);
                    if (start != null && end != null) {
                      dateRange = '${_formatDate(start)} — ${_formatDate(end)}';
                    }
                  }

                  return GestureDetector(
                    onTap: () => context.push('/traveler/${user['id']}', extra: {'tripId': t['tripId']}),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: ZussGoTheme.glassCard,
                      child: Row(children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: color.withValues(alpha: 0.15)),
                          ),
                          alignment: Alignment.center,
                          child: Text((user['fullName'] ?? 'U')[0], style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('${user['fullName'] ?? 'Unknown'}${user['age'] != null ? ', ${user['age']}' : ''}', style: ZussGoTheme.labelBold),
                          if (dateRange.isNotEmpty)
                            Text(dateRange, style: ZussGoTheme.bodySmall),
                          Text('${user['city'] ?? 'Exploring'} • ${user['travelStyle'] ?? 'Explorer'}', style: ZussGoTheme.bodySmall.copyWith(color: ZussGoTheme.textMuted)),
                        ])),
                        Icon(Icons.chevron_right_rounded, color: ZussGoTheme.textMuted, size: 20),
                      ]),
                    ),
                  );
                }),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}