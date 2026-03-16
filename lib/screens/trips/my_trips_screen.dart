import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/gradient_button.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  List<Map<String, dynamic>> _upcoming = [];
  List<Map<String, dynamic>> _past = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    final user = await AuthService.getSavedUser();
    final userId = user?['userId'];
    if (userId == null) { setState(() => _isLoading = false); return; }

    final result = await ApiService.getMyTrips(userId);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result["success"] == true && result["data"] != null) {
          final data = result["data"];
          _upcoming = List<Map<String, dynamic>>.from(data["upcoming"] ?? []);
          _past = List<Map<String, dynamic>>.from(data["past"] ?? []);
        }
      });
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  int _daysBetween(String? start, String? end) {
    if (start == null || end == null) return 0;
    final s = DateTime.tryParse(start);
    final e = DateTime.tryParse(end);
    if (s == null || e == null) return 0;
    return e.difference(s).inDays;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Journeys', style: ZussGoTheme.displayMedium),
                  const SizedBox(height: 20),

                  if (_isLoading)
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: ZussGoTheme.amber.withValues(alpha: 0.5))),
                    ),

                  // No trips
                  if (!_isLoading && _upcoming.isEmpty && _past.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(color: ZussGoTheme.bgSecondary, borderRadius: BorderRadius.circular(20), border: Border.all(color: ZussGoTheme.borderDefault)),
                      child: Column(children: [
                        const Text('✈️', style: TextStyle(fontSize: 40)),
                        const SizedBox(height: 12),
                        Text('No trips yet', style: ZussGoTheme.displaySmall),
                        const SizedBox(height: 8),
                        Text('Plan your first escape and find travel companions!', style: ZussGoTheme.bodySmall, textAlign: TextAlign.center),
                        const SizedBox(height: 20),
                        GradientButton(text: 'Explore Destinations', onPressed: () => context.go('/search')),
                      ]),
                    ),

                  // Upcoming
                  if (!_isLoading && _upcoming.isNotEmpty) ...[
                    Text('COMING UP', style: TextStyle(fontSize: 11, color: ZussGoTheme.textMuted, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
                    const SizedBox(height: 10),
                    ...List.generate(_upcoming.length, (i) {
                      final trip = _upcoming[i];
                      final dest = trip['destination'] ?? {};
                      final days = _daysBetween(trip['startDate'], trip['endDate']);
                      return Container(
                        padding: const EdgeInsets.all(18),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [ZussGoTheme.amber.withValues(alpha: 0.06), ZussGoTheme.rose.withValues(alpha: 0.06)]),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: ZussGoTheme.amber.withValues(alpha: 0.1)),
                        ),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('${dest['emoji'] ?? '✈️'} ${dest['name'] ?? 'Trip'}', style: ZussGoTheme.labelBold.copyWith(fontSize: 17)),
                              Text('${_formatDate(trip['startDate'])} — ${_formatDate(trip['endDate'])}', style: ZussGoTheme.bodySmall),
                            ]),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(color: ZussGoTheme.mint.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                              child: Text('$days days', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: ZussGoTheme.mint)),
                            ),
                          ]),
                          if (trip['budget'] != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: ZussGoTheme.bgCard, borderRadius: BorderRadius.circular(6), border: Border.all(color: ZussGoTheme.borderDefault)),
                              child: Text(trip['budget'], style: TextStyle(fontSize: 10, color: ZussGoTheme.textMuted)),
                            ),
                          ],
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => context.push('/destination/${dest['slug'] ?? ''}'),
                            child: Text('Find travel companions →', style: TextStyle(fontSize: 13, color: ZussGoTheme.amber, fontWeight: FontWeight.w600)),
                          ),
                        ]),
                      );
                    }),
                    const SizedBox(height: 20),
                  ],

                  // Past
                  if (!_isLoading && _past.isNotEmpty) ...[
                    Text('MEMORIES', style: TextStyle(fontSize: 11, color: ZussGoTheme.textMuted, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
                    const SizedBox(height: 10),
                    ...List.generate(_past.length, (i) {
                      final trip = _past[i];
                      final dest = trip['destination'] ?? {};
                      return Opacity(
                        opacity: 0.5,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: ZussGoTheme.glassCard,
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('${dest['emoji'] ?? '✈️'} ${dest['name'] ?? 'Trip'}', style: ZussGoTheme.labelBold),
                            Text('${_formatDate(trip['startDate'])} — ${_formatDate(trip['endDate'])}', style: ZussGoTheme.bodySmall),
                          ]),
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                  ],

                  if (!_isLoading)
                    GradientButton(text: '+ Plan a New Escape', onPressed: () => context.go('/search')),
                ],
              ),
            ),
          ),

          const Positioned(bottom: 0, left: 0, right: 0, child: ZussGoBottomNav(currentIndex: 3)),
        ],
      ),
    );
  }
}