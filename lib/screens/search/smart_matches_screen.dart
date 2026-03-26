// lib/screens/search/smart_matches_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class SmartMatchesScreen extends StatefulWidget {
  final String tripId;
  final String destinationName;
  final String destinationEmoji;

  const SmartMatchesScreen({
    super.key,
    required this.tripId,
    required this.destinationName,
    required this.destinationEmoji,
  });

  @override
  State<SmartMatchesScreen> createState() => _SmartMatchesScreenState();
}

class _SmartMatchesScreenState extends State<SmartMatchesScreen> {
  List<Map<String, dynamic>> _matches = [];
  bool _isLoading = true;
  bool _preferSameGender = false;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    setState(() => _isLoading = true);

    final user = await AuthService.getSavedUser();
    final userId = user?['userId'];
    if (userId == null) { setState(() => _isLoading = false); return; }

    final result = await ApiService.getSmartMatches(
      tripId: widget.tripId,
      userId: userId,
      preferSameGender: _preferSameGender,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result["success"] == true && result["data"] != null) {
          _matches = List<Map<String, dynamic>>.from(result["data"]["matches"] ?? []);
        }
      });
    }
  }

  Color _scoreColor(double score) {
    if (score >= 85) return ZussGoTheme.mint;
    if (score >= 70) return ZussGoTheme.amber;
    if (score >= 55) return const Color(0xFF38BDF8);
    if (score >= 40) return ZussGoTheme.lavender;
    return ZussGoTheme.textMuted;
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const Icon(Icons.arrow_back_rounded, color: ZussGoTheme.textSecondary),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Text(widget.destinationEmoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Smart Matches', style: ZussGoTheme.displaySmall),
                      Text('Travelers heading to ${widget.destinationName}', style: ZussGoTheme.bodySmall),
                    ]),
                  ),
                ]),
                const SizedBox(height: 16),

                // Filter
                Row(children: [
                  GestureDetector(
                    onTap: () { setState(() => _preferSameGender = !_preferSameGender); _loadMatches(); },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _preferSameGender ? ZussGoTheme.amber.withValues(alpha: 0.1) : ZussGoTheme.bgSecondary,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _preferSameGender ? ZussGoTheme.amber.withValues(alpha: 0.3) : ZussGoTheme.borderDefault),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(
                          _preferSameGender ? Icons.check_circle_rounded : Icons.circle_outlined,
                          size: 16,
                          color: _preferSameGender ? ZussGoTheme.amber : ZussGoTheme.textMuted,
                        ),
                        const SizedBox(width: 6),
                        Text('Same gender', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _preferSameGender ? ZussGoTheme.amber : ZussGoTheme.textMuted)),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: ZussGoTheme.bgSecondary, borderRadius: BorderRadius.circular(10), border: Border.all(color: ZussGoTheme.borderDefault)),
                    child: Text('${_matches.length} found', style: TextStyle(fontSize: 12, color: ZussGoTheme.textMuted, fontWeight: FontWeight.w500)),
                  ),
                ]),
                const SizedBox(height: 12),
              ]),
            ),

            const Divider(color: ZussGoTheme.borderDefault, height: 1),

            // Results
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(strokeWidth: 2, color: ZussGoTheme.amber.withValues(alpha: 0.5)))
                  : _matches.isEmpty
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Text('🔍', style: TextStyle(fontSize: 40)),
                    const SizedBox(height: 12),
                    Text('No matches yet', style: ZussGoTheme.displaySmall),
                    const SizedBox(height: 8),
                    Text('Be patient — as more travelers plan trips to ${widget.destinationName}, your matches will appear here.', style: ZussGoTheme.bodySmall, textAlign: TextAlign.center),
                  ]),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                itemCount: _matches.length,
                itemBuilder: (context, i) {
                  final match = _matches[i];
                  final traveler = match['traveler'] ?? {};
                  final breakdown = match['breakdown'] ?? {};
                  final label = match['matchLabel'] ?? {};
                  final score = (match['score'] ?? 0).toDouble();
                  final color = _scoreColor(score);
                  final alreadyRequested = match['alreadyRequested'] == true;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: ZussGoTheme.bgSecondary,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: score >= 70 ? color.withValues(alpha: 0.15) : ZussGoTheme.borderDefault),
                    ),
                    child: Column(children: [
                      // Score header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.04),
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                        ),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Row(children: [
                            Text(label['emoji'] ?? '🌱', style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(label['label'] ?? 'Match', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
                          ]),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                            child: Text('${score.round()}%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color, fontFamily: 'Playfair Display')),
                          ),
                        ]),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(children: [
                          // Traveler info
                          Row(children: [
                            Container(
                              width: 52, height: 52,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: color.withValues(alpha: 0.15)),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                (traveler['fullName'] ?? 'U')[0].toUpperCase(),
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color, fontFamily: 'Playfair Display'),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('${traveler['fullName'] ?? 'Unknown'}${traveler['age'] != null ? ', ${traveler['age']}' : ''}', style: ZussGoTheme.labelBold),
                              Text('${traveler['city'] ?? 'Explorer'} • ${traveler['travelStyle'] ?? 'Unknown style'}', style: ZussGoTheme.bodySmall),
                              if (traveler['totalRatings'] != null && traveler['totalRatings'] > 0)
                                Row(children: [
                                  const Text('⭐ ', style: TextStyle(fontSize: 11)),
                                  Text('${traveler['averageRating']} (${traveler['totalRatings']} trips)', style: TextStyle(fontSize: 11, color: ZussGoTheme.amber)),
                                ]),
                            ])),
                          ]),
                          const SizedBox(height: 12),

                          // Dates
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: ZussGoTheme.bgPrimary, borderRadius: BorderRadius.circular(12)),
                            child: Row(children: [
                              Icon(Icons.calendar_month_rounded, size: 14, color: ZussGoTheme.textMuted),
                              const SizedBox(width: 6),
                              Text('${_formatDate(traveler['startDate'])} — ${_formatDate(traveler['endDate'])}', style: TextStyle(fontSize: 12, color: ZussGoTheme.textSecondary)),
                              const Spacer(),
                              if (traveler['budget'] != null)
                                Text(traveler['budget'], style: TextStyle(fontSize: 11, color: ZussGoTheme.textMuted, fontWeight: FontWeight.w500)),
                            ]),
                          ),
                          const SizedBox(height: 12),

                          // Score breakdown
                          Row(children: [
                            _ScorePill(label: 'Dates', value: (breakdown['dateOverlap'] ?? 0).toDouble(), max: 40, color: color),
                            const SizedBox(width: 4),
                            _ScorePill(label: 'Style', value: (breakdown['travelStyle'] ?? 0).toDouble(), max: 20, color: color),
                            const SizedBox(width: 4),
                            _ScorePill(label: 'Budget', value: (breakdown['budgetMatch'] ?? 0).toDouble(), max: 15, color: color),
                            const SizedBox(width: 4),
                            _ScorePill(label: 'Age', value: (breakdown['ageProximity'] ?? 0).toDouble(), max: 10, color: color),
                          ]),
                          const SizedBox(height: 14),

                          // Action
                          if (alreadyRequested)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: ZussGoTheme.mint.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: ZussGoTheme.mint.withValues(alpha: 0.12)),
                              ),
                              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Icon(Icons.check_circle_rounded, color: ZussGoTheme.mint, size: 16),
                                const SizedBox(width: 6),
                                Text('Request Sent', style: TextStyle(color: ZussGoTheme.mint, fontWeight: FontWeight.w600, fontSize: 13)),
                              ]),
                            )
                          else
                            GestureDetector(
                              onTap: () => context.push('/traveler/${traveler['userId']}', extra: {'tripId': traveler['tripId']}),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(gradient: ZussGoTheme.gradientPrimary, borderRadius: BorderRadius.circular(14)),
                                child: Text("Let's Go Together 🤝", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                              ),
                            ),
                        ]),
                      ),
                    ]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  final String label;
  final double value;
  final double max;
  final Color color;

  const _ScorePill({required this.label, required this.value, required this.max, required this.color});

  @override
  Widget build(BuildContext context) {
    final percent = (value / max).clamp(0.0, 1.0);
    return Expanded(
      child: Column(children: [
        Text(label, style: TextStyle(fontSize: 9, color: ZussGoTheme.textMuted, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 4,
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: ZussGoTheme.bgPrimary,
              valueColor: AlwaysStoppedAnimation<Color>(color.withValues(alpha: 0.6)),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text('${value.round()}/${max.round()}', style: TextStyle(fontSize: 9, color: ZussGoTheme.textMuted)),
      ]),
    );
  }
}