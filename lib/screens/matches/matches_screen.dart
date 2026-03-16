import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../widgets/bottom_nav.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  List<Map<String, dynamic>> _pendingRequests = [];
  List<Map<String, dynamic>> _sentRequests = [];
  List<Map<String, dynamic>> _matches = [];
  bool _isLoading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final user = await AuthService.getSavedUser();
    _userId = user?['userId'];
    if (_userId == null) { setState(() => _isLoading = false); return; }

    final results = await Future.wait([
      ApiService.getPendingRequests(_userId!),
      ApiService.getSentRequests(_userId!),
      ApiService.getMatches(_userId!),
    ]);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (results[0]["success"] == true) _pendingRequests = List<Map<String, dynamic>>.from(results[0]["data"] ?? []);
        if (results[1]["success"] == true) _sentRequests = List<Map<String, dynamic>>.from(results[1]["data"] ?? []);
        if (results[2]["success"] == true) _matches = List<Map<String, dynamic>>.from(results[2]["data"] ?? []);
      });
    }
  }

  Future<void> _acceptRequest(String requestId) async {
    final result = await ApiService.acceptMatchRequest(requestId, _userId!);
    if (result["success"] == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Match accepted! You can now chat 🎉'), backgroundColor: ZussGoTheme.mint.withValues(alpha: 0.8)),
      );
    }
    _loadAll();
  }

  Future<void> _rejectRequest(String requestId) async {
    await ApiService.rejectMatchRequest(requestId, _userId!);
    _loadAll();
  }

  Color _userColor(int index) {
    final colors = [ZussGoTheme.rose, ZussGoTheme.sky, ZussGoTheme.sage, ZussGoTheme.lavender, ZussGoTheme.amber];
    return colors[index % colors.length];
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
                  // Header with chat button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Connections', style: ZussGoTheme.displayMedium),
                      GestureDetector(
                        onTap: () => context.push('/chats'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: ZussGoTheme.gradientPrimary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            Text('Chats', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                          ]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (_isLoading)
                    Padding(padding: const EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: ZussGoTheme.amber.withValues(alpha: 0.5)))),

                  // Empty state
                  if (!_isLoading && _pendingRequests.isEmpty && _sentRequests.isEmpty && _matches.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(color: ZussGoTheme.bgSecondary, borderRadius: BorderRadius.circular(20), border: Border.all(color: ZussGoTheme.borderDefault)),
                      child: Column(children: [
                        const Text('🤝', style: TextStyle(fontSize: 40)),
                        const SizedBox(height: 12),
                        Text('No connections yet', style: ZussGoTheme.displaySmall),
                        const SizedBox(height: 8),
                        Text('Plan a trip and send match requests to travelers heading your way!', style: ZussGoTheme.bodySmall, textAlign: TextAlign.center),
                      ]),
                    ),

                  // Pending requests
                  if (!_isLoading && _pendingRequests.isNotEmpty) ...[
                    Text('REQUESTS FOR YOU', style: TextStyle(fontSize: 11, color: ZussGoTheme.amber, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
                    const SizedBox(height: 10),
                    ...List.generate(_pendingRequests.length, (i) {
                      final req = _pendingRequests[i];
                      final sender = req['sender'] ?? {};
                      final trip = req['trip'] ?? {};
                      final dest = trip['destination'] ?? {};
                      final color = _userColor(i);
                      return Container(
                        padding: const EdgeInsets.all(14),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: ZussGoTheme.glassCard,
                        child: Column(children: [
                          Row(children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withValues(alpha: 0.15))),
                              alignment: Alignment.center,
                              child: Text((sender['fullName'] ?? 'U')[0], style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(sender['fullName'] ?? 'Unknown', style: ZussGoTheme.labelBold),
                              Text('${dest['emoji'] ?? ''} ${dest['name'] ?? ''} • ${sender['travelStyle'] ?? ''}', style: ZussGoTheme.bodySmall),
                            ])),
                          ]),
                          if (req['message'] != null) ...[
                            const SizedBox(height: 8),
                            Text('"${req['message']}"', style: ZussGoTheme.bodySmall.copyWith(fontStyle: FontStyle.italic, color: ZussGoTheme.textSecondary)),
                          ],
                          const SizedBox(height: 12),
                          Row(children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _rejectRequest(req['id']),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: ZussGoTheme.borderDefault)),
                                  alignment: Alignment.center,
                                  child: Text('Pass', style: ZussGoTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: GestureDetector(
                                onTap: () => _acceptRequest(req['id']),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(gradient: ZussGoTheme.gradientPrimary, borderRadius: BorderRadius.circular(12)),
                                  alignment: Alignment.center,
                                  child: Text("Let's Go! 🤝", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                                ),
                              ),
                            ),
                          ]),
                        ]),
                      );
                    }),
                    const SizedBox(height: 20),
                  ],

                  // Sent requests
                  if (!_isLoading && _sentRequests.isNotEmpty) ...[
                    Text('SENT', style: TextStyle(fontSize: 11, color: ZussGoTheme.textMuted, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
                    const SizedBox(height: 10),
                    ...List.generate(_sentRequests.length, (i) {
                      final req = _sentRequests[i];
                      final receiver = req['receiver'] ?? {};
                      final trip = req['trip'] ?? {};
                      final dest = trip['destination'] ?? {};
                      final status = req['status'] ?? 'PENDING';
                      final statusColor = status == 'ACCEPTED' ? ZussGoTheme.mint : status == 'REJECTED' ? ZussGoTheme.rose : ZussGoTheme.amber;
                      return Container(
                        padding: const EdgeInsets.all(14),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: ZussGoTheme.glassCard,
                        child: Row(children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(color: ZussGoTheme.bgCard, borderRadius: BorderRadius.circular(12)),
                            alignment: Alignment.center,
                            child: Text((receiver['fullName'] ?? 'U')[0], style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ZussGoTheme.textSecondary)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(receiver['fullName'] ?? 'Unknown', style: ZussGoTheme.labelBold),
                            Text('${dest['emoji'] ?? ''} ${dest['name'] ?? ''}', style: ZussGoTheme.bodySmall),
                          ])),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                            child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor)),
                          ),
                        ]),
                      );
                    }),
                    const SizedBox(height: 20),
                  ],

                  // Confirmed matches
                  if (!_isLoading && _matches.isNotEmpty) ...[
                    Text('MATCHED', style: TextStyle(fontSize: 11, color: ZussGoTheme.mint, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
                    const SizedBox(height: 10),
                    ...List.generate(_matches.length, (i) {
                      final match = _matches[i];
                      final other = match['otherUser'] ?? {};
                      final trip = match['trip'] ?? {};
                      final dest = trip['destination'] ?? {};
                      final convo = match['conversation'];
                      final color = _userColor(i);
                      return GestureDetector(
                        onTap: () {
                          if (convo != null && convo['id'] != null) {
                            context.push('/chat/${convo['id']}');
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: ZussGoTheme.glassCard,
                          child: Row(children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withValues(alpha: 0.15))),
                              alignment: Alignment.center,
                              child: Text((other['fullName'] ?? 'U')[0], style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(other['fullName'] ?? 'Unknown', style: ZussGoTheme.labelBold),
                              Text('${dest['emoji'] ?? ''} ${dest['name'] ?? ''}', style: ZussGoTheme.bodySmall),
                              if (convo?['lastMessage'] != null)
                                Text(convo['lastMessage'], style: ZussGoTheme.bodySmall.copyWith(color: ZussGoTheme.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ])),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: ZussGoTheme.mint.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                              child: Text('Chat →', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: ZussGoTheme.mint)),
                            ),
                          ]),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),

          const Positioned(bottom: 0, left: 0, right: 0, child: ZussGoBottomNav(currentIndex: 2)),
        ],
      ),
    );
  }
}